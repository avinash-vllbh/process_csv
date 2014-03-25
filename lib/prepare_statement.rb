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
	def prepare_statement(filename)		
			tbl_name = "Input".downcase
			sql_string = "CREATE TABLE "+tbl_name.to_s+" (id INT NOT NULL AUTO_INCREMENT, "
		if File::exists?(filename)
			line_no = 0
			CSV.foreach(filename) do |line|
				print line[2]
				puts "\n"
				if line_no > 2
					if line[2] == "int"
						if line[6] == "Not Empty"
							sql_string = sql_string+"#{line[1]} "+line[2].upcase+" NOT NULL, "
						else
							sql_string = sql_string+line[1]+" "+line[2].upcase+", "
						end
					elsif line[2] == "date"
						if line[6] == "Not Empty"
							sql_string = sql_string+line[1]+" "+line[2].upcase+" NOT NULL, "
						else
							sql_string = sql_string+line[1]+" "+line[2].upcase+", "
						end
					else
						if line[6] == "Not Empty"
							sql_string = sql_string+line[1]+" varchar NOT NULL, "
						else
							sql_string = sql_string+line[1]+" varchar, "
						end
					end
				end
				line_no = line_no + 1;
			end
			sql_string = sql_string+"PRIMARY KEY ( id ));"
		end
		puts sql_string
	end
end
