const fs = require('fs/promises');
const path = require('path');

const ordersFilePath = path.join(__dirname, '..', 'data', 'orders.json');

async function ensureOrdersFile() {
  try {
    await fs.access(ordersFilePath);
  } catch (_error) {
    await fs.writeFile(ordersFilePath, JSON.stringify([], null, 2), 'utf8');
  }
}

async function readOrders() {
  await ensureOrdersFile();

  const raw = await fs.readFile(ordersFilePath, 'utf8');
  if (!raw.trim()) {
    return [];
  }

  return JSON.parse(raw);
}

async function writeOrders(orders) {
  await fs.writeFile(ordersFilePath, JSON.stringify(orders, null, 2), 'utf8');
}

module.exports = {
  readOrders,
  writeOrders,
};