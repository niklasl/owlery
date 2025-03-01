##
# "Classicize" RDF triple terms
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

insert {
  ?ttnode a rdf:Statement ;
    rdf:subject ?tts ;
    rdf:predicate ?ttp ;
    rdf:object ?tto ;
    rdf:reifies ?tt .
} where {
  ?s ?p ?tt .
  filter(isTriple(?tt))

  bind(subject(?tt) as ?tts)
  bind(predicate(?tt) as ?ttp)
  bind(object(?tt) as ?tto)
  optional {
    ?given_ttnode a rdf:Statement ;
      rdf:reifies ?tt ;
      rdf:subject ?tts ;
      rdf:predicate ?ttp ;
      rdf:object ?tto .
  }
  bind(coalesce(?given_ttnode, bnode()) as ?ttnode)
}
