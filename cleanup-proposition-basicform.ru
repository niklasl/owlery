##
# Drop RDF basic proposition forms of triple terms
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

delete {
  ?s ?p ?ttnode .
  ?ttnode a rdf:PropositionForm ;
    owl:sameAs ?tt ;
    rdf:propositionFormSubject ?tts ;
    rdf:propositionFormPredicate ?ttp ;
    rdf:propositionFormObject ?tto .
} where {
  ?s ?p ?ttnode .
  ?ttnode a rdf:PropositionForm ;
    owl:sameAs ?tt .
  filter(isBlank(?ttnode))
  filter(isTriple(?tt))
  bind(subject(?tt) as ?tts)
  bind(predicate(?tt) as ?ttp)
  bind(object(?tt) as ?tto)
  ?ttnode
    rdf:propositionFormSubject ?tts ;
    rdf:propositionFormPredicate ?ttp ;
    rdf:propositionFormObject ?tto .
  filter not exists {
    ?s2 ?p2 ?ttnode .
    filter not exists {
      ?s2 ?p2 ?tt .
    }
  }
}
