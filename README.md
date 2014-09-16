# GAS Pump

A gem for importing, exporting, and creating new Google Apps Scripts from/to your Google Drive

## Installation

1. Clone this repo
2. Add your client_secrets.json file to the folder. Instructions are here: https://code.google.com/p/google-apps-manager/wiki/CreatingClientSecretsFile
3. You will also need an API key for server applications: 
 - You can get this from the [Console](https://console.developers.google.com) > APIs & auth > Credentials > Public API Access
 - Select "Create New Key", choose "Server Key", select "Create"
 - Set the API key as an ENV variable 
 -- on your terminal: `export GAS_API_KEY=YOUR_API_KEY`
4. To avoid having an invalid_client error:
 - Go [here](https://console.developers.google.com/project) 
 - Click on project name
 - Go to "APIs & auth" -> "Consent screen".
 - Write a project name and select your email address
5. `bundle install`
6. `rake install`

## Usage

`gas-pump <command> [<arg>]`
	  
Commands:
  list                   -- lists the Google Apps Scripts projects on your Google Drive
  download <PROJECT_ID>  -- downloads the project
  upload <PROJECT_ID>    -- uploads local changes to the project
  create <FOLDER_NAME>   -- creates the project

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gas-pump/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
