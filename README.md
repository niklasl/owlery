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

### Generalized RDF

An update query, `generalize.ru`, is also defined for "generalizing" RDF. This makes non-serializable entailments possible to work with, such as blank node predicates or literal subjects. It inserts `owl:sameAs` relations, mapping IRIs to blank nodes, and blank nodes to literals. For triple terms, see the following section.

### RDF 1.2 Triple Terms

Another update query, `classicize.ru`, maps triple terms via `rdf:reifies` to blank node `rdf:Statement` "companion tokens".

## Run

You need an RDF graph implementation with SPARQL support. Then:

* Create a *generalized* graph `g` and read RDF data into it.
* Repeat loop:
  - Let `c` be size of `g`.
  - Insert generalized triples by applying the `owl.ru` update query to `g`.
  - If new size of `g` is still `c`:
    - Break loop.
* Serialize `g` as a regular RDF graph.

## Example Usage

A simple Python version of the above:

    $ python test/owlery.py test/rolification.ttl
