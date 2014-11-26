# GAS Pump

A gem for importing, exporting, and creating new Google Apps Scripts from/to your Google Drive

## Installation

1. Clone this repo
2. Add your client_secrets.json file to the folder. Instructions are here: https://code.google.com/p/google-apps-manager/wiki/CreatingClientSecretsFile
3. To avoid having an invalid_client error:
 - Go [here](https://github.com/jay0lee/GAM/wiki/CreatingClientSecretsFile) 
 - Click on project name
 - Go to "APIs & auth" -> "Consent screen".
 - Write a project name and select your email address
4. `bundle install`
5. `rake install`
6. Optional: if you want to *create new files*, you will also need an API key for server applications:
  - You can get this from the [Console](https://console.developers.google.com) > APIs & auth > Credentials > Public API Access
  - Select "Create New Key", choose "Server Key", select "Create"
  - Set the API key as an ENV variable 
     - On your terminal: `export GAS_API_KEY=YOUR_API_KEY`
  - Note that Google will rename this as "Untitled". If you wish to have your own project name, we suggest creating an empty project file and uploading to that project file id.

## Usage

`gas-pump <command> [<arg>]`
	  
Commands:
  1. list                   -- lists the Google Apps Scripts projects on your Google Drive
  2. download <PROJECT_ID>  -- downloads the project
  3. upload <PROJECT_ID>    -- uploads local changes to the project
  4. create <FOLDER_NAME>   -- creates the project

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gas-pump/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
