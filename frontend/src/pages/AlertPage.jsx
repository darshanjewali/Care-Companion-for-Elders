import { useEffect, useState } from "react";
import { alertApi } from "../services/api";

export default function AlertPage() {
  const [location, setLocation] = useState({ lat: "", lng: "" });
  const [alerts, setAlerts] = useState([]);
  const [sending, setSending] = useState(false);

  const load = async () => {
    const { data } = await alertApi.mine();
    setAlerts(data);
  };

  useEffect(() => {
    load().catch(() => setAlerts([]));
  }, []);

  const sendSos = async () => {
    setSending(true);
    await alertApi.emergency({
      message: "Emergency assistance required",
      healthStatus: "critical",
      location: {
        lat: Number(location.lat || 0),
        lng: Number(location.lng || 0)
      }
    });
    setSending(false);
    load();
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Emergency and Alerts</h2>
          <p>Trigger SOS alerts with live location data and review recent alert history.</p>
        </div>
      </div>
      <div className="card">
        <h2>Emergency SOS</h2>
        <div className="grid-form">
          <label>Latitude <input value={location.lat} onChange={(e) => setLocation({ ...location, lat: e.target.value })} placeholder="12.9716" /></label>
          <label>Longitude <input value={location.lng} onChange={(e) => setLocation({ ...location, lng: e.target.value })} placeholder="77.5946" /></label>
        </div>
        <button className="sos-btn" onClick={sendSos}>{sending ? "Sending..." : "Send SOS Alert"}</button>
      </div>
      <div className="card">
        <h2>Alert History</h2>
        {alerts.length === 0 && <p>No alerts yet.</p>}
        {alerts.map((a) => (
          <div className="list-row" key={a.id}>
            <span>{a.type}: {a.message}</span>
            <span>{a.location || "No location"}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
