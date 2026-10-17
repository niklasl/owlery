##
# Drop blank nodes used as types
delete {
  ?x a ?t .
} where {
  ?x a ?t .
  filter isBlank(?t)
}
