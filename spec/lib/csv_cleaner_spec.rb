require 'spec_helper'
require 'csv_cleaner'

describe CSVCleaner do
  let (:csv_clean) { CSVCleaner.new }

  fixture_path = 'spec/fixtures'

  describe 'cleaner_csv' do
  	context 'when input file doesn\'t exist' do
  		it 'return file not found for invalid file' do
  			csv_clean.cleaner_csv("input_sample.csv",",","processed_sample.csv").should be_an_instance_of(FileNotFound)
  		end
  	end
  	context 'when proper input file is submitted' do
  		xit 'thrown a csv error at line 2' do
  			replace_nulls = "YES"
  			replace_quotes = "YES"
  		end
  	end
  end
  
  describe 'replace_line_single_quotes' do
  	#Example fails when given wrong delimiter as input
  	it 'should fail for wrong delimiter' do
  		line = "hi,'hello',howru"
  		ret = "hi,\"hello\",howru"
  		expect(csv_clean.replace_line_single_quotes(line, "|")).to_not eq(ret)
  	end
  	it 'replaces single quotes to double quotes' do
  		line = "hi,'hello',howru"
  		ret = "hi,\"hello\",howru"
  		expect(csv_clean.replace_line_single_quotes(line,",")).to eq(ret)
  	end
  end

  describe 'replace_line_nulls' do
  	it 'check if it replaces nulls' do
  		line = ["null","hi","","test",nil]
  		ret = ["null","hi","NULL","test","NULL"]
  		expect(csv_clean.replace_line_nulls(line)).to eq(ret)
  	end
  end
end