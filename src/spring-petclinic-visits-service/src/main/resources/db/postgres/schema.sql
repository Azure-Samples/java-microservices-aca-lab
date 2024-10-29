


CREATE TABLE IF NOT EXISTS visits (
  id SERIAL PRIMARY KEY,  
  pet_id INT NOT NULL,
  visit_date DATE,
  description VARCHAR(8192),
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE  
);
