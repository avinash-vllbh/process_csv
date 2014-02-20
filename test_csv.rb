require 'csv'
require 'set'
require 'smarter_csv'
no_of_columns = 0
no_of_rows = 0
CSV.foreach("sampleCSV.csv") do |row|
	if(no_of_columns == 0)
		no_of_columns = row.length
		puts row
	end
	break
end

def get_datatype(field)
	if(Integer(field) rescue false)
		return "int"
	elsif(Float(field) rescue false)
		return "float"
	elsif(Date.parse(field) rescue false)
		puts field
		return "date"
	else
		return "string"
	end
end

headers = Array.new
get_keys = false
arr_unique = Array.new{hash.new}
#hash_datatype = {"int" => 0, "float" => 0, "date" => 0, "string" => 0}
arr_details = Array.new(no_of_columns){{"int" => 0, "float" => 0, "date" => 0, "string" => 0}}
total_chunks = SmarterCSV.process('sampleCSV.csv', {:chunk_size => 200, :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
	#puts chunk
	if(get_keys == false)
		chunk.each do |row|	
			headers = row.keys
			#puts headers[0].to_sym
			get_keys = true
			break
		end
	end
	for i in 0..headers.length-1
		arr = chunk.map{|x| x[headers[i].to_sym]}
		if(arr_unique[i].to_a.empty?)
			arr_unique[i] = arr
			#arr_details.push(hash_datatype)
			arr.each do |field|
				field_type = get_datatype(field)
				count = arr_details[i][field_type]
				arr_details[i][field_type] = count+1
			end
		else
			arr_unique[i] |= arr
			arr.each do |field|
				field_type = get_datatype(field)
				count = arr_details[i][field_type]
				arr_details[i][field_type] = count+1
			end
		end
	end
end

puts arr_details
=begin
test = Set.new
arr = {"hello"=>0, "hi"=>1}
test.merge(arr)
puts test.to_a
h = Hash[test.each_slice(1).to_a]
puts h

arr_test = Array.new{hash.new}
browsers = {'Chrome'=>1, 'Firefox'=>1, 'Safari'=>2, 'Opera'=>3, 'IE'=>4}
testsss = {'Ch'=>0, 'Fi'=>0, 'Sa'=>0, 'Op'=>0, 'IE'=>0}

arr_test << browsers
arr_test << testsss

arr_test[0].merge!('ch'=>100, 'test'=>50, 'ttt'=>100)

puts arr_test[0]

#test_set = arr_test[]

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