##
# Interpret RDF triple terms as basic proposition forms
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

insert {
  ?s ?p ?ttnode .
  ?ttnode a rdf:PropositionForm ;
    owl:sameAs ?tt ;
    rdf:propositionFormSubject ?tts ;
    rdf:propositionFormPredicate ?ttp ;
    rdf:propositionFormObject ?tto .
} where {
  ?s ?p ?tt .
  filter(isTriple(?tt))

  bind(subject(?tt) as ?tts)
  bind(predicate(?tt) as ?ttp)
  bind(object(?tt) as ?tto)
  optional {
    ?given_ttnode a rdf:PropositionForm ;
      owl:sameAs ?tt ;
      rdf:propositionFormSubject ?tts ;
      rdf:propositionFormPredicate ?ttp ;
      rdf:propositionFormObject ?tto .
  }
  bind(coalesce(?given_ttnode, bnode()) as ?ttnode)
}
