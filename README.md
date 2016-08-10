# query-builder

sql query builder library for crystal-lang


## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  query-builder:
    github: izniburak/query-builder
```


## Usage


```crystal
require "query-builder"
builder = Query::Builder.new

p builder.table("test").where("id", 17).or_where("language", "crystal").get

# Output:
# "SELECT * FROM test WHERE id = '17' OR language = 'crystal' LIMIT 1"


p builder.query("SELECT id, title FROM test_table WHERE id = ? AND title = ? ORDER BY id DESC LIMIT 10", [17, "Crystal"])

# Output:
# "SELECT id, title FROM test_table WHERE id = '17' AND title = 'Crystal' ORDER BY id DESC LIMIT 10"
```


## Documentation

Coming soon...


## Contributing

1. Fork it ( https://github.com/izniburak/query-builder/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [izniburak](https://github.com/izniburak]) İzni Burak Demirtaş - creator, maintainer
