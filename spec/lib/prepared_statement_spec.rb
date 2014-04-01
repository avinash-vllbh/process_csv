require 'prepared_statement'

fixture_path = 'spec/fixtures'

describe 'prepared_statement' do
	let(:prep_stmt) {PreparedStatement.new}
	describe 'tbl_prepare_statement' do
		it 'checks if input file is valid' do
			prep_stmt.tbl_prepare_statement('test.csv').should be_an_instance_of(FileNotFound)
		end
		it 'returns valid postgres SQL statement' do
			sql_query = "CREATE TABLE input ( year_id INT NOT NULL, make_id varchar NOT NULL, model_id varchar NOT NULL, description_id varchar, price_id INT NOT NULL, PRIMARY KEY ( id ));"
			expect(prep_stmt.tbl_prepare_statement("#{fixture_path}/test_prep_stmt.csv")).to eq(sql_query)
		end
	end
end