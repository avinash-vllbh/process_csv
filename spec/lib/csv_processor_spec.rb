
require 'csv_processor'

describe CSVProcessor do 
  let (:csv_processor) { CSVProcessor.new }
  describe 'datetime_pattern' do
    it 'returns true for valid dates' do
      expect(csv_processor.datetime_pattern('1/2/2014')).to be_true
    end
    it 'returns false for valid dates' do
      expect(csv_processor.datetime_pattern('1014')).to be_false
    end
  end

  describe 'get_datatype' do
    it 'defaults to string' do # , :focus => true   # run with rspec spec --tag=focus
       expect(csv_processor.get_datatype('')).to eq("string")
       expect(csv_processor.get_datatype(nil)).to eq("string")
    end

    it 'knows what a string looks like' do
       expect(csv_processor.get_datatype('blah')).to eq("string")
       expect(csv_processor.get_datatype('string with spaces')).to eq("string")
    end

    context 'knows what an int looks like' do
      it 'when it has spaces' do
         expect(csv_processor.get_datatype('10')).to eq("int")
         expect(csv_processor.get_datatype(' 10')).to eq("int")
         expect(csv_processor.get_datatype('10 ')).to eq("int")
         expect(csv_processor.get_datatype(' 9 ')).to eq("int")
         expect(csv_processor.get_datatype('0')).to eq("int")
      end
      it 'when it has a comma' do
        expect(csv_processor.get_datatype('1,000')).to eq("int")
      end
      it 'when its negative' do 
        expect(csv_processor.get_datatype('-3')).to eq("int")
      end
    end

    context 'knows what a date looks like' do
      it 'that has slashes' do
        expect(csv_processor.get_datatype('1/2/3')).to eq("date")
        expect(csv_processor.get_datatype('//')).to eq("string")
        expect(csv_processor.get_datatype('1/2/')).to eq("date")
        expect(csv_processor.get_datatype('2014/2/1')).to eq("date")
      end
      it 'with spaces' do 
        expect(csv_processor.get_datatype('1 2 2014')).to eq("date")
       end
      it 'with dashes' do 
        expect(csv_processor.get_datatype('1-2-14')).to eq("date")
      end
    end

    context 'knows what a date time looks like' do
      it 'with timezone' do
         expect(csv_processor.get_datatype('2014-04-07T20:51:13.257Z')).to eq("datetime")
      end
      it 'that has dashes' do
         expect(csv_processor.get_datatype('2014-04-07 20:51:13')).to eq("datetime")
      end
    end

    context 'knows what a float looks like' do
      it "when it has a decimal" do
        expect(csv_processor.get_datatype('1.2')).to eq("float")
        expect(csv_processor.get_datatype('.2')).to eq("float")
      end
      it 'when it has a comma' do
        expect(csv_processor.get_datatype('1,000.9')).to eq("float")
      end
      it 'when its in scientific notation' do
        expect(csv_processor.get_datatype('-5.8932e+11')).to eq("float")
      end
    end

    it 'knows what NaN means' do
      expect(csv_processor.get_datatype("NaN")).to eq("string") 
    end
  end
  
end