SET aad_auth_validate_oids_in_tenant = OFF;
DROP USER IF EXISTS 'mysql_conn'@'%';
CREATE AADUSER 'mysql_conn' IDENTIFIED BY 'a57068a9-bbcb-4b9c-a7d8-fe49b6ab3f5e';
GRANT ALL PRIVILEGES ON petclinic.* TO 'mysql_conn'@'%';
FLUSH privileges;
