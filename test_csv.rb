require 'csv'
require 'set'
require 'smarter_csv'
header_length = 0
CSV.foreach("sampleCSV.csv") do |row|
	if(header_length == 0)
		header_length = row.length
	end
	break
end
puts header_length
for i in 0..header_length
	headers[i] = Set.new
end

total_chunks = SmarterCSV.process('sampleCSV.csv', {:chunk_size => 2, :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
	chunk.each do |row|
		row.each do |k,v|
			puts "#{k} => #{v}"
		end
		puts "#{row}\n\n"
	end
end

test = Set.new
arr = Array["hello", "hi", 1, 2]
test.merge(arr)
puts test.to_a

=begin
a = Array.new
test_smart_csv.each do |test|
	puts test
		test.each do |k,v|
			puts "#{k} => #{v}"

		end
end
nums = Array["hi","hello",3,5,6]
nums2 = Array[5,"hi"]


year = test_smart_csv.map { |x| x[:year] }.uniq
puts year
puts test_smart_csv.uniq
=end