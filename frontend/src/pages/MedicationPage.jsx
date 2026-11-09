import { useEffect, useState } from "react";
import { medicationApi } from "../services/api";

export default function MedicationPage() {
  const [items, setItems] = useState([]);
  const [today, setToday] = useState([]);
  const [form, setForm] = useState({ name: "", dosage: "", reminderTime: "", instructions: "" });

  const load = async () => {
    const [all, current] = await Promise.all([medicationApi.mine(), medicationApi.today()]);
    setItems(all.data);
    setToday(current.data);
  };

  useEffect(() => {
    load().catch(() => setItems([]));
  }, []);

  const save = async (e) => {
    e.preventDefault();
    await medicationApi.createCurrent(form);
    setForm({ name: "", dosage: "", reminderTime: "", instructions: "" });
    load();
  };

  const markTaken = async (id) => {
    await medicationApi.markTakenCurrent(id);
    load();
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Medicine Reminders</h2>
          <p>Create reminders, monitor pending doses, and mark today’s medicines as taken.</p>
        </div>
      </div>
      <div className="card">
        <h2>Add Medication Reminder</h2>
        <form className="grid-form" onSubmit={save}>
          <label>Medicine <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required /></label>
          <label>Dosage <input value={form.dosage} onChange={(e) => setForm({ ...form, dosage: e.target.value })} /></label>
          <label>Reminder Time <input value={form.reminderTime} onChange={(e) => setForm({ ...form, reminderTime: e.target.value })} placeholder="08:00" required /></label>
          <label>Instructions <input value={form.instructions} onChange={(e) => setForm({ ...form, instructions: e.target.value })} placeholder="After breakfast" /></label>
          <button type="submit">Add Reminder</button>
        </form>
      </div>
      <div className="dashboard-grid">
        <div className="card">
          <h2>Today</h2>
          {today.length === 0 && <p>No reminders for today.</p>}
          {today.map((m) => (
            <div className="list-block" key={m.id}>
              <div className="card-heading-row">
                <strong>{m.name}</strong>
                <span className={`status-badge ${m.status === "taken" ? "success" : m.status === "missed" ? "danger" : "warning"}`}>
                  {m.status}
                </span>
              </div>
              <p>{m.time}</p>
              {m.status !== "taken" && <button onClick={() => markTaken(m.id)}>Mark Taken</button>}
            </div>
          ))}
        </div>
        <div className="card">
          <h2>All Reminders</h2>
          {items.length === 0 && <p>No medication reminders saved yet.</p>}
          {items.map((m) => (
            <div className="list-row" key={m.id}>
              <span>{m.medicineName} · {m.dosage || "dose not set"}</span>
              <span>{m.reminderTime || "--:--"}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
