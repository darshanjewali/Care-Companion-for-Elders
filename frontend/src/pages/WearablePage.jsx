import { useEffect, useState } from "react";
import { wearableApi } from "../services/api";

export default function WearablePage() {
  const [status, setStatus] = useState({ connected: false, deviceName: "" });
  const [deviceName, setDeviceName] = useState("Samsung Galaxy Watch");
  const [reminders, setReminders] = useState([]);
  const [metrics, setMetrics] = useState({ heartRate: "--", pulse: "--", spo2: "--", steps: 0, calories: 0 });
  const [bluetoothSupported, setBluetoothSupported] = useState(false);
  const [form, setForm] = useState({ title: "Medicine Reminder", time: "08:00", repeatDaily: true });
  const [message, setMessage] = useState("");

  const load = async () => {
    const [s, r, live] = await Promise.all([
      wearableApi.status(),
      wearableApi.reminders(),
      wearableApi.liveVitals().catch(() => ({ data: { connected: false } }))
    ]);
    setStatus(s.data);
    setReminders(r.data || []);
    if (live.data?.metrics) {
      setMetrics(live.data.metrics);
    }
  };

  useEffect(() => {
    setBluetoothSupported(typeof navigator !== "undefined" && !!navigator.bluetooth);
    load().catch(() => setReminders([]));

    const interval = setInterval(async () => {
      try {
        const { data } = await wearableApi.liveVitals();
        if (data?.metrics) {
          setMetrics(data.metrics);
        }
      } catch {
        // no-op polling fail
      }
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const connect = async () => {
    const { data } = await wearableApi.connect({ deviceName });
    setStatus(data);
    setMessage("Smart watch connected successfully.");
  };

  const disconnect = async () => {
    await wearableApi.disconnect();
    setStatus({ connected: false, deviceName: "" });
    setMessage("Smart watch disconnected.");
  };

  const connectBluetooth = async () => {
    if (!(typeof navigator !== "undefined" && navigator.bluetooth)) {
      setMessage("Web Bluetooth is not supported in this browser. Use latest Chrome/Edge.");
      return;
    }
    try {
      const device = await navigator.bluetooth.requestDevice({
        acceptAllDevices: true,
        optionalServices: ["heart_rate", "battery_service"]
      });
      const resolved = device?.name || "Bluetooth Smart Watch";
      setDeviceName(resolved);
      await wearableApi.connect({ deviceName: resolved });
      setStatus({ connected: true, deviceName: resolved });
      setMessage(`Bluetooth paired with ${resolved}.`);
    } catch (e) {
      setMessage("Bluetooth pairing cancelled or failed.");
    }
  };

  const addReminder = async (e) => {
    e.preventDefault();
    await wearableApi.addReminder(form);
    setMessage("Reminder synced to wearable.");
    setForm({ title: "", time: "08:00", repeatDaily: true });
    load();
  };

  const triggerMedicationAlarm = async () => {
    if ("Notification" in window) {
      if (Notification.permission === "default") {
        await Notification.requestPermission();
      }
      if (Notification.permission === "granted") {
        new Notification("Medication Alarm", {
          body: "Time to take your medication.",
          icon: "/favicon.ico"
        });
      }
    }
    setMessage("Medication alarm triggered.");
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Smart Watch Integration</h2>
          <p>Connect a wearable to sync medicine reminders, inactivity nudges, and quick alerts.</p>
        </div>
      </div>

      <div className="dashboard-grid">
        <article className="card">
          <h3>Wearable Connection</h3>
          <label>
            Device Name
            <input value={deviceName} onChange={(e) => setDeviceName(e.target.value)} />
          </label>
          <div className="inline-actions">
            <button onClick={connect}>Connect Watch</button>
            <button type="button" onClick={connectBluetooth} disabled={!bluetoothSupported}>
              Connect via Bluetooth
            </button>
            <button className="ghost-btn" onClick={disconnect}>Disconnect</button>
          </div>
          <p className="hint-text">
            Status: {status.connected ? `Connected to ${status.deviceName}` : "Not connected"}
          </p>
          <p className="hint-text">
            Bluetooth: {bluetoothSupported ? "Supported in this browser" : "Not supported"}
          </p>
        </article>

        <article className="card">
          <h3>Sync Reminder to Wearable</h3>
          <form className="grid-form" onSubmit={addReminder}>
            <label>Title
              <input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} required />
            </label>
            <label>Time
              <input value={form.time} onChange={(e) => setForm({ ...form, time: e.target.value })} required />
            </label>
            <label>
              Repeat Daily
              <select
                value={String(form.repeatDaily)}
                onChange={(e) => setForm({ ...form, repeatDaily: e.target.value === "true" })}
              >
                <option value="true">Yes</option>
                <option value="false">No</option>
              </select>
            </label>
            <button type="submit">Sync Reminder</button>
          </form>
          <button onClick={triggerMedicationAlarm}>Trigger Medication Alarm</button>
        </article>
      </div>

      <div className="stats-grid">
        <article className="card metric-card">
          <span className="metric-label">Heart Rate</span>
          <strong>{metrics.heartRate}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">Pulse</span>
          <strong>{metrics.pulse}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">SpO2</span>
          <strong>{metrics.spo2}</strong>
        </article>
        <article className="card metric-card">
          <span className="metric-label">Steps / Calories</span>
          <strong>{metrics.steps} / {metrics.calories}</strong>
        </article>
      </div>

      <div className="card">
        <h3>Wearable Reminder Queue</h3>
        {message && <p className="hint-text">{message}</p>}
        {reminders.length === 0 && <p>No wearable reminders synced yet.</p>}
        {reminders.map((r) => (
          <div className="list-row" key={r.id}>
            <span>{r.title}</span>
            <span>{r.time} · {r.repeatDaily ? "Daily" : "One-time"}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

