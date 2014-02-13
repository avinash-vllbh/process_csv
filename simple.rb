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

=end

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
