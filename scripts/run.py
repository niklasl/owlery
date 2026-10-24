#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["pyoxigraph >= 0.5.13, < 2.0"]
# ///
import argparse
import sys
from pathlib import Path
from typing import Iterable

from pyoxigraph import Quad, QueryResultsFormat, RdfFormat, Store, parse

REPO_ROOT = Path(__file__).resolve().parent.parent

MAX_ITERS = 24


def run_updates(
    store: Store, updates: list[str], verbose: bool = False, max_iters: int = MAX_ITERS
) -> None:
    if verbose:
        print(f"Initial size: {len(store)}", file=sys.stderr)

    for i in range(max_iters):
        c = len(store)

        for update in updates:
            store.update(update)

        if verbose:
            print(f"Iteration {i + 1}; size: {len(store)}", file=sys.stderr)

        if len(store) == c:
            break


def main() -> None:
    argp = argparse.ArgumentParser()
    argp.add_argument('-B', '--basic', action='store_true', default=False)
    argp.add_argument('-L', '--compound-literal', action='store_true', default=False)
    argp.add_argument('-C', '--cleanup', action='store_true', default=False)
    argp.add_argument('-T', '--drop-blank-types', action='store_true', default=False)
    argp.add_argument(
        '-a', '--all', action='store_true', default=False,
        help='Apply all extensions and cleanup (same as -B -L -C -T)'
    )
    argp.add_argument('-M', '--max-iters', type=int, default=MAX_ITERS)
    argp.add_argument('-V', '--verbose', action='store_true', default=False)
    argp.add_argument('--c14n', help='Canonicalize bnodes in results', action='store_true')
    argp.add_argument('sources', metavar='SOURCE', nargs='*')

    args = argp.parse_args()

    if args.all:
        args.basic = True
        args.compound_literal = True
        args.cleanup = True
        args.drop_blank_types = True

    # OWL rules:
    owlery = (REPO_ROOT / 'owl.ru').read_text()
    # Generalize (term interpretation may introduce new nodes):
    genery = (REPO_ROOT / 'generalize.ru').read_text()

    updates = [owlery, genery]
    cleanups = []

    if args.cleanup:
        cleanupery = (REPO_ROOT / 'cleanup.ru').read_text()
        cleanups.append(cleanupery)

    if args.basic:
        updates.append((REPO_ROOT / 'proposition-basicform.ru').read_text())
        if args.cleanup:
            cleanups.append((REPO_ROOT / 'cleanup-proposition-basicform.ru').read_text())

    if args.compound_literal:
        updates.append((REPO_ROOT / 'langdir-compoundliteral.ru').read_text())

    if args.drop_blank_types:
        cleanups.append((REPO_ROOT / 'cleanup-blank-types.ru').read_text())

    pwd_iri = Path('').absolute().as_uri() + '/'

    prefixes = {}
    base_iri = pwd_iri
    store = Store()

    final_queries = []

    for fpath in args.sources:
        if fpath.endswith('.rq'):
            final_queries.append(Path(fpath).read_text())
            continue
        elif fpath.endswith('.ru'):
            updates.append(Path(fpath).read_text())
            continue

        data: Iterable[Quad]
        if fpath == '-':
            reader = parse(sys.stdin.buffer, format=RdfFormat.TRIG)
            data = reader
        else:
            file_iri = Path(fpath).absolute().as_uri()
            reader = parse(path=fpath, base_iri=file_iri)
            data = reader

        store.bulk_extend(data)
        prefixes.update(reader.prefixes)
        if reader.base_iri:
            base_iri = reader.base_iri

    run_updates(store, updates, args.verbose, args.max_iters)

    for cleanup in cleanups:
        store.update(cleanup)

    if cleanups and args.verbose:
        print(f"Post-cleanup size: {len(store)}", file=sys.stderr)

    if args.c14n:
        from pyoxigraph import Dataset, CanonicalizationAlgorithm
        dataset = Dataset(store)
        dataset.canonicalize(CanonicalizationAlgorithm.RDFC_1_0)
        store = Store()
        store.extend(dataset)

    if final_queries:
        for query in final_queries:
            results = store.query(query, base_iri=pwd_iri, use_default_graph_as_union=True)
            print(results.serialize(format=QueryResultsFormat.TSV).decode())  # type: ignore

        return

    try:
        from gnarly.trig import TrigSerializer, get_options  # type: ignore[import-not-found]
        TrigSerializer(
            sys.stdout, prefixes, base_iri, options=None
        ).serialize(store)
    except ImportError:
        store.dump(
            sys.stdout.buffer, RdfFormat.TRIG, prefixes=prefixes, base_iri=base_iri
        )


if __name__ == '__main__':
    main()
