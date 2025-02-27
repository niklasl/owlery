# Owlery

An [OWL 2](https://www.w3.org/TR/owl2-overview/) implementation in [SPARQL 1.1](https://www.w3.org/TR/sparql11-update/).

## Notes

This is made for fun and learning purposes. It is not how one should implement OWL.

Limitations:
* Requires *repeated* runs to manifest all possible entailments.
* No negative rules are implemented.
* Rules involving lists are currently capped at a few (~7) member items.

## Run

You need an RDF graph implementation with SPARQL support. Then:

* Create a *generalized* graph `g` and read RDF data into it.
* Repeat loop:
  - Let `c` be size of `g`.
  - Insert generalized triples by applying the `owl.ru` update query to `g`.
  - If new size of `g` is still `c`:
    - Break loop.
* Serialize `g` as a regular RDF graph.

## Example

A simple Python version of the above:

    $ python test/owlery.py test/rolification.ttl
