RSpec.configure do |config|
	config.after(:suite) do # or :each or :all
		FileUtils.rm_rf(Dir["#{Dir.pwd}/tmp/"])
	end
end