require 'optparse'
require_relative './lib/csv_processor'
require_relative './lib/col_seperator'
require_relative './lib/prepared_statement'
require_relative './lib/csv_cleaner'

options = {:input => nil, :metadata_output => nil, :processed_input => nil, :unique => 10, :chunk => 20, :skip => 0}
parser = OptionParser.new do |opts|
			opts.banner = "Usage: process_csv.rb [options]"

			opts.on('-i', '--input filename', 'Input file name') do |input|
				options[:input] = input  # todo: be able to handle files not in the current directory
			end
			opts.on('-m', '--output-structure filename', 'Output the metadata of file') do |metadata_output|
				options[:metadata_output] = metadata_output
			end
			opts.on('-o', '--output-cleaned filename', 'Output the cleaned csv file name, defaults to current driectory proccessed_(filename).csv ') do |processed_input|
				options[:processed_input] = processed_input
			end
			opts.on('-u', '--unique unique', 'No of Unique values you need, default: 10') do |unique|
				options[:unique] = unique
			end
			opts.on('-c', '--chunk size', 'Chunk size for predecting datatypes, default: 64') do |chunk|
				options[:chunk] = chunk
			end
			opts.on('-s', '--skip lines', 'skip the number of lines at the top, default: 0') do |skip|
				options[:skip] = skip
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
skip_lines = options[:skip]

if File::exists?(input_file)

	#puts File.basename(input_file)
	#puts File.absolute_path(input_file)
	if options[:metadata_output] == nil
		output_file = Dir.pwd+"/output.csv"
	else
		output_file = options[:metadata_output]
	end
	#puts output_file
	#Obtain the delimeter
	col_sep = ColSeperator.new
	delimiter = col_sep.get_delimiter(input_file)
	if delimiter == "\t"
		puts "Delimiter in given input is Tab"
	else
		puts "Delimiter in given input is #{delimiter}"
	end
	if options[:processed_input] == nil
		processed_file_name = "processed_"+File.basename(input_file)
	else
		processed_file_name = options[:processed_input]
	end
	csv_clean = CSVCleaner.new
	csv_clean.cleaner_csv(input_file,delimiter,processed_file_name,skip_lines)

	csv_process = CSVProcessor.new
	csv_process.get_header_length(processed_file_name,delimiter)
	csv_process.initial_data_type(processed_file_name,chunk_size,delimiter)
	csv_process.process_csv_file(processed_file_name, no_of_unique,delimiter)
	csv_process.output_csv(output_file, no_of_unique)

	prep_stat = PreparedStatement.new
	sql_query_result = prep_stat.tbl_prepare_statement(output_file,input_file)
	import_query = prep_stat.csv_import_statement(input_file,delimiter)
	puts sql_query_result
	puts import_query
else
	puts "No such input file exists!!"
	puts parser
end