require "./spec_helper"

describe Query::Builder do
  builder = Query::Builder.new
  it "selects * from table" do
    builder.table("test").get.should eq "SELECT * FROM test LIMIT 1"
  end

  it "sql query" do
    query = builder.query("SELECT id, title FROM test_table WHERE id = ? AND title = ? ORDER BY id DESC LIMIT 10", [17, "Crystal"])
    query.should eq "SELECT id, title FROM test_table WHERE id = '17' AND title = 'Crystal' ORDER BY id DESC LIMIT 10"
  end

  it "select given fields from table" do
    query = builder.table("test").select("id, title, content, status").get_all
    query.should eq "SELECT id, title, content, status FROM test"
  end

  it "select functions (max, min, count, sum, avg)" do
    query = builder.table("test").max("price", "maxPrice").get_all
    query.should eq "SELECT MAX(price) AS maxPrice FROM test"
  end

  it "sql join" do
    query = builder.table("test").left_join("foo", "test.id", "foo.page_id").get_all
    query.should eq "SELECT * FROM test LEFT JOIN foo ON test.id = foo.page_id"
  end

  it "where and or_where" do
    query = builder.table("test").where("auth", 1).or_where("auth", 2).get_all
    query.should eq "SELECT * FROM test WHERE auth = '1' OR auth = '2'"
  end

  it "sql where in" do
    query = builder.table("test").where("active", 1).in("id", [1, 2, 3]).get_all
    query.should eq "SELECT * FROM test WHERE active = '1' AND id IN ('1', '2', '3')"
  end

  it "sql where between" do
    query = builder.table("test").where("status", 1).between("age", 18, 30).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' AND age BETWEEN '18' AND '30'"
  end

  it "sql where like" do
    query = builder.table("test").where("status", 1).like("title", "%crystal%").limit(10).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' AND title LIKE '%crystal%' LIMIT 10"
  end

  it "sql group by" do
    query = builder.table("test").where("status", 1).group_by("cat_id").get_all
    query.should eq "SELECT * FROM test WHERE status = '1' GROUP BY cat_id"
  end

  it "sql having" do
    query = builder.table("test").where("status", 1).group_by("city").having("COUNT(person)", 100).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' GROUP BY city HAVING COUNT(person) > '100'"
  end

  it "sql order by" do
    query = builder.table("test").where("active", 1).order_by("id", "desc").limit(5).get_all
    query.should eq "SELECT * FROM test WHERE active = '1' ORDER BY id DESC LIMIT 5"
  end

  it "sql limit" do
    query = builder.table("test").where("status", 1).limit(10, 20).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' LIMIT 10, 20"
  end

  it "get a row" do
    query = builder.table("test").where("user_id", 1).get
    query.should eq "SELECT * FROM test WHERE user_id = '1' LIMIT 1"
  end

  it "sql delete" do
    query = builder.table("test").where("id", 17).delete
    query.should eq "DELETE FROM test WHERE id = '17'"
  end

  it "sql delete truncate" do
    query = builder.table("test").delete
    query.should eq "TRUNCATE TABLE test"
  end

  it "insert method" do
    data = {
      "title"   => "query builder for Crystal",
      "slug"    => "query-builder-for-crystal",
      "content" => "sql query builder library for crystal-lang...",
      "tags"    => "crystal, query, builder",
      "time"    => Time.new(2016, 6, 21).to_s("%Y-%m-%d %H:%M:%S"),
      "status"  => 1,
    }
    query = builder.table("test").insert(data)
    query.should eq "INSERT INTO test (title, slug, content, tags, time, status) VALUES ('query builder for Crystal', 'query-builder-for-crystal', 'sql query builder library for crystal-lang...', 'crystal, query, builder', '2016-06-21 00:00:00', '1')"
  end

  it "insert method with nil data" do
    data = {
      "title"   => "query builder for Crystal",
      "slug"    => "query-builder-for-crystal",
      "content" => "sql query builder library for crystal-lang...",
      "tags"    => nil,
      "time"    => Time.new(2016, 6, 21).to_s("%Y-%m-%d %H:%M:%S"),
    }
    query = builder.table("test").insert(data)
    query.should eq "INSERT INTO test (title, slug, content, tags, time) VALUES ('query builder for Crystal', 'query-builder-for-crystal', 'sql query builder library for crystal-lang...', NULL, '2016-06-21 00:00:00')"
  end

  it "update method" do
    data = {
      "title"   => "Kemal",
      "slug"    => "kemal-web-framework",
      "content" => "Super Simple web framework for Crystal.",
      "tags"    => "crystal, framework, kemal",
      "status"  => 1,
    }
    query = builder.table("test").where("id", 17).update(data)
    query.should eq "UPDATE test SET title = 'Kemal', slug = 'kemal-web-framework', content = 'Super Simple web framework for Crystal.', tags = 'crystal, framework, kemal', status = '1' WHERE id = '17'"
  end

  it "update method with nil data" do
    data = {
      "title" => "Kemal",
      "slug"  => "kemal-web-framework",
      "tags"  => nil,
    }
    query = builder.table("test").where("id", 17).update(data)
    query.should eq "UPDATE test SET title = 'Kemal', slug = 'kemal-web-framework', tags = NULL WHERE id = '17'"
  end

  it "table maintenance method: analyze" do
    query = builder.table("test").analyze
    query.should eq "ANALYZE TABLE test"

    query = builder.table(["foo", "bar", "baz"]).analyze
    query.should eq "ANALYZE TABLE foo, bar, baz"
  end

  it "table maintenance method: check" do
    query = builder.table("test").check
    query.should eq "CHECK TABLE test"

    query = builder.table(["foo", "bar", "baz"]).check
    query.should eq "CHECK TABLE foo, bar, baz"
  end

  it "table maintenance method: checksum" do
    query = builder.table("test").checksum
    query.should eq "CHECKSUM TABLE test"

    query = builder.table(["foo", "bar", "baz"]).checksum
    query.should eq "CHECKSUM TABLE foo, bar, baz"
  end

  it "table maintenance method: optimize" do
    query = builder.table("test").optimize
    query.should eq "OPTIMIZE TABLE test"

    query = builder.table(["foo", "bar", "baz"]).optimize
    query.should eq "OPTIMIZE TABLE foo, bar, baz"
  end

  it "table maintenance method: repair" do
    query = builder.table("test").repair
    query.should eq "REPAIR TABLE test"

    query = builder.table(["foo", "bar", "baz"]).repair
    query.should eq "REPAIR TABLE foo, bar, baz"
  end

  it "drop table" do
    query = builder.table("test").drop
    query.should eq "DROP TABLE test"

    query = builder.table(["test", "fo", "bar"]).drop
    query.should eq "DROP TABLE test, fo, bar"

    # check table(s) exists
    query = builder.table("test").drop(true)
    query.should eq "DROP TABLE IF EXISTS test"
  end

  it "alter table" do
    query = builder.table("test").alter("add", "test_column", "varchar(255)")
    query.should eq "ALTER TABLE test ADD test_column varchar(255)"

    query = builder.table("test").alter("modify_column", "test_column", "int NOT NULL")
    query.should eq "ALTER TABLE test MODIFY COLUMN test_column int NOT NULL"

    query = builder.table("test").alter("modify", "test_date", "datetime NOT NULL")
    query.should eq "ALTER TABLE test MODIFY test_date datetime NOT NULL"

    query = builder.table("test").alter("drop_column", "test_column")
    query.should eq "ALTER TABLE test DROP COLUMN test_column"

    query = builder.table("test").alter("drop_index", "index_name")
    query.should eq "ALTER TABLE test DROP INDEX index_name"

    query = builder.table("test").alter("add_constraint", "my_primary_key", "PRIMARY KEY (column1, column2)")
    query.should eq "ALTER TABLE test ADD CONSTRAINT my_primary_key PRIMARY KEY (column1, column2)"
  end

  it "offset" do 
    query = builder.table("test").where("status", 1).limit(5).offset(10).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' LIMIT 5 OFFSET 10"
  end

  it "pagination" do 
    query = builder.table("test").pagination(15, 1).get_all
    query.should eq "SELECT * FROM test LIMIT 15 OFFSET 0"

    query = builder.table("test").pagination(15, 2).get_all
    query.should eq "SELECT * FROM test LIMIT 15 OFFSET 15"
  end

  it "query count" do 
    builder.query_count.should eq 42
  end
end
