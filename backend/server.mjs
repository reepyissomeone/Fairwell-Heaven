import express from "express";
import crypto from "node:crypto";

const app = express();
app.use(express.json({ limit: "16kb" }));

const PORT = Number(process.env.PORT || 8787);
const ADMIN_KEY = process.env.DEV_LAB_ADMIN_KEY || "";
const GITHUB_TOKEN = process.env.GITHUB_TOKEN || "";
const GITHUB_REPO = process.env.GITHUB_REPO || "reepyissomeone/Fairwell-Heaven";

if (!ADMIN_KEY) console.warn("Dev Bridge: DEV_LAB_ADMIN_KEY is not configured.");
if (!GITHUB_TOKEN) console.warn("Dev Bridge: GITHUB_TOKEN is not configured.");

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

async function createGitHubIssue({ featureName, description, target, hubVersion, timestamp }) {
  if (!GITHUB_TOKEN) {
    return { configured: false };
  }

  const response = await fetch(
    `https://api.github.com/repos/${GITHUB_REPO}/issues`,
    {
      method: "POST",
      headers: {
        "Accept": "application/vnd.github+json",
        "Authorization": `Bearer ${GITHUB_TOKEN}`,
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/json",
        "User-Agent": "Fairwell-Dev-Bridge"
      },
      body: JSON.stringify({
        title: `[Fairwell Dev] ${featureName}`,
        body: [
          "## Fairwell Dev request",
          "",
          `**Target:** ${target}`,
          `**Hub version:** ${hubVersion}`,
          `**Submitted:** ${timestamp}`,
          "",
          "### Description",
          description,
          "",
          "---",
          "This issue was created automatically by the private Fairwell Dev Bridge.",
          "Do not merge or deploy changes from this request automatically."
        ].join("\n")
      })
    }
  );

  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    const message = typeof data.message === "string" ? data.message : "GitHub request failed.";
    throw new Error(`GitHub API ${response.status}: ${message}`);
  }

  return {
    configured: true,
    issueNumber: data.number,
    issueUrl: data.html_url
  };
}

app.get("/health", (_req, res) => {
  res.json({
    ok: true,
    service: "Fairwell Dev Bridge",
    githubConfigured: Boolean(GITHUB_TOKEN)
  });
});

// Called only by the private Fairwell Dev Bot.
// The bot chooses the password and sends it here over the admin-protected route.
// Only a hash is kept by the backend.
app.post("/admin/set-password", requireAdmin, (req, res) => {
  const password = req.body?.password;

  if (typeof password !== "string" || password.length < 12 || password.length > 256) {
    return res.status(400).json({
      error: "Password must be between 12 and 256 characters."
    });
  }

  passwordHash = hashPassword(password);
  sessions.clear();
  attempts.clear();

  res.json({
    ok: true,
    message: "Dev Lab password updated. Existing sessions were invalidated."
  });
});

app.post("/auth", (req, res) => {
  const key = String(req.ip || "unknown");

  if (rateLimited(key)) {
    return res.status(429).json({ error: "Too many attempts. Try again later." });
  }

  if (!passwordHash) {
    return res.status(503).json({ error: "No Dev Lab password has been set yet." });
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

app.post("/request", requireSession, async (req, res) => {
  const body = req.body;

  if (!body || typeof body !== "object") {
    return res.status(400).json({ error: "Invalid request." });
  }

  const featureName = String(body.FeatureName || "").trim();
  const description = String(body.Description || "").trim();
  const target = String(body.Target || "GLOBAL").trim().slice(0, 80) || "GLOBAL";
  const hubVersion = String(body.HubVersion || "unknown").trim().slice(0, 40) || "unknown";

  if (!featureName || !description) {
    return res.status(400).json({ error: "FeatureName and Description are required." });
  }

  if (featureName.length > 120 || description.length > 8000) {
    return res.status(413).json({ error: "Request is too large." });
  }

  const timestamp = new Date().toISOString();

  console.log(JSON.stringify({
    type: "feature-request",
    featureName,
    description,
    target,
    hubVersion,
    timestamp
  }));

  try {
    const github = await createGitHubIssue({
      featureName,
      description,
      target,
      hubVersion,
      timestamp
    });

    if (!github.configured) {
      return res.status(202).json({
        accepted: true,
        github: false,
        message: "Feature request accepted by the Dev Bridge. GitHub is not configured yet."
      });
    }

    return res.status(202).json({
      accepted: true,
      github: true,
      issueNumber: github.issueNumber,
      issueUrl: github.issueUrl,
      message: "Feature request accepted and added to GitHub."
    });
  } catch (error) {
    console.error("GitHub issue creation failed:", error);

    return res.status(502).json({
      accepted: false,
      github: false,
      error: "The request was authenticated, but GitHub could not accept it."
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Fairwell Dev Bridge listening on port ${PORT}`);
});
