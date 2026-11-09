# Care Companion for Elders: A Smart Healthcare Support System

Production-oriented multi-platform healthcare assistant for elderly users with caregiver collaboration, emergency protection, AI-assisted insights, and accessibility-first UX.

## Product Vision
- Support elder independence with simple daily health tools.
- Improve safety via emergency SOS, missed-dose escalation, and geo/location alerts.
- Enable proactive care through trend analysis, risk scoring, and caregiver dashboards.

## Tech Stack
- Mobile App: Flutter (`mobile`)
- Web Dashboard: React + Vite (`frontend`)
- API Backend: Spring Boot + JWT + OpenAPI (`backend`)
- AI Service: FastAPI risk engine (`ml-service`)
- Database: PostgreSQL schema (`infra/postgres-schema.sql`)
- Realtime/Notifications: WebSocket-ready + FCM integration points
- DevOps: Docker Compose + GitHub Actions CI/CD

## Feature Coverage
### Core
- OTP-ready auth flow foundation with JWT and RBAC model (`ELDER`, `CAREGIVER`, `DOCTOR`, `ADMIN` extensible)
- Medicine reminders, taken status, and caregiver escalation endpoints
- Appointment booking and schedule tracking
- Health logs (BP, sugar, HR) with chart support
- Emergency SOS with location payload
- PDF report generation and chat

### Advanced (implemented foundations + integration hooks)
- AI risk scoring microservice (`/risk-score`) for anomaly/risk flags
- Voice assistant screen and command-ready UX placeholders
- Behavior monitoring and inactivity alert data paths
- Fall detection and wearable integration architecture hooks
- Offline-first mobile sync strategy (documented)
- Geofencing/location logs schema
- Telemedicine/video consultation module integration points
- Medicine recognition integration slot (camera + ML model)

## Folder Structure
- `frontend`: caregiver/admin/elder web dashboard
- `mobile`: elder mobile app (Flutter)
- `backend`: Spring Boot APIs and business services
- `ml-service`: AI/ML risk scoring service
- `infra`: production schema and deployment compose
- `docs`: architecture, API, and UI specs
- `sample-data`: development seed SQL
- `.github/workflows`: CI/CD pipeline

## API & Documentation
- OpenAPI contract: `docs/API_OPENAPI.yaml`
- Architecture: `docs/ARCHITECTURE.md`
- UI/UX accessibility spec: `docs/UI_SCREENS.md`
- Runtime Swagger: `http://localhost:8080/swagger-ui/index.html`

## Local Run (Current)
1. Frontend:
   - `cd frontend`
   - `npm install`
   - `npm run dev`
2. Backend (with local fallback H2 profile style arguments):
   - `cd backend`
   - Set `DB_PASS` to the local database password and `JWT_SECRET` to a unique secret of at least 32 characters.
   - `mvn spring-boot:run`
3. Mobile:
   - `cd mobile`
   - `flutter pub get`
   - `flutter run`

## Production-like Run
1. `cd infra`
2. Set `DB_PASS` and `JWT_SECRET` in the environment. Keep these values private and do not commit them.
3. `docker compose -f docker-compose.prod.yml up --build`
4. Services:
   - Web: `http://localhost:5173`
   - API: `http://localhost:8080`
   - ML: `http://localhost:8000/health`

## Security and Compliance
- JWT token auth and role-based access controls
- Encrypted transport expected through TLS in deployment
- Secret/environment separation for production
- Audit and alert events designed for monitoring pipelines

## Accessibility Commitments
- Large fonts, high contrast, one-click critical actions
- Multilingual structure (English/Hindi/Kannada)
- Voice-first navigation-ready screen design

## Seed Data
- `sample-data/seed.sql` provides starter users, medicines, and contacts.
