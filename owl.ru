##
# Owlery - An OWL 2 Implementation in SPARQL.
# (See <https://www.w3.org/TR/owl2-profiles/#Reasoning_in_OWL_2_RL_and_RDF_Graphs_using_Rules>.)

prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>

##
# OWL RL Rules

##
# The Semantics of Equality (Table 4)

# eq-ref
insert {
  ?s owl:sameAs ?s .
  ?p owl:sameAs ?p .
  ?o owl:sameAs ?o .
} where {
  ?s ?p ?o .
};

# eq-sym
insert {
  ?x owl:sameAs ?y .
} where {
  ?y owl:sameAs ?x .
};

# eq-trans
insert {
  ?x owl:sameAs ?z .
  ?x owl:sameAs ?y .
} where {
  ?y owl:sameAs ?z .
};

# eq-rep-s
insert {
  ?s2 ?p ?o .
} where {
  ?s owl:sameAs ?s2 .
  ?s ?p ?o .
};

# eq-rep-p
insert {
  ?s ?p2 ?o .
} where {
  ?p owl:sameAs ?p2 .
  ?s ?p ?o .
};

# eq-rep-o
insert {
  ?s ?p ?o2 .
} where {
  ?o owl:sameAs ?o2 .
  ?s ?p ?o .
};

#eq-diff1
#T(?x, owl:sameAs, ?y)
#T(?x, owl:differentFrom, ?y)
#false

#eq-diff2
#T(?x, a, owl:AllDifferent)
#T(?x, owl:members, ?y)
#LIST[?y, ?z1, ..., ?zn]
#T(?zi, owl:sameAs, ?zj)
#false
#for each 1 ≤ i < j ≤ n

#eq-diff3
#T(?x, a, owl:AllDifferent)
#T(?x, owl:distinctMembers, ?y)
#LIST[?y, ?z1, ..., ?zn]
#T(?zi, owl:sameAs, ?zj)
#false
#for each 1 ≤ i < j ≤ n


##
# The Semantics of Axioms about Properties (Table 5)

# prp-ap
#T(ap, a, owl:AnnotationProperty)
#for each built-in annotation property of OWL 2 RL

# prp-dom
insert {
  ?x a ?c .
} where {
  ?p rdfs:domain ?c .
  ?x ?p ?y .
};

# prp-rng
insert {
  ?y a ?c .
} where {
  ?p rdfs:range ?c .
  ?x ?p ?y .
};

# prp-fp
insert {
  ?y1 owl:sameAs ?y2 .
} where {
  ?p a owl:FunctionalProperty .
  ?x ?p ?y1 .
  ?x ?p ?y2 .
};

# prp-ifp
insert {
  ?x1 owl:sameAs ?x2 .
} where {
  ?p a owl:InverseFunctionalProperty .
  ?x1 ?p ?y .
  ?x2 ?p ?y .
};

#prp-irp
#T(?p, a, owl:IrreflexiveProperty)
#T(?x, ?p, ?x)
#false

# prp-symp
insert {
  ?y ?p ?x .
} where {
  ?p a owl:SymmetricProperty .
  ?x ?p ?y .
};

#prp-asyp
#T(?p, a, owl:AsymmetricProperty)
#T(?x, ?p, ?y)
#T(?y, ?p, ?x)
#false

# prp-trp
insert {
  ?x ?p ?z .
} where {
  ?p a owl:TransitiveProperty .
  ?x ?p ?y .
  ?y ?p ?z .
};

# prp-spo1
insert {
  ?x ?p2 ?y .
} where {
  ?p1 rdfs:subPropertyOf ?p2 .
  ?x ?p1 ?y .
};

# prp-spo2
insert {
  ?u1 ?p ?u_last .
} where {
    # ?p owl:propertyChainAxiom ?x .
    #LIST[?x, ?p1, ..., ?pn]

  ?p owl:propertyChainAxiom ?x .
  ?x rdf:first ?p1 .
  ?u1 ?p1 ?u2 .
  {
    ?x rdf:rest (?p2) .
    ?u2 ?p2 ?u_last .
  } union {
    ?x rdf:rest (?p2 ?p3) .
    ?u2 ?p2 ?u3 .
    ?u3 ?p3 ?u_last .
  } union {
    ?x rdf:rest (?p2 ?p3 ?p4) .
    ?u2 ?p2 ?u3 .
    ?u3 ?p3 ?u4 .
    ?u4 ?p4 ?u_last .
  } union {
    ?x rdf:rest (?p2 ?p3 ?p4 ?p5) .
    ?u2 ?p2 ?u3 .
    ?u3 ?p3 ?u4 .
    ?u4 ?p4 ?u5 .
    ?u5 ?p5 ?u_last .
  } union {
    ?x rdf:rest (?p2 ?p3 ?p4 ?p5 ?p6) .
    ?u2 ?p2 ?u3 .
    ?u3 ?p3 ?u4 .
    ?u4 ?p4 ?u5 .
    ?u5 ?p5 ?u6 .
    ?u6 ?p6 ?u_last .
  } union {
    ?x rdf:rest (?p2 ?p3 ?p4 ?p5 ?p6 ?p7) .
    ?u2 ?p2 ?u3 .
    ?u3 ?p3 ?u4 .
    ?u4 ?p4 ?u5 .
    ?u5 ?p5 ?u6 .
    ?u6 ?p6 ?u7 .
    ?u7 ?p7 ?u_last .
  }
  #...
  # ?un ?pn ?un_plus1 .
};

# prp-eqp1
insert {
  ?x ?p2 ?y .
} where {
  ?p1 owl:equivalentProperty ?p2 .
  ?x ?p1 ?y .
};

# prp-eqp2
insert {
  ?x ?p1 ?y .
} where {
  ?p1 owl:equivalentProperty ?p2 .
  ?x ?p2 ?y .
};

# prp-pdw
#T(?p1, owl:propertyDisjointWith, ?p2)
#T(?x, ?p1, ?y)
#T(?x, ?p2, ?y)
#false

#prp-adp
#T(?x, a, owl:AllDisjointProperties)
#T(?x, owl:members, ?y)
#LIST[?y, ?p1, ..., ?pn]
#T(?u, ?pi, ?v)
#T(?u, ?pj, ?v)
#false
#for each 1 ≤ i < j ≤ n

# prp-inv1
insert {
  ?y ?p2 ?x .
} where {
  ?p1 owl:inverseOf ?p2 .
  ?x ?p1 ?y .
};

# prp-inv2
insert {
  ?y ?p1 ?x .
} where {
  ?p1 owl:inverseOf ?p2 .
  ?x ?p2 ?y .
};

# prp-key
insert {
  ?x owl:sameAs ?y .
} where {
  ?c owl:hasKey ?u .
  ?x a ?c ; ?p1 ?z1 .
  ?y a ?c ; ?p1 ?z1 .
  #LIST[?u, ?p1, ..., ?pn]
  ?u rdf:first ?p1 .
  ?x ?p2 ?z2 .
  ?y ?p2 ?z2 .
  {
    ?u rdf:rest (?p2) .
  } union {
    ?x ?p3 ?z3 .
    ?y ?p3 ?z3 .
    {
      ?u rdf:rest (?p2 ?p3) .
    } union {
      ?u rdf:rest (?p2 ?p3 ?p4) .
      ?x ?p4 ?z4 .
      ?y ?p4 ?z4 .
      #...
    }
  }
};

#prp-npa1
#T(?x, owl:sourceIndividual, ?i1)
#T(?x, owl:assertionProperty, ?p)
#T(?x, owl:targetIndividual, ?i2)
#T(?i1, ?p, ?i2)
#false

#prp-npa2
#T(?x, owl:sourceIndividual, ?i)
#T(?x, owl:assertionProperty, ?p)
#T(?x, owl:targetValue, ?lt)
#T(?i, ?p, ?lt)
#false


##
# The Semantics of Classes (Table 6)

# cls-thing
#insert { owl:Thing a owl:Class };

# cls-nothing1
#insert { owl:Nothing a owl:Class };

#cls-nothing2
#?x a owl:Nothing
#false

# cls-int1
insert {
  ?y a ?c .
} where {
  #LIST[?x ?c1 ... ?cn]
  ?c owl:intersectionOf ?x .
  ?x rdf:first ?c1 .
  ?y a ?c1 .

  ?y a ?c2 .
  {
    ?x rdf:rest (?c2) .
  } union {
    ?y a ?c3 .
    {
      ?x rdf:rest (?c2 ?c3) .
    } union {
      ?y a ?c4 .
      ?x rdf:rest (?c2 ?c3 ?c4) .
    }
  }
  #...
  #?y a ?cn .
};

# cls-int2
insert {
  ?y a ?c1, ?c2, ?c3, ?c4, ?c5, ?c6, ?c7  .
  #...
} where {
  ?c owl:intersectionOf ?x .
  ?y a ?c .
  ?x rdf:first ?c1 .
  #LIST[?x ?c1 ... ?cn]
  {
    ?x rdf:rest (?c2) .
  } union {
    ?x rdf:rest (?c2 ?c3) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5 ?c6) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5 ?c6 ?c7) .
  }
};

# cls-uni
insert {
  ?y a ?c .
} where {
  ?c owl:unionOf ?x .
  #LIST[?x ?c1 ... ?cn]
  # for each 1 ≤ i ≤ n
  ?x rdf:first ?c1 .
  ?y a ?c1 .

  ?y a ?c2 .
  {
    ?x rdf:rest (?c2) .
  } union {
    ?y a ?c3 .
    {
      ?x rdf:rest (?c2 ?c3) .
    } union {
      ?y a ?c4 .
      ?x rdf:rest (?c2 ?c3 ?c4) .
    }
  }
};

#cls-com
#T(?c1, owl:complementOf, ?c2)
#T(?x, a, ?c1)
#T(?x, a, ?c2)
#false

# cls-svf1
insert {
  ?u a ?x .
} where {
  ?x owl:onProperty ?p ;
    owl:someValuesFrom ?y .
  ?u ?p ?v .
  ?v a ?y .
};

# cls-svf2
insert {
  ?u a ?x .
} where {
  ?x owl:onProperty ?p ;
    owl:someValuesFrom owl:Thing .
  ?u ?p ?v .
};

# cls-avf
insert {
  ?v a ?y .
} where {
  ?x owl:onProperty ?p ;
    owl:allValuesFrom ?y .
  ?u a ?x ;
    ?p ?v .
};

# cls-hv1
insert {
  ?u ?p ?y .
} where {
  ?x owl:onProperty ?p ;
    owl:hasValue ?y .
  ?u a ?x .
};

# cls-hv2
insert {
  ?u a ?x .
} where {
  ?x owl:onProperty ?p ;
    owl:hasValue ?y .
  ?u ?p ?y .
};

#cls-maxc1
#T(?x, owl:maxCardinality, "0"^^xsd:nonNegativeInteger)
#T(?x, owl:onProperty, ?p)
#T(?u, a, ?x)
#T(?u, ?p, ?y)
#false

# cls-maxc2
insert {
  ?y1 owl:sameAs ?y2 .
} where {
  ?x owl:onProperty ?p .
  {
    ?x owl:maxCardinality "1"^^xsd:nonNegativeInteger
  } union {
    ?x owl:maxCardinality 1
  }
  ?u a ?x ;
    ?p ?y1 , ?y2 .
};

#cls-maxqc1
#T(?x, owl:maxQualifiedCardinality, "0"^^xsd:nonNegativeInteger)
#T(?x, owl:onProperty, ?p)
#T(?x, owl:onClass, ?c)
#T(?u, a, ?x)
#T(?u, ?p, ?y)
#T(?y, a, ?c)
#false

#cls-maxqc2
#T(?x, owl:maxQualifiedCardinality, "0"^^xsd:nonNegativeInteger)
#T(?x, owl:onProperty, ?p)
#T(?x, owl:onClass, owl:Thing)
#T(?u, a, ?x)
#T(?u, ?p, ?y)
#false

# cls-maxqc3
insert {
  ?y1 owl:sameAs ?y2 .
} where {
  ?x owl:onProperty ?p ;
    owl:onClass ?c .
  {
    ?x owl:maxQualifiedCardinality "1"^^xsd:nonNegativeInteger
  } union {
    ?x owl:maxQualifiedCardinality 1
  }
  ?u a ?x ;
    ?p ?y1 .
  ?y1 a ?c .
  ?u ?p ?y2 .
  ?y2 a ?c .
};

# cls-maxqc4
insert {
  ?y1 owl:sameAs ?y2 .
} where {
  ?x owl:onProperty ?p .
  {
    ?x owl:maxQualifiedCardinality "1"^^xsd:nonNegativeInteger
  } union {
    ?x owl:maxQualifiedCardinality 1
  }
  ?x owl:onClass owl:Thing .
  ?u a ?x ;
    ?p ?y1 , ?y2 .
};

#cls-oo
insert {
  ?y1 a ?c .
  ?y2 a ?c .
  ?y3 a ?c .
  ?y4 a ?c .
  ?y5 a ?c .
  ?y6 a ?c .
  ?y7 a ?c .
  #...
} where {
  ?c owl:oneOf ?x .
  ?x rdf:first ?y1 .
  {
    ?x rdf:rest (?y2) .
  } union {
    ?x rdf:rest (?y2 ?y3) .
  } union {
    ?x rdf:rest (?y2 ?y3 ?y4) .
  } union {
    ?x rdf:rest (?y2 ?y3 ?y4 ?y5) .
  } union {
    ?x rdf:rest (?y2 ?y3 ?y4 ?y5 ?y6) .
  } union {
    ?x rdf:rest (?y2 ?y3 ?y4 ?y5 ?y6 ?y7) .
  }
  #LIST[?x, ?y1, ..., ?yn]
};


##
# The Semantics of Class Axioms (Table 7)

#cax-sco
insert {
  ?x a ?c2 .
} where {
  ?c1 rdfs:subClassOf ?c2 .
  ?x a ?c1 .
};

#cax-eqc1
insert {
  ?x a ?c2 .
} where {
  ?c1 owl:equivalentClass ?c2 .
  ?x a ?c1 .
};

#cax-eqc2
insert {
  ?x a ?c1 .
} where {
  ?c1 owl:equivalentClass ?c2 .
  ?x a ?c2 .
};

#cax-dw
#T(?c1, owl:disjointWith, ?c2)
#T(?x, a, ?c1)
#T(?x, a, ?c2)
#false

#cax-adc
#T(?x, a, owl:AllDisjointClasses)
#T(?x, owl:members, ?y)
#LIST[?y, ?c1, ..., ?cn]
#T(?z, a, ?ci)
#T(?z, a, ?cj)
#false

#for each 1 ≤ i < j ≤ n
#insert {
#} where {
#};


##
# The Semantics of Datatypes (Table 8)

#dt-type1
#T(dt, a, rdfs:Datatype)
#for each datatype dt supported in OWL 2 RL

#dt-type2
#T(lt, a, dt)
#for each literal lt and each datatype dt supported in OWL 2 RL
#such that the data value of lt is contained in the value space of dt

#dt-eq
#T(lt1, owl:sameAs, lt2)
#for all literals lt1 and lt2 with the same data value

#dt-diff
#T(lt1, owl:differentFrom, lt2)
#for all literals lt1 and lt2 with different data values

#dt-not-type
#T(lt, a, dt)
#false
#for each literal lt and each datatype dt supported in OWL 2 RL
#such that the data value of lt is not contained in the value space of dt


##
# The Semantics of Schema Vocabulary (Table 9)

#scm-cls
insert {
  ?c rdfs:subClassOf ?c .
  ?c owl:equivalentClass ?c .
  ?c rdfs:subClassOf owl:Thing .
  owl:Nothing rdfs:subClassOf ?c .
} where {
  ?c a owl:Class .
};

#scm-sco
insert {
  ?c1 rdfs:subClassOf ?c3 .
} where {
  ?c1 rdfs:subClassOf ?c2 .
  ?c2 rdfs:subClassOf ?c3 .
};

#scm-eqc1
insert {
  ?c1 owl:equivalentClass ?c2 .
} where {
  ?c1 rdfs:subClassOf ?c2 .
  ?c2 rdfs:subClassOf ?c1 .
};

#scm-eqc2
insert {
  ?c1 owl:equivalentClass ?c2 .
} where {
  ?c1 rdfs:subClassOf ?c2 .
  ?c2 rdfs:subClassOf ?c1 .
};

#scm-op
insert {
  ?p rdfs:subPropertyOf ?p .
  ?p owl:equivalentProperty ?p .
} where {
  ?p a owl:ObjectProperty .
};

#scm-dp
insert {
  ?p rdfs:subPropertyOf ?p .
  ?p owl:equivalentProperty ?p .
} where {
  ?p a owl:DatatypeProperty .
};

#scm-spo
insert {
  ?p1 rdfs:subPropertyOf ?p3 .
} where {
  ?p1 rdfs:subPropertyOf ?p2 .
  ?p2 rdfs:subPropertyOf ?p3 .
};

#scm-eqp1
insert {
  ?p1 rdfs:subPropertyOf ?p2 .
  ?p2 rdfs:subPropertyOf ?p1 .
} where {
  ?p1 owl:equivalentProperty ?p2 .
};

#scm-eqp2
insert {
  ?p1 owl:equivalentProperty ?p2 .
} where {
  ?p1 rdfs:subPropertyOf ?p2 .
  ?p2 rdfs:subPropertyOf ?p1 .
};

#scm-dom1
insert {
  ?p rdfs:domain ?c2 .
} where {
  ?p rdfs:domain ?c1 .
  ?c1 rdfs:subClassOf ?c2 .
};

#scm-dom2
insert {
  ?p1 rdfs:domain ?c .
} where {
  ?p2 rdfs:domain ?c .
  ?p1 rdfs:subPropertyOf ?p2 .
};

#scm-rng1
insert {
  ?p rdfs:range ?c2 .
} where {
  ?p rdfs:range ?c1 .
  ?c1 rdfs:subClassOf ?c2 .
};

#scm-rng2
insert {
  ?p1 rdfs:range ?c .
} where {
  ?p2 rdfs:range ?c .
  ?p1 rdfs:subPropertyOf ?p2 .
};

#scm-hv
insert {
  ?c1 rdfs:subClassOf ?c2 .
} where {
  ?c1 owl:hasValue ?i .
  ?c1 owl:onProperty ?p1 .
  ?c2 owl:hasValue ?i .
  ?c2 owl:onProperty ?p2 .
  ?p1 rdfs:subPropertyOf ?p2 .
};

#scm-svf1
insert {
  ?c1 rdfs:subClassOf ?c2 .
} where {
  ?c1 owl:someValuesFrom ?y1 .
  ?c1 owl:onProperty ?p .
  ?c2 owl:someValuesFrom ?y2 .
  ?c2 owl:onProperty ?p .
  ?y1 rdfs:subClassOf ?y2 .
};

#scm-svf2
insert {
  ?c1 rdfs:subClassOf ?c2 .
} where {
  ?c1 owl:someValuesFrom ?y .
  ?c1 owl:onProperty ?p1 .
  ?c2 owl:someValuesFrom ?y .
  ?c2 owl:onProperty ?p2 .
  ?p1 rdfs:subPropertyOf ?p2 .
};

#scm-avf1
insert {
  ?c1 rdfs:subClassOf ?c2 .
} where {
  ?c1 owl:allValuesFrom ?y1 .
  ?c1 owl:onProperty ?p .
  ?c2 owl:allValuesFrom ?y2 .
  ?c2 owl:onProperty ?p .
  ?y1 rdfs:subClassOf ?y2 .
};

#scm-avf2
insert {
  ?c2 rdfs:subClassOf ?c1 .
} where {
  ?c1 owl:allValuesFrom ?y .
  ?c1 owl:onProperty ?p1 .
  ?c2 owl:allValuesFrom ?y .
  ?c2 owl:onProperty ?p2 .
  ?p1 rdfs:subPropertyOf ?p2 .
};

#scm-int
insert {
  ?c rdfs:subClassOf ?c1, ?c2, ?c3, ?c4, ?c5, ?c6, ?c7 .
  #...
} where {
  ?c owl:intersectionOf ?x .
  ?x rdf:first ?c1 .
  #LIST[?x, ?c1, ..., ?cn]
  {
    ?x rdf:rest (?c2) .
  } union {
    ?x rdf:rest (?c2 ?c3) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5 ?c6) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5 ?c6 ?c7) .
  }
};

#scm-uni

insert {
  ?c1 rdfs:subClassOf ?c .
  ?c2 rdfs:subClassOf ?c .
  ?c3 rdfs:subClassOf ?c .
  ?c4 rdfs:subClassOf ?c .
  ?c5 rdfs:subClassOf ?c .
  ?c6 rdfs:subClassOf ?c .
  ?c7 rdfs:subClassOf ?c .
  #...
} where {
  ?c owl:unionOf ?x .
  ?x rdf:first ?c1 .
  #LIST[?x, ?c1, ..., ?cn]
  {
    ?x rdf:rest (?c2) .
  } union {
    ?x rdf:rest (?c2 ?c3) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5 ?c6) .
  } union {
    ?x rdf:rest (?c2 ?c3 ?c4 ?c5 ?c6 ?c7) .
  }
};


##
# Additional Rules

# owl:hasSelf
insert {
  ?x ?p ?x .
} where {
  ?c owl:onProperty ?p ;
    owl:hasSelf true .
  ?x a ?c .
};
