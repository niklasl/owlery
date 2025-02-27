# /// script
# dependencies = ["rdflib >= 7.0, < 7.1"]
# ///
import sys
from pathlib import Path

from rdflib import ConjunctiveGraph

owlery = (Path(__file__).parent.parent / 'owl.ru').read_text()

ds = ConjunctiveGraph()

for fpath in sys.argv[1:]:
    ds.parse(fpath)

for i in range(7):
    c = len(ds)
    ds.update(owlery)
    if len(ds) == c:
        break

ds.serialize(sys.stdout.buffer, format="application/trig")
