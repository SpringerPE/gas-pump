module Fetch

  def download_project(id, client=@client)
    puts "*** Connecting to Google Drive ***"

    file = select_project(id)

    response = get_project(file)

    if response.code == 200
      puts "*** DOWNLOADING FILES ***"
      gas_project_data = response.parsed_response
      gas_project_data["id"] = id

      ## DO I NEED TO SAVE THE RESPONSE?
      # save_response(gas_project_data.to_json, "imported_data_#{id}")
      dir_name = create_directory(file.title)
      create_files(dir_name, gas_project_data)

      expected_number_of_files = gas_project_data["files"].length
      number_of_files = count_files(dir_name)
      puts "*** Successfully downloaded Google Apps Script [ID: #{id}] to #{dir_name} ***" if files_created?(expected_number_of_files, number_of_files)
    else
      puts "*** Unauthorized to download the file ***"
    end
  end

  def get_project(file, client=@client)
    json_url = file.export_links["application/vnd.google-apps.script+json"]
    auth = "Bearer " + client.authorization.access_token
    response = HTTParty.get(json_url, :headers => {"Authorization" => auth})
    response
  end

  def create_directory(name)
    save_folder = @path + "/#{name}"
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
