prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

##
# Drop trivial entailments
delete { ?s owl:sameAs ?s } where { ?s owl:sameAs ?s };
delete { ?s owl:equivalentProperty ?s } where { ?s owl:equivalentProperty ?s };
delete { ?s rdfs:subPropertyOf ?s } where { ?s rdfs:subPropertyOf ?s };
delete { ?s owl:equivalentClass ?s } where { ?s owl:equivalentClass ?s };
delete { ?s rdfs:subClassOf ?s } where { ?s rdfs:subClassOf ?s };

##
# Drop skolemized bnodes
delete { ?s ?p ?o } where {
  ?s ?p ?o .
  filter( contains(str(?s), "/.well-known/genid/")
          || contains(str(?p), "/.well-known/genid/")
          || contains(str(?o), "/.well-known/genid/") )
}
