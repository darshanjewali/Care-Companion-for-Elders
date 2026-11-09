import { useEffect, useState } from "react";
import { appointmentApi } from "../services/api";

export default function AppointmentPage() {
  const [appointments, setAppointments] = useState([]);
  const [form, setForm] = useState({ doctorId: "", appointmentTime: "", reason: "", status: "BOOKED" });

  const load = async () => {
    const { data } = await appointmentApi.mine();
    setAppointments(data);
  };

  useEffect(() => {
    load().catch(() => setAppointments([]));
  }, []);

  const submit = async (e) => {
    e.preventDefault();
    await appointmentApi.createCurrent(form);
    setForm({ doctorId: "", appointmentTime: "", reason: "", status: "BOOKED" });
    load();
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Appointments</h2>
          <p>Schedule doctor visits, see upcoming bookings, and prepare for prescription uploads.</p>
        </div>
      </div>
      <div className="card">
        <h2>Book Appointment</h2>
        <form className="grid-form" onSubmit={submit}>
          <label>Doctor ID <input value={form.doctorId} onChange={(e) => setForm({ ...form, doctorId: e.target.value })} required /></label>
          <label>Time <input type="datetime-local" value={form.appointmentTime} onChange={(e) => setForm({ ...form, appointmentTime: e.target.value })} required /></label>
          <label>Reason <input value={form.reason} onChange={(e) => setForm({ ...form, reason: e.target.value })} /></label>
          <button type="submit">Book</button>
        </form>
      </div>
      <div className="card">
        <h2>Upcoming Appointments</h2>
        {appointments.length === 0 && <p>No appointments booked yet.</p>}
        {appointments.map((a) => (
          <div className="list-row" key={a.id}>
            <span>Doctor {a.doctorId} · {a.reason || "General consultation"}</span>
            <span>{String(a.appointmentTime).replace("T", " ").slice(0, 16)} · {a.status}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
