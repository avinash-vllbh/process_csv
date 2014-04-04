require 'csv'
require 'english'
require_relative 'error_handler'

class String
	#To extend the String class with support for camel casing
		def camelize()
			splits = self.split("_")
			for i in 1..splits.length-1
				splits[i][0] = splits[i][0].upcase
			end
			return splits.join
		end
	end

###
##	
# Below class process the output.csv file from csv_processor.rb to prepare a create table statement.
# Prepared SQL statements are compatible with POSTGRES SQL.
# tbl_prepare_statement("output.csv", "processed_sample.csv")	
##
###
class PreparedStatement
	def tbl_prepare_statement(output_filename, input_filename)		
			tbl_name = File.basename(input_filename,".*")
			tbl_name = tbl_name.gsub(/^processed_/,'')
			sql_string = "CREATE TABLE #{tbl_name} ( "
		if File::exists?(output_filename)
			CSV.foreach(output_filename) do |line|
				if $INPUT_LINE_NUMBER > 3 #$ --> inbuilt ruby reference to the line number when reading a file
					if line.size == 8
						result = generate_column_sql_part(line)
						sql_string <<result.chomp << ", "
					end
				end
			end
			sql_string = sql_string.chomp(", ")
			sql_string << " );"
			return sql_string
		else
			return FileNotFound.new
		end
	end

	# returns the sql commands that needs to be appended to main sql statement to create_table_query
	# sample line = 1,year,int,3,1996,1999,Not Empty,"1997,1999,1996"
	# column_name  = year
	# data_type    = int
	# empty_values = Not Empty
	def generate_column_sql_part(line)
		column_name  = line[1]
		data_type    = line[2]
		empty_values = line[6]
		if data_type == "int"
			if empty_values == "Not Empty"
				result = "#{column_name} integer NOT NULL"
			else
				result = "#{column_name} integer"
			end
		elsif data_type == "float"
			if empty_values == "Not Empty"
				result = "#{column_name} real NOT NULL"
			else
				result = "#{column_name} real"
			end
		elsif data_type == "date"
			if empty_values == "Not Empty"
				result = "#{column_name} date NOT NULL "
			else
				result = "#{column_name} date"
			end
		elsif data_type == "datetime"
			if empty_values == "Not Empty"
				result = "#{column_name} timestamp NOT NULL "
			else
				result = "#{column_name} timestamp"
			end
		else
			if empty_values == "Not Empty"
				result = "#{column_name} varchar NOT NULL"
			else
				result = "#{column_name} varchar"
			end
		end
		return result
	end
		
	# returns the postgres-sql commands to load the CSV file into database as a new table with file name as table name
	# csv_import_statement("processed_sample.csv",",")
	# 
	def csv_import_statement(input_filename,delimiter)
		#LOAD DATA INFILE '/tmp/test.txt' INTO TABLE test IGNORE 1 LINES;
		file = "#{input_filename}"
		puts file
		input_filename.slice!(/^processed_/)
		tbl_name = File.basename(input_filename,".*")
		import_statement = "LOAD DATA INFILE #{file} INTO TABLE #{tbl_name} "+
							"FIELDS TERMINATED BY '#{delimiter}' "+
							"ENCLOSED BY '\"' "+
							"LINES TERMINATED BY '\\n' "+
							"IGNORE 1 LINES;"
	end
end
