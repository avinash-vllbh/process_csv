require 'optparse'
require 'tco'
require_relative './lib/csv_processor'
require_relative './lib/col_seperator'
require_relative './lib/prepared_statement'
require_relative './lib/csv_cleaner'

options = {:input => nil, :metadata_output => nil, :processed_input => nil, :unique => 10, :chunk => 20, :skip => 0, :database => nil, :quote_convert => "YES", :replace_nulls => "NO"}
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
			opts.on('-d', '--database type', 'MySQL or Postgres, Options: M or P, default: nil(print nothing)') do |database_type|
				options[:database] = database_type.upcase
			end
			opts.on('-q', '--quotes conversion', 'Convert single quotes to double quotes, options: yes or no, default: yes') do |quote_convert|
				options[:quote_convert] = quote_convert.upcase
			end
			opts.on('-r', '--replace nulls', 'replace empty, Null\'s, \N, NAN with NULL, options: yes or no, default: yes') do |replace_nulls|
				options[:replace_nulls] = replace_nulls.upcase
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
if(Integer(options[:unique]) rescue false && options[:unique] >= 0)
else
	while not flag
		puts "Not a valid number for unique. Enter a positive integer"
		options[:unique] = gets.chomp
		puts options[:unique]
		if(Integer(options[:unique]) rescue false && options[:unique] >= 0)
			flag = true		
		end
	end
end
flag = false
if(Integer(options[:chunk]) rescue false && options[:chunk] >= 0)
else
	while not flag
		puts "Not a valid number for chunk size. Enter a positive integer"
		options[:chunk] = gets.chomp
		puts options[:chunk]
		if(Integer(options[:chunk]) rescue false && options[:chunk] >= 0)
			flag = true		
		end
	end
end
if options[:database_type] == "M" || options[:database_type] == "MYSQL"
	options[:database_type] = "M"
elsif options[:database_type] == "P" || options[:database_type] == "POSTGRESSQL" || options[:database_type] == "POSTGRES"
	options[:database_type] = "P"
else
	while options[:database_type] == "M" || options[:database_type] == "P"
		puts "Invalid option for Database Type. Enter M for MySQL or P for PostgresSQL".fg("#ff0000")
		options[:database_type] = gets.chomp.upcase
	end
end
#To verify the skip_lines argument data integrity
if options[:skip] >= 0
	skip_lines = options[:skip]
else
	while options[:skip] >= 0
		puts "Wrong input for skip lines! Enter a positive integer"
		options[:skip] = gets.chomp
	end
	skip_lines = options[:skip]
end

input_file = options[:input]
chunk_size = options[:chunk]
no_of_unique = options[:unique]
quotes_convert = options[:quote_convert]
replace_nulls = options[:replace_nulls]

replace_nulls = "YES" if replace_nulls == ""
replace_nulls = "YES" if replace_nulls == "Y"
replace_nulls = "NO" if replace_nulls == "N"
while replace_nulls != "YES" && replace_nulls != "NO"
	puts "Invalid input!! Enter either (Yes/no)".fg("#ff0000")
	replace_nulls = gets.chomp.upcase
	replace_nulls = "YES" if replace_nulls == ""
	replace_nulls = "YES" if replace_nulls == "Y"
	replace_nulls = "NO" if replace_nulls == "N"
end
quotes_convert = "YES" if quotes_convert == ""
quotes_convert = "YES" if quotes_convert == "Y"
quotes_convert = "NO" if quotes_convert == "N"
while quotes_convert != "YES" && quotes_convert != "NO"
	puts "Invalid input!! Enter either (Yes/no)".fg("#ff0000")
	quotes_convert = gets.chomp.upcase
	quotes_convert = "YES" if quotes_convert == ""
	quotes_convert = "YES" if quotes_convert == "Y"
	quotes_convert = "NO" if quotes_convert == "N"
end


if File::exists?(input_file)

	if(File.extname(input_file) == ".csv" || File.extname(input_file) == ".tsv" || File.extname(input_file) == ".dat")

		if options[:metadata_output] == nil

			output_file = Dir.pwd+"/"+"metadata_"+File.basename(input_file)
			if File::exists?(output_file)
				output_file = Dir.pwd+"/"+Time.new.strftime("%Y%m%d%H%M%S")+"_metadata_"+File.basename(input_file)
			end
		else
			output_file = options[:metadata_output]
		end
		if options[:processed_input] == nil
			processed_file_name = "processed_"+File.basename(input_file)
			if File::exists?(processed_file_name)
				processed_file_name = Dir.pwd+"/"+Time.new.strftime("%Y%m%d%H%M%S")+"_processed_"+File.basename(processed_file_name)
			end
		else
			processed_file_name = options[:processed_input]
		end

		#To clean the line endings
		#Replace CR (\r) used as line endings with \n
		file_base = File.basename(input_file)
		file_dir = File.dirname(processed_file_name)
		new_input_file = "#{file_dir}/new.#{file_base}".to_s
		#puts new_input_file
		csv_clean = CSVCleaner.new
		csv_clean.clean_line_endings(input_file,new_input_file)
		input_file = new_input_file
		#puts output_file
		#Obtain the delimeter
		input_file = new_input_file
		col_sep = ColSeperator.new
		delimiter = col_sep.get_delimiter(input_file)
		if delimiter == "\t"
			puts "Delimiter in given input is Tab"
		else
			puts "Delimiter in given input is #{delimiter}"
		end

		
		csv_clean.cleaner_csv(input_file,delimiter,processed_file_name,skip_lines,replace_nulls,quotes_convert)

		csv_process = CSVProcessor.new
		csv_process.get_header_length(processed_file_name,delimiter)
		csv_process.initial_data_type(processed_file_name,chunk_size,delimiter)
		csv_process.process_csv_file(processed_file_name, no_of_unique,delimiter)
		csv_process.output_csv(output_file, delimiter,no_of_unique,replace_nulls,quotes_convert)

		prep_stat = PreparedStatement.new
		my_sql_query,pg_sql_query = prep_stat.tbl_prepare_statement(output_file,input_file)
		my_import_query,pg_import_query = prep_stat.csv_import_statement(processed_file_name,delimiter,skip_lines)

		CSV.open(output_file, "a+") do |csv|
			csv << []
			csv << ["SQL Commands"]
			csv << ["Database Type", "MYSQL"]
			csv << ["CREATE TABLE STMT",my_sql_query]
			csv << ["IMPORT PROCESSED FILE STMT", my_import_query]
			csv << ["Database Type", "POSTGRES"]
			csv << ["CREATE TABLE STMT",pg_sql_query]
			csv << ["IMPORT PROCESSED FILE STMT", pg_import_query]			
		end
		if options[:database] == "M"
			puts "MySQL".fg("#ff0000")
			puts my_sql_query
			puts my_import_query
		elsif options[:database] == "P"
			puts "PostgresSQL".fg("#ff0000")
			puts pg_sql_query
			puts pg_import_query
		end

		#to delete the new.input file created during the process
		#File.delete(input_file)
	else
		puts "Please export the input file to CSV or TSV".fg("#ff0000")
	end
else
	puts "No such input file exists!!"
	puts parser
end