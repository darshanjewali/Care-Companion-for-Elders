import { useEffect, useMemo, useState } from "react";
import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
} from "chart.js";
import { aiApi, dashboardApi, healthApi, medicationApi } from "../services/api";

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

export default function DashboardPage({ user }) {
  const [summary, setSummary] = useState(null);
  const [latest, setLatest] = useState(null);
  const [todayMeds, setTodayMeds] = useState([]);
  const [risk, setRisk] = useState(null);
  const [caregiverPatients, setCaregiverPatients] = useState([]);

  useEffect(() => {
    if (user?.role === "caregiver") {
      dashboardApi.caregiver().then(({ data }) => setCaregiverPatients(data)).catch(() => setCaregiverPatients([]));
      return;
    }
    Promise.all([
      dashboardApi.summary().then((r) => setSummary(r.data)).catch(() => setSummary(null)),
      healthApi.latest().then((r) => setLatest(r.data)).catch(() => setLatest(null)),
      medicationApi.today().then((r) => setTodayMeds(r.data)).catch(() => setTodayMeds([])),
      aiApi.predict().then((r) => setRisk(r.data)).catch(() => setRisk(null))
    ]);
  }, [user?.role]);

  const chartData = useMemo(
    () => ({
      labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      datasets: [
        {
          label: "Heart Rate",
          data: [72, 75, 74, 78, 73, 76, 72],
          borderColor: "#2563eb",
          backgroundColor: "rgba(37, 99, 235, 0.3)"
        }
      ]
    }),
    []
  );

  if (user?.role === "caregiver") {
    return (
      <section className="stack">
        <div className="page-hero">
          <div>
            <h2>Caregiver Dashboard</h2>
            <p>Track linked elders, missed medicines, and recent SOS activity from one place.</p>
          </div>
        </div>
        <div className="dashboard-grid">
          {caregiverPatients.length === 0 && (
            <article className="card">
              <h3>No linked elders yet</h3>
              <p>Log in with a caregiver account and link an elder phone number from the mobile flow or backend API.</p>
            </article>
          )}
          {caregiverPatients.map((patient) => (
            <article className="card" key={patient.elderId}>
              <div className="card-heading-row">
                <h3>{patient.elderName}</h3>
                <span className="status-badge warning">Care target</span>
              </div>
              <p>BP: {patient.latest?.bp || "N/A"}</p>
              <p>Sugar: {patient.latest?.sugar || "N/A"}</p>
              <p>Heart rate: {patient.latest?.heartRate || 0}</p>
              <p>Missed medicines: {patient.missedMedsCount}</p>
              <p>Recent SOS alerts: {patient.recentSosCount}</p>
            </article>
          ))}
        </div>
      </section>
    );
  }

  return (
    <section className="stack">
      <div className="page-hero">
        <div>
          <h2>Welcome back, {summary?.username || user?.name || "Companion User"}</h2>
          <p>Monitor daily health, medicine adherence, SOS readiness, and AI wellness guidance.</p>
        </div>
        <div className="hero-chip">{summary?.healthStatus || "Stable"}</div>
      </div>

      <div className="stats-grid">
        <article className="card metric-card">
          <span className="metric-label">Next medicine</span>
          <strong>{summary?.nextMedicine || "No pending medicines"}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">Latest BP</span>
          <strong>{latest?.bp || "N/A"}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">Blood sugar</span>
          <strong>{latest?.sugar || "N/A"}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">AI Risk</span>
          <strong>{risk?.risk || "Low"}</strong>
        </article>
      </div>

      <div className="dashboard-grid">
        <article className="card">
          <h3>Weekly Trend</h3>
          <p>Health monitoring remains easy to read with a large, elder-friendly chart.</p>
          <Line data={chartData} />
        </article>
        <article className="card">
          <h3>Today’s Medicines</h3>
          {todayMeds.length === 0 && <p>No medicine reminders for today.</p>}
          {todayMeds.slice(0, 5).map((med) => (
            <div className="list-row" key={med.id}>
              <span>{med.name}</span>
              <span>{med.time} · {med.status}</span>
            </div>
          ))}
        </article>
        <article className="card">
          <h3>Emergency Readiness</h3>
          <p>One-click SOS with location sharing is enabled from the Alerts page.</p>
          <div className="info-panel danger-panel">
            <strong>Use SOS for falls, sudden pain, or any emergency.</strong>
          </div>
        </article>
        <article className="card">
          <h3>AI Wellness Insight</h3>
          <p>{risk?.suggestion || "Continue monitoring health and taking medicines on time."}</p>
        </article>
      </div>
    </section>
  );
}
