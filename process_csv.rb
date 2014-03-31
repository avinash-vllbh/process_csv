require 'optparse'
require_relative './lib/csv_processor'
require_relative './lib/col_seperator'
require_relative './lib/prepared_statement'
require_relative './lib/csv_cleaner'

options = {:input => nil, :output => "output.csv", :unique => 10, :chunk => 20}
parser = OptionParser.new do |opts|
			opts.banner = "Usage: process_csv.rb [options]"

			opts.on('-i', '--input filename', 'Input file name') do |input|
				options[:input] = input  # todo: be able to handle files not in the current directory
			end
			#   another option to control the output of the structured file 
			# opts.on('-s', '--output-structure filename', 'Output the file name') do |output|
			# 	options[:output] = output
			# end
			opts.on('-o', '--output-cleaned filename', 'Output the cleaned csv file name, defaults to current driectory proccessed_(filename).csv ') do |output|
				options[:output] = output
			end
			opts.on('-u', '--unique unique', 'No of Unique values you need, default: 10') do |unique|
				options[:unique] = unique
			end
			opts.on('-c', '--chunk size', 'Chunk size for predecting datatypes, default: 64') do |chunk|
				options[:chunk] = chunk
			end
			opts.on('-h', '--help', 'Displays Help') do
				puts opts
				exit
			end
		end
parser.parse!

# Input validations
filename = nil
if options[:input] == nil
	print " Requires a valid input file name! \n"
	puts parser
	exit
end 

flag = false
if(Integer(options[:unique]) rescue false)
else
	while not flag
		puts "Not a valid number for unique. Enter an integer"
		options[:unique] = gets.chomp
		puts options[:unique]
		if(Integer(options[:unique]) rescue false)
			flag = true		
		end
	end
end
flag = false
if(Integer(options[:chunk]) rescue false)
else
	while not flag
		puts "Not a valid number for chunk size. Enter an integer"
		options[:chunk] = gets.chomp
		puts options[:chunk]
		if(Integer(options[:chunk]) rescue false)
			flag = true		
		end
	end
end

input_file = options[:input]
chunk_size = options[:chunk]
no_of_unique = options[:unique]
output_file = options[:output]

#Obtain the delimeter
col_sep = ColSeperator.new
delimiter = col_sep.get_delimiter(input_file)
if delimiter == "\t"
	puts "Delimiter in given input is Tab"
else
	puts "Delimiter in given input is #{delimiter}"
end
csv_clean = CSVCleaner.new
csv_clean.process_csv(input_file,delimiter)
input_file = "processed_#{input_file}"

csv_process = CSVProcessor.new
csv_process.get_header_length(input_file,delimiter)
csv_process.initial_data_type(input_file,chunk_size,delimiter)
csv_process.process_csv_file(input_file, no_of_unique,delimiter)
csv_process.output_csv(output_file, no_of_unique)

prep_stat = PreparedStatement.new
sql_query_result = prep_stat.tbl_prepare_statement(output_file)
import_query = prep_stat.csv_import_statement(input_file,delimiter)
puts sql_query_result
puts import_query





