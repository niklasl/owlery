# /// script
# dependencies = ["pyoxigraph >= 0.4.8, < 2.0"]
# ///
import sys
from pathlib import Path

from pyoxigraph import QueryResultsFormat, RdfFormat, Store, parse

REPO_ROOT = Path(__file__).parent.parent

MAX_ITERS = 24

owlery = (REPO_ROOT / 'owl.ru').read_text()
genery = (REPO_ROOT / 'generalize.ru').read_text()

extra_updates = []
extra_queries = []

store = Store()

prefixes = {}

for fpath in sys.argv[1:]:
    if fpath.endswith('.rq'):
        extra_queries.append(Path(fpath).read_text())
        continue
    elif fpath.endswith('.ru'):
        extra_updates.append(Path(fpath).read_text())
        continue

    data = (
        parse(sys.stdin.buffer, format=RdfFormat.TRIG)
        if fpath == '-'
        else parse(path=fpath)
    )
    store.bulk_extend(data)
    prefixes.update(data.prefixes)

store.update(genery)

for update in extra_updates:
    store.update(update)

for i in range(MAX_ITERS):
    c = len(store)
    store.update(owlery)
    if len(store) == c:
        break

if extra_queries:
    for query in extra_queries:
        results = store.query(query, use_default_graph_as_union=True)
        print(results.serialize(format=QueryResultsFormat.TSV).decode())  # type: ignore
else:
    store.dump(sys.stdout.buffer, RdfFormat.TRIG, prefixes=prefixes)
