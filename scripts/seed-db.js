#!/usr/bin/env node

/**
 * Database seeding script
 * Creates tables and inserts sample data (idempotent)
 * 
 * Usage: 
 *   DB_URL=postgresql://postgres:postgres@localhost:5432/gymapp node scripts/seed-db.js
 * 
 * Or with docker-compose running:
 *   docker exec gym-postgres psql -U postgres -d gymapp -c "SELECT 1"
 *   node scripts/seed-db.js
 * 
 * Tables created: users, workouts, sets, coins, stickers
 */

const { Client } = require('pg');

// =============================================================================
// DDL - Create tables (idempotent with IF NOT EXISTS)
// =============================================================================
const DDL = `
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Workouts table
CREATE TABLE IF NOT EXISTS workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  duration_minutes INT DEFAULT 0,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sets table (exercise sets within workouts)
CREATE TABLE IF NOT EXISTS sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_name VARCHAR(255) NOT NULL,
  set_number INT NOT NULL,
  reps INT DEFAULT 0,
  weight_kg DECIMAL(10,2) DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Coins table (gamification currency)
CREATE TABLE IF NOT EXISTS coins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  balance INT DEFAULT 0,
  lifetime_earned INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Stickers table
CREATE TABLE IF NOT EXISTS stickers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  cost_coins INT NOT NULL DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- User stickers (purchased)
CREATE TABLE IF NOT EXISTS user_stickers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  sticker_id UUID REFERENCES stickers(id) ON DELETE CASCADE,
  purchased_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, sticker_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_created_at ON workouts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sets_workout_id ON sets(workout_id);
CREATE INDEX IF NOT EXISTS idx_coins_user_id ON coins(user_id);
CREATE INDEX IF NOT EXISTS idx_user_stickers_user_id ON user_stickers(user_id);
`;

// =============================================================================
// Sample data (idempotent with ON CONFLICT)
// =============================================================================
const SEED_DATA = `
-- Sample user (password: test123 - this is a placeholder hash, replace with bcrypt in production)
INSERT INTO users (id, email, name, password_hash) VALUES
  ('11111111-1111-1111-1111-111111111111', 'alex@example.com', 'Alex', '$2b$10$placeholder_hash_replace_with_real'),
  ('22222222-2222-2222-2222-222222222222', 'jamie@example.com', 'Jamie', '$2b$10$placeholder_hash_replace_with_real')
ON CONFLICT (email) DO NOTHING;

-- Sample workouts
INSERT INTO workouts (id, user_id, title, description, duration_minutes, completed_at) VALUES
  ('aaaa1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Upper Body Strength', 'Chest, shoulders, triceps', 45, NOW() - INTERVAL '1 day'),
  ('aaaa2222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Leg Day', 'Quads, hamstrings, calves', 50, NOW() - INTERVAL '2 days'),
  ('aaaa3333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'HIIT Cardio', 'High intensity intervals', 30, NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- Sample sets
INSERT INTO sets (workout_id, exercise_name, set_number, reps, weight_kg) VALUES
  ('aaaa1111-1111-1111-1111-111111111111', 'Bench Press', 1, 10, 60),
  ('aaaa1111-1111-1111-1111-111111111111', 'Bench Press', 2, 8, 70),
  ('aaaa1111-1111-1111-1111-111111111111', 'Shoulder Press', 1, 12, 30),
  ('aaaa2222-2222-2222-2222-222222222222', 'Squats', 1, 10, 80),
  ('aaaa2222-2222-2222-2222-222222222222', 'Squats', 2, 8, 90)
ON CONFLICT DO NOTHING;

-- Sample coins
INSERT INTO coins (user_id, balance, lifetime_earned) VALUES
  ('11111111-1111-1111-1111-111111111111', 250, 500),
  ('22222222-2222-2222-2222-222222222222', 100, 100)
ON CONFLICT (user_id) DO NOTHING;

-- Sample stickers
INSERT INTO stickers (id, name, description, cost_coins, image_url) VALUES
  ('bbbb1111-1111-1111-1111-111111111111', 'Fire Emoji', 'You are on fire!', 50, '/stickers/fire.webp'),
  ('bbbb2222-2222-2222-2222-222222222222', 'Muscle Flex', 'Show off those gains', 75, '/stickers/muscle.webp'),
  ('bbbb3333-3333-3333-3333-333333333333', 'Trophy', 'Champion vibes', 100, '/stickers/trophy.webp'),
  ('bbbb4444-4444-4444-4444-444444444444', 'Lightning Bolt', 'Speed demon', 60, '/stickers/lightning.webp')
ON CONFLICT DO NOTHING;
`;

// =============================================================================
// Main
// =============================================================================
async function seed() {
  const connectionString = process.env.DB_URL ||
    process.env.DATABASE_URL ||
    'postgresql://postgres:postgres@localhost:5432/gymapp';

  const client = new Client({ connectionString });

  try {
    console.log('🔄 Connecting to database...');
    console.log(`   URL: ${connectionString.replace(/:[^:@]+@/, ':***@')}`);
    await client.connect();

    console.log('📋 Creating tables...');
    await client.query(DDL);

    console.log('🌱 Inserting sample data...');
    await client.query(SEED_DATA);

    // Verify
    const userCount = await client.query('SELECT COUNT(*) FROM users');
    const workoutCount = await client.query('SELECT COUNT(*) FROM workouts');
    const stickerCount = await client.query('SELECT COUNT(*) FROM stickers');

    console.log('');
    console.log('✅ Database seeded successfully!');
    console.log(`   Users: ${userCount.rows[0].count}`);
    console.log(`   Workouts: ${workoutCount.rows[0].count}`);
    console.log(`   Stickers: ${stickerCount.rows[0].count}`);

  } catch (err) {
    console.error('❌ Seeding failed:', err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

seed();
