require 'csv'
require 'tco'
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
			tbl_name.slice!(/^new./)
			pg_sql_string = "CREATE TABLE #{tbl_name} ( "
			my_sql_string = "CREATE TABLE #{tbl_name} ( "
		if File::exists?(output_filename)
			CSV.foreach(output_filename) do |line|
				if $INPUT_LINE_NUMBER > 3 #$ --> inbuilt ruby reference to the line number when reading a file
					if line.size == 8
						pg_result,my_result = generate_column_sql_part(line)
						pg_sql_string << pg_result.chomp << ", "
						my_sql_string << my_result.chomp << ", "
					end
				end
			end
			pg_sql_string = pg_sql_string.chomp(", ")
			my_sql_string = my_sql_string.chomp(", ")
			pg_sql_string << " );"
			my_sql_string << " );"
			return my_sql_string,pg_sql_string
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
				pg_result = "#{column_name} integer NOT NULL"
				my_result = "#{column_name} INT NOT NULL"
			else
				pg_result = "#{column_name} integer"
				my_result = "#{column_name} INT"
			end
		elsif data_type == "float"
			if empty_values == "Not Empty"
				pg_result = "#{column_name} real NOT NULL"
				my_result = "#{column_name} FLOAT NOT NULL"
			else
				pg_result = "#{column_name} real"
				my_result = "#{column_name} FLOAT"
			end
		elsif data_type == "date"
			if empty_values == "Not Empty"
				pg_result = "#{column_name} date NOT NULL "
				my_result = "#{column_name} date NOT NULL "
			else
				pg_result = "#{column_name} date"
				my_result = "#{column_name} date"
			end
		elsif data_type == "datetime"
			if empty_values == "Not Empty"
				pg_result = "#{column_name} timestamp NOT NULL "
				my_result = "#{column_name} timestamp NOT NULL "
			else
				pg_result = "#{column_name} timestamp"
				my_result = "#{column_name} timestamp NOT NULL "
			end
		else
			if empty_values == "Not Empty"
				pg_result = "#{column_name} varchar NOT NULL"
				my_result = "#{column_name} varchar NOT NULL"
			else
				pg_result = "#{column_name} varchar"
				my_result = "#{column_name} varchar"
			end
		end
		return pg_result,my_result
	end
		
	# returns the postgres-sql commands to load the CSV file into database as a new table with file name as table name
	# csv_import_statement("processed_sample.csv",",")
	# 
	def csv_import_statement(input_filename,delimiter,skip)
		
		#LOAD DATA INFILE '/tmp/test.txt' INTO TABLE test IGNORE 1 LINES;
		file = File.absolute_path(input_filename)
		#puts file
		input_filename.slice!(/^processed_/)
		tbl_name = File.basename(input_filename,".*")
		tbl_name.slice!(/^new./)
		skip = 1 if skip == 0
		my_import_statement = "LOAD DATA INFILE #{file} INTO TABLE #{tbl_name} "+
							"FIELDS TERMINATED BY '#{delimiter}' "+
							"ENCLOSED BY '\"' "+
							"LINES TERMINATED BY '\\n' "+
							"IGNORE #{skip} LINES;"
		pg_import_statement = "COPY #{tbl_name} FROM '#{file}' HEADER DELIMITER '#{delimiter}' CSV;"
		return my_import_statement,pg_import_statement
	end
end
