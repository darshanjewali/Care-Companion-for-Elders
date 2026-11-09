import axios from "axios";

const api = axios.create({
  baseURL: "http://localhost:8080/api"
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("cc_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const authApi = {
  register: (payload) => api.post("/auth/register", payload),
  login: (payload) => api.post("/auth/login", payload),
  requestOtp: (payload) => api.post("/auth/request-otp", payload)
};

export const sessionApi = {
  me: () => api.get("/me")
};

export const dashboardApi = {
  summary: () => api.get("/dashboard"),
  caregiver: () => api.get("/caregiver/patient-data")
};

export const healthApi = {
  add: (payload) => api.post("/health-records", payload),
  list: (elderId) => api.get(`/health-records/${elderId}`),
  mine: () => api.get("/health-records/me"),
  latest: () => api.get("/health/latest")
};

export const medicationApi = {
  add: (payload) => api.post("/medications", payload),
  list: (elderId) => api.get(`/medications/${elderId}`),
  mine: () => api.get("/medications/me"),
  today: () => api.get("/medicines/today"),
  createCurrent: (payload) => api.post("/medicines", payload),
  markTaken: (id) => api.put(`/medications/${id}/taken`),
  markTakenCurrent: (medicineId) => api.post("/medicines/taken", { medicineId })
};

export const appointmentApi = {
  add: (payload) => api.post("/appointments", payload),
  list: (elderId) => api.get(`/appointments/${elderId}`),
  mine: () => api.get("/appointments/me"),
  createCurrent: (payload) => api.post("/appointments/me", payload)
};

export const alertApi = {
  sos: (payload) => api.post("/alerts/sos", payload),
  list: (elderId) => api.get(`/alerts/${elderId}`),
  mine: () => api.get("/alerts/me"),
  emergency: (payload) => api.post("/emergency", payload)
};

export const chatApi = {
  send: (payload) => api.post("/chat", payload),
  list: (a, b) => api.get(`/chat?userA=${a}&userB=${b}`),
  mine: (peerId) => api.get(`/chat/me?peerId=${peerId}`)
};

export const aiApi = {
  suggest: (payload) => api.post("/ai/suggestions", payload),
  predict: () => api.get("/ai/health-prediction")
};

export const reportApi = {
  download: (elderId) => window.open(`http://localhost:8080/api/reports/elder/${elderId}/pdf`, "_blank"),
  downloadMine: () => window.open("http://localhost:8080/api/reports/me/pdf", "_blank")
};

export const wearableApi = {
  status: () => api.get("/wearables/status"),
  connect: (payload) => api.post("/wearables/connect", payload),
  disconnect: () => api.post("/wearables/disconnect"),
  reminders: () => api.get("/wearables/reminders"),
  addReminder: (payload) => api.post("/wearables/reminders", payload),
  liveVitals: () => api.get("/wearables/vitals/live"),
  pushVitals: (payload) => api.post("/wearables/vitals", payload)
};

export default api;
