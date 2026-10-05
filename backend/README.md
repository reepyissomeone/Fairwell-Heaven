# Fairwell Dev Bridge

Private backend for Fairwell Dev Lab.

## Environment variables

- `DEV_LAB_ADMIN_KEY` — secret used only by the private Fairwell Dev Bot to set the Dev Lab password.
- `GITHUB_TOKEN` — GitHub fine-grained token used by the backend to create Fairwell Dev request issues.
- `GITHUB_REPO` — legacy repository setting. The Dev Lab request route now sends suggestions to the Discord bot instead of creating GitHub issues directly.
- `BOT_SUGGESTION_URL` — public HTTPS URL of the Python Discord bot suggestion endpoint.
- `BOT_SUGGESTION_SECRET` — shared secret between the backend and Python Discord bot.
- `PORT` — optional; Render supplies this automatically.

Never commit passwords, Discord bot tokens, admin keys, OpenAI keys, GitHub tokens, or session tokens.

## Endpoints

### POST /admin/set-password

Bot-only endpoint.

Requires:
`X-Dev-Admin-Key: <DEV_LAB_ADMIN_KEY>`

Body:
`{"password":"..." }`

The backend stores only a scrypt password hash and invalidates all existing sessions. The plaintext password is never written to GitHub or backend logs.

The private Fairwell Dev Bot should restrict this command to the owner Discord account before calling this endpoint.

### POST /auth

Body:
`{"password":"...","userId":123}`

Returns a short-lived bearer token when the current password is correct.

### POST /request

Header:
`Authorization: Bearer <token>`

Body: feature request JSON from Fairwell.

The backend forwards the authenticated request to the Discord bot. The bot is responsible for creating `suggestions/<feature>.md` in GitHub. The backend never sends GitHub or Discord credentials to Roblox.

## GitHub permissions

For the initial integration, use a GitHub fine-grained token restricted to the `Fairwell-Heaven` repository.

Grant only the permissions needed for the request queue:
- Metadata: Read-only
- Issues: Read and write

Do not give the backend account full repository administration or Actions administration.

## Important

Render must contain `DEV_LAB_ADMIN_KEY` and `GITHUB_TOKEN` as environment variables. Neither value belongs in GitHub or the Roblox script.

The password hash and active sessions are currently held in memory. A Render restart clears them, so the owner will need to use the bot's password command again after a restart.
