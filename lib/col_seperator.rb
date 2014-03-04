require 'csv'
require 'smarter_csv'
=begin
CSV.foreach("sample.csv") do |row|
	test = row.to_s
	puts test
	count = test.scan(/(",)/)
	puts count.size
end
=end
class SQLStructure
	def get_delimiter(filename)
		delimiters = Array[",",";","\t",'\|']
		line_num = 0
		count = Array.new(3) {Array.new}
		esc_count = 0

		File.foreach(filename) do |line|
			for i in 0..delimiters.length-1
				line = line.to_s	
				count[line_num][i] = line.scan(/(#{delimiters[i]})/).size != nil ? line.scan(/(#{delimiters[i]})/).size : 0
				escaped = line.scan(/".*?"/)
				esc_count = escaped.join.scan(/(#{delimiters[i]})/) != nil ? escaped.join.scan(/(#{delimiters[i]})/).size.to_i : 0
				count[line_num][i] = count[line_num][i] - esc_count
			end
			#puts "#{line}\n #{count}\n #{line_num}"
			line_num = line_num + 1
			if line_num > 2
				break
			end
		end

		delimiter = {"," => 0, ";" => 0, "\t" => 0, "|" => 0}
		i = 0
		count.each do |arr|
			if(delimiters[arr.index(arr.max)] == '\|')
				value = delimiter["|"]
				value = value + 1
				delimiter["|"] = value
			else
				value = delimiter[delimiters[arr.index(arr.max)]] 
				value = value + 1
				delimiter[delimiters[arr.index(arr.max)]] = value
			end
		end
		#print delimiter
		max_delimiter = ","
		max_value = -1
		delimiter.each do |key, value|
			if max_value < value
				max_delimiter = key
				max_value = value
			end
		end
		return max_delimiter
	end
end

=begin
sql = SQLStructure.new
delimiter = sql.get_delimiter("sample.csv")

puts delimiter


total_chunks = SmarterCSV.process("sample.csv", {:col_sep => delimiter, :chunk_size => 10, :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
				puts chunk
			end
=end

