CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(200) UNIQUE NOT NULL,
  phone VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL,
  preferred_language VARCHAR(10) DEFAULT 'en',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS caregiver_links (
  id BIGSERIAL PRIMARY KEY,
  elder_id BIGINT NOT NULL REFERENCES users(id),
  caregiver_id BIGINT NOT NULL REFERENCES users(id),
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE IF NOT EXISTS medicines (
  id BIGSERIAL PRIMARY KEY,
  elder_id BIGINT NOT NULL REFERENCES users(id),
  medicine_name VARCHAR(150) NOT NULL,
  dosage VARCHAR(100),
  schedule_json JSONB NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS appointments (
  id BIGSERIAL PRIMARY KEY,
  elder_id BIGINT NOT NULL REFERENCES users(id),
  doctor_id BIGINT REFERENCES users(id),
  appointment_time TIMESTAMP NOT NULL,
  reason TEXT,
  status VARCHAR(30) DEFAULT 'BOOKED'
);

CREATE TABLE IF NOT EXISTS health_records (
  id BIGSERIAL PRIMARY KEY,
  elder_id BIGINT NOT NULL REFERENCES users(id),
  heart_rate INT,
  systolic_bp INT,
  diastolic_bp INT,
  blood_sugar DOUBLE PRECISION,
  spo2 INT,
  recorded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
  id BIGSERIAL PRIMARY KEY,
  elder_id BIGINT NOT NULL REFERENCES users(id),
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  relation VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  type VARCHAR(40) NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'PENDING',
  sent_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS location_logs (
  id BIGSERIAL PRIMARY KEY,
  elder_id BIGINT NOT NULL REFERENCES users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  event_source VARCHAR(30) DEFAULT 'GPS',
  created_at TIMESTAMP DEFAULT NOW()
);
