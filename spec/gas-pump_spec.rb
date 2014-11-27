require "gas-pump"
require "spec_helper"

describe GASPump do
	let(:agent)    { GASPump.new }
	let(:client)   { agent.client }
	let(:drive)    { agent.drive }
	let(:doc_file) { double("file", :title => "Document", 
																	:id => "1", 
																	:mimeType => "Doc", 
																	:ownerNames => "Me")
									}
	let(:gas_file) { double("file", :title => "GAS Project", 
																	:id => "2", 
																	:mimeType => "application/vnd.google-apps.script", 
																	:ownerNames => "Me",
																	:export_links => {"application/vnd.google-apps.script+json" => "www.fake.com"})
									}
	let(:all_drive_files) { Array.new }
	let(:response) { double("response", :code => 200,
																			:parsed_response => { "files" => [{ "id" => "123456",																				
																																					"name" => "Main",
																																					"type" => "server_js",
																																					"source" =>"some source"}]})}
	before(:each) do
		all_drive_files << doc_file
		all_drive_files << gas_file
		agent.all_projects = all_drive_files
		path = Dir.pwd
		agent.path = path+"/tmp"
	end

	it "has a client and a Google Drive" do
		expect(client.authorization.access_token).not_to eq nil
		expect(drive).not_to eq nil
	end

	it "can get a list of Google Apps Scripts files in Drive" do
		project_files = agent.retrieve_apps_script(all_drive_files)
		expect(project_files.length).to eq 1
	end

	it "can select a project" do
		file = agent.select_project("2")
		expect(file).to eq(gas_file)
	end

	it "can download a project" do
		agent.stub(:get_project).and_return(response)
  	output = capture_stdout { agent.download_project("2") }
  	expect(output).to eq("*** Connecting to Google Drive ***\n*** DOWNLOADING FILES ***\n*** Successfully downloaded Google Apps Script [ID: 2] to [\"#{agent.path}/GAS Project\"] ***\n")
	end

	it "can create a project hash for upload from old drive files" do
		agent.stub(:get_project).and_return(response)
		expect( agent.prepare_for_upload(gas_file, nil)).to eq({"files"=>[{"id"=>"123456", "name"=>"Main", "type"=>"server_js", "source"=>"some source"}]})
	end

	it "can create a project hash from new files" do
		dir_name = agent.create_directory("fake_directory")
		gas_project_data = response.parsed_response
		agent.create_files(dir_name, gas_project_data)
		expect( agent.prepare_for_upload("fake_directory", nil, false)).to eq({"files"=>[{"name"=>"Main", "type"=>"server_js", "source"=>"some source"}]})
	end


	def capture_stdout(&block)
	  original_stdout = $stdout
	  $stdout = fake = StringIO.new
	  begin
	    yield
	  ensure
	    $stdout = original_stdout
	  end
	  fake.string
	end
end