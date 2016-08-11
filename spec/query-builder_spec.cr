require "./spec_helper"

describe Query::Builder do
  it "selects * from table" do
    builder = Query::Builder.new
    builder.table("test").get.should eq "SELECT * FROM test LIMIT 1"
  end

  it "select given fields from table" do
    builder = Query::Builder.new
    query = builder.query("SELECT id, title FROM test_table WHERE id = ? AND title = ? ORDER BY id DESC LIMIT 10", [17, "Crystal"])
    query.should eq "SELECT id, title FROM test_table WHERE id = '17' AND title = 'Crystal' ORDER BY id DESC LIMIT 10"
  end
end
