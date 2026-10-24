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

argp = argparse.ArgumentParser()
argp.add_argument('-B', '--basic', action='store_true', default=False)
argp.add_argument('-L', '--compound-literal', action='store_true', default=False)
argp.add_argument('-C', '--cleanup', action='store_true', default=False)
argp.add_argument('-T', '--drop-blank-types', action='store_true', default=False)
argp.add_argument('-M', '--max-iters', type=int, default=MAX_ITERS)
argp.add_argument('-V', '--verbose', action='store_true', default=False)
argp.add_argument('--c14n', help='Canonicalize bnodes in results', action='store_true')
argp.add_argument('sources', metavar='SOURCE', nargs='*')
args = argp.parse_args()

owlery = (REPO_ROOT / 'owl.ru').read_text()
genery = (REPO_ROOT / 'generalize.ru').read_text()

extra_updates = []
cleanups = []

prefixes = {}

store = Store()

if args.cleanup:
    cleanupery = (REPO_ROOT / 'cleanup.ru').read_text()
    cleanups.append(cleanupery)

if args.basic:
    extra_updates.append((REPO_ROOT / 'proposition-basicform.ru').read_text())
    if args.cleanup:
        cleanups.append((REPO_ROOT / 'cleanup-proposition-basicform.ru').read_text())

if args.compound_literal:
    extra_updates.append((REPO_ROOT / 'langdir-compoundliteral.ru').read_text())

if args.drop_blank_types:
    cleanups.append((REPO_ROOT / 'cleanup-blank-types.ru').read_text())

pwd_iri = Path('').absolute().as_uri() + '/'

extra_queries = []

for fpath in args.sources:
    if fpath.endswith('.rq'):
        extra_queries.append(Path(fpath).read_text())
        continue
    elif fpath.endswith('.ru'):
        extra_updates.append(Path(fpath).read_text())
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

if args.verbose:
    print(f"Initial size: {len(store)}", file=sys.stderr)

for i in range(args.max_iters):
    c = len(store)

    store.update(owlery)
    # Term interpretation may introduce new nodes:
    store.update(genery)

    for update in extra_updates:
        store.update(update)

    if args.verbose:
        print(f"Iteration {i + 1}; size: {len(store)}", file=sys.stderr)

    if len(store) == c:
        break

for cleanup in cleanups:
    store.update(cleanup)

if args.c14n:
    from pyoxigraph import Dataset, CanonicalizationAlgorithm
    dataset = Dataset(store)
    dataset.canonicalize(CanonicalizationAlgorithm.RDFC_1_0)
    store = Store()
    store.extend(dataset)

if extra_queries:
    for query in extra_queries:
        results = store.query(query, base_iri=pwd_iri, use_default_graph_as_union=True)
        print(results.serialize(format=QueryResultsFormat.TSV).decode())  # type: ignore
else:
    try:
        from gnarly.trig import TrigSerializer, get_options  # type: ignore[import-not-found]
        TrigSerializer(
            sys.stdout, prefixes, pwd_iri, options=None
        ).serialize(store)
    except ImportError:
       store.dump(sys.stdout.buffer, RdfFormat.TRIG, prefixes=prefixes, base_iri=pwd_iri)
