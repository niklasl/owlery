##
# "Generalize" RDF by adding owl:sameAs aliases.
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

##
# "Skolemize" bnodes used in property axioms, so they can be used as predicates.
insert {
  ?b owl:sameAs ?bskolem
} where {
  { select distinct ?b {
    { ?x ?xp ?b } union { ?b ?bp ?y }
  } }
  filter(
    isBlank(?b)
    # unless already skolemized:
    && not exists { ?b owl:sameAs ?alias . filter isIRI(?alias) }
    # and is used in some property axiom:
    && exists {
      [] rdfs:subPropertyOf|^rdfs:subPropertyOf
         |owl:equivalentProperty
         |owl:onProperty
         |owl:inverseOf|^owl:inverseOf
         |^owl:propertyChainAxiom ?b
    }
  )
  bind(IRI(concat('http://example.org/.well-known/genid/', STRUUID())) as ?bskolem)
};


##
# Add IRI stand-ins for literal values.
insert {
  ?s ?p ?litnode .
  ?litnode a rdfs:Literal, ?dt ;
    owl:sameAs ?o .
} where {
  ?s ?p ?o .
  filter(isLiteral(?o))
  optional {
    ?existing_litnode owl:sameAs ?o .
    filter(isIRI(?existing_litnode) &&
           contains(str(?existing_litnode), "/.well-known/genid/"))
  }
  BIND(COALESCE(?existing_litnode,
                IRI(concat('http://example.org/.well-known/genid/',
                           SHA256(concat(str(?o), '^^', str(datatype(?o)),
                                         '@', lang(?o),
                                         '--', langdir(?o))))))
       as ?litnode)
}
