##
# "Generalize" RDF by adding owl:sameAs aliases.
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

##
# "Skolemize" bnodes; in case they are entailed to be properties.
insert {
  ?b owl:sameAs ?bskolem
} where {
  { select distinct ?b {
    { ?x ?xp ?b } union { ?b ?bp ?y }
  } }
  filter(
    isBlank(?b)
    && not exists { ?b owl:sameAs ?alias . filter isIRI(?alias) }
    #&& not exists { ?b owl:onProperty [] }
  )
  bind(IRI(concat('http://example.org/.well-known/genid/', STRUUID())) as ?bskolem)
};


##
# Add IRI stand-ins for literal values.
insert {
  ?s ?p ?shaurn .
  ?shaurn a rdfs:Literal, ?dt ;
    owl:sameAs ?o .
} where {
  ?s ?p ?o .
  filter(isLiteral(?o))
  bind(datatype(?o) as ?dt)
  bind(concat(str(?o), '^^', str(?dt), '@', lang(?o)) as ?ltrepr)  # TODO: , '--', langdir(?o)
  #bind(IRI(concat('urn:tdb:2025:urn:sha:', SHA256(?ltrepr))) as ?shaurn)
  bind(IRI(concat('http://example.org/.well-known/genid/', SHA256(?ltrepr))) as ?shaurn)
}
