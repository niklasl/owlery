prefix owl: <http://www.w3.org/2002/07/owl#>

delete { ?s ?p ?o } where {
  ?s ?p ?o .
  filter( contains(str(?s), "/.well-known/genid/")
       || contains(str(?p), "/.well-known/genid/")
       || contains(str(?o), "/.well-known/genid/") )
};
delete { ?s owl:sameAs ?s } where { ?s owl:sameAs ?s };
delete { ?s a ?o } where { ?s a ?o . filter(isBlank(?o)) }
