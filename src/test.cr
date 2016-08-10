require "./query-builder"

query = Query::Builder.new

p query.table("test").where("id", 17).or_where("language", "crystal").get