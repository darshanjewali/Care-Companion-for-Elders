from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Care Companion ML Service", version="1.0.0")


class RiskInput(BaseModel):
    systolic_bp: int
    diastolic_bp: int
    blood_sugar: float
    heart_rate: int
    inactivity_hours: float = 0


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/risk-score")
def risk_score(payload: RiskInput):
    score = 0
    if payload.systolic_bp >= 140 or payload.diastolic_bp >= 90:
        score += 30
    if payload.blood_sugar >= 180:
        score += 30
    if payload.heart_rate >= 110 or payload.heart_rate <= 50:
        score += 20
    if payload.inactivity_hours >= 8:
        score += 20
    level = "LOW" if score < 30 else "MEDIUM" if score < 60 else "HIGH"
    return {
        "riskScore": score,
        "riskLevel": level,
        "recommendation": "Consult caregiver/doctor if medium-high risk persists."
    }
