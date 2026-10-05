const {
  Client,
  GatewayIntentBits,
  REST,
  Routes,
  SlashCommandBuilder,
  PermissionFlagsBits
} = require("discord.js");

const DISCORD_TOKEN = process.env.DISCORD_TOKEN || "";
const DISCORD_CLIENT_ID = process.env.DISCORD_CLIENT_ID || "";
const DISCORD_GUILD_ID = process.env.DISCORD_GUILD_ID || "";
const GITHUB_TOKEN = process.env.GITHUB_TOKEN || "";
const GITHUB_REPO = process.env.GITHUB_REPO || "reepyissomeone/Fairwell-Heaven";

if (!DISCORD_TOKEN) throw new Error("DISCORD_TOKEN is missing.");
if (!DISCORD_CLIENT_ID) throw new Error("DISCORD_CLIENT_ID is missing.");
if (!GITHUB_TOKEN) throw new Error("GITHUB_TOKEN is missing.");

const [OWNER, REPO] = GITHUB_REPO.split("/");
if (!OWNER || !REPO) throw new Error("GITHUB_REPO must be owner/name.");

const commands = [
  new SlashCommandBuilder()
    .setName("suggest")
    .setDescription("Submit a Fairwell Heaven feature suggestion.")
    .addStringOption(o => o.setName("name").setDescription("Feature name").setRequired(true).setMaxLength(120))
    .addStringOption(o => o.setName("description").setDescription("What should it do?").setRequired(true).setMaxLength(8000))
    .addStringOption(o => o.setName("target").setDescription("Where should it work?").setRequired(false).setMaxLength(80)),
  new SlashCommandBuilder()
    .setName("suggestions")
    .setDescription("Show recent Fairwell Heaven suggestions.")
    .setDefaultMemberPermissions(PermissionFlagsBits.ManageGuild)
].map(c => c.toJSON());

function safeFilePart(value) {
  return String(value).trim()
    .replace(/[^a-zA-Z0-9 _-]/g, "")
    .replace(/\\s+/g, "_")
    .replace(/_+/g, "_")
    .slice(0, 70) || "Suggestion";
}

function encodePath(path) {
  return path.split("/").map(encodeURIComponent).join("/");
}

async function githubRequest(path, options = {}) {
  const response = await fetch("https://api.github.com/repos/" + OWNER + "/" + REPO + "/" + path, {
    ...options,
    headers: {
      "Accept": "application/vnd.github+json",
      "Authorization": "Bearer " + GITHUB_TOKEN,
      "X-GitHub-Api-Version": "2022-11-28",
      "User-Agent": "Fairwell-Heaven-Discord-Bot",
      "Content-Type": "application/json",
      ...(options.headers || {})
    }
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(typeof data.message === "string" ? data.message : "GitHub API " + response.status);
  }
  return data;
}

async function createSuggestion({ name, description, target, user }) {
  const timestamp = new Date().toISOString();
  const date = timestamp.slice(0, 10);
  const time = timestamp.slice(11, 19).replace(/:/g, "-");
  const safeName = safeFilePart(name);
  const filePath = "suggestions/" + date + "_" + time + "_" + safeName + ".md";

  const content = [
    "# " + name.trim(),
    "",
    "## Description",
    "",
    description.trim(),
    "",
    "## Target",
    "",
    (target || "GLOBAL").trim(),
    "",
    "## Submitted By",
    "",
    (user.tag || user.username || user.id) + " (" + user.id + ")",
    "",
    "## Submitted",
    "",
    timestamp,
    "",
    "## Status",
    "",
    "PENDING",
    "",
    "---",
    "",
    "Created by the Fairwell Heaven Discord Bot."
  ].join("\n");

  await githubRequest("contents/" + encodePath(filePath), {
    method: "PUT",
    body: JSON.stringify({
      message: "Add feature suggestion: " + name.trim(),
      content: Buffer.from(content, "utf8").toString("base64")
    })
  });

  return filePath;
}

async function listSuggestions() {
  return githubRequest("contents/" + encodePath("suggestions"));
}

async function registerCommands() {
  const rest = new REST({ version: "10" }).setToken(DISCORD_TOKEN);
  const route = DISCORD_GUILD_ID
    ? Routes.applicationGuildCommands(DISCORD_CLIENT_ID, DISCORD_GUILD_ID)
    : Routes.applicationCommands(DISCORD_CLIENT_ID);

  await rest.put(route, { body: commands });
  console.log(DISCORD_GUILD_ID ? "Registered guild commands." : "Registered global commands.");
}

const client = new Client({ intents: [GatewayIntentBits.Guilds] });

client.once("ready", () => {
  console.log("Fairwell bot online as " + client.user.tag);
});

client.on("interactionCreate", async interaction => {
  if (!interaction.isChatInputCommand()) return;

  if (interaction.commandName === "suggest") {
    await interaction.deferReply({ ephemeral: true });

    try {
      const filePath = await createSuggestion({
        name: interaction.options.getString("name", true),
        description: interaction.options.getString("description", true),
        target: interaction.options.getString("target") || "GLOBAL",
        user: interaction.user
      });

      await interaction.editReply("Suggestion saved to GitHub: " + filePath);
    } catch (error) {
      console.error("Suggestion creation failed:", error);
      await interaction.editReply("I couldn't save the suggestion to GitHub. Check the bot GitHub token and permissions.");
    }
    return;
  }

  if (interaction.commandName === "suggestions") {
    await interaction.deferReply({ ephemeral: true });

    try {
      const entries = await listSuggestions();
      const files = Array.isArray(entries)
        ? entries.filter(e => e.type === "file" && e.name.endsWith(".md"))
        : [];

      if (!files.length) {
        await interaction.editReply("There are no suggestions yet.");
        return;
      }

      const recent = files.slice(-10).reverse();
      await interaction.editReply(
        "**Recent Fairwell Heaven suggestions:**\n" +
        recent.map((e, i) => (i + 1) + ". " + e.name).join("\n")
      );
    } catch (error) {
      console.error("Suggestion listing failed:", error);
      await interaction.editReply("I couldn't read the suggestions folder from GitHub.");
    }
  }
});

(async () => {
  await registerCommands();
  await client.login(DISCORD_TOKEN);
})();
