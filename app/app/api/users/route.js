import pool from "@/lib/db";

export async function GET() {
  const result = await pool.query("SELECT * FROM users ORDER BY id DESC");
  return Response.json(result.rows);
}

export async function POST(request) {
  const body = await request.json();
  const { name, email } = body;

  if (!name || !email)
    return new Response("Missing fields", { status: 400 });

  await pool.query("INSERT INTO users (name, email) VALUES ($1, $2)", [name, email]);

  return new Response("User added", { status: 201 });
}
