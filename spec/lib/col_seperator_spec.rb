require 'col_seperator'
#require_relative '../../lib/col_seperator'

describe ColSeperator do
  let (:col_sep) { ColSeperator.new }

  describe 'substr_count' do
    let(:input) {"1997,Ford,|,\"ac, abs, moon\",\"3000.00\""}
    it 'can find number of delimiters' do
      expect(input.substr_count(',')).to eq(6)
    end
    it 'can find number of pipe as delimiters' do
      expect(input.substr_count('|')).to eq(1)
    end
  end

  describe 'getting_contents_of_quoted_values' do
    let(:input) {"1997,Ford,,\"ac, abs, moon\",\"3000.00\""} #declaring input as global to describe block
    it 'return data between double quotes' do
      #input = "1997,Ford,,\"ac, abs, moon\",\"3000.00\""#input is local to just the it block
      output = "\"ac, abs, moon\"\"3000.00\""
      expect(ColSeperator.getting_contents_of_quoted_values(input)).to eq(output)
    end
    it 'return error with mis-match' do
      output = "\"ac, abs,moon\"\"3000.00\""
      expect(ColSeperator.getting_contents_of_quoted_values(input)).to_not eq(output)
    end
  end

  describe 'get_delimiter' do
    it 'can identify invalid arguments' do
       col_sep.get_delimiter(10).should be_an_instance_of(InvalidInput)
    end
    it 'can tell if a file doesnt exist' do
      col_sep.get_delimiter('test.csv').should be_an_instance_of(FileNotFound)
    end

  end
  
  describe 'count_occurances_delimiter' do
    let(:input) {"1997,Ford,,\"ac, abs, moon\",\"3000.00\""}
  	it 'return correct number of delimiters' do
      test = col_sep.count_occurances_delimiter(input)
      expect(test[","]).to eq(4)
  	end
  end
  describe 'pick_max_occurance_delimiter' do
    context 'given good data' do 
      before do
        col_sep.instance_variable_set(:@delimter, {"," => 0, ";" => 0, "\t" => 0, "|" => 0})
    #  	let(:@count) {[{","=>4,";" => 0, "\t" => 0,"|"=>2},{","=>2,";" => 0, "\t" => 0,"|"=>2},{","=>4,";" => 0, "\t" => 0,"|"=>2}]}
    #    let(:@delimiter) {{"," => 0, ";" => 0, "\t" => 0, "|" => 0}}
      end
      it 'can pick the delimiter with maximum occurance' do
        col_sep.instance_variable_set(:@count, [{","=>4,"|"=>2},{","=>2,"|"=>2},{","=>4,"\t"=>2}])
        expect(col_sep.pick_max_occurance_delimiter).to eq(",")
      end
      xit 'can pick a delimiter given crappy data' do
        col_sep.instance_variable_set(:@count, [{","=>4,"|"=>4},{","=>4,"|"=>4},{","=>4,"\t"=>4}])
        expect(col_sep.pick_max_occurance_delimiter).to eq(",")
      end
    end
  end
end
