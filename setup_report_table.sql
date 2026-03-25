-- ============================================
-- Report Data Table - Run in Supabase SQL Editor
-- ============================================

CREATE TABLE IF NOT EXISTS report_data (
  id SERIAL PRIMARY KEY,
  report_date DATE NOT NULL,
  month TEXT,
  platform TEXT,
  source TEXT,
  campaign_name TEXT,
  geo TEXT,
  manager TEXT,
  brand TEXT,
  spend NUMERIC DEFAULT 0,
  agency_fee NUMERIC DEFAULT 0,
  real_spend NUMERIC DEFAULT 0,
  installs INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  reg INTEGER DEFAULT 0,
  ftd INTEGER DEFAULT 0,
  ecpa NUMERIC DEFAULT 0,
  income NUMERIC DEFAULT 0,
  profit NUMERIC DEFAULT 0,
  roi NUMERIC DEFAULT 0,
  total_commission_zar NUMERIC DEFAULT 0,
  subtitle TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE report_data ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read report data
CREATE POLICY "Authenticated users can read reports" ON report_data
  FOR SELECT USING (auth.role() = 'authenticated');

-- Allow insert/delete via service role (Python script uses anon key with permissive policy)
CREATE POLICY "Allow insert for all" ON report_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow delete for all" ON report_data
  FOR DELETE USING (true);

-- Index for fast date lookup
CREATE INDEX idx_report_date ON report_data(report_date);
