require "gasagent"

describe GASAgent do
	let(:agent)    { GASAgent.new }
	let(:client)   { agent.client }
	let(:drive)    { agent.drive }
	let(:doc_file) { double("file", :title => "Document", 
																	:id => 1, 
																	:mimeType => "Doc", 
																	:ownerNames => "Me")
									}
	let(:gas_file) { double("file", :title => "GAS Project", 
																	:id => 2, 
																	:mimeType => "application/vnd.google-apps.script", 
																	:ownerNames => "Me",
																	:export_links => {"application/vnd.google-apps.script+json" => "www.fake.com"})
									}
	let(:all_drive_files) { Array.new }
	let(:response) { double("response", :code => 200,
																			:parsed_response => { "files" => [{ :id => "123456",																				
																																					:name => "Main",
																																					:type => "server_js",
																																					:source =>"some source"}]})}
	before(:each) do
		all_drive_files << doc_file
		all_drive_files << gas_file
	end

	it "has a client and a Google Drive" do
		expect(client.authorization.access_token).not_to eq nil
		expect(drive).not_to eq nil
	end

	it "can get a list of Google Apps Scripts files in Drive" do
		project_files = agent.retrieve_apps_script(all_drive_files)
		expect(project_files.length).to eq 1
	end

	it "prints a list of files and their IDs" do
		file1 = double("file", :title => "Untitled", :id => 1, :mimeType => "Doc", :ownerNames => "Me")
		list = Array.new(1) {file1}
		expect(agent.summarize(list)).to eq ["Name: \"Untitled\" \nID: 1 \nmimeType: Doc \nOwners: Me\n"]
	end

	it "can select a project" do
		file = agent.select_project(2, all_drive_files)
		expect(file).to eq(gas_file)
	end

	it "can download a project" do
		HTTParty.stub(:get).and_return(response)
  	agent.stub(:save_response)
  	agent.stub(:create_directory)
  	agent.stub(:create_files)
  	agent.stub(:count_files).and_return(1)
  	expect(agent.download_project(2, all_drive_files)).to eq "*** Successfully downloaded Google Apps Script [ID: 2] ***"
	end
end