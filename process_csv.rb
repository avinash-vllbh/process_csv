require 'csv'

class ProcessCSV
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
end

filename = ARGV[0]
#check if the file exists
if File::exists?(filename)
	csv_process = ProcessCSV.new
	csv_process.clean_line_endings(filename)
else
	puts "invalid filename"
end
