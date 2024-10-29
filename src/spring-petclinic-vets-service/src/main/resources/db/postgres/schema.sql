
CREATE TABLE IF NOT EXISTS vets (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL
);

CREATE INDEX idx_vets_last_name ON vets(last_name);

CREATE TABLE IF NOT EXISTS specialties (
    id SERIAL PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    UNIQUE (name) 
);

CREATE TABLE IF NOT EXISTS vet_specialties (
    vet_id INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (vet_id, specialty_id), 
    FOREIGN KEY (vet_id) REFERENCES vets(id) ON DELETE CASCADE, 
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE 
);
