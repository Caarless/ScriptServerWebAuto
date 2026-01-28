-- Datos de ejemplo para la aplicación
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email) VALUES 
('admin', 'admin@example.com'),
('demo_user', 'demo@example.com'),
('test_user', 'test@example.com');
