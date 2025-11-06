##
# Interpret RDF triple terms as basic triple forms
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

insert {
  ?s ?p ?ttnode .
  ?ttnode a rdf:TripleForm ;
    owl:sameAs ?tt ;
    rdf:tripleSubject ?tts ;
    rdf:triplePredicate ?ttp ;
    rdf:tripleObject ?tto .
} where {
  ?s ?p ?tt .
  filter(isTriple(?tt))

  bind(subject(?tt) as ?tts)
  bind(predicate(?tt) as ?ttp)
  bind(object(?tt) as ?tto)
  optional {
    ?given_ttnode a rdf:TripleForm ;
      owl:sameAs ?tt ;
      rdf:tripleSubject ?tts ;
      rdf:triplePredicate ?ttp ;
      rdf:tripleObject ?tto .
  }
  bind(coalesce(?given_ttnode, bnode()) as ?ttnode)
}
