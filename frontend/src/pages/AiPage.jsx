import { useState } from "react";
import { aiApi } from "../services/api";

export default function AiPage() {
  const [input, setInput] = useState("Elder has mild high blood pressure and occasional sugar spikes.");
  const [output, setOutput] = useState("");
  const [risk, setRisk] = useState(null);

  const generate = async () => {
    const { data } = await aiApi.suggest({ clinicalSummary: input });
    setOutput(data.suggestion);
  };

  const predict = async () => {
    const { data } = await aiApi.predict();
    setRisk(data);
  };

  return (
    <div className="stack">
      <div className="page-hero">
        <div>
          <h2>AI Health Assistant</h2>
          <p>Get prediction-based risk scoring and readable wellness suggestions for elders and caregivers.</p>
        </div>
      </div>
      <div className="card">
        <h2>Health Risk Prediction</h2>
        <button onClick={predict}>Predict Current Risk</button>
        {risk && (
          <div className="ai-result">
            <strong>Risk: {risk.risk}</strong>
            <p>{risk.suggestion}</p>
          </div>
        )}
      </div>
      <div className="card">
        <h2>AI-based Health Suggestions</h2>
        <textarea rows={6} value={input} onChange={(e) => setInput(e.target.value)} />
        <button onClick={generate}>Generate Suggestion</button>
        {output && <p className="ai-result">{output}</p>}
      </div>
    </div>
  );
}
