require "./query-builder/*"

module Query
  class Builder
    def initialize
      @select = "*"
      @table, @join, @where, @group_by, @having, @order_by, @limit, @last_query = "", "", "", "", "", "", "", ""
      @operators = ["=", "!=", "<", ">", "<=", ">=", "<>"]
    end

    def table(name)
      @table = name.is_a?(Array) ? name.join(", ") : name.to_s
      self
    end

    def select(fields)
      select = fields.is_a?(Array) ? fields.join(", ") : fields.to_s
      @select = @select.compare("*") == 0 ? select : "#{@select}, #{select}"
      self
    end

    {% for method in %w(max min sum count avg) %}
      def {{method.id}}(field, name = nil)
        {{method.id}} = "#{"{{method.id}}".upcase}(#{field})"
        {{method.id}} += " AS #{name}" if !name.nil?
        @select = @select.compare("*") == 0 ? {{method.id}} : "#{@select}, #{{{method.id}}}"
        self
      end
    {% end %}

    def join(table : String, field1 : String, field2 = nil, type = "")
      @join += field2.nil? ? " #{type}JOIN #{table} ON #{field1}" : " #{type}JOIN #{table} ON #{field1} = #{field2}"
      self
    end

    {% for method in %w(left right inner full_outer left_outer right_outer) %}
      def {{method.id}}_join(table : String, field1 : String, field2 = nil)
        join table, field1, field2, "#{"{{method.id}}"} ".gsub('_', ' ').upcase
      end
    {% end %}

    def where(field : String, operator, val = nil, type = "", and_or = "AND")
      if operator.is_a?(Array)
        query = ""
        field.split("?").map_with_index { |val, i| query += i < operator.size ? "#{type}#{val}#{escape(operator[i])}" : "#{val}" }
        where = query
      elsif @operators.includes?(operator.to_s)
        where = "#{type}#{field} #{operator} #{escape(val)}"
      else
        where = "#{type}#{field} = #{escape(operator)}"
      end
      @where += @where.empty? ? where : " #{and_or} #{where}"
      self
    end

    def or_where(field : String, operator, val = nil)
      where field, operator, val, "", "OR"
    end

    def not_where(field : String, operator, val = nil)
      where field, operator, val, "NOT ", "AND"
    end

    def or_not_where(field : String, operator, val = nil)
      where field, operator, val, "NOT ", "OR"
    end

    def in(field, values : Array, type = "", and_or = "AND")
      keys = [] of String
      values.each { |val| keys << "#{escape(val)}" }
      @where += @where.empty? ? "#{field} #{type}IN (#{keys.join(", ")})" : " #{and_or} #{field} #{type}IN (#{keys.join(", ")})"
      self
    end

    def or_in(field, values : Array)
      in field, values, "", "OR"
      self
    end

    def not_in(field, values : Array)
      in field, values, "NOT ", "AND"
      self
    end

    def or_not_in(field, values : Array)
      in field, values, "NOT ", "OR"
      self
    end

    def between(field, value1, value2, type = "", and_or = "AND")
      @where += @where.empty? ? "#{field} #{type}BETWEEN #{escape(value1)} AND #{escape(value2)}" : " #{and_or} #{field} #{type}BETWEEN #{escape(value1)} AND #{escape(value2)}"
      self
    end

    def or_between(field, value1, value2)
      between field, value1, value2, "", "OR"
    end

    def not_between(field, value1, value2)
      between field, value1, value2, "NOT ", "AND"
    end

    def or_not_between(field, value1, value2)
      between field, value1, value2, "NOT ", "OR"
    end

    def like(field, value, option = "", type = "", and_or = "AND")
      like = "%" + "#{value}" + "%"
      if option == "%-"
        like = "%" + "#{value}"
      elsif option == "-%"
        like = "#{value}" + "%"
      end
      @where += @where.empty? ? "#{field} #{type}LIKE #{escape(like)}" : " #{and_or} #{field} #{type}LIKE #{escape(like)}"
      self
    end

    def or_like(field, value, option = "")
      like field, value, option, "", "OR"
    end

    def not_like(field, value, option = "")
      like field, value, option, "NOT ", "AND"
    end

    def or_not_like(field, value, option = "")
      like field, value, option, "NOT ", "OR"
    end

    def limit(limit, limit_end = nil)
      @limit = !limit_end.nil? ? "#{limit}, #{limit_end}" : "#{limit}"
      self
    end

    def order_by(field : String, dir = nil)
      if !dir.nil?
        order_by = "#{field} #{dir.upcase}"
      else
        order_by = (field.includes?(" ") || field == "rand()") ? field : "#{field} ASC"
      end
      @order_by += @order_by.empty? ? order_by : ", #{order_by}"
      self
    end

    def group_by(field)
      @group_by = field.is_a?(Array) ? field.join(", ") : field
      self
    end

    def having(field : String, operator, val = nil)
      if operator.is_a?(Array)
        query = ""
        field.split("?").map_with_index { |val, i| query += i < operator.size ? "#{val}#{escape(operator[i])}" : "#{val}" }
        @having = query
      else
        @having = @operators.includes?(operator.to_s) ? "#{field} #{operator} #{escape(val)}" : "#{field} > #{escape(operator)}"
      end
      self
    end

    def get
      @limit = 1
      get_all
    end

    def get_all
      query = "SELECT #{@select} FROM #{@table}"
      query += "#{@join}" if !@join.empty?
      query += " WHERE #{@where}" if !@where.empty?
      query += " GROUP BY #{@group_by}" if !@group_by.empty?
      query += " HAVING #{@having}" if !@having.empty?
      query += " ORDER BY #{@order_by}" if !@order_by.empty?
      query += " LIMIT #{@limit}" if !@limit.to_s.empty?
      end_query query
    end

    def insert(datas : Hash)
      fields = datas.keys
      values = [] of String
      datas.values.each { |val| values << "#{escape(val)}" }
      query = "INSERT INTO #{@table} (#{fields.join(", ")}) VALUES (#{values.join(", ")})"
      end_query query
    end

    def update(datas : Hash)
      query = "UPDATE #{@table} SET"
      fields = datas.keys
      values = [] of String
      datas.values.map_with_index { |val, i| values << "#{fields[i]} = #{escape(val)}" }
      query += " #{values.join(", ")}"
      query += " WHERE #{@where}" if !@where.empty?
      query += " ORDER BY #{@order_by}" if !@order_by.empty?
      query += " LIMIT #{@limit}" if !@limit.to_s.empty?
      end_query query
    end

    def delete
      query = "DELETE FROM #{@table}"
      query += " WHERE #{@where}" if !@where.empty?
      query += " ORDER BY #{@order_by}" if !@order_by.empty?
      query += " LIMIT #{@limit}" if !@limit.to_s.empty?
      query = "TRUNCATE TABLE #{@table}" if query == "DELETE FROM #{@table}"
      end_query query
    end

    def query(sql : String, params : Array)
      query = ""
      sql.split("?").map_with_index { |val, i| query += i < params.size ? "#{val}#{escape(params[i])}" : "#{val}" }
      end_query query
    end

    def last_query
      @last_query
    end

    private def reset
      @table, @join, @where, @group_by, @having, @order_by, @limit, @last_query = "", "", "", "", "", "", "", ""
    end

    private def end_query(query)
      reset
      @last_query = query
      query
    end

    private def escape(data)
      "'#{data.to_s.gsub("'", "\\'")}'"
    end
  end
end
