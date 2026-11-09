import { useState } from "react";
import { authApi, sessionApi } from "../services/api";

const getUserFromResponse = async (response) => {
  const token = response.data.token;
  localStorage.setItem("cc_token", token);

  let user = response.data.user
    ? { name: response.data.user.name, role: response.data.user.role }
    : null;

  try {
    const { data } = await sessionApi.me();
    user = {
      id: data.id,
      name: data.fullName,
      role: data.role?.toLowerCase(),
      email: data.email,
      phone: data.phone
    };
  } catch {
    user = user || { name: "Care Companion User", role: "elder" };
  }

  localStorage.setItem("cc_user", JSON.stringify(user));
  return user;
};

export default function LoginPage({ onAuthSuccess }) {
  const [authMode, setAuthMode] = useState("otp");
  const [isRegister, setIsRegister] = useState(false);
  const [otpSent, setOtpSent] = useState(false);
  const [debugOtp, setDebugOtp] = useState("");
  const [otpMessage, setOtpMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({
    fullName: "",
    email: "",
    password: "",
    phone: "",
    otp: "",
    role: "ELDER"
  });
  const [error, setError] = useState("");

  const submit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const response = isRegister
        ? await authApi.register({
            fullName: form.fullName,
            email: form.email,
            phone: form.phone,
            password: form.password,
            role: form.role
          })
        : authMode === "otp"
          ? await authApi.login({ phone: form.phone, otp: form.otp, role: form.role })
          : await authApi.login({ email: form.email, password: form.password });
      const user = await getUserFromResponse(response);
      onAuthSuccess(user);
    } catch (err) {
      setError(err?.response?.data?.message || "Authentication failed");
    } finally {
      setLoading(false);
    }
  };

  const requestOtp = async () => {
    setError("");
    setLoading(true);
    try {
      const { data } = await authApi.requestOtp({ phone: form.phone });
      setOtpSent(true);
      setOtpMessage(data.message || "OTP sent.");
      setDebugOtp(data.otp || "");
    } catch (err) {
      setError(err?.response?.data?.message || "Could not send OTP");
    } finally {
      setLoading(false);
    }
  };

  return (
    <section className="auth-wrap auth-shell">
      <div className="card auth-side-panel">
        <span className="eyebrow">Elder-first care platform</span>
        <h1>Care Companion for Elders</h1>
        <p>
          Manage health readings, medicine reminders, emergency alerts, appointments,
          caregiver visibility, and AI wellness guidance from one accessible dashboard.
        </p>
        <ul className="feature-list">
          <li>Large-text, simple workflow for elders</li>
          <li>Caregiver dashboard and emergency support</li>
          <li>Health risk prediction and PDF reports</li>
        </ul>
      </div>

      <form className="card auth-card" onSubmit={submit}>
        <div className="tab-row">
          <button type="button" className={authMode === "otp" ? "tab-btn active-tab" : "tab-btn"} onClick={() => setAuthMode("otp")}>
            OTP Login
          </button>
          <button type="button" className={authMode === "password" ? "tab-btn active-tab" : "tab-btn"} onClick={() => setAuthMode("password")}>
            Email Login
          </button>
        </div>

        <h2>{isRegister ? "Create account" : "Sign in"}</h2>

        {isRegister && (
          <>
            <label>
              Full name
              <input value={form.fullName} onChange={(e) => setForm({ ...form, fullName: e.target.value })} required />
            </label>
            <label>
              Phone
              <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} required />
            </label>
          </>
        )}

        {!isRegister && authMode === "otp" && (
          <>
            <label>
              Phone
              <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} required />
            </label>
            <label>
              Role
              <select value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })}>
                <option value="ELDER">Elder</option>
                <option value="CAREGIVER">Caregiver</option>
                <option value="DOCTOR">Doctor</option>
              </select>
            </label>
            <div className="inline-actions">
              <button type="button" onClick={requestOtp} disabled={loading || !form.phone}>
                {loading ? "Sending..." : "Request OTP"}
              </button>
            </div>
            {otpSent && (
              <label>
                OTP
                <input value={form.otp} onChange={(e) => setForm({ ...form, otp: e.target.value })} required />
              </label>
            )}
            {otpMessage && <p className="hint-text">{otpMessage}</p>}
            {debugOtp && <p className="hint-text">Development OTP: {debugOtp}</p>}
          </>
        )}

        {(isRegister || authMode === "password") && (
          <>
            <label>
              Email
              <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required />
            </label>
            <label>
              Password
              <input type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required />
            </label>
          </>
        )}

        {isRegister && (
          <label>
            Role
            <select value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })}>
              <option value="ELDER">Elder</option>
              <option value="CAREGIVER">Caregiver</option>
              <option value="DOCTOR">Doctor</option>
            </select>
          </label>
        )}

        {error && <p className="error-text">{error}</p>}
        <button type="submit" disabled={loading}>
          {loading ? "Please wait..." : isRegister ? "Create Account" : "Continue"}
        </button>
        <button type="button" className="ghost-btn" onClick={() => setIsRegister(!isRegister)}>
          {isRegister ? "Already have an account?" : "Create new account"}
        </button>
      </form>
    </section>
  );
}
