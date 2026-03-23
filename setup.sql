-- ============================================
-- ACH Link Generator + Campaign Naming - Supabase Setup Script
-- Run this in Supabase SQL Editor (supabase.com > SQL Editor)
-- ============================================

-- 1. Brands table
CREATE TABLE IF NOT EXISTS brands (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Platforms table
CREATE TABLE IF NOT EXISTS platforms (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Sources table
CREATE TABLE IF NOT EXISTS sources (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Owners table
CREATE TABLE IF NOT EXISTS owners (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Counter table (tracks next ACHx number)
CREATE TABLE IF NOT EXISTS counters (
  id TEXT PRIMARY KEY DEFAULT 'link_counter',
  value INTEGER NOT NULL DEFAULT 99
);

-- 6. Links table
CREATE TABLE IF NOT EXISTS links (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  user_email TEXT,
  description TEXT NOT NULL,
  brand_id INTEGER NOT NULL REFERENCES brands(id),
  code TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Campaigns table
CREATE TABLE IF NOT EXISTS campaigns (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  user_email TEXT,
  brand_id INTEGER NOT NULL REFERENCES brands(id),
  platform_id INTEGER NOT NULL REFERENCES platforms(id),
  source_id INTEGER NOT NULL REFERENCES sources(id),
  owner_id INTEGER NOT NULL REFERENCES owners(id),
  country_code TEXT NOT NULL,
  link_id INTEGER NOT NULL REFERENCES links(id),
  version INTEGER NOT NULL,
  campaign_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Seed data
-- ============================================

-- Counter (starts at 99, first generated will be ACHx100)
INSERT INTO counters (id, value) VALUES ('link_counter', 99)
ON CONFLICT (id) DO NOTHING;

-- Brands
INSERT INTO brands (name) VALUES
  ('JackPotCity'),
  ('TicTacBets'),
  ('BetBox'),
  ('BoraWin'),
  ('FreeSpins'),
  ('888Arabic'),
  ('Royals Casino'),
  ('CardCrush'),
  ('BetWay')
ON CONFLICT (name) DO NOTHING;

-- Platforms
INSERT INTO platforms (name) VALUES
  ('fb'),
  ('moloco')
ON CONFLICT (name) DO NOTHING;

-- Sources
INSERT INTO sources (name) VALUES
  ('app'),
  ('web'),
  ('Jackpotcharm')
ON CONFLICT (name) DO NOTHING;

-- Owners
INSERT INTO owners (name) VALUES
  ('MB'),
  ('CP')
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- Atomic function to generate next code
-- ============================================
CREATE OR REPLACE FUNCTION generate_next_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  next_val INTEGER;
BEGIN
  UPDATE counters
  SET value = value + 1
  WHERE id = 'link_counter'
  RETURNING value INTO next_val;

  RETURN 'ACHx' || next_val::TEXT;
END;
$$;

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE platforms ENABLE ROW LEVEL SECURITY;
ALTER TABLE sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE links ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE counters ENABLE ROW LEVEL SECURITY;

-- Brands
CREATE POLICY "Authenticated users can read brands" ON brands FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert brands" ON brands FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can delete brands" ON brands FOR DELETE TO authenticated USING (true);

-- Platforms
CREATE POLICY "Authenticated users can read platforms" ON platforms FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert platforms" ON platforms FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can delete platforms" ON platforms FOR DELETE TO authenticated USING (true);

-- Sources
CREATE POLICY "Authenticated users can read sources" ON sources FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert sources" ON sources FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can delete sources" ON sources FOR DELETE TO authenticated USING (true);

-- Owners
CREATE POLICY "Authenticated users can read owners" ON owners FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert owners" ON owners FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can delete owners" ON owners FOR DELETE TO authenticated USING (true);

-- Links: everyone can read all, insert own
CREATE POLICY "Authenticated can read all links" ON links FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert own links" ON links FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Campaigns: everyone can read all, insert own
CREATE POLICY "Authenticated can read all campaigns" ON campaigns FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can insert own campaigns" ON campaigns FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Counter
CREATE POLICY "Authenticated can read counter" ON counters FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can update counter" ON counters FOR UPDATE TO authenticated USING (true);

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_links_user_id ON links(user_id);
CREATE INDEX IF NOT EXISTS idx_links_created_at ON links(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_campaigns_user_id ON campaigns(user_id);
CREATE INDEX IF NOT EXISTS idx_campaigns_created_at ON campaigns(created_at DESC);
