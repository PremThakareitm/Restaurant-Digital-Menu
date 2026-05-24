const fs = require('fs/promises');
const path = require('path');

const usersFilePath = path.join(__dirname, '..', 'data', 'users.json');

async function ensureUsersFile() {
  try {
    await fs.access(usersFilePath);
  } catch (_error) {
    await fs.writeFile(usersFilePath, JSON.stringify([], null, 2), 'utf8');
  }
}

async function readUsers() {
  await ensureUsersFile();

  const raw = await fs.readFile(usersFilePath, 'utf8');
  if (!raw.trim()) {
    return [];
  }

  return JSON.parse(raw);
}

async function writeUsers(users) {
  await fs.writeFile(usersFilePath, JSON.stringify(users, null, 2), 'utf8');
}

module.exports = {
  readUsers,
  writeUsers,
};