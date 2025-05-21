# Google Drive MCP Authentication

This document provides detailed instructions for setting up authentication for the Google Drive MCP integration.

## Overview

The Google Drive MCP server allows MCP clients (like Amazon Q, Claude, or other AI assistants) to:
- List, search, and access files in your Google Drive
- Create, update, and delete files in your Google Drive
- Perform operations on your Google Drive via natural language prompts

Authentication is done using OAuth 2.0 through Google Cloud Console. The integration requires three credentials:
1. Client ID
2. Client Secret
3. Refresh Token

## Prerequisites

- Google account with Google Drive access
- Docker installed on your system
- Access to Google Cloud Console (https://console.cloud.google.com/)
- Basic knowledge of terminal/command-line operations

## OAuth Credential Setup

Follow these steps to set up your Google Drive API credentials:

1. **Create a Google Cloud Project**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Click "Select a project" at the top, then "NEW PROJECT"
   - Name your project (e.g., "MCP Google Drive Integration")
   - Click "CREATE"

2. **Enable the Google Drive API**:
   - Select your new project
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Drive API"
   - Click on "Google Drive API" and then "ENABLE"

3. **Configure OAuth Consent Screen**:
   - Go to "APIs & Services" > "OAuth consent screen"
   - Select "External" (unless you have a Google Workspace organization)
   - Fill in the required application information:
     - App name: "MCP Google Drive"
     - User support email: Your email
     - Developer contact information: Your email
   - Click "SAVE AND CONTINUE"
   - Add scopes: Search for "drive" and select ".../auth/drive"
   - Click "SAVE AND CONTINUE"
   - Add any test users (your Google account email)
   - Click "SAVE AND CONTINUE" then "BACK TO DASHBOARD"

4. **Create OAuth Credentials**:
   - Navigate to "APIs & Services" > "Credentials"
   - Click "CREATE CREDENTIALS" > "OAuth client ID"
   - Application type: "Desktop app"
   - Name: "MCP Google Drive Client"
   - Click "CREATE"
   - Note down your Client ID and Client Secret (you'll need these later)

## Generating a Refresh Token

Once you have your Client ID and Client Secret, you need to generate a refresh token:

1. **Install Google OAuth Library**:
   ```bash
   pip install google-auth google-auth-oauthlib
   ```

2. **Create a token generation script**:
   ```bash
   mkdir -p ~/tmp/gdrive-oauth
   cd ~/tmp/gdrive-oauth
   ```

   Create a file named `get_refresh_token.py` with the following content:
   ```python
   from google_auth_oauthlib.flow import InstalledAppFlow

   # Create credentials.json with your Client ID and Client Secret
   # Example:
   # {
   #   "installed": {
   #     "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
   #     "client_secret": "YOUR_CLIENT_SECRET"
   #   }
   # }

   # Set up the OAuth 2.0 flow
   flow = InstalledAppFlow.from_client_secrets_file(
       'credentials.json',
       scopes=['https://www.googleapis.com/auth/drive']
   )

   # Run the flow
   credentials = flow.run_local_server(port=0)

   # Print the refresh token
   print("\nRefresh Token:\n" + credentials.refresh_token)
   ```

3. **Create credentials file**:
   Create a file named `credentials.json` with the following content:
   ```json
   {
     "installed": {
       "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
       "client_secret": "YOUR_CLIENT_SECRET"
     }
   }
   ```
   Replace `YOUR_CLIENT_ID` and `YOUR_CLIENT_SECRET` with the values from step 4 above.

4. **Run the script**:
   ```bash
   python get_refresh_token.py
   ```
   - This will open a browser window asking you to log in to your Google account
   - Grant the requested permissions
   - The script will output a refresh token

## Environment Variable Configuration

Once you have all three credentials (Client ID, Client Secret, and Refresh Token), you need to add them to your environment:

1. **Edit your secrets file**:
   ```bash
   nano ~/.bash_secrets
   ```

2. **Add the following lines**:
   ```bash
   export GOOGLE_DRIVE_CLIENT_ID="your_client_id"
   export GOOGLE_DRIVE_CLIENT_SECRET="your_client_secret"
   export GOOGLE_DRIVE_REFRESH_TOKEN="your_refresh_token"
   ```
   Replace the placeholder values with your actual credentials.

3. **Apply the changes**:
   ```bash
   source ~/.bash_secrets
   ```

## Token Storage Location

- **Environment Variables**: Your credentials are stored in environment variables loaded from `~/.bash_secrets`
- **File Permissions**: Ensure your `.bash_secrets` file has appropriate permissions:
  ```bash
  chmod 600 ~/.bash_secrets
  ```
- **Docker Container**: When the MCP server runs, the credentials are passed to the Docker container as environment variables, not stored in the container filesystem

## Verification Steps

To verify that your Google Drive MCP integration is working correctly:

1. **Check environment variables**:
   ```bash
   echo $GOOGLE_DRIVE_CLIENT_ID
   echo $GOOGLE_DRIVE_CLIENT_SECRET
   echo $GOOGLE_DRIVE_REFRESH_TOKEN
   ```
   Each command should display the corresponding credential value.

2. **Run a test command**:
   - Start or restart your MCP client (e.g., Amazon Q CLI)
   - Try a simple query like: "List my recent Google Drive files"

3. **Check Docker logs if needed**:
   ```bash
   # Find the container ID
   docker ps | grep gdrive
   
   # Check logs
   docker logs <container_id>
   ```

4. **Troubleshooting**:
   - If you see "Error: Missing Google Drive credentials in ~/.bash_secrets", ensure the environment variables are correctly set
   - If you see authentication errors, verify that the credentials are correct
   - If the token is expired, generate a new refresh token

## Additional Resources

- [Google Drive API Documentation](https://developers.google.com/drive/api/v3/about-sdk)
- [OAuth 2.0 for Mobile & Desktop Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)