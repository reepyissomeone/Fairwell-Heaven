# Fairwell Dev Bridge

Private backend for Fairwell Dev Lab.

## Environment variables

- `DEV_LAB_ADMIN_KEY` — secret used only by the private Fairwell Dev Bot to generate/rotate the Dev Lab password.
- `PORT` — optional; Render supplies this automatically.

Never commit passwords, Discord bot tokens, admin keys, OpenAI keys, GitHub tokens, or session tokens.

## Endpoints

### POST /admin/generate-password

Bot-only endpoint.

Requires:
`X-Dev-Admin-Key: <DEV_LAB_ADMIN_KEY>`

Generates a fresh random password, invalidates all existing sessions, stores only a scrypt hash, and returns the new password once.

The bot should immediately deliver that password privately to the owner.

### POST /auth

Body:
`{"password":"...","userId":123}`

Returns a short-lived bearer token when the current password is correct.

### POST /request

Header:
`Authorization: Bearer <token>`

Body: feature request JSON from Fairwell.

The backend validates, rate-limits, and accepts requests before any GitHub/Discord automation is added.

## Important

The Render environment must contain `DEV_LAB_ADMIN_KEY`. The value must never be committed to GitHub or placed in the Roblox script.
