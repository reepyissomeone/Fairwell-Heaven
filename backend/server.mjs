import express from "express";
import crypto from "node:crypto";

const app = express();
app.use(express.json({ limit: "16kb" }));

const PORT = Number(process.env.PORT || 8787);
const PASSWORD_HASH = process.env.DEV_LAB_PASSWORD_HASH || "";
const SESSION_SECRET = process.env.DEV_LAB_SESSION_SECRET || "";

if (!PASSWORD_HASH || !SESSION_SECRET) {
  console.warn("Dev Bridge: required secrets are not configured.");
}

const attempts = new Map();
const sessions = new Map();
const WINDOW_MS = 10 * 60 * 1000;
const MAX_ATTEMPTS = 8;
const SESSION_MS = 15 * 60 * 1000;

function rateLimited(key) {
  const now = Date.now();
  const item = attempts.get(key);
  if (!item || now - item.start > WINDOW_MS) {
    attempts.set(key, { start: now, count: 1 });
    return false;
  }
  item.count++;
  return item.count > MAX_ATTEMPTS;
}

function verifyPassword(password) {
  // Hash format: scrypt$<salt>$<derived-key>
  const parts = String(PASSWORD_HASH).split("$");
  if (parts.length !== 3 || parts[0] !== "scrypt") return false;
  const [, salt, expectedHex] = parts;
  const actual = crypto.scryptSync(String(password), salt, 32);
  const expected = Buffer.from(expectedHex, "hex");
  return expected.length === actual.length && crypto.timingSafeEqual(actual, expected);
}

function makeToken() {
  const token = crypto.randomBytes(32).toString("base64url");
  sessions.set(token, Date.now() + SESSION_MS);
  return token;
}

function requireSession(req, res, next) {
  const auth = String(req.headers.authorization || "");
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  const expires = sessions.get(token);

  if (!token || !expires || expires < Date.now()) {
    sessions.delete(token);
    return res.status(401).json({ error: "Unauthorized." });
  }

  next();
}

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "Fairwell Dev Bridge" });
});

app.post("/auth", (req, res) => {
  const key = String(req.ip || "unknown");

  if (rateLimited(key)) {
    return res.status(429).json({ error: "Too many attempts. Try again later." });
  }

  if (!PASSWORD_HASH || !SESSION_SECRET) {
    return res.status(503).json({ error: "Authentication is not configured." });
  }

  const password = req.body?.password;
  if (typeof password !== "string" || password.length < 1 || password.length > 256) {
    return res.status(401).json({ error: "Incorrect password." });
  }

  if (!verifyPassword(password)) {
    return res.status(401).json({ error: "Incorrect password." });
  }

  const token = makeToken();
  res.json({ token, expiresIn: SESSION_MS / 1000 });
});

app.post("/request", requireSession, (req, res) => {
  const body = req.body;

  if (!body || typeof body !== "object") {
    return res.status(400).json({ error: "Invalid request." });
  }

  const featureName = String(body.FeatureName || "").trim();
  const description = String(body.Description || "").trim();

  if (!featureName || !description) {
    return res.status(400).json({ error: "FeatureName and Description are required." });
  }

  if (featureName.length > 120 || description.length > 8000) {
    return res.status(413).json({ error: "Request is too large." });
  }

  // Safe default: accept/queue only. GitHub/Discord automation is intentionally
  // not connected until an approval workflow is added.
  console.log(JSON.stringify({
    type: "feature-request",
    featureName,
    description,
    target: String(body.Target || "GLOBAL").slice(0, 80),
    hubVersion: String(body.HubVersion || "unknown").slice(0, 40),
    timestamp: new Date().toISOString()
  }));

  res.status(202).json({ accepted: true, message: "Feature request accepted by the Dev Bridge." });
});

app.listen(PORT, () => {
  console.log(`Fairwell Dev Bridge listening on port ${PORT}`);
});
