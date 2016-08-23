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

# Output: "SELECT * FROM test"
```
```crystal
# Usage 2: Array Parameter
builder.table(["foo", "bar"])

# Output: "SELECT * FROM foo, bar"
```

### select
```crystal
# Usage 1: String Parameter
builder.table("test").select("id, title, content, tags")

# Output: "SELECT id, title, content, tags FROM test"
```
```crystal
# Usage 2: Array Parameter
builder.table("test").select(["id", "title", "content", "tags"])

# Output: "SELECT id, title, content, tags FROM test"
```

### join 
```crystal

```

### where
```crystal
builder.table("test").where("active", 1).get_all

# Output: "SELECT * FROM test WHERE active = '1'"

# OR 

builder.table("test").where("age", ">=", 18).get_all

# Output: "SELECT * FROM test WHERE age >= '18'"

# OR 

builder.table("test").or_where("age", [18, 20, 22]).get_all

# Output: "SELECT * FROM test WHERE age = '18' OR age = '20' OR age = '22'"
```

You can use this method in 4 ways. These;

- where
- or_where
- not_where
- or_not_where

Example:
```crystal
builder.table("test").where("active", 1).not_where("auth", 1).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND NOT auth = '1'"

# OR 

builder.table("test").where("age", 20).or_where("age", '>', 25).get_all

# Output: "SELECT * FROM test WHERE age = '20' OR age > '25'"
```

### in
```crystal
builder.table("test").where("active", 1).in("id", [1, 2, 3]).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND id IN ('1', '2', '3')"
```

You can use this method in 4 ways. These;

- in
- or_in
- not_in
- or_not_in

Example:
```crystal
builder.table("test").where("active", 1).not_in("id", [1, 2, 3]).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND id NOT IN ('1', '2', '3')"

# OR 

builder.table("test").where("active", 1).or_in("id", [1, 2, 3]).get_all

# Output: "SELECT * FROM test WHERE active = '1' OR id IN ('1', '2', '3')"
```

### between
```crystal
builder.table("test").where("active", 1).between("age", 18, 25).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND age BETWEEN '18' AND '25'"
```

You can use this method in 4 ways. These;

- between
- or_between
- not_between
- or_not_between

Example:
```crystal
builder.table("test").where("active", 1).not_between("age", 18, 25).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND age NOT BETWEEN '18' AND '25'"

# OR 

builder.table("test").where("active", 1).or_between("age", 18, 25).get_all

# Output: "SELECT * FROM test WHERE active = '1' OR age BETWEEN '18' AND '25'"
```

### like
```crystal

```

### group_by
```crystal
# Usage 1: One parameter
builder.table("test").where("status", 1).group_by("cat_id").get_all

# Output: "SELECT * FROM test WHERE status = '1' GROUP BY cat_id"
```

```crystal
# Usage 1: Array parameter
builder.table("test").where("status", 1).group_by(["cat_id", "user_id"]).get_all

# Output: "SELECT * FROM test WHERE status = '1' GROUP BY cat_id, user_id"
```

### having
```crystal

```

### order_by
```crystal
# Usage 1: One parameter
builder.table("test").where("status", 1).order_by("id").get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY id ASC"

### OR

builder.table("test").where("status", 1).order_by("id desc").get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY id desc"
```

```crystal
# Usage 1: Two parameters
builder.table("test").where("status", 1).order_by("id", "desc").get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY id DESC"
```

```crystal
# Usage 3: Rand()
builder.table("test").where("status", 1).order_by("rand()").limit(10).get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY rand() LIMIT 10"
```

### limit
```crystal
# Usage 1: One parameter
builder.table("test").limit(10).get_all 

# Output: "SELECT * FROM test LIMIT 10"
```
```crystal
# Usage 2: Two parameters
builder.table("test").limit(10, 20).get_all 

# Output: "SELECT * FROM test LIMIT 10, 20"
```

### get - get_all
```crystal
# 1. get
# Return 1 record.
builder.table("test").get 

# Output: "SELECT * FROM test LIMIT 1"
```
```crystal
# 2. get_all
# Return many records.
builder.table("test").get_all 

# Output: "SELECT * FROM test"
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