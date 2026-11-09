import { Route, Routes } from "react-router-dom";
import { useEffect, useState } from "react";
import Layout from "./components/Layout";
import LoginPage from "./pages/LoginPage";
import DashboardPage from "./pages/DashboardPage";
import HealthPage from "./pages/HealthPage";
import MedicationPage from "./pages/MedicationPage";
import AppointmentPage from "./pages/AppointmentPage";
import AlertPage from "./pages/AlertPage";
import ChatPage from "./pages/ChatPage";
import WearablePage from "./pages/WearablePage";
import AiPage from "./pages/AiPage";
import ReportPage from "./pages/ReportPage";
import { sessionApi } from "./services/api";

const getStoredUser = () => {
  try {
    return JSON.parse(localStorage.getItem("cc_user") || "null");
  } catch {
    return null;
  }
};

export default function App() {
  const [token, setToken] = useState(localStorage.getItem("cc_token"));
  const [user, setUser] = useState(getStoredUser());

  useEffect(() => {
    if (!token || user) return;
    sessionApi.me().then(({ data }) => {
      const hydratedUser = {
        id: data.id,
        name: data.fullName,
        role: data.role?.toLowerCase(),
        email: data.email,
        phone: data.phone
      };
      localStorage.setItem("cc_user", JSON.stringify(hydratedUser));
      setUser(hydratedUser);
    }).catch(() => {
      localStorage.removeItem("cc_token");
      localStorage.removeItem("cc_user");
      setToken(null);
      setUser(null);
    });
  }, [token, user]);

  if (!token) {
    return <LoginPage onAuthSuccess={(nextUser) => {
      setToken(localStorage.getItem("cc_token"));
      setUser(nextUser || getStoredUser());
    }} />;
  }

  const logout = () => {
    localStorage.removeItem("cc_token");
    localStorage.removeItem("cc_user");
    setToken(null);
    setUser(null);
  };

  return (
    <Layout onLogout={logout} user={user}>
        <Routes>
          <Route path="/" element={<DashboardPage user={user} />} />
          <Route path="/health" element={<HealthPage user={user} />} />
          <Route path="/medications" element={<MedicationPage user={user} />} />
          <Route path="/appointments" element={<AppointmentPage user={user} />} />
          <Route path="/alerts" element={<AlertPage user={user} />} />
          <Route path="/chat" element={<ChatPage user={user} />} />
          <Route path="/wearables" element={<WearablePage user={user} />} />
          <Route path="/ai" element={<AiPage user={user} />} />
          <Route path="/reports" element={<ReportPage user={user} />} />
        </Routes>
    </Layout>
  );
}
