"use client";
import { useEffect, useState } from "react";

interface User {
  id: number;
  name: string;
  email: string;
}

export default function Home() {
  const [users, setUsers] = useState<User[]>([]);
  const [form, setForm] = useState({ name: "", email: "" });

  const fetchUsers = async () => {
    const res = await fetch("/api/users");
    const data = await res.json();
    setUsers(data);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    await fetch("/api/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form),
    });
    setForm({ name: "", email: "" });
    fetchUsers();
  };

  return (
    <main style={styles.container}>
      <h1 style={styles.title}>Lab 5 – User Manager</h1>
      <form onSubmit={handleSubmit} style={styles.form}>
        <input
          type="text"
          placeholder="Name"
          value={form.name}
          onChange={(e) => setForm({ ...form, name: e.target.value })}
          style={styles.input}
        />
        <input
          type="email"
          placeholder="Email"
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
          style={styles.input}
        />
        <button type="submit" style={styles.button}>Add User</button>
      </form>

      <ul style={styles.list}>
        {users.map((u) => (
          <li key={u.id} style={styles.listItem}>
            <strong>{u.name}</strong> — {u.email}
          </li>
        ))}
      </ul>
    </main>
  );
}

const styles: Record<string, React.CSSProperties> = {
  container: { padding: "40px", maxWidth: "600px", margin: "auto", fontFamily: "Arial" },
  title: { textAlign: "center", fontSize: "26px", marginBottom: "20px" },
  form: { display: "flex", flexDirection: "column", gap: "10px", marginBottom: "30px" },
  input: { padding: "10px", fontSize: "16px", border: "1px solid #ccc", borderRadius: "4px" },
  button: { padding: "10px", background: "#0070f3", color: "white", border: "none", borderRadius: "4px", cursor: "pointer" },
  list: { listStyle: "none", padding: 0 },
  listItem: { padding: "8px 0", borderBottom: "1px solid #eee" },
};
