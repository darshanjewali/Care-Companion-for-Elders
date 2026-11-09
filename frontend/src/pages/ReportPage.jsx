import { reportApi } from "../services/api";

export default function ReportPage() {
  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>Reports</h2>
          <p>Download PDF summaries of recent health records for doctor visits and caregiver review.</p>
        </div>
      </div>
      <div className="card">
        <h2>Report Generation (PDF)</h2>
        <p>The report includes your recent health readings in an easy-to-share PDF.</p>
        <button onClick={() => reportApi.downloadMine()}>Download My PDF Report</button>
      </div>
    </div>
  );
}
