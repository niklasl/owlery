# Owlery

An [OWL 2](https://www.w3.org/TR/owl2-overview/) implementation in [SPARQL 1.1](https://www.w3.org/TR/sparql11-update/).

## Notes

This is made for fun and learning purposes. It is not how one should implement OWL.

Limitations:
* Requires *repeated* runs to manifest all possible entailments.
* No negative rules are implemented.
* Rules involving lists are currently capped at a few (~7) member items.

## Implementation

### OWL 2 Rule Logic

The `owl.ru` update query inserts triples entailed by pattern matching. It implements (most of) the [OWL RL rules](https://www.w3.org/TR/owl2-profiles/#Reasoning_in_OWL_2_RL_and_RDF_Graphs_using_Rules), and additionally supports `owl:hasSelf` (for rolification).

### Running

You need an RDF graph implementation with SPARQL support. Then:

* Create a *generalized* graph `g` and read RDF data into it.
* Repeat loop:
  - Let `c` be triple count of `g`.
  - Insert generalized triples by applying the `owl.ru` update query to `g`.
  - If triple count of `g` is still `c`:
    - Break loop.
* Serialize `g` as a regular RDF graph.

## Extensions

### Generalized RDF

An update query, `generalize.ru`, is also defined for "generalizing" RDF. This makes non-serializable entailments possible to work with, such as blank node predicates or literal subjects. It inserts `owl:sameAs` relations, mapping IRIs to blank nodes, and blank nodes to literals. For triple terms, see the following section.

### RDF 1.2 Triple Terms

Another update query, `classicize.ru`, maps triple terms via `rdf:reifies` to blank node `rdf:Statement` "companion tokens".

### Time Value Expansion

The additional `time.ru` update query (currently) expands `xsd:date`, `xsd:dateTime` and `xsd:dateTimeStamp` literals into (`owl:sameAs`) value nodes with up to seven constituent time properties (`time:year`, `time:month`, `time:day`, `time:hour`, `time:minute`, `time:second`, `time:timeZone`) from the [Time Ontology](https://www.w3.org/TR/owl-time/).

## Example Usage

A simple Python script (using [pyoxigraph](https://pyoxigraph.readthedocs.io/)) following the above steps is provided.

To see resulting entailments, pass it some RDF data:

    $ uv run test/run.py test/data/rolification.ttl

It can optionally apply a query for verifying the results instead:

    $ uv run test/run.py test/data/rolification.ttl test/data/verify-rolification.rq

The script also applies the above mentioned `generalize.ru` update query; thus working with more complex requirements, such as entailed blank properties:

    $ uv run test/run.py test/data/metarolification.ttl test/data/verify-rolification.rq

Additionally passed update query files will also be applied.

Handling entailment rules based on triple terms:

    $ uv run test/run.py classicize.ru test/data/purchase.ttl test/data/verify-purchase.rq

To test the time expansion (see above):

    $ uv run test/run.py time.ru test/data/time.ttl test/data/verify-time.rq

Full test of all examples:

    $ uv run test/run.py classicize.ru time.ru test/data/*.ttl test/data/verify-*.rq

## Applying Manually

For testing and introspection, using a plain SPARQL CLI and applying the steps manually is enough.

Using [OxRQ](https://github.com/niklasl/oxrq) (two passes are needed for this particular test):

    $ cat test/data/rolification.ttl |
      oxrq -f generalize.ru |
      oxrq -f owl.ru |
      oxrq -f owl.ru |
      oxrq -f test/data/verify-rolification.rq

Variant using the [Jena CLI tools](https://jena.apache.org/documentation/tools/index.html):

    $ update --update generalize.ru --data test/data/rolification.ttl --dump > /tmp/jena-scratch-1.ttl
    $ update --update owl.ru --data /tmp/jena-scratch-1.ttl --dump > /tmp/jena-scratch-2.ttl
    $ update --update owl.ru --data /tmp/jena-scratch-2.ttl --dump > /tmp/jena-scratch-3.ttl
    $ arq --file test/data/verify-rolification.rq --data /tmp/jena-scratch-3.ttl

