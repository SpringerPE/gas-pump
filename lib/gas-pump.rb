require 'list'
require 'fetch'
require 'upload'
require 'fileutils'
require 'json'
require 'httparty'
require 'command_line_reporter'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'

class GASPump
	include List, Fetch, CommandLineReporter, Upload
	attr_accessor :client, :drive, :all_projects, :path, :api_key

	API_KEY = ENV['GAS_API_KEY']
	API_VERSION = 'v2'
	CACHED_API_FILE = "drive-#{API_VERSION}.cache"
	CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"
	DEFAULT_PATH = Dir.pwd

  def initialize
  	@client, @drive = setup
  	@all_files = retrieve_drive_files_list(@client, @drive)
  	@all_projects = retrieve_apps_script(@all_files)
  	@path = DEFAULT_PATH
  	@api_key = API_KEY
	end

	def setup
	  log_file = File.open('drive.log', 'a+')
	  log_file.sync = true
	  logger = Logger.new(log_file)
	  logger.level = Logger::DEBUG

	  client = Google::APIClient.new(:application_name => 'GAS Pump',
	      :application_version => '1.0.0')

	  # FileStorage stores auth credentials in a file, so they survive multiple runs
	  # of the application. This avoids prompting the user for authorization every
	  # time the access token expires, by remembering the refresh token.
	  # Note: FileStorage is not suitable for multi-user applications.
	  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
	  if file_storage.authorization.nil?
	  	puts "Please check your browser for authentication"
	    client_secrets = Google::APIClient::ClientSecrets.load
	    # The InstalledAppFlow is a helper class to handle the OAuth 2.0 installed
	    # application flow, which ties in with FileStorage to store credentials
	    # between runs.
	    flow = Google::APIClient::InstalledAppFlow.new(
	      :client_id => client_secrets.client_id,
	      :client_secret => client_secrets.client_secret,
	      :scope => ['https://www.googleapis.com/auth/drive', 'https://www.googleapis.com/auth/drive.scripts']
	    )
	    client.authorization = flow.authorize(file_storage)
	  else
	    client.authorization = file_storage.authorization
	  end

	  drive = nil
	  # Load cached discovered API, if it exists. This prevents retrieving the
	  # discovery document on every run, saving a round-trip to API servers.
	  if File.exists? CACHED_API_FILE
	    File.open(CACHED_API_FILE) do |file|
	      drive = Marshal.load(file)
	    end
	  else
	    drive = client.discovered_api('drive', API_VERSION)
	    File.open(CACHED_API_FILE, 'w') do |file|
	      Marshal.dump(drive, file)
	    end
	  end

	  return client, drive
	end

	

end
