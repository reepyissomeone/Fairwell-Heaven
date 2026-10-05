# Fairwell Heaven Discord Bot

Stores feature suggestions directly in the Fairwell Heaven GitHub repository.

## Commands

- /suggest — creates a Markdown file under suggestions/.
- /suggestions — shows recent suggestion files to server managers.

## Environment variables

Required:
- DISCORD_TOKEN
- DISCORD_CLIENT_ID
- GITHUB_TOKEN

Optional:
- DISCORD_GUILD_ID — registers commands to one server immediately.
- GITHUB_REPO — defaults to reepyissomeone/Fairwell-Heaven.

## GitHub token permissions

Use a fine-grained token restricted to Fairwell-Heaven:
- Metadata: Read-only
- Contents: Read and write

Never commit the token or put it in Roblox code.

## Running

npm install
npm start
