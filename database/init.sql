-- Create tasks table with all necessary fields
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    due_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);

-- Insert sample data
INSERT INTO tasks (title, description, status, priority, due_date) VALUES
('Set up development environment', 'Install Docker, Node.js, and configure the development workspace for the new project.', 'completed', 'high', '2025-09-20'),
('Design database schema', 'Create the PostgreSQL database schema with proper indexes and constraints for optimal performance.', 'completed', 'high', '2025-09-21'),
('Implement user authentication', 'Add JWT-based authentication system with login, register, and password reset functionality.', 'in_progress', 'high', '2025-09-25'),
('Create API documentation', 'Write comprehensive API documentation using Swagger/OpenAPI specification.', 'pending', 'medium', '2025-09-30'),
('Build responsive dashboard', 'Develop a modern, mobile-first dashboard with charts and analytics using React and D3.js.', 'pending', 'high', '2025-10-05'),
('Implement real-time notifications', 'Add WebSocket support for real-time updates and push notifications.', 'pending', 'medium', '2025-10-10'),
('Set up CI/CD pipeline', 'Configure GitHub Actions for automated testing, building, and deployment.', 'pending', 'medium', '2025-10-15'),
('Write unit tests', 'Create comprehensive test suite with Jest and React Testing Library.', 'pending', 'medium', '2025-10-12'),
('Optimize database queries', 'Review and optimize slow database queries, add proper indexing.', 'pending', 'low', '2025-10-20'),
('Deploy to production', 'Set up production environment on AWS/DigitalOcean with proper monitoring.', 'pending', 'high', '2025-10-25'),
('Create user onboarding flow', 'Design and implement smooth user onboarding experience with tooltips and guided tour.', 'pending', 'medium', '2025-09-28'),
('Implement data backup strategy', 'Set up automated database backups and disaster recovery procedures.', 'pending', 'high', '2025-10-08');

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON tasks 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Display initial setup information
DO $$
BEGIN
    RAISE NOTICE 'Database initialized successfully!';
    RAISE NOTICE 'Tables created: tasks';
    RAISE NOTICE 'Sample data inserted: % rows', (SELECT COUNT(*) FROM tasks);
    RAISE NOTICE 'Indexes created for optimal performance';
    RAISE NOTICE 'Triggers set up for automatic timestamp updates';
END $$;