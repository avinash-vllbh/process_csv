require 'rubygems'
require 'bundler/setup'
require 'csv_processor'

Bundler.require(:default)

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

# require_relative '../process_csv.rb'

RSpec.configure do |config|

end
