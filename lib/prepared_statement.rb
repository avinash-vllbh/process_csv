require 'csv'
class FileNotFound < StandardError; end

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
#Below class process the output.csv file from csv_processor.rb to prepare a create table statement.
#Prepared SQL statements are compatible with POSTGRES SQL.
#	
##
###
class PreparedStatement
	def tbl_prepare_statement(filename)		
			tbl_name = "Input".downcase # make this based on the filename
			sql_string = "CREATE TABLE "+tbl_name.to_s+" ( "
		if File::exists?(filename)
			line_no = 0
			CSV.foreach(filename) do |line|
				empty_values = line[6]
				#data_type    = line[2]
				#column_name  = line[1]
        
				if line_no > 2
					if line[2] == "int"
						if empty_values == "Not Empty"
							sql_string = sql_string+"#{line[1]} "+line[2].upcase+" NOT NULL, "
						else
							sql_string = sql_string+line[1]+" "+line[2].upcase+", "
						end
					elsif line[2] == "date"
						if empty_values == "Not Empty"
							sql_string = sql_string+line[1]+" "+line[2].upcase+" NOT NULL, "
						else
							sql_string = sql_string+line[1]+" "+line[2].upcase+", "
						end
					else
						if empty_values == "Not Empty"
							sql_string = sql_string+line[1]+" varchar NOT NULL, "
						else
							sql_string = sql_string+line[1]+" varchar, "
						end
					end
				end
				line_no = line_no + 1;
			end
			sql_string = sql_string+"PRIMARY KEY ( id ));"
			return sql_string
		else
			return FileNotFound.new
		end
	end
	def csv_import_statement(filename,delimiter)
		#LOAD DATA INFILE '/tmp/test.txt' INTO TABLE test IGNORE 1 LINES;
		file = "#{filename}"
		puts file
		filename.slice!(/^processed_/)
		tbl_name = File.basename(filename,".*")
		import_statement = "LOAD DATA INFILE #{file} INTO TABLE #{tbl_name} "+
							"FIELDS TERMINATED BY '#{delimiter}' "+
							"ENCLOSED BY '\"' "+
							"LINES TERMINATED BY '\\n' "+
							"IGNORE 1 LINES;"
	end
end

# prep_stmt = PreparedStatement.new
# file = '../spec/prepared_statement/test.csv'
# prep_stmt.prepare_statement(file)
