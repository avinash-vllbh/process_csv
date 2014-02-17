require_relative 'user'

describe User do
	it "should be in any role assigned to it" do
		user = User.new
		user.should be_in_role("assigned role")
	end
end