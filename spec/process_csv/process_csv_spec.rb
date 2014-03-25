
require 'csv_processor'

describe CSVProcessor do 
  let (:csv_processor) { CSVProcessor.new }

  describe 'get_datatype' do
    it 'defaults to string' do # , :focus => true   # run with rspec spec --tag=focus
       expect(csv_processor.get_datatype('')).to eq("string")
       expect(csv_processor.get_datatype(nil)).to eq("string")
    end
    it 'knows what a string looks like' do
       expect(csv_processor.get_datatype('blah')).to eq("string")
    end
    it 'knows what an int looks like' do
       expect(csv_processor.get_datatype('10')).to eq("int")
       expect(csv_processor.get_datatype(' 10')).to eq("int")
       expect(csv_processor.get_datatype(' 10 ')).to eq("int")
       expect(csv_processor.get_datatype(' 9 ')).to eq("int")
    end
    it 'knows what a date looks like' do
       expect(csv_processor.get_datatype('1/2/3')).to eq("date")
       expect(csv_processor.get_datatype('//')).to eq("string")
       expect(csv_processor.get_datatype('1/2/')).to eq("date")
    end
    xit 'knows what a float looks like'
  end
  
end