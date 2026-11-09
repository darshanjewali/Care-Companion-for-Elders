import { NavLink } from "react-router-dom";

const menu = [
  ["Dashboard", "/"],
  ["Health", "/health"],
  ["Medications", "/medications"],
  ["Appointments", "/appointments"],
  ["Alerts", "/alerts"],
  ["Chat", "/chat"],
  ["Wearables", "/wearables"],
  ["AI Suggestions", "/ai"],
  ["Reports", "/reports"]
];

export default function Layout({ children, onLogout, user }) {
  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="brand-block">
          <h1>Care Companion</h1>
          <p className="subtitle">Smart Healthcare Support</p>
        </div>
        <div className="user-panel">
          <div className="avatar-circle">{(user?.name || "C").slice(0, 1).toUpperCase()}</div>
          <div>
            <strong>{user?.name || "Companion User"}</strong>
            <p className="subtitle role-label">{user?.role || "elder"}</p>
          </div>
        </div>
        <nav>
          {menu.map(([label, path]) => (
            <NavLink key={path} to={path} className={({ isActive }) => (isActive ? "active" : "")}>
              {label}
            </NavLink>
          ))}
        </nav>
        <button onClick={onLogout} className="ghost-btn">Logout</button>
      </aside>
      <main className="content">{children}</main>
    </div>
  );
}
