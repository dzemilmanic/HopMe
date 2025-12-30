-- ============================================
-- ADD TESTIMONIALS TABLE
-- ============================================
-- This migration adds the testimonials table if it doesn't exist

-- Create testimonials table
CREATE TABLE IF NOT EXISTS testimonials (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text TEXT NOT NULL CHECK (char_length(text) >= 10 AND char_length(text) <= 500),
    is_approved BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)  -- One testimonial per user
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_testimonials_user ON testimonials(user_id);
CREATE INDEX IF NOT EXISTS idx_testimonials_approved ON testimonials(is_approved);
CREATE INDEX IF NOT EXISTS idx_testimonials_created ON testimonials(created_at);

-- Create trigger for updating updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add trigger to testimonials table (drop first if exists)
DROP TRIGGER IF EXISTS update_testimonials_updated_at ON testimonials;
CREATE TRIGGER update_testimonials_updated_at BEFORE UPDATE ON testimonials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

SELECT 'Testimonials table created successfully!' as message;
