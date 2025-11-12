// lib/db.js
import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
  host: process.env.DB_HOST || 'db-service',
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 5432,
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'appdb',
});

// Ensure the table exists
const createTableQuery = `
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);
`;

pool.query(createTableQuery)
  .then(() => console.log("✅ 'users' table is ready"))
  .catch(err => console.error("❌ Error creating 'users' table:", err));

export default pool;
