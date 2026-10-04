# Fairwell Dev Bridge

Private backend for Fairwell Dev Lab.

## Environment variables

- DEV_LAB_PASSWORD_HASH — scrypt hash generated with `node scripts/hash-password.mjs`
- DEV_LAB_SESSION_SECRET — long random secret used to sign short-lived session tokens
- PORT — optional, defaults to 8787

Never commit passwords, Discord tokens, OpenAI keys, GitHub tokens, or session secrets.

## Endpoints

POST /auth
- Body: {"password":"...","userId":123}
- Returns a short-lived bearer token when the password is correct.

POST /request
- Header: Authorization: Bearer <token>
- Body: feature request JSON from Fairwell.

The backend should validate, rate-limit, log, and queue requests before any GitHub write.
