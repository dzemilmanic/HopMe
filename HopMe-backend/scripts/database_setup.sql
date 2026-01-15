-- ============================================
-- HOPME DATABASE SETUP
-- ============================================

-- Deleting existing enum types and tables (if they exist)
DROP TABLE IF EXISTS testimonials CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS waypoints CASCADE;
DROP TABLE IF EXISTS rides CASCADE;
DROP TABLE IF EXISTS vehicle_images CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS verification_tokens CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS account_status CASCADE;
DROP TYPE IF EXISTS booking_status CASCADE;
DROP TYPE IF EXISTS ride_status CASCADE;

-- Creating enum types
CREATE TYPE user_role AS ENUM ('putnik', 'vozac', 'admin');
CREATE TYPE account_status AS ENUM ('pending', 'approved', 'rejected', 'suspended');
CREATE TYPE booking_status AS ENUM ('pending', 'accepted', 'rejected', 'cancelled', 'completed');
CREATE TYPE ride_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');

-- Creating users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    date_of_birth DATE,
    bio TEXT,
    profile_image_url TEXT,
    roles user_role[] DEFAULT ARRAY['putnik']::user_role[],
    account_status account_status DEFAULT 'pending',
    is_email_verified BOOLEAN DEFAULT false,
    is_phone_verified BOOLEAN DEFAULT false,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating vehicles table
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    year INTEGER,
    license_plate VARCHAR(50),
    color VARCHAR(50),
    seats INTEGER DEFAULT 4,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating vehicle images table
CREATE TABLE vehicle_images (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER REFERENCES vehicles(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    blob_name VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating verification tokens table
CREATE TABLE verification_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating rides table
CREATE TABLE rides (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id INTEGER REFERENCES vehicles(id),
    departure_location VARCHAR(255) NOT NULL,
    departure_lat DECIMAL(10, 8),
    departure_lng DECIMAL(11, 8),
    arrival_location VARCHAR(255) NOT NULL,
    arrival_lat DECIMAL(10, 8),
    arrival_lng DECIMAL(11, 8),
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP,
    available_seats INTEGER NOT NULL,
    price_per_seat DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RSD',
    description TEXT,
    status ride_status DEFAULT 'scheduled',
    auto_accept_bookings BOOLEAN DEFAULT false,
    allow_smoking BOOLEAN DEFAULT false,
    allow_pets BOOLEAN DEFAULT false,
    max_two_in_back BOOLEAN DEFAULT false,
    luggage_size VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating waypoints table
CREATE TABLE waypoints (
    id SERIAL PRIMARY KEY,
    ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
    location VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    order_index INTEGER NOT NULL,
    estimated_time TIMESTAMP
);

-- Creating bookings table
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
    passenger_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    seats_booked INTEGER NOT NULL DEFAULT 1,
    total_price DECIMAL(10, 2) NOT NULL,
    status booking_status DEFAULT 'pending',
    pickup_location VARCHAR(255),
    dropoff_location VARCHAR(255),
    message TEXT,
    driver_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    rejected_at TIMESTAMP,
    completed_at TIMESTAMP
);

-- Creating ratings table
CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES bookings(id) ON DELETE CASCADE,
    ride_id INTEGER REFERENCES rides(id) ON DELETE CASCADE,
    rater_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    rated_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(booking_id, rater_id)
);

-- Creating notifications table
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating testimonials table
CREATE TABLE testimonials (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text TEXT NOT NULL CHECK (char_length(text) >= 10 AND char_length(text) <= 500),
    is_approved BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)  -- One testimonial per user
);

-- Creating user ratings view
CREATE VIEW user_ratings AS
SELECT 
    rated_id as user_id,
    COUNT(*) as total_ratings,
    ROUND(AVG(rating), 2) as average_rating,
    COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
    COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
    COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
    COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
    COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
FROM ratings
GROUP BY rated_id;

-- Creating driver stats view
CREATE VIEW driver_stats AS
SELECT 
    u.id as driver_id,
    COUNT(DISTINCT r.id) as total_rides,
    COUNT(DISTINCT b.id) as total_passengers,
    COALESCE(ur.average_rating, 0) as average_rating,
    COALESCE(ur.total_ratings, 0) as total_ratings
FROM users u
LEFT JOIN rides r ON u.id = r.driver_id
LEFT JOIN bookings b ON r.id = b.ride_id AND b.status = 'completed'
LEFT JOIN user_ratings ur ON u.id = ur.user_id
WHERE 'vozac' = ANY(u.roles)
GROUP BY u.id, ur.average_rating, ur.total_ratings;

-- Creating indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(account_status);
CREATE INDEX idx_vehicles_user ON vehicles(user_id);
CREATE INDEX idx_rides_driver ON rides(driver_id);
CREATE INDEX idx_rides_departure_time ON rides(departure_time);
CREATE INDEX idx_rides_status ON rides(status);
CREATE INDEX idx_bookings_ride ON bookings(ride_id);
CREATE INDEX idx_bookings_passenger ON bookings(passenger_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_ratings_rated ON ratings(rated_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_testimonials_user ON testimonials(user_id);
CREATE INDEX idx_testimonials_approved ON testimonials(is_approved);
CREATE INDEX idx_testimonials_created ON testimonials(created_at);

-- Trigger for updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rides_updated_at BEFORE UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_testimonials_updated_at BEFORE UPDATE ON testimonials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- For creating first admin user, run:
-- npm run create-admin

-- Completed!
SELECT 'Database setup completed successfully!' as message;