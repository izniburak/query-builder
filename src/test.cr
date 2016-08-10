require "./query-builder"

builder = Query::Builder.new

p builder.table("test").where("id", 17).or_where("language", "crystal").get

p builder.query("SELECT id, title FROM test_table WHERE id = ? AND title = ? ORDER BY id DESC LIMIT 10", [17, "Crystal"])
