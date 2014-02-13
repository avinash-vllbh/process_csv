require 'csv'
require 'smarter_csv'

#csv_fname = 'sampleCSV.csv'

#using mode - wb de
=begin
csvwrite = CSV.open("testCSV.csv", "wb")

CSV.foreach("sampleCSV.csv") do |row|
	puts "\n This is a new row"
	puts row
	csvwrite << row
end
#end
header_row = false;
columns = 0;
begin
	CSV.foreach("sampleCSV.csv") do |row|
		if(header_row == false)
			columns = row.length
			header_row = true
		else
			if(columns != row.length)
				puts "given CSV file isn't square\n"
				puts "#{row}\n"
				puts "there are #{row.length} columns in this row"
			end
		end
	end
rescue Exception => e
		puts e
end

puts columns
=end
test_smart_csv = SmarterCSV.process('sampleCSV.csv')
puts test_smart_csv[0][:year]
puts "hello world".object_id
puts "hello world".object_id
puts :"hello world".object_id
puts :"hello world".object_id
puts Symbol.all_symbols.inspect


