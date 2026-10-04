import crypto from "node:crypto";
import readline from "node:readline";

const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: true });

rl.question("Enter your Dev Lab password (input is hidden by your terminal): ", password => {
  const salt = crypto.randomBytes(16).toString("hex");
  const key = crypto.scryptSync(password, salt, 32);
  console.log("\nDEV_LAB_PASSWORD_HASH=");
  console.log(`scrypt$${salt}$${key.toString("hex")}`);
  rl.close();
});
