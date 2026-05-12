-- Supabase Schema for Smart Notes Hub

-- 1. Create custom types
CREATE TYPE user_role AS ENUM ('student', 'teacher');
CREATE TYPE note_status AS ENUM ('pending', 'approved', 'rejected');

-- 2. Create tables
CREATE TABLE users (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role user_role DEFAULT 'student',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    content_url TEXT NOT NULL,
    category TEXT,
    author_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status note_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    teacher_id UUID REFERENCES users(id) ON DELETE CASCADE,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    grade TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS Policies
-- Users can read their own profile
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
-- Teachers can view all profiles
CREATE POLICY "Teachers can view all profiles" ON users FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
);

-- Notes:
-- Authors can view and edit their own notes
CREATE POLICY "Authors can view own notes" ON notes FOR SELECT USING (auth.uid() = author_id);
CREATE POLICY "Authors can insert own notes" ON notes FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Authors can update own notes" ON notes FOR UPDATE USING (auth.uid() = author_id);
-- Teachers can view all notes (for approval queue)
CREATE POLICY "Teachers can view all notes" ON notes FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
);
-- Teachers can update notes (to approve/reject)
CREATE POLICY "Teachers can update notes" ON notes FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher')
);
-- Everyone can view approved notes
CREATE POLICY "Anyone can view approved notes" ON notes FOR SELECT USING (status = 'approved');

-- 5. Storage setup (assuming bucket 'notes_files' exists)
INSERT INTO storage.buckets (id, name) VALUES ('notes_files', 'notes_files');

-- Enable RLS on storage bucket (replace 'notes_files' with actual bucket ID if different)
-- Policy to allow authenticated uploads to 'notes_files'
CREATE POLICY "Authenticated users can upload files" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'notes_files');
CREATE POLICY "Authenticated users can view files" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'notes_files');
