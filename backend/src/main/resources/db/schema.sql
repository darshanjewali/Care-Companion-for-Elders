CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    phone VARCHAR(30) UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS health_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    elder_id BIGINT NOT NULL,
    heart_rate INT,
    systolic_bp INT,
    diastolic_bp INT,
    blood_sugar DOUBLE,
    notes TEXT,
    recorded_at DATETIME
);

CREATE TABLE IF NOT EXISTS medications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    elder_id BIGINT NOT NULL,
    medicine_name VARCHAR(150) NOT NULL,
    dosage VARCHAR(100),
    reminder_time VARCHAR(20),
    reminder_date DATE DEFAULT (CURRENT_DATE),
    instructions TEXT,
    taken BOOLEAN DEFAULT FALSE,
    created_at DATETIME
);

CREATE TABLE IF NOT EXISTS appointments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    elder_id BIGINT NOT NULL,
    doctor_id BIGINT NOT NULL,
    appointment_time DATETIME,
    reason TEXT,
    status VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS alerts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    elder_id BIGINT NOT NULL,
    type VARCHAR(30),
    message TEXT,
    location VARCHAR(255),
    acknowledged BOOLEAN DEFAULT FALSE,
    created_at DATETIME
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    message TEXT NOT NULL,
    sent_at DATETIME
);

CREATE TABLE IF NOT EXISTS caregiver_links (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    elder_id BIGINT NOT NULL,
    caregiver_id BIGINT NOT NULL,
    status VARCHAR(20),
    created_at DATETIME
);

CREATE TABLE IF NOT EXISTS location_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    elder_id BIGINT NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE,
    event_source VARCHAR(50),
    created_at DATETIME
);

CREATE TABLE IF NOT EXISTS voice_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    command_text TEXT,
    lang VARCHAR(10),
    intent VARCHAR(50),
    message TEXT,
    created_at DATETIME
);

CREATE TABLE IF NOT EXISTS prescriptions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    appointment_id BIGINT NOT NULL,
    file_name VARCHAR(255),
    content_type VARCHAR(100),
    file_path VARCHAR(500),
    uploaded_at DATETIME
);
