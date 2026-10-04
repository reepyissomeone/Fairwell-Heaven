import express from "express";
import crypto from "node:crypto";

const app = express();
app.use(express.json({ limit: "16kb" }));

const PORT = Number(process.env.PORT || 8787);
const ADMIN_KEY = process.env.DEV_LAB_ADMIN_KEY || "";

if (!ADMIN_KEY) {
  console.warn("Dev Bridge: DEV_LAB_ADMIN_KEY is not configured.");
}

let passwordHash = "";
const sessions = new Map();
const attempts = new Map();

const WINDOW_MS = 10 * 60 * 1000;
const MAX_ATTEMPTS = 8;
const SESSION_MS = 15 * 60 * 1000;

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString("hex");
  const derived = crypto.scryptSync(String(password), salt, 32);
  return `scrypt$${salt}$${derived.toString("hex")}`;
}

function verifyPassword(password) {
  const parts = String(passwordHash).split("$");
  if (parts.length !== 3 || parts[0] !== "scrypt") return false;

  const [, salt, expectedHex] = parts;
  const actual = crypto.scryptSync(String(password), salt, 32);
  const expected = Buffer.from(expectedHex, "hex");

  return expected.length === actual.length &&
    crypto.timingSafeEqual(actual, expected);
}

function makeToken() {
  const token = crypto.randomBytes(32).toString("base64url");
  sessions.set(token, Date.now() + SESSION_MS);
  return token;
}

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

function requireAdmin(req, res, next) {
  const supplied = String(req.headers["x-dev-admin-key"] || "");

  if (!ADMIN_KEY || supplied.length !== ADMIN_KEY.length ||
      !crypto.timingSafeEqual(Buffer.from(supplied), Buffer.from(ADMIN_KEY))) {
    return res.status(403).json({ error: "Admin authorization required." });
  }

  next();
}

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "Fairwell Dev Bridge" });
});

// Called only by the private Fairwell Dev Bot.
// Generates a new password, invalidates the old one, and returns the new
// password once so the bot can deliver it privately to the owner.
app.post("/admin/generate-password", requireAdmin, (_req, res) => {
  const password = crypto.randomBytes(18).toString("base64url");

  passwordHash = hashPassword(password);
  sessions.clear();

  res.json({
    password,
    expiresIn: 0,
    message: "New Dev Lab password generated. It is shown only once."
  });
});

app.post("/auth", (req, res) => {
  const key = String(req.ip || "unknown");

  if (rateLimited(key)) {
    return res.status(429).json({ error: "Too many attempts. Try again later." });
  }

  if (!passwordHash) {
    return res.status(503).json({ error: "No Dev Lab password has been generated yet." });
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

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Fairwell Dev Bridge listening on port ${PORT}`);
});
