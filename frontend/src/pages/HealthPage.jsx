import { useEffect, useState } from "react";
import { healthApi } from "../services/api";

export default function HealthPage() {
  const [records, setRecords] = useState([]);
  const [latest, setLatest] = useState(null);
  const [form, setForm] = useState({ heartRate: "", systolicBp: "", diastolicBp: "", bloodSugar: "", notes: "" });

  const load = async () => {
    const [history, current] = await Promise.all([healthApi.mine(), healthApi.latest()]);
    setRecords(history.data);
    setLatest(current.data);
  };

  useEffect(() => {
    load().catch(() => setRecords([]));
  }, []);

  const submit = async (e) => {
    e.preventDefault();
    await healthApi.add({
      heartRate: Number(form.heartRate),
      systolicBp: Number(form.systolicBp),
      diastolicBp: Number(form.diastolicBp),
      bloodSugar: Number(form.bloodSugar),
      notes: form.notes
    });
    setForm({ heartRate: "", systolicBp: "", diastolicBp: "", bloodSugar: "", notes: "" });
    load();
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Health Monitoring</h2>
          <p>Log BP, heart rate, and sugar values with simple large inputs and recent history.</p>
        </div>
      </div>
      <div className="stats-grid">
        <article className="card metric-card">
          <span className="metric-label">BP</span>
          <strong>{latest?.bp || "N/A"}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">Sugar</span>
          <strong>{latest?.sugar || "N/A"}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">Heart rate</span>
          <strong>{latest?.heartRate || 0}</strong>
        </article>
      </div>
      <div className="card">
        <h2>Add Health Record</h2>
        <form className="grid-form" onSubmit={submit}>
          <label>Heart Rate <input value={form.heartRate} onChange={(e) => setForm({ ...form, heartRate: e.target.value })} required /></label>
          <label>Systolic BP <input value={form.systolicBp} onChange={(e) => setForm({ ...form, systolicBp: e.target.value })} required /></label>
          <label>Diastolic BP <input value={form.diastolicBp} onChange={(e) => setForm({ ...form, diastolicBp: e.target.value })} required /></label>
          <label>Blood Sugar <input value={form.bloodSugar} onChange={(e) => setForm({ ...form, bloodSugar: e.target.value })} required /></label>
          <label>Notes <input value={form.notes} onChange={(e) => setForm({ ...form, notes: e.target.value })} /></label>
          <button type="submit">Save Record</button>
        </form>
      </div>
      <div className="card">
        <h2>Recent Records</h2>
        {records.length === 0 && <p>No records yet.</p>}
        {records.map((r) => (
          <div className="list-row" key={r.id}>
            <span>HR {r.heartRate} | BP {r.systolicBp}/{r.diastolicBp} | Sugar {r.bloodSugar}</span>
            <span>{r.recordedAt?.replace("T", " ").slice(0, 16)}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
