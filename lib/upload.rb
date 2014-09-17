module Upload
	def create_project(scripts_project, client=@client)
		puts "*** Connecting to Google Drive ***"
		if @api_key == nil
			puts "
			You don't have an API key set up for uploading. 
			You can get this from https://console.developers.google.com/project 
			(Console > APIs & auth > Credentials > Public API Access)
			Select \"Create New Key\", choose \"Server Key\", and select \"Create\"
			Type your API key:".gsub /^( |\t)+/, ""
			@api_key = STDIN.gets.chomp
			puts "!!! Please don't forget to set this as an ENV variable.\nTo do this, just run this command: export GAS_API_KEY=#{@api_key}"
			puts "*** Reconnecting you now!***"
			create_project(scripts_project)
		else
		  receiver = "https://www.googleapis.com/upload/drive/v2/files?convert=true&key="+@api_key
		  auth = "Bearer " + client.authorization.access_token
		  content = prepare_for_upload(scripts_project).to_json

		  response = HTTParty.post(receiver, :headers => { "Authorization" => auth, 
		  																							   "Content-Type" =>  "application/vnd.google-apps.script+json"}, 
		  																	 :body => content)

		  if response.code == 200
				puts "*** Successfully uploaded Google Apps Script. Google has renamed this file \"Untitled\" ***"
			else
				puts "*** Sorry, I can't upload the file. [code: #{response.code}, #{response.parsed_response}]***"
			end
		end
	end

	def upload_project(id, client=@client)
		puts "*** Connecting to Google Drive ***"

		scripts_project = select_project(id)

	  receiver = "https://www.googleapis.com/upload/drive/v2/files/"+scripts_project.id
	  auth = "Bearer " + client.authorization.access_token
	  content = prepare_for_upload(scripts_project).to_json

	  response = HTTParty.put(receiver, :headers => {"Authorization" => auth, 
	  																							"Content-Type" =>  "application/vnd.google-apps.script+json"}, 
	  																	:body => content)
		
		if response.code == 200
			puts "*** Successfully uploaded Google Apps Script [ID: #{id}] ***"
		else
			puts "*** Sorry, I can't upload the file. [code: #{response.code}, #{response.parsed_response}] ***"
		end
	end

	def prepare_for_upload(scripts_project)
		puts "*** PREPARING UPLOAD ***"
		directory_name = (scripts_project.is_a? String) ? scripts_project : scripts_project.title 
		project_id = (scripts_project.is_a? String) ? nil : scripts_project.id 

	  project_files = @path + "/" + directory_name + "/*.{gs,html}"
	  collected_file_data = []
	  files_for_upload = {}

	  if !project_id.nil?
	  	file = select_project(project_id)
	  	gas_project_data = get_project(file).parsed_response
	  end

	  Dir.glob(project_files) do |file|
	    file_name = File.basename(file,File.extname(file))
	    file_type = file_type(file)
	    file_source = IO.read(file)
	    file_id = !project_id.nil? ? find_old_file_id(file_name, gas_project_data) : nil
	    collected_file_data << create_file_data(file_name, file_type, file_source, file_id) 
	  end
	  files_for_upload["files"] = collected_file_data
	  files_for_upload
	end

	def create_file_data(file_name, file_type, file_source, file_id) 
		new_file_data = {}
	  new_file_data["id"] = file_id if !file_id.nil?
	  new_file_data["name"] = file_name
	  new_file_data["type"] = file_type
	  new_file_data["source"] = file_source
	  new_file_data
	end

	def file_type(file)
		file_extension = File.extname(file)
		if file_extension == ".gs"
			type = "server_js"
		else
			type = "html"
		end
		type
	end

	def find_old_file_id(file_name, gas_project_data)
	  list_of_files = gas_project_data["files"]
	  file = list_of_files.detect {|file| file["name"] == file_name}
	  file["id"]
	end

end