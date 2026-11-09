INSERT INTO users (full_name, email, phone, password_hash, role, preferred_language)
VALUES
('Lakshmi Rao', 'elder1@care.app', '+919999111111', '$2a$10$demoHash', 'ELDER', 'en'),
('Arjun Rao', 'caregiver1@care.app', '+919999222222', '$2a$10$demoHash', 'CAREGIVER', 'en'),
('Dr Mehta', 'doctor1@care.app', '+919999333333', '$2a$10$demoHash', 'DOCTOR', 'en');

INSERT INTO medicines (elder_id, medicine_name, dosage, schedule_json)
VALUES
(1, 'Metformin', '500mg', '{"times":["08:00","20:00"]}'),
(1, 'Amlodipine', '5mg', '{"times":["09:00"]}');

INSERT INTO emergency_contacts (elder_id, name, phone, relation)
VALUES
(1, 'Arjun Rao', '+919999222222', 'Son');
