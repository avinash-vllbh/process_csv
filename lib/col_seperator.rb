	require 'csv'
	require 'smarter_csv'

	class FileNotFound < StandardError; end
	class InvalidInput < StandardError; end

	class String
		def substr_count(needle)
			needle = "\\#{needle}" if(needle == '|') # To escape inside regex
			self.scan(/(#{needle})/).size
		end
	end

	class ColSeperator

		def self.getting_contents_of_quoted_values(input)
			input.scan(/".*?"/).join
		end

		def get_delimiter(filename_or_sample)
			@line_num = 0
			@count = []
			if filename_or_sample.class == String
				if File::exists?(filename_or_sample)
		    		File.foreach(filename_or_sample) do |line|
		    			delimiters_for_line = count_occurances_delimiter(line)
		    			@count.push(delimiters_for_line)
		    			@line_num = @line_num + 1
		    			if @line_num == 5 # If input is a file, only top 5 rows considered for analysis
		    				break
		    			end
		    		end
		    		pick_max_occurance_delimiter
		    	else
		    		return FileNotFound.new
		    	end
	    	elsif filename_or_sample.class == Array
	    		filename_or_sample.each do |line|
	    			delimiters_for_line = count_occurances_delimiter(line)
		    		@count.push(delimiters_for_line)
	    			@line_num = @line_num + 1
	    		end
	    		pick_max_occurance_delimiter
	    	else
	    		return InvalidInput.new
	    	end

	    end

	    def count_occurances_delimiter(line)
	    	@delimiter = {"," => 0, ";" => 0, "\t" => 0, "|" => 0}
	    	esc_count = 0
	    		@delimiter.each {|key, value|
	    			line = line.to_s
	    			ini_count = line.substr_count(key)
	    			quoted_values = ColSeperator.getting_contents_of_quoted_values(line)
	    			esc_count = quoted_values.substr_count(key)
	    			value = ini_count - esc_count
	    			@delimiter[key] = value
	    		}
			return @delimiter
			#puts "\n#{line}\n #{@count}\n\n"
		end

		def pick_max_occurance_delimiter
			@delimiter.each_value { |val| val = 0 }
			i = 0
			@count.each do |hash|
				arr = hash.values
				value = @delimiter[hash.key(arr.max)]
				value = value + 1
				@delimiter[hash.key(arr.max)] = value
			end
			max_delimiter = ","
			max_value = -1
			@delimiter.each do |key, value|
				if max_value < value
					max_delimiter = key
					max_value = value
				end
			end
			return max_delimiter
		end
	end

	# col_sep = ColSeperator.new

	# #test = ["Year,Make,Model,Description,Price", "1997,Ford,E350,\"ac, abs, moon\",\"3000.00\"", "1999,Chevy,\"Venture \"\"Extended Edition, Very Large\"\"\",,5000.00"]

	# delimiter =  col_sep.get_delimiter("sample.csv")
	# if delimiter == "\t"
	# 	puts "Delimiter of input file is Tab"
	# else
	# 	puts "Delimiter of input file is #{delimiter}"
	# end

	# # delimiter = ColSeperator.get_delimiter(test)
	# # if delimiter == "\t"
	# # 	puts "Delimiter in given input is Tab"
	# # else
	# # 	puts "Delimiter in given input is #{delimiter}"
	# # end
