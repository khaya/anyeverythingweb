-- Create a new database
CREATE DATABASE IF NOT EXISTS laravel;

CREATE USER IF NOT EXISTS 'laravel'@'%' IDENTIFIED BY 'laravel';

GRANT ALL PRIVILEGES ON laravel.* TO 'laravel'@'%';

-- Apply changes
FLUSH PRIVILEGES;