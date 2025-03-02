##
# Entail time properties on temporal XSD literals.
# See <https://www.w3.org/TR/owl-time/>.
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix time: <http://www.w3.org/2006/time#>

insert {

  ?s ?p ?timeurn .

  ?timeurn a ?type, time:DateTimeDescription ;
    owl:sameAs ?time ;
    time:year ?year ;
    time:month ?month ;
    time:day ?day ;
    time:hour ?hours ;
    time:minute ?minutes ;
    time:second ?seconds ;
    time:timeZone ?tzNode .

  ?tzNode a time:TimeZone ;
    rdf:value ?tz, ?timezone .

} where {

  ?s ?p ?time .
  bind(datatype(?time) as ?type)
  filter(?type in (xsd:dateTimeStamp, xsd:dateTime, xsd:date))

  bind(strdt(str(year(?time)), xsd:gYear) as ?year)
  bind(strdt(concat("--", if(month(?time) < 10, "0", ""), str(month(?time))), xsd:gMonth) as ?month)
  bind(strdt(concat("---", if(day(?time) < 10, "0", ""), str(day(?time))), xsd:gDay) as ?day)
  bind(strdt(str(hours(?time)), xsd:nonNegativeInteger) as ?hours)
  bind(strdt(str(minutes(?time)), xsd:nonNegativeInteger) as ?minutes)
  bind(seconds(?time) as ?seconds)
  bind(tz(?time) as ?tz)
  bind(timezone(?time) as ?timezone)

  bind(bnode(str(?timezone)) as ?tzNode)

  bind(IRI(concat('urn:sha:', SHA256(concat(str(?time), '^^', str(?type))))) as ?timeurn)

}
