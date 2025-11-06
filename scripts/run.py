#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["pyoxigraph >= 0.5.0, < 2.0"]
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
argp.add_argument('-C', '--cleanup', action='store_true', default=False)
argp.add_argument('-M', '--max-iters', type=int, default=MAX_ITERS)
argp.add_argument('-V', '--verbose', action='store_true', default=False)
argp.add_argument('sources', metavar='SOURCE', nargs='*')
args = argp.parse_args()

owlery = (REPO_ROOT / 'owl.ru').read_text()
genery = (REPO_ROOT / 'generalize.ru').read_text()

extra_updates = []

prefixes = {}

store = Store()

if args.basic:
    extra_updates.append((REPO_ROOT / 'proposition-basicform.ru').read_text())

cleanupery = (REPO_ROOT / 'cleanup.ru').read_text() if args.cleanup else None

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

for i in range(args.max_iters):
    c = len(store)

    if args.verbose:
        print(f"Iteration {i}; size: {c}", file=sys.stderr)

    store.update(owlery)

    for update in extra_updates:
        store.update(update)

    # First update may introduce new bnodes:
    if i == 0:
        store.update(genery)

    if len(store) == c:
        break

if cleanupery:
    store.update(cleanupery)

if extra_queries:
    for query in extra_queries:
        results = store.query(query, base_iri=pwd_iri, use_default_graph_as_union=True)
        print(results.serialize(format=QueryResultsFormat.TSV).decode())  # type: ignore
else:
    store.dump(sys.stdout.buffer, RdfFormat.TRIG, prefixes=prefixes, base_iri=pwd_iri)
