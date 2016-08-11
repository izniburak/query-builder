require "./query-builder/*"

module Query
	class Builder

		def initialize
			@select = "*"
			@table, @join, @where, @group_by, @having, @order_by, @limit, @last_query = "", "", "", "", "", "", "", ""
			@operators = ["=","!=","<",">","<=",">=","<>"]
		end

		def select(fields)
			@select = fields.is_a? (Array) ? fields.join(",") : fields.to_s
			self
		end

		def table(name)
			@table = name.is_a? (Array) ? name.join(",") : name.to_s
			self
		end

		def join(table : String, field1 : String, field2 = nil, type = "")
			@join += field2.nil? ? " #{type}JOIN #{table} ON #{field1}" : " #{type}JOIN #{table} ON #{field1} = #{field2}"
			self
		end

		def left_join(table : String, field1 : String, field2 = nil)
			join table, field1, field2, "LEFT "
		end

		def right_join(table : String, field1 : String, field2 = nil)
			join table, field1, field2, "RIGHT "
		end

		def inner_join(table : String, field1 : String, field2 = nil)
			join table, field1, field2, "INNER "
		end

		def full_outer_join(table : String, field1 : String, field2 = nil)
			join table, field1, field2, "FULL OUTER "
		end

		def left_outer_join(table : String, field1 : String, field2 = nil)
			join table, field1, field2, "LEFT OUTER "
		end

		def right_outer_join(table : String, field1 : String, field2 = nil)
			join table, field1, field2, "RIGHT OUTER "
		end

		def where(field : String, operator, val = nil, type = "AND")
			if operator.is_a? (Array)
				query = ""
				field.split("?").map_with_index do |val, i|  
					query += i < operator.size ? "#{val}#{escape(operator[i])}" : "#{val}"
				end
				where = query
			elsif @operators.includes?(operator.to_s)
				where = "#{field} #{operator} #{escape(val)}"
			else
				where = "#{field} = #{escape(operator)}"
			end
			@where += @where.empty? ? where : " #{type} #{where}"
			self
		end

		def or_where(field : String, operator, val = nil)
			where field, operator, val, "OR"
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
			@group_by = field.is_a? (Array) ? field.join(", ") : field
			self
		end

		def having(field : String, operator, val = nil)
			if operator.is_a? (Array)
				query = ""
				field.split("?").map_with_index do |val, i|  
					query += i < operator.size ? "#{val}#{escape(operator[i])}" : "#{val}"
				end
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

		def update
			
		end

		def insert
			
		end

		def delete
			
		end

		def query(sql : String, params : Array)
			query = ""
			sql.split("?").map_with_index do |val, i|  
				query += i < params.size ? "#{val}#{escape(params[i])}" : "#{val}"
			end
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

		private	def escape(data)
			"'#{data.to_s.gsub("'", "\'")}'"
		end

	end
end