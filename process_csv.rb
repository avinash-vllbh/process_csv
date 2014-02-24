require 'csv'
require 'smarter_csv'

class ProcessCSV


# To clean the line endings, make "\n" as standard.
	def clean_line_endings(filename)
		begin
			csvwrite = CSV.open("test1CSV.csv", "wb")
			CSV.foreach(filename) do |row|
				csvwrite << row
			end
			puts "CSV file has been successfully cleaned"
		rescue Exception => e
			puts e
		end
	end
#To determine the data-type of an input field
	def get_datatype(field)
		if(Integer(field) rescue false)
			return "int"
		elsif(Float(field) rescue false)
			return "float"
		elsif(Date.parse(field) rescue false)
			if(field =~ /[a-z][0-9]/)
				return "string"
			else
				return "date"
			end
		else
			return "string"
		end
	end
#To get the header row length
	def get_header_length(filename)
		@no_of_columns = 0
		@no_of_rows = 0
		CSV.foreach(filename) do |row|
			if(@no_of_columns == 0)
				@no_of_columns = row.length
			else
				@no_of_rows = @no_of_rows + 1
				if(row.size != @no_of_columns)
					puts "The file isn't square at row #{@no_of_rows+1}"
				end
			end
		end
		puts "Total No of rows: #{@no_of_rows} and No of columns: #{@no_of_columns}"
	end
#To guess the data types based on a small chunk
	def initial_data_type(filename,chunk)
		@headers = Array.new
		@header_datatype = Array.new
		get_keys = false
		@arr_unique = Array.new{hash.new}
		#hash_datatype = {"int" => 0, "float" => 0, "date" => 0, "string" => 0}
		@arr_details = Array.new(@no_of_columns){{"int" => 0, "float" => 0, "date" => 0, "string" => 0}}
		total_chunks = SmarterCSV.process(filename, {:chunk_size => chunk, :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
			if(get_keys == false)
				chunk.each do |row|	
					@headers = row.keys
					#puts headers[0].to_sym
					get_keys = true
					break
				end
			end
			for i in 0..@headers.length-1
				arr = chunk.map{|x| x[@headers[i].to_sym]}
				if(@arr_unique[i].to_a.empty?)
					@arr_unique[i] = arr
					arr.each do |field|
						field_type = get_datatype(field)
						count = @arr_details[i][field_type]
						@arr_details[i][field_type] = count+1

					end
				else
					@arr_unique[i] |= arr
					arr.each do |field|
						field_type = get_datatype(field)
						count = @arr_details[i][field_type]
						@arr_details[i][field_type] = count+1
					end
				end
			end
			break
		end
		#To prepare hash with datatypes of every column to decide on the intial datatypes
		@arr_details.each do |hash|
			max_value = 0
			max_value_key = String.new
			hash.each do |key, value|
				if(max_value <= value)
					max_value = value
					max_value_key = key
				end
			end
			@header_datatype.push(max_value_key)
		end
		puts @header_datatype
		puts "\n\n\n"
		puts @arr_details
		puts "\n\n\n"
	end
#Function to process the csv file and display processed data
	def process_csv_file(filename, no_of_unique)
		@arr_unique = Array.new{hash.new}
		@arr_details = Array.new(@no_of_columns){{"int" => 0, "float" => 0, "date" => 0, "string" => 0, "max_value" => 0, "min_value" => 0}}
		total_chunks = SmarterCSV.process(filename, {:chunk_size => 200, :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
			for i in 0..@headers.length-1
				arr = chunk.map{|x| x[@headers[i].to_sym]}
				if(@arr_unique[i].to_a.empty?)
					@arr_unique[i] = arr.uniq
				elsif(@arr_unique[i].size < no_of_unique.to_i)
					@arr_unique[i] |= arr.uniq
				end
				
				arr.each do |field|
					field_type = get_datatype(field)
					count = @arr_details[i][field_type]
					@arr_details[i][field_type] = count+1
					if(field != nil)
						if(@header_datatype[i] == "int" || @header_datatype[i] == "float")
							
							if(@arr_details[i]["max_value"] < field)
								@arr_details[i]["max_value"] = field
							end
							if(@arr_details[i]["min_value"] > field || @arr_details[i]["min_value"] == 0)
								@arr_details[i]["min_value"] = field
							end
						else
							if(@arr_details[i]["max_value"] < field.to_s.length)
								@arr_details[i]["max_value"] = field.to_s.length
							end
							if(@arr_details[i]["min_value"] > field.to_s.length ||  @arr_details[i]["min_value"] == 0)
								@arr_details[i]["min_value"] = field.to_s.length
							end
						end
					end
				end
			end
		end
		puts @arr_unique
		puts "\n\n"
		return @arr_details	
	end
end

filename = ARGV[0]
chunk_size = ARGV[1]
no_of_unique = ARGV[2]
#check if the file exists
if File::exists?(filename)
	csv_process = ProcessCSV.new
	csv_process.clean_line_endings(filename)
	csv_process.get_header_length(filename)
	csv_process.initial_data_type(filename,chunk_size)
	array_details = csv_process.process_csv_file(filename, no_of_unique)
	puts array_details
else
	puts "invalid filename"
end
