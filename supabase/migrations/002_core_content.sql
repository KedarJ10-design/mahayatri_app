-- ============================================
-- Mahayatri Database Schema — Phase 2: Core Content
-- ============================================
-- Run this AFTER 001_profiles.sql
-- Dashboard → SQL Editor → New Query → Paste → Run
-- ============================================

-- ─── 1. Destinations ───
CREATE TABLE IF NOT EXISTS public.destinations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  short_description TEXT,
  image_url TEXT,
  cover_url TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  district TEXT,
  category TEXT NOT NULL DEFAULT 'general'
    CHECK (category IN ('fort', 'beach', 'hill_station', 'temple', 'waterfall', 'wildlife', 'heritage', 'general')),
  tags TEXT[] DEFAULT '{}',
  avg_rating DOUBLE PRECISION DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.destinations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Destinations are viewable by everyone"
  ON public.destinations FOR SELECT USING (true);

CREATE POLICY "Only admins can modify destinations"
  ON public.destinations FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ─── 2. Guides ───
CREATE TABLE IF NOT EXISTS public.guides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  phone_number TEXT,
  languages TEXT[] DEFAULT '{Hindi, Marathi}',
  specializations TEXT[] DEFAULT '{}',
  experience_years INTEGER DEFAULT 0,
  hourly_rate DECIMAL(10,2),
  daily_rate DECIMAL(10,2),
  district TEXT,
  is_verified BOOLEAN DEFAULT false,
  is_available BOOLEAN DEFAULT true,
  avg_rating DOUBLE PRECISION DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  total_trips INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.guides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Guides are viewable by everyone"
  ON public.guides FOR SELECT USING (true);

CREATE POLICY "Guide owners can update their profile"
  ON public.guides FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create guide profile"
  ON public.guides FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ─── 3. Stays ───
CREATE TABLE IF NOT EXISTS public.stays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  short_description TEXT,
  type TEXT NOT NULL DEFAULT 'homestay'
    CHECK (type IN ('homestay', 'hotel', 'resort', 'campsite', 'villa', 'hostel')),
  image_url TEXT,
  images TEXT[] DEFAULT '{}',
  price_per_night DECIMAL(10,2) NOT NULL,
  max_guests INTEGER DEFAULT 2,
  district TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  amenities TEXT[] DEFAULT '{}',
  is_verified BOOLEAN DEFAULT false,
  is_available BOOLEAN DEFAULT true,
  avg_rating DOUBLE PRECISION DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.stays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Stays are viewable by everyone"
  ON public.stays FOR SELECT USING (true);

CREATE POLICY "Stay owners can update their listing"
  ON public.stays FOR UPDATE
  USING (auth.uid() = owner_id);

CREATE POLICY "Authenticated users can create stay listing"
  ON public.stays FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- ─── 4. Reviews ───
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('guide', 'stay', 'destination')),
  entity_id UUID NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  images TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reviews are viewable by everyone"
  ON public.reviews FOR SELECT USING (true);

CREATE POLICY "Users can create reviews"
  ON public.reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
  ON public.reviews FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
  ON public.reviews FOR DELETE
  USING (auth.uid() = user_id);

-- ─── 5. Indexes ───
CREATE INDEX IF NOT EXISTS idx_destinations_category ON public.destinations(category);
CREATE INDEX IF NOT EXISTS idx_destinations_featured ON public.destinations(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_destinations_district ON public.destinations(district);
CREATE INDEX IF NOT EXISTS idx_guides_district ON public.guides(district);
CREATE INDEX IF NOT EXISTS idx_guides_verified ON public.guides(is_verified) WHERE is_verified = true;
CREATE INDEX IF NOT EXISTS idx_stays_district ON public.stays(district);
CREATE INDEX IF NOT EXISTS idx_stays_type ON public.stays(type);
CREATE INDEX IF NOT EXISTS idx_stays_price ON public.stays(price_per_night);
CREATE INDEX IF NOT EXISTS idx_reviews_entity ON public.reviews(entity_type, entity_id);

-- ─── 6. Updated_at triggers ───
DROP TRIGGER IF EXISTS on_destination_updated ON public.destinations;
CREATE TRIGGER on_destination_updated
  BEFORE UPDATE ON public.destinations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS on_guide_updated ON public.guides;
CREATE TRIGGER on_guide_updated
  BEFORE UPDATE ON public.guides
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS on_stay_updated ON public.stays;
CREATE TRIGGER on_stay_updated
  BEFORE UPDATE ON public.stays
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
