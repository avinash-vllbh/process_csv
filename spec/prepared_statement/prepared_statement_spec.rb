require 'prepared_statement'

describe 'prepared_statement' do
	let(:prep_stmt) {PreparedStatement.new}
	describe 'prepare_statement' do
		it 'checks if input file is valid' do
			prep_stmt.prepare_statement('test.csv').should be_an_instance_of(FileNotFound)
		end
		it 'returns valid postgres SQL statement' do
			sql_query = "CREATE TABLE input (id INT NOT NULL AUTO_INCREMENT, year_id INT NOT NULL, make_id varchar NOT NULL, model_id varchar NOT NULL, description_id varchar, price_id INT NOT NULL, PRIMARY KEY ( id ));"
			expect(prep_stmt.prepare_statement('./spec/prepared_statement/test.csv')).to eq(sql_query)
		end
	end
end