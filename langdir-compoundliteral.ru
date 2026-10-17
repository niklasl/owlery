PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

##
# Encode rdf:langString information.
INSERT {
  ?s ?p ?litnode .
  ?litnode a rdf:CompoundLiteral ;
    owl:sameAs ?strlang ;
    rdf:value ?lexical ;
    rdf:language ?lang .
}
WHERE {
  ?s ?p ?strlang .
  FILTER(hasLANG(?strlang) && !hasLANGDIR(?strlang))
  BIND(STR(?strlang) as ?lexical)
  BIND(LANG(?strlang) as ?lang)
  OPTIONAL {
    ?existing_litnode owl:sameAs ?strlang .
  }
  BIND(COALESCE(?existing_litnode,
                IRI(concat('http://example.org/.well-known/genid/',
                           SHA256(concat(str(?o), '^^', str(datatype(?o)),
                                         '@', lang(?o))))))
       as ?litnode)
};

##
# Encode rdf:dirLangString information.
INSERT {
  ?s ?p ?litnode .
  ?litnode a rdf:CompoundLiteral ;
    owl:sameAs ?strlangdir ;
    rdf:value ?lexical ;
    rdf:language ?lang ;
    rdf:direction ?langdir .
}
WHERE {
  ?s ?p ?strlangdir .
  FILTER(hasLANG(?strlangdir) && hasLANGDIR(?strlangdir))
  BIND(STR(?strlangdir) as ?lexical)
  BIND(LANG(?strlangdir) as ?lang)
  BIND(LANGDIR(?strlangdir) as ?langdir)
  OPTIONAL {
    ?existing_litnode owl:sameAs ?strlangdir .
  }
  BIND(COALESCE(?existing_litnode,
                IRI(concat('http://example.org/.well-known/genid/',
                           SHA256(concat(str(?o), '^^', str(datatype(?o)),
                                         '@', lang(?o),
                                         '--', langdir(?o))))))
       as ?litnode)
}
