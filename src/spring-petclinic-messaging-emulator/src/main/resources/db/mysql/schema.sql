USE petclinic;

CREATE TABLE IF NOT EXISTS visitrequests (
  id INT(4) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pet_id INT(4) UNSIGNED NOT NULL,
  message VARCHAR(2048) NOT NULL,
  response VARCHAR(2048),
  accepted BOOLEAN NOT NULL DEFAULT FALSE
) engine = InnoDB;
