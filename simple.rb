require 'smarter_csv'

total_chunks = SmarterCSV.process("testCSV.csv", {:chunk_size => 10, :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
				puts chunk
			end

=begin
	
rescue Exception => e
	
end$global_test = 100
#$gl_test
class Simple
	def hello
		puts "Hello Ruby!!"
		puts "global variable is global_test value is #$global_test"
	end
end

test = Simple.new
test.hello
puts "You just used an instance of class simple"

end

#Sample file operation

csvFile =  File.open("sampleCSV.csv") if File::exists?("sampleCSV.csv")
if csvFile 
	puts "able to access file successfully"
	content = csvFile.read
	puts content

else 
	puts "unable to open file"
end
bckupFile = File.new("testCSV.csv", "wb")
puts "\ncontent from sampleCSV.csv"
File.foreach("sampleCSV.csv") do |line| 
	#if (line =~ /\r\n/)
		puts line
		line = line.gsub(/\r\n/, "\n");
		bckupFile.puts("#{line}")
	#end
end
bckupFile.close

puts "\ncontent from testCSV.csv"
File.foreach("testCSV.csv") do |line|
	if(line =~ /\n$/)
		puts line
	end
end


#csv_fname = 'sampleCSV.csv'

#using mode - wb de
csvwrite = CSV.open("testCSV.csv", "wb")

CSV.foreach("sampleCSV.csv") do |row|
	puts "\n This is a new row"
	puts row
	csvwrite << row
end
header_row = false;
columns = 0;
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

def get_datatype(field)
	if(Integer(field) rescue false)
		return "int"
	elsif(Float(field) rescue false)
		return "float"
	elsif(Date.parse(field) rescue false)
		return "date"
	else
		return "string"
	end
end
hash_datatype = {"int" => 0, "float" => 0, "date" => 0, "string" => 0}
arr_details = Array.new(2){{"int" => 0, "float" => 0, "date" => 0, "string" => 0}}
#arr_details[0] = hash_datatype.to_a
#arr_details[1] = hash_datatype.to_a
puts hash_datatype.object_id
puts arr_details[0].object_id
puts arr_details[1].object_id
test = get_datatype("3")
value = arr_details[0][test]
arr_details[0][test] = value+1

puts arr_details
#puts hash_datatype
=end


