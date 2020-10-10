CREATE TABLE IF NOT EXISTS users
(
    id       INT PRIMARY KEY,
    name     VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL
);