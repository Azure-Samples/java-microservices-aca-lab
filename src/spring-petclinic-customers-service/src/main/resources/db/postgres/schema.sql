
CREATE TABLE IF NOT EXISTS types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    UNIQUE (name) 
);


CREATE TABLE IF NOT EXISTS owners (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(80) NOT NULL,
    telephone VARCHAR(20) NOT NULL
);


CREATE TABLE IF NOT EXISTS pets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    birth_date DATE NOT NULL,
    type_id INT NOT NULL,
    owner_id INT NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE, 
    FOREIGN KEY (type_id) REFERENCES types(id) ON DELETE CASCADE  
);

CREATE INDEX idx_last_name ON owners(last_name);
CREATE INDEX idx_name ON pets(name);
