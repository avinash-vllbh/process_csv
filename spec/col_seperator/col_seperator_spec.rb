
require 'spec_helper'
require 'col_seperator'

describe ColSeperator do
  let (:col_sep) { ColSeperator.new }

  describe 'get_delimiter' do
    it 'can identify invalid arguments' do
       ColSeperator.get_delimiter(10).should be_an_instance_of(InvalidInput)
    end
    it 'can tell if a file doesnt exist' do
      ColSeperator.get_delimiter('test.csv').should be_an_instance_of(FileNotFound)
    end

  end

end
