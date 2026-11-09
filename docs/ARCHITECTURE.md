# Care Companion - Production Architecture

## System Architecture

```mermaid
flowchart LR
  ElderMobile[Flutter Elder App]
  CaregiverWeb[React Caregiver/Admin Web]
  FCM[Firebase Cloud Messaging]
  APIGW[Spring Boot API Gateway]
  Auth[Auth + RBAC + JWT]
  Health[Health Service]
  Alert[Emergency/SOS Service]
  Realtime[WebSocket Service]
  AI[ML Risk Engine]
  Storage[(PostgreSQL)]
  Cache[(Redis)]
  Blob[(Object Storage)]
  SMS[SMS Provider]
  Maps[Geo/Maps Provider]

  ElderMobile --> APIGW
  CaregiverWeb --> APIGW
  APIGW --> Auth
  APIGW --> Health
  APIGW --> Alert
  APIGW --> Realtime
  Health --> Storage
  Alert --> Storage
  Realtime --> Cache
  APIGW --> AI
  AI --> Storage
  APIGW --> FCM
  APIGW --> SMS
  APIGW --> Maps
  APIGW --> Blob
```

## Deployment Topology
- `web` and `api` deployed behind HTTPS load balancer.
- `mobile` consumes public API.
- `postgres` in managed cloud DB (RDS/Cloud SQL/Azure Database).
- `redis` for sessions, notification queue, and real-time status.
- `ml-service` deployed as separate container with autoscaling.

## Core Non-Functional Requirements
- High availability with rolling deployments and health probes.
- Security: JWT, RBAC, encrypted transport (TLS), encrypted secrets.
- Observability: structured logs, metrics, and alerting.
- Accessibility-first UI with multilingual and high-contrast mode.
