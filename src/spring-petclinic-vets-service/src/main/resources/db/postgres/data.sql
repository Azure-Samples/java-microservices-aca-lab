INSERT INTO vets (id, first_name, last_name) VALUES
(1, 'James', 'Carter'),
(2, 'Helen', 'Leary'),
(3, 'Linda', 'Douglas'),
(4, 'Rafael', 'Ortega'),
(5, 'Henry', 'Stevens'),
(6, 'Sharon', 'Jenkins')
ON CONFLICT (id) DO NOTHING;

INSERT INTO specialties (id, name) VALUES
(1, 'radiology'),
(2, 'surgery'),
(3, 'dentistry')
ON CONFLICT (id) DO NOTHING;

INSERT INTO vet_specialties (vet_id, specialty_id) VALUES
(2, 1),
(3, 2),
(3, 3),
(4, 2),
(5, 1)
ON CONFLICT (vet_id, specialty_id) DO NOTHING;

