DROP TABLE visitrequests IF EXISTS;
CREATE TABLE visitrequests (
  id INTEGER IDENTITY PRIMARY KEY,
  pet_id INTEGER NOT NULL,
  message VARCHAR(2048),
  response VARCHAR(2048),
  accepted INT
);
