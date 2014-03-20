class PreparedStatement
	def prepare_statement(filename)
		if File::exists?(filename)
			CSV.foreach(filename) do |line|
				print line
				puts "\n"
			end
		end
	end
end
