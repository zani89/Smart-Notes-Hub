-- Expanded Supabase Schema for Smart Notes Hub (V2 - Multi-Portal)

-- 1. Create custom types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE note_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE request_status AS ENUM ('pending', 'accepted', 'denied');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 2. Create tables
CREATE TABLE IF NOT EXISTS users (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role user_role DEFAULT 'student',
    semester TEXT, -- For students
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    content_url TEXT NOT NULL,
    category TEXT, -- Course
    semester TEXT,
    tags TEXT[] DEFAULT '{}',
    is_shared BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status note_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    note_id UUID REFERENCES notes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (user_id, note_id)
);

CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    target_role user_role, -- student, teacher, or null for all
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    teacher_id UUID REFERENCES users(id) ON DELETE CASCADE,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    grade TEXT,
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS contribution_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    note_id UUID REFERENCES notes(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT,
    status request_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE contribution_requests ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS Policies
-- Users can read their own profile
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);

-- Admin can manage everything
CREATE POLICY "Admin can do anything" ON users FOR ALL USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Notes policies
CREATE POLICY "Anyone can view approved notes" ON notes FOR SELECT USING (status = 'approved');
CREATE POLICY "Anyone can view shared notes" ON notes FOR SELECT USING (is_shared = true);
CREATE POLICY "Authors can manage own notes" ON notes FOR ALL USING (auth.uid() = author_id);
CREATE POLICY "Teachers can view all notes" ON notes FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
);

-- Notifications & Events
CREATE POLICY "Anyone can view notifications" ON notifications FOR SELECT USING (true);
CREATE POLICY "Anyone can view events" ON events FOR SELECT USING (true);
CREATE POLICY "Admins/Teachers can post events" ON events FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
);

-- Storage setup
INSERT INTO storage.buckets (id, name, public) VALUES ('notes_files', 'notes_files', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('submissions', 'submissions', true) ON CONFLICT (id) DO NOTHING;

-- Trigger for profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, name, email, role)
    VALUES (
        new.id,
        new.raw_user_meta_data->>'name',
        new.email,
        COALESCE((new.raw_user_meta_data->>'role')::user_role, 'student')
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
