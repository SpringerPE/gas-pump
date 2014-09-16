module Fetch

	def download_project(id, files_list=@all_projects, client=@client)
		"*** Connecting to Google Drive ***"
	  file = select_project(id, files_list)
	   
	  json_url = file.export_links["application/vnd.google-apps.script+json"]
	  auth = "Bearer " + client.authorization.access_token
	  response = HTTParty.get(json_url, :headers => {"Authorization" => auth})
		if response.code == 200
			puts "*** Downloading files ***"
			gas_project_data = response.parsed_response
			gas_project_data["id"] = id

		  save_response(gas_project_data.to_json, "imported_data_#{id}")
		  dir_name = create_directory(file.title)
		  create_files(dir_name, gas_project_data)

		  expected_number_of_files = gas_project_data["files"].length
		  number_of_files = count_files(dir_name)
		  puts "*** Successfully downloaded Google Apps Script [ID: #{id}] to #{dir_name} ***" if files_created?(expected_number_of_files, number_of_files)
		else
			puts "*** Unauthorized to download the file ***"
		end
	end

	def create_directory(name, path=@path)
		save_folder = path+"/#{name}"
	  FileUtils::mkdir_p(save_folder)
	end

	def create_files(dir_name, source_code)
	  source_code["files"].each do |script|
	  	file_name = script["name"]+".gs" if script["type"] == "server_js"
	  	file_name = script["name"]+".html" if script["type"] == "html"
		  File.open(File.join(dir_name, file_name), "w+") { |file| file.write(script["source"]) }
	  end
	end

	def save_response(response, name)
	  File.open(name+".json", "w+") { |file| file.write(response)}
	end

	def files_created?(expected_number_of_files, number_of_files)
		expected_number_of_files == number_of_files
	end

	def count_files(directory)
		Dir.glob(File.join(directory, '**', '*')).select { |file| File.file?(file) }.count
	end
end
