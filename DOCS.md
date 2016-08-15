# query-builder Documentation

sql query builder library for crystal-lang

Documentation Page


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  query-builder:
    github: izniburak/query-builder
```

## Quick Usage

```crystal
require "query-builder"
builder = Query::Builder.new

p builder.table("test").where("id", 1).get

# Output:
# "SELECT * FROM test WHERE id = '1' LIMIT 1"
```

# Usage and Methods

Create a new query-builder Object

```crystal
require "query-builder"
builder = Query::Builder.new
```

### table
```crystal
# Usage 1: String Parameter
builder.table("test")

# Usage 2: Array Parameter
builder.table(["foo", "bar"])
```

### select
```crystal
# Usage 1: String Parameter
builder.table("test").select("id, title, content, tags")

# Usage 2: Array Parameter
builder.table("test").select(["id", "title", "content", "tags"])
```

### get - get_all
```crystal

```

### join 
```crystal

```

### where
```crystal

```

### in
```crystal

```

### between
```crystal

```

### like
```crystal

```

### group_by
```crystal

```

### having
```crystal

```

### order_by
```crystal

```

### limit
```crystal

```

### insert
```crystal

```

### update
```crystal

```

### delete
```crystal

```

### query
```crystal

```

### last_query
```crystal

```