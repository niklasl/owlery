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
  {
    select ?b ?bprops (group_concat(?brel; separator="|") as ?brels) {
      optional {
        ?x ?xp ?b .
        bind(concat(coalesce(str(?x), '?'), ' ', str(?xp)) as ?brel)
      }

      {
        select ?b (group_concat(?bprop; separator="|") as ?bprops) {
          ?b ?bp ?y .

          filter(
            isBlank(?b)
            # Don't skolemize list nodes:
            && not exists { ?b rdf:first [] }
          )

          bind(concat(str(?bp), ' ', coalesce(str(?y), '?')) as ?bprop)
        } group by ?b
      }
    } group by ?b ?bprops
  }

  bind(concat(coalesce(?brels, ''), '::', ?bprops) as ?bshape)
  bind(IRI(concat('http://example.org/.well-known/genid/', SHA256(?bshape))) as ?bskolem)
};

##
# Add IRI stand-ins for literal values.
insert {
  ?shaurn a rdfs:Literal, ?dt ;
    owl:sameAs ?o .
} where {
  ?s ?p ?o .
  filter(isLiteral(?o))
  bind(datatype(?o) as ?dt)
  bind(IRI(concat('urn:sha:', SHA256(concat(str(?o), '^^', str(?dt))))) as ?shaurn)
}
