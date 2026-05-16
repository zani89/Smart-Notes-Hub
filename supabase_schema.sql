-- Expanded Supabase Schema for Smart Notes Hub (V2 - Multi-Portal)

-- 1. Create custom types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE note_status AS ENUM ('pending', 'approved', 'rejected', 'requested_collab');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE request_status AS ENUM ('pending', 'accepted', 'denied');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 2. Create tables
CREATE TABLE IF NOT EXISTS users (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    name TEXT,
    email TEXT UNIQUE,
    uni_id TEXT UNIQUE,
    semester TEXT,
    role TEXT DEFAULT 'student',
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Note: We'll handle the 'at least one' constraint via application logic 
-- or a more flexible check to avoid trigger failures.

CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    content_url TEXT,
    uploader_id UUID REFERENCES users(id) ON DELETE CASCADE,
    semester TEXT NOT NULL,
    course TEXT NOT NULL,
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
-- Admin check function to avoid recursion
CREATE OR REPLACE FUNCTION public.is_admin() 
RETURNS boolean AS $$
  SELECT role = 'admin' FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Users
DROP POLICY IF EXISTS "Users can view own profile" ON users;
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON users;
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admin can do anything" ON users;
CREATE POLICY "Admin can do anything" ON users FOR ALL USING (public.is_admin());

-- Notes
DROP POLICY IF EXISTS "Anyone can view public notes" ON notes;
CREATE POLICY "Anyone can view public notes" ON notes FOR SELECT USING (status IN ('approved', 'requested_collab'));

DROP POLICY IF EXISTS "Authors can manage own notes" ON notes;
CREATE POLICY "Authors can manage own notes" ON notes FOR ALL USING (auth.uid() = uploader_id);

DROP POLICY IF EXISTS "Students can view own notes" ON notes;
CREATE POLICY "Students can view own notes" ON notes FOR SELECT USING (auth.uid() = uploader_id);

DROP POLICY IF EXISTS "Teachers can view all notes" ON notes;
CREATE POLICY "Teachers can view all notes" ON notes FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
);

DROP POLICY IF EXISTS "Anyone can view sample notes" ON notes;
CREATE POLICY "Anyone can view sample notes" ON notes FOR SELECT USING (uploader_id IS NULL);

-- Notifications & Events
DROP POLICY IF EXISTS "Anyone can view notifications" ON notifications;
CREATE POLICY "Anyone can view notifications" ON notifications FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can view events" ON events;
CREATE POLICY "Anyone can view events" ON events FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins/Teachers can post events" ON events;
CREATE POLICY "Admins/Teachers can post events" ON events FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
);

-- Assignments
DROP POLICY IF EXISTS "Anyone can view assignments" ON assignments;
CREATE POLICY "Anyone can view assignments" ON assignments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Teachers can manage assignments" ON assignments;
CREATE POLICY "Teachers can manage assignments" ON assignments FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
);

-- Submissions
DROP POLICY IF EXISTS "Students can view own submissions" ON submissions;
CREATE POLICY "Students can view own submissions" ON submissions FOR SELECT USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Students can submit assignments" ON submissions;
CREATE POLICY "Students can submit assignments" ON submissions FOR INSERT WITH CHECK (auth.uid() = student_id);

DROP POLICY IF EXISTS "Teachers can view all submissions" ON submissions;
CREATE POLICY "Teachers can view all submissions" ON submissions FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
);

-- Contribution Requests
DROP POLICY IF EXISTS "Students can create requests" ON contribution_requests;
CREATE POLICY "Students can create requests" ON contribution_requests FOR INSERT WITH CHECK (auth.uid() = student_id);

DROP POLICY IF EXISTS "Users can view own requests" ON contribution_requests;
CREATE POLICY "Users can view own requests" ON contribution_requests FOR SELECT USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Teachers can view all requests" ON contribution_requests;
CREATE POLICY "Teachers can view all requests" ON contribution_requests FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
);

DROP POLICY IF EXISTS "Teachers can update requests" ON contribution_requests;
CREATE POLICY "Teachers can update requests" ON contribution_requests FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
);

-- Storage setup
INSERT INTO storage.buckets (id, name, public) VALUES ('notes_files', 'notes_files', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('submissions', 'submissions', true) ON CONFLICT (id) DO NOTHING;

-- Trigger for profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger for profile creation (REMOVED: Handle insert from Flutter client instead)
-- Actually, we'll keep the trigger as a backup or for basic info, 
-- but the Flutter client will update the rest.

-- 5. Storage Policies
-- Bucket for Notes
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'notes_files');

DROP POLICY IF EXISTS "Authenticated users can upload notes" ON storage.objects;
CREATE POLICY "Authenticated users can upload notes" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'notes_files' AND auth.role() = 'authenticated'
);

-- Bucket for Profile Images
DROP POLICY IF EXISTS "Profile images are public" ON storage.objects;
CREATE POLICY "Profile images are public" ON storage.objects FOR SELECT USING (bucket_id = 'profile_images');

DROP POLICY IF EXISTS "Users can upload own profile image" ON storage.objects;
CREATE POLICY "Users can upload own profile image" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'profile_images' AND auth.role() = 'authenticated'
);

DROP POLICY IF EXISTS "Users can update own profile image" ON storage.objects;
CREATE POLICY "Users can update own profile image" ON storage.objects FOR UPDATE USING (
    bucket_id = 'profile_images' AND auth.uid() = owner
);

DROP POLICY IF EXISTS "Authors can delete own notes" ON storage.objects;
CREATE POLICY "Authors can delete own notes" ON storage.objects FOR DELETE USING (
    auth.uid() = owner
);

