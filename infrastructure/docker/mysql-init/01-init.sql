-- BlockScore database initialization
-- This script runs once when the MySQL container starts for the first time

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Ensure the database exists with correct charset
CREATE DATABASE IF NOT EXISTS blockscoredb
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE blockscoredb;

-- Ensure the app user has correct privileges (scoped, not ALL)
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON blockscoredb.* TO 'appuser'@'%';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Disallow remote root login
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database if it exists
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
