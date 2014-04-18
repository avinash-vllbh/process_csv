require 'csv'
require 'tco'
require_relative 'error_handler'

# ##
# Performs below set of processing on input CSV file.
# -Format line endings i.e., convert line endings into UNIX style \n format
# -Removes any 'nulls', '\N', '',"",, and replaces them with NULL for easier import into Database
# -Removes any quotings around numbers
# -Coverts single quotes into double quotes if they are used as field encapsulations
# -creates another file with file name prepended by 'processed_'
# ##
class CSVCleaner
	
	def cleaner_csv(filename,delimiter,processed_file_name,skip_lines,replace_nulls,replace_quotes)
		skip_lines = skip_lines.to_i
		if File::exists?(filename)
			output = processed_file_name
			csvwrite = CSV.open(output, "wb", {:col_sep => delimiter})
		    if(replace_nulls == "YES" && replace_quotes == "YES")
				File.foreach(filename) do |line|
					#puts line
					if skip_lines > 0
						skip_lines = skip_lines - 1
					else
						#Check if the line is empty
						if line.length > 1
							line = replace_line_single_quotes(line,delimiter)
							begin
								line = CSV.parse_line(line, {:col_sep => delimiter})
							rescue CSV::MalformedCSVError => error
								puts "#{error}".fg("#ff0000")
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
					end
				end
			elsif(replace_nulls == "YES" && replace_quotes == "NO")
				File.foreach(filename) do |line|
					if skip_lines > 0
						skip_lines = skip_lines - 1
					else
						if line.length > 1
							begin
								line = CSV.parse_line(line, {:col_sep => delimiter})
							rescue CSV::MalformedCSVError => error
								puts "#{error}".fg("#ff0000")
								puts line
								puts "Please correct the above line and re-enter"
								line = gets.chomp
								line = CSV.parse_line(line, {:col_sep => delimiter})
							end
							line = replace_line_nulls(line)
							csvwrite << line
						end
					end
				end
			else
				File.foreach(filename) do |line|
					if skip_lines > 0
						skip_lines = skip_lines - 1
					else
						if line.length > 1
							line = replace_line_single_quotes(line,delimiter)
							begin
								line = CSV.parse_line(line, {:col_sep => delimiter})
							rescue CSV::MalformedCSVError => error
								puts "#{error}".fg("#ff0000")
								puts line
								puts "Please correct the above line and re-enter"
								line = gets.chomp
								line = CSV.parse_line(line, {:col_sep => delimiter})
							end
							csvwrite << line
						end
					end
				end
			end
			csvwrite.close
		else
			FileNotFound.new
		end
	end

	def replace_line_single_quotes(line,delimiter)
		delimiter = "\\|" if delimiter == "|"
		pattern = "#{delimiter}'.*?'#{delimiter}"
		#puts pattern
		res = line.gsub(/#{pattern}/)
		result = res.each { |match|
			replace = "#{delimiter}\""
			replace = "\|\"" if delimiter == "\\|"
			match = match.gsub(/^#{delimiter}'/,replace)
			replace = "\"#{delimiter}"
			replace = "\"\|" if delimiter == "\\|"
			match = match.gsub(/'#{delimiter}$/,replace)
		}
		result = result.gsub(/''/,'\'')

		return result
	end

	def replace_line_nulls(line)
		line.each do |value|
            if(value == nil || value == "\\N" || value == "nil" ||value == "" ||value == "NAN")
              replace_index = line.index(value)
              line[replace_index] = "NULL"
            end
        end
        return line
	end

	def clean_line_endings(in_filename,out_filename)
		write = File.open(out_filename, "wb:UTF-8")
		carriage_return = false
		File.open(in_filename, "rb") do |file|
			file.each_char { |ch| 
				if carriage_return == true
					if ch == "\n"
						write << ch
					else
						write << "\n"
						write << ch.encode!('UTF-8', :invalid => :replace, :undef => :replace, :replace => '??')
					end
					carriage_return = false
				else
					if ch == "\r"
						carriage_return = true
					else
						write << ch.encode!('UTF-8', :invalid => :replace, :undef => :replace, :replace => '??')
					end
				end
			}
		end
		write.close
	end
end
