module List
	def retrieve_drive_files_list(client, drive)
	  result = Array.new
	  page_token = nil
	  begin
	    parameters = {}
	    if page_token.to_s != ''
	      parameters['pageToken'] = page_token
	    end
	    api_result = client.execute(
	      :api_method => drive.files.list,
	      :parameters => parameters)

	    if api_result.status == 200
	      files = api_result.data
	      result.concat(files.items)
	      page_token = files.next_page_token
	    else
	      puts "An error occurred: #{api_result.data['error'].inspect}"
	      page_token = nil
	    end
	  end while page_token.to_s != ''
	  result
	end

	def retrieve_apps_script(drive_files_list=@all_files)
	  drive_files_list.select { |file| file.mimeType == "application/vnd.google-apps.script"}
	end

	def create_table(files_list=@all_projects)
		files_list.each do |file|
			table(:border => true) do
				row do
					column('NAME', :width => 6)
					column(file.title, :width => 118)	
				end

				row do
					column('ID')
					column(file.id)
				end
				row do
					column('OWNERS')
					column(file.ownerNames)
				end
				row do
					column('LINK')
					column(file.alternateLink)
				end
			end
	  end
  end

	def select_project(id, files_list=@all_projects)
	  files_list.find { |file| file.id == id}
	end
end