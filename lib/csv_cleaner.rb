require 'csv'

#Error handlers for easier testing in spec files

class FileNotFound < StandardError; end

# ##
# Performs below set of processing on input CSV file.
# -Format line endings i.e., convert line endings into UNIX style \n format
# -Removes any 'nulls', '\N', '',"",, and replaces them with NULL for easier import into Database
# -Removes any quotings around numbers
# -Coverts single quotes into double quotes if they are used as field encapsulations
# -creates another file with file name prepended by 'processed_'
# ##
class CSVCleaner
	def process_csv(filename,delimiter)
		#delimiter = "\\|" if delimiter == '|'
		if File::exists?(filename)
			output = 'processed_'+filename
			csvwrite = CSV.open(output, "wb", {:col_sep => delimiter})
			#To check if users wants line endings standerdized
			# puts "Do you want standardize line endings to UNIX format"
			# puts "Enter Yes or No"
			# line_endings = gets.chomp.upcase
			# while line_endings != "YES" && line_endings != "NO"
		 	#      puts "Invalid input!! Enter either yes or no"
		 	#      line_endings = gets.chomp.upcase
		 	#      line_endings = "YES" if line_endings == "Y"
		 	#      line_endings = "NO" if line_endings == "N"
			#    end
		    #Check if user wants to replace empty spaces null references to NULL
			puts "Do you want replace any empty spaces or Null's or \\N with NULL?"
			puts "Enter Yes or No"
			replace_nulls = gets.chomp.upcase
			replace_nulls = "YES" if replace_nulls == "Y"
		     replace_nulls = "NO" if replace_nulls == "N"
			while replace_nulls != "YES" && replace_nulls != "NO"
		      puts "Invalid input!! Enter either yes or no"
		      replace_nulls = gets.chomp.upcase
		      replace_nulls = "YES" if replace_nulls == "Y"
		      replace_nulls = "NO" if replace_nulls == "N"
		    end
		    #Check if user wants to remove any quotings around numbers
		 #    puts "Do you want to remove quotings around numbers"
			# puts "Enter Yes or No"
			# chop_quotes_nums = gets.chomp.upcase
			# while chop_quotes_nums != "YES" && chop_quotes_nums != "NO" && chop_quotes_nums != "N" && chop_quotes_nums != "Y"
		 #      puts "Invalid input!! Enter either yes or no"
		 #      chop_quotes_nums = gets.chomp.upcase
		 #      chop_quotes_nums = "YES" if chop_quotes_nums == "Y"
		 #      chop_quotes_nums = "NO" if chop_quotes_nums == "N"
		 #    end
		    #check if user wants to convert single quotes to double quotes
		    puts "Do you want to convert single quotes to double quotes"
			puts "Enter Yes or No"
			replace_quotes = gets.chomp.upcase
			replace_quotes = "YES" if replace_quotes == "Y"
		      replace_quotes = "NO" if replace_quotes == "N"
			while replace_quotes != "YES" && replace_quotes != "NO" && replace_quotes != "N" && replace_quotes != "Y"
		      puts "Invalid input!! Enter either yes or no"
		      replace_quotes = gets.chomp.upcase
		      replace_quotes = "YES" if replace_quotes == "Y"
		      replace_quotes = "NO" if replace_quotes == "N"
		    end

		    if(replace_nulls == "YES" && replace_quotes == "YES")
				File.foreach(filename) do |line|
					line = replace_line_single_quotes(line,delimiter)
					begin
						line = CSV.parse_line(line, {:col_sep => delimiter})
					rescue CSV::MalformedCSVError => error
						puts error
						puts line
						puts "Please correct the above line and re-enter"
						line = gets.chomp
						line = CSV.parse_line(line, {:col_sep => delimiter})
					end
					#line = replace_line_endings(line)
					line = replace_line_nulls(line)
					#line = remove_quotes_around_numbers(line)
					csvwrite << line
				end
			elsif(replace_nulls == "YES" && replace_quotes == "NO")
				File.foreach(filename) do |line|
					#line = replace_line_single_quotes(line,delimiter)
					begin
						line = CSV.parse_line(line, {:col_sep => delimiter})
					rescue CSV::MalformedCSVError => error
						puts error
						puts line
						puts "Please correct the above line and re-enter"
						line = gets.chomp
						line = CSV.parse_line(line, {:col_sep => delimiter})
					end
					#line = replace_line_endings(line)
					line = replace_line_nulls(line)
					#line = remove_quotes_around_numbers(line)
					
					csvwrite << line
				end
			else
				File.foreach(filename) do |line|
					line = replace_line_single_quotes(line,delimiter)
					begin
						line = CSV.parse_line(line, {:col_sep => delimiter})
					rescue CSV::MalformedCSVError => error
						puts error
						puts line
						puts "Please correct the above line and re-enter"
						line = gets.chomp
						line = CSV.parse_line(line, {:col_sep => delimiter})
					end
					csvwrite << line
				end
			end
			csvwrite.close
		else
			FileNotFound.new
		end
	end

	# def replace_line_endings(line)

	# end
	def replace_line_single_quotes(line,delimiter)
		delimiter = "\\|" if delimiter == "|"
		pattern = "#{delimiter}'.*?'#{delimiter}"
		puts pattern
		res = line.gsub(/#{pattern}/)
		result = res.each { |match|
			replace = "#{delimiter}\""
			replace = "\|\"" if delimiter == "\\|"
			match = match.gsub(/^#{delimiter}'/,replace)
			replace = "\"#{delimiter}"
			replace = "\"\|" if delimiter == "\\|"
			match = match.gsub(/'#{delimiter}$/,replace)
		}
		#puts result
		#result = result.gsub(/\\|/,'|')
		result = result.gsub(/''/,'\'')

		return result
	end

	def replace_line_nulls(line)
		line.each do |value|
            if(value == nil || value == "\\N" || value == "nil")
              replace_index = line.index(value)
              line[replace_index] = "NULL"
            end
        end
        return line
	end
	# def remove_quotes_around_numbers(line)
	# 	line.each do |value|
	# end
	
end

# clean = CSVCleaner.new
# filename = "sampleCSV.csv"
# delimiter = ","
# clean.process_csv(filename,delimiter)