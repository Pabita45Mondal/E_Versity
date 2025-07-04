
-- This script defines the schema for the E_Varsity database, which is designed to manage an online education platform.
-- It includes tables for users, courses, progress tracking, donations, scholarships, live classes, notifications, and more.

-- Create and Use Database
CREATE DATABASE IF NOT EXISTS E_Varsity; 
USE E_Varsity; -- Switches to the E_Varsity database

-- Users Table: Shortened and obfuscated attribute names
CREATE TABLE Users (
    uid INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each user
    fname VARCHAR(255) NOT NULL, -- Full name of the user
    mail VARCHAR(255) UNIQUE NOT NULL, -- Email address
    pwd_hash VARCHAR(255) NOT NULL, -- Hashed password
    slt VARCHAR(255) NOT NULL, -- Salt for hashing
    rl ENUM(
        'student', 
        'instructor', 
        'admin', 
        'technical_officer', 
        'professor', 
        'teaching_assistant', 
        'HOD', 
        'student_mentor', 
        'faculty_advisor', 
        '2nd_year_senior', 
        '3rd_year_senior', 
        '4th_year_senior', 
        'part_time_professor', 
        'part_time_student'
    ) NOT NULL, -- Role of the user
    act BOOLEAN DEFAULT TRUE, -- Indicates if the user is active
    dual_deg BOOLEAN DEFAULT FALSE, -- Indicates if the user is pursuing a dual degree
    ctime TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of account creation
);

-- Password Reset Table: Shortened and obfuscated attribute names
CREATE TABLE PasswordResets (
    rid INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each reset request
    uid INT, -- User ID
    rtoken VARCHAR(255) UNIQUE NOT NULL, -- Reset token
    exp TIMESTAMP NOT NULL, -- Expiration time
    used BOOLEAN DEFAULT FALSE, -- Indicates if the token has been used
    FOREIGN KEY (uid) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- User Sessions Table: Tracks active login sessions for users
CREATE TABLE UserSessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each session
    user_id INT, -- ID of the user logged in
    session_token VARCHAR(255) UNIQUE NOT NULL, -- Unique token for the session
    ip_address VARCHAR(50), -- IP address of the user during the session
    user_agent TEXT, -- User agent string (browser/device information)
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Login timestamp
    expires_at TIMESTAMP NOT NULL, -- Expiration time for the session
    FOREIGN KEY (user_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Login History Table: Tracks login and logout information for users
CREATE TABLE LoginHistory (
    login_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each login record
    user_id INT, -- ID of the user logging in
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Login timestamp
    logout_time TIMESTAMP NULL DEFAULT NULL, -- Logout timestamp
    location VARCHAR(255), -- Location of the user during login
    FOREIGN KEY (user_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Courses Table: Shortened and obfuscated attribute names
CREATE TABLE Courses (
    cid INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each course
    cname VARCHAR(255) NOT NULL, -- Name of the course
    desc TEXT, -- Description of the course
    cat VARCHAR(100), -- Category of the course
    prc DECIMAL(10,2) DEFAULT 0.00, -- Price of the course
    ctime TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of course creation
    CONSTRAINT chk_prc_non_negative CHECK (prc >= 0) -- Ensure non-negative price
);

-- Semesters Table: Defines semesters for each course
CREATE TABLE Semesters (
    semester_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each semester
    course_id INT, -- ID of the course the semester belongs to
    semester_number INT NOT NULL, -- Semester number (e.g., 1, 2, 3)
    semester_name VARCHAR(50) NOT NULL, -- Name of the semester
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE -- Links to the Courses table
);

-- Subjects Table: Lists subjects offered in each semester
CREATE TABLE Subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each subject
    course_id INT, -- ID of the course the subject belongs to
    semester_number INT NOT NULL, -- Semester number the subject is part of
    subject_name VARCHAR(255) NOT NULL, -- Name of the subject
    credits INT NOT NULL, -- Number of credits for the subject
    type ENUM('Theory', 'Lab', 'BSC', 'HSC', 'ESC', 'PCC', 'PEC', 'OEC', 'MNC') NOT NULL, -- Type of subject
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE -- Links to the Courses table
);

-- Enrollments Table: Shortened and obfuscated attribute names
CREATE TABLE Enrollments (
    eid INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each enrollment
    sid INT, -- Student ID
    cid INT, -- Course ID
    etime TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Enrollment timestamp
    FOREIGN KEY (sid) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the Users table
    FOREIGN KEY (cid) REFERENCES Courses(cid) ON DELETE CASCADE -- Links to the Courses table
);

-- Lessons Table: Stores course content (lessons)
CREATE TABLE Lessons (
    lesson_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each lesson
    course_id INT, -- ID of the course the lesson belongs to
    title VARCHAR(255) NOT NULL, -- Title of the lesson
    content TEXT, -- Content of the lesson
    video_url VARCHAR(255), -- URL of the lesson video
    position INT DEFAULT 1, -- Position/order of the lesson
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of lesson creation
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE -- Links to the Courses table
);

-- Assignments Table: Tracks assignments for courses
CREATE TABLE Assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each assignment
    course_id INT, -- ID of the course the assignment belongs to
    title VARCHAR(255) NOT NULL, -- Title of the assignment
    description TEXT, -- Description of the assignment
    due_date DATE, -- Due date for the assignment
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of assignment creation
    deadline_notification_sent BOOLEAN DEFAULT FALSE, -- Whether a deadline notification has been sent
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE, -- Links to the Courses table
    CONSTRAINT chk_assignment_due_date_future CHECK (due_date >= CURRENT_DATE) -- Ensure that assignment due date is in the future
);

-- Submissions Table: Tracks student submissions for assignments
CREATE TABLE Submissions (
    submission_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each submission
    assignment_id INT, -- ID of the assignment the submission is for
    student_id INT, -- ID of the student who submitted
    file_url VARCHAR(255), -- URL of the submitted file
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of submission
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id) ON DELETE CASCADE, -- Links to the Assignments table
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Plagiarism Check Table
CREATE TABLE PlagiarismChecks (
    check_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT,
    similarity_score DECIMAL(5,2) NOT NULL, 
    matched_sources TEXT,
    flagged BOOLEAN DEFAULT FALSE,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES Submissions(submission_id) ON DELETE CASCADE
);

-- Cheating Prevention Table (Online Exams)
CREATE TABLE ExamMonitoring (
    monitor_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    exam_id INT,
    face_tracking BOOLEAN DEFAULT FALSE,
    screen_activity BOOLEAN DEFAULT FALSE,
    suspicious_behavior BOOLEAN DEFAULT FALSE,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE
);

-- Progress Tracking Tables

-- Track Lesson Completion
CREATE TABLE LessonProgress (
    progress_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    lesson_id INT,
    is_completed BOOLEAN DEFAULT FALSE,
    completion_date TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES Lessons(lesson_id) ON DELETE CASCADE
);

-- Track Assignment Progress
CREATE TABLE AssignmentProgress (
    progress_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    assignment_id INT,
    is_submitted BOOLEAN DEFAULT FALSE,
    submitted_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE,
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id) ON DELETE CASCADE
);

-- Track Overall Course Progress
CREATE TABLE CourseProgress (
    progress_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    total_lessons INT DEFAULT 0,
    completed_lessons INT DEFAULT 0,
    total_assignments INT DEFAULT 0,
    submitted_assignments INT DEFAULT 0,
    progress_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN total_lessons + total_assignments = 0 THEN 0
            ELSE (completed_lessons + submitted_assignments) * 100.0 / (total_lessons + total_assignments)
        END
    ) STORED,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE
);

-- Grading System Table
CREATE TABLE GradingSystem (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    min_percentage DECIMAL(5,2) NOT NULL,
    max_percentage DECIMAL(5,2) NOT NULL,
    grade VARCHAR(2) NOT NULL,
    grade_points DECIMAL(3,1) NOT NULL,
    remarks VARCHAR(50) NOT NULL
);

-- Semester Progression Constraints
CREATE TABLE SemesterPrerequisites (
    prerequisite_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    current_semester INT NOT NULL,
    next_semester INT NOT NULL,
    min_credits_required INT NOT NULL,
    min_gpa_required DECIMAL(3,2) NOT NULL,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE
);

-- Certificates Table
CREATE TABLE Certificates (
    certificate_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    certificate_type ENUM('Completion', 'Excellence', 'Proficiency') NOT NULL,
    certificate_url VARCHAR(255),
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE
);

-- Payment Gateway Options
CREATE TABLE PaymentGateways (
    gateway_id INT AUTO_INCREMENT PRIMARY KEY,
    gateway_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    transaction_fee DECIMAL(5,2) DEFAULT 0.00,
    supported_currencies VARCHAR(255)
);

-- Course Reviews Table
CREATE TABLE CourseReviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    rating DECIMAL(3,2) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE
);

-- Dropout and Refund Management
CREATE TABLE CourseDropouts (
    dropout_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date TIMESTAMP,
    dropout_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_course_duration INT, -- Total course duration in days
    completed_duration INT, -- Completed duration in days
    refund_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN completed_duration <= (total_course_duration * 0.25) THEN 90.00
            WHEN completed_duration <= (total_course_duration * 0.50) THEN 50.00
            WHEN completed_duration <= (total_course_duration * 0.75) THEN 25.00
            ELSE 0.00
        END
    ) STORED,
    refund_amount DECIMAL(10,2) GENERATED ALWAYS AS (
        (SELECT prc FROM Courses WHERE cid = CourseDropouts.course_id) * (refund_percentage / 100)
    ) STORED,
    reason TEXT,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE
);

-- Donations Table
CREATE TABLE Donations (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(255) NOT NULL,
    donor_email VARCHAR(255),
    amount DECIMAL(10,2) NOT NULL,
    purpose ENUM('General Fund', 'Scholarship Fund', 'Infrastructure Development') NOT NULL,
    donated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_donation_amount_positive CHECK (amount > 0) -- Ensure that donation amount is positive
);

-- Scholarships Table
CREATE TABLE Scholarships (
    scholarship_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    scholarship_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE,
    CONSTRAINT chk_scholarship_amount_positive CHECK (amount > 0) -- Ensure that scholarship amount is positive
);

-- Medals Table
CREATE TABLE Medals (
    medal_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    medal_type ENUM('Branch Topper', 'University Topper') NOT NULL,
    academic_year YEAR NOT NULL,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE
);

-- Student Profiles Table: Stores additional profile information for students
CREATE TABLE StudentProfiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each profile
    student_id INT UNIQUE, -- ID of the student (unique)
    photo_url VARCHAR(255), -- URL of the student's profile photo
    leetcode_ranking INT, -- Ranking on LeetCode
    leetcode_questions_solved INT, -- Number of questions solved on LeetCode
    codeforces_ranking INT, -- Ranking on Codeforces
    codeforces_questions_solved INT, -- Number of questions solved on Codeforces
    other_platform_ranking INT, -- Ranking on another coding platform
    other_platform_questions_solved INT, -- Number of questions solved on another platform
    overall_score DECIMAL(5,2) GENERATED ALWAYS AS ( -- Overall score calculation
        (SELECT AVG(progress_percentage) FROM CourseProgress WHERE student_id = StudentProfiles.student_id) * 0.5 +
        (leetcode_questions_solved + codeforces_questions_solved + other_platform_questions_solved) * 0.5
    ) STORED,
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Skills Table: Tracks skills mastered by students
CREATE TABLE Skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each skill
    student_id INT, -- ID of the student who mastered the skill
    skill_name VARCHAR(255) NOT NULL, -- Name of the skill
    skill_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') NOT NULL, -- Level of mastery
    skill_rating DECIMAL(3,2) CHECK (skill_rating BETWEEN 0 AND 5), -- Rating for the skill
    certificate_url VARCHAR(255), -- URL of the certificate for the skill
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Privileges Table: Defines role-based access control
CREATE TABLE Privileges (
    privilege_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each privilege
    role ENUM('student', 'instructor', 'admin', 'technical_officer', 'professor', 'HOD', 'student_mentor', 'faculty_advisor', '2nd_year_senior', '3rd_year_senior', '4th_year_senior', 'part_time_professor', 'part_time_student') NOT NULL, -- Role associated with the privilege
    privilege_name VARCHAR(255) NOT NULL, -- Name of the privilege
    description TEXT -- Description of the privilege
);

-- Insert Privileges for Each Role
INSERT INTO Privileges (role, privilege_name, description) VALUES
('student', 'View Grades', 'Students can view their grades'),
('student', 'Rate Courses', 'Students can rate courses and professors'),
('professor', 'Assign Grades', 'Professors can assign grades to students'),
('professor', 'Choose Courses', 'Professors can choose which courses to teach'),
('technical_officer', 'Manage Database', 'Technical Officers can manage the database'),
('admin', 'Full Access', 'Admins have full access to the system'),
('HOD', 'Manage Department', 'HOD can manage department-level activities'),
('HOD', 'Approve Courses', 'HOD can approve courses for the department'),
('student_mentor', 'Mentor Students', 'Student mentors can guide students on academic and personal matters'),
('faculty_advisor', 'Advise Students', 'Faculty advisors can provide academic advice to students'),
('faculty_advisor', 'Approve Course Registrations', 'Faculty advisors can approve course registrations for students');

-- Ratings Table: Stores app ratings and feedback
CREATE TABLE Ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each rating
    user_id INT, -- ID of the user giving the rating
    rating DECIMAL(3,2) NOT NULL CHECK (rating BETWEEN 1 AND 5), -- Rating value (1 to 5)
    feedback TEXT, -- Optional feedback text
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the rating
    FOREIGN KEY (user_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Grades Table: Professors can submit grades for students
CREATE TABLE Grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each grade
    student_id INT, -- ID of the student receiving the grade
    subject_id INT, -- ID of the subject the grade is for
    professor_id INT, -- ID of the professor assigning the grade
    grade VARCHAR(2) NOT NULL, -- Grade (e.g., A, B, C)
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of grade submission
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the Users table
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id) ON DELETE CASCADE, -- Links to the Subjects table
    FOREIGN KEY (professor_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Course and Professor Ratings Table: Students can rate courses and professors
CREATE TABLE CourseProfessorRatings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each rating
    student_id INT, -- ID of the student giving the rating
    course_id INT, -- ID of the course being rated
    professor_id INT, -- ID of the professor being rated
    course_rating DECIMAL(3,2) NOT NULL CHECK (course_rating BETWEEN 1 AND 5), -- Rating for the course
    professor_rating DECIMAL(3,2) NOT NULL CHECK (professor_rating BETWEEN 1 AND 5), -- Rating for the professor
    feedback TEXT, -- Optional feedback text
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the rating
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the Users table
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE, -- Links to the Courses table
    FOREIGN KEY (professor_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Teaching Assistants Table: Stores information about TAs
CREATE TABLE TeachingAssistants (
    ta_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each TA
    user_id INT UNIQUE, -- ID of the user who is a TA
    professor_id INT, -- ID of the professor the TA assists
    assigned_courses TEXT, -- List of courses the TA is assigned to
    FOREIGN KEY (user_id) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the Users table
    FOREIGN KEY (professor_id) REFERENCES Users(uid) ON DELETE SET NULL -- Links to the professor
);

-- Doubts Table: Tracks doubts asked by students
CREATE TABLE Doubts (
    doubt_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each doubt
    student_id INT, -- ID of the student asking the doubt
    course_id INT, -- ID of the course related to the doubt
    ta_id INT, -- ID of the TA resolving the doubt
    professor_id INT, -- ID of the professor resolving the doubt (if applicable)
    doubt_text TEXT NOT NULL, -- The doubt/question asked by the student
    resolution_text TEXT, -- The resolution/answer provided
    is_resolved BOOLEAN DEFAULT FALSE, -- Whether the doubt has been resolved
    asked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the doubt was asked
    resolved_at TIMESTAMP NULL DEFAULT NULL, -- Timestamp when the doubt was resolved
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the Users table
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE, -- Links to the Courses table
    FOREIGN KEY (ta_id) REFERENCES TeachingAssistants(ta_id) ON DELETE SET NULL, -- Links to the TA
    FOREIGN KEY (professor_id) REFERENCES Users(uid) ON DELETE SET NULL -- Links to the professor
);

-- Counselling Requests Table: Tracks counseling requests from students
CREATE TABLE CounsellingRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each request
    student_id INT, -- ID of the student requesting counseling
    ta_id INT, -- ID of the TA providing counseling
    request_text TEXT NOT NULL, -- Details of the counseling request
    is_completed BOOLEAN DEFAULT FALSE, -- Whether the counseling session is completed
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the request was made
    completed_at TIMESTAMP NULL DEFAULT NULL, -- Timestamp when the session was completed
    FOREIGN KEY (student_id) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the Users table
    FOREIGN KEY (ta_id) REFERENCES TeachingAssistants(ta_id) ON DELETE SET NULL -- Links to the TA
);

-- Notifications Table: Tracks email and SMS notifications sent to users
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each notification
    user_id INT, -- ID of the user receiving the notification
    notification_type ENUM('email', 'sms') NOT NULL, -- Type of notification
    message TEXT NOT NULL, -- Notification message content
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the notification was sent
    FOREIGN KEY (user_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Live Classes Table: Tracks live classes and related information
CREATE TABLE LiveClasses (
    live_class_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each live class
    course_id INT, -- ID of the course the live class belongs to
    professor_id INT, -- ID of the professor conducting the live class
    start_time TIMESTAMP NOT NULL, -- Start time of the live class
    end_time TIMESTAMP NOT NULL, -- End time of the live class
    topic VARCHAR(255) NOT NULL, -- Topic of the live class
    comments TEXT, -- Comments made during the live class
    student_count INT DEFAULT 0, -- Count of students attending the live class
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE, -- Links to the Courses table
    FOREIGN KEY (professor_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Revenue Table: Tracks total revenue generated
CREATE TABLE Revenue (
    revenue_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each revenue record
    source ENUM('course_fee', 'donation') NOT NULL, -- Source of revenue
    amount DECIMAL(10,2) NOT NULL, -- Amount of revenue generated
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp when the revenue was generated
);

-- E-Resources Table: Stores e-journals, e-books, and research papers
CREATE TABLE EResources (
    resource_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each resource
    title VARCHAR(255) NOT NULL, -- Title of the resource
    type ENUM('e-journal', 'e-book', 'research-paper') NOT NULL, -- Type of resource
    author VARCHAR(255), -- Author of the resource
    publication_date DATE, -- Publication date of the resource
    description TEXT, -- Description of the resource
    file_url VARCHAR(255), -- URL to download the resource
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of resource creation
);

-- Third-Party Links Table: Stores links to external websites for journals, books, and referrals
CREATE TABLE ThirdPartyLinks (
    link_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each link
    resource_id INT, -- ID of the related resource (optional)
    link_type ENUM('journal', 'book', 'referral') NOT NULL, -- Type of link
    url VARCHAR(255) NOT NULL, -- URL of the third-party website
    description TEXT, -- Description of the link
    FOREIGN KEY (resource_id) REFERENCES EResources(resource_id) ON DELETE SET NULL -- Links to the EResources table
);

-- Course Discounts Table: Tracks discounts on courses based on referrals
CREATE TABLE CourseDiscounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each discount
    course_id INT, -- ID of the course the discount applies to
    referral_code VARCHAR(50) NOT NULL, -- Referral code for the discount
    discount_percentage DECIMAL(5,2) NOT NULL CHECK (discount_percentage BETWEEN 0 AND 100), -- Discount percentage
    valid_from DATE NOT NULL, -- Start date of the discount
    valid_until DATE NOT NULL, -- End date of the discount
    FOREIGN KEY (course_id) REFERENCES Courses(cid) ON DELETE CASCADE -- Links to the Courses table
);

-- Faculty Details Table: Stores detailed information about faculty members
CREATE TABLE FacultyDetails (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each faculty member
    user_id INT UNIQUE, -- ID of the user (must be a professor)
    email VARCHAR(255) NOT NULL, -- Email address of the faculty member
    phone_number VARCHAR(15), -- Phone number of the faculty member
    research_area TEXT, -- Research area(s) of the faculty member
    current_publications TEXT, -- List of current publications
    research_id VARCHAR(50), -- Research ID (e.g., ORCID, Scopus ID)
    room_number VARCHAR(50), -- Room number of the faculty member
    designation VARCHAR(100), -- Designation (e.g., Professor, Assistant Professor)
    FOREIGN KEY (user_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Guidance Sessions Table: Tracks guidance sessions between senior and junior students
CREATE TABLE GuidanceSessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each session
    senior_id INT, -- ID of the senior student
    junior_id INT, -- ID of the junior student
    topic VARCHAR(255) NOT NULL, -- Topic of the guidance session
    session_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Date and time of the session
    feedback TEXT, -- Feedback from the junior student
    FOREIGN KEY (senior_id) REFERENCES Users(uid) ON DELETE CASCADE, -- Links to the senior student
    FOREIGN KEY (junior_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the junior student
);

-- Part-Time Professor Payments Table: Shortened and obfuscated attribute names
CREATE TABLE PartTimeProfessorPayments (
    pid INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each payment record
    prof_id INT, -- ID of the part-time professor
    hr_rate DECIMAL(10,2) NOT NULL, -- Hourly rate
    hrs DECIMAL(5,2) NOT NULL, -- Hours worked
    total DECIMAL(10,2) GENERATED ALWAYS AS (hr_rate * hrs) STORED, -- Total payment
    pdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Payment date
    FOREIGN KEY (prof_id) REFERENCES Users(uid) ON DELETE CASCADE -- Links to the Users table
);

-- Insert BTech Courses
INSERT INTO Courses (cname, desc, cat, prc) 
VALUES 
('BTech Computer Science and Engineering', '4-year undergraduate program in Computer Science and Engineering', 'Engineering', 0.00),
('BTech Mathematics and Computing', '4-year undergraduate program in Mathematics and Computing', 'Engineering', 0.00);

-- Get Course IDs
SET @CSE_Course_ID = (SELECT cid FROM Courses WHERE cname = 'BTech Computer Science and Engineering' LIMIT 1);
SET @MnC_Course_ID = (SELECT cid FROM Courses WHERE cname = 'BTech Mathematics and Computing' LIMIT 1);

-- Insert Semesters for BTech CSE
INSERT INTO Semesters (course_id, semester_number, semester_name) 
VALUES 
(@CSE_Course_ID, 1, 'Semester 1'), (@CSE_Course_ID, 2, 'Semester 2'), 
(@CSE_Course_ID, 3, 'Semester 3'), (@CSE_Course_ID, 4, 'Semester 4'), 
(@CSE_Course_ID, 5, 'Semester 5'), (@CSE_Course_ID, 6, 'Semester 6'), 
(@CSE_Course_ID, 7, 'Semester 7'), (@CSE_Course_ID, 8, 'Semester 8');

-- Insert Semesters for BTech MnC
INSERT INTO Semesters (course_id, semester_number, semester_name) 
VALUES 
(@MnC_Course_ID, 1, 'Semester 1'), (@MnC_Course_ID, 2, 'Semester 2'), 
(@MnC_Course_ID, 3, 'Semester 3'), (@MnC_Course_ID, 4, 'Semester 4'), 
(@MnC_Course_ID, 5, 'Semester 5'), (@MnC_Course_ID, 6, 'Semester 6'), 
(@MnC_Course_ID, 7, 'Semester 7'), (@MnC_Course_ID, 8, 'Semester 8');

-- Insert Subjects for CSE
INSERT INTO Subjects (course_id, semester_number, subject_name, credits, type) VALUES
-- Semester 1
(@CSE_Course_ID, 1, 'Induction Program', 0, 'MNC'),
(@CSE_Course_ID, 1, 'Linear Algebra, Calculus and Differential Equations', 3, 'BSC'),
(@CSE_Course_ID, 1, 'English for Technical Communication', 3, 'HSC'),
(@CSE_Course_ID, 1, 'Applied Physics', 3, 'BSC'),
(@CSE_Course_ID, 1, 'Economics and Financial Analysis', 3, 'HSC'),
(@CSE_Course_ID, 1, 'Problem Solving and Computer Programming', 3, 'ESC'),
(@CSE_Course_ID, 1, 'Applied Physics Laboratory', 2, 'BSC'),
(@CSE_Course_ID, 1, 'Problem Solving and Computer Programming Laboratory', 3, 'ESC'),
(@CSE_Course_ID, 1, 'Extra Academic Activity', 0, 'MNC'),

-- Semester 3
(@CSE_Course_ID, 3, 'Operating Systems', 3, 'PCC'),
(@CSE_Course_ID, 3, 'Data Warehousing and Data Mining', 3, 'PCC'),
(@CSE_Course_ID, 3, 'Software Engineering', 3, 'PCC'),
(@CSE_Course_ID, 3, 'Computer Networks', 3, 'PCC'),
(@CSE_Course_ID, 3, 'Department Elective - 1', 3, 'PEC'),
(@CSE_Course_ID, 3, 'Operating Systems Laboratory', 2, 'PCC'),
(@CSE_Course_ID, 3, 'Knowledge Engineering Laboratory', 1, 'PCC'),
(@CSE_Course_ID, 3, 'CASE Tools Laboratory', 2, 'PCC'),
(@CSE_Course_ID, 3, 'Computer Networks Laboratory', 2, 'PCC'),
(@CSE_Course_ID, 3, 'Mandatory Non-Credit Course', 0, 'MNC'),

-- Semester 5
(@CSE_Course_ID, 5, 'Mobile Computing', 3, 'PCC'),
(@CSE_Course_ID, 5, 'Cryptography', 3, 'PCC'),
(@CSE_Course_ID, 5, 'Machine Learning', 3, 'PCC'),
(@CSE_Course_ID, 5, 'Advanced Algorithms', 3, 'PCC'),
(@CSE_Course_ID, 5, 'Department Elective - 2', 3, 'PEC'),
(@CSE_Course_ID, 5, 'Department Elective - 3', 3, 'PEC'),

-- Semester 7
(@CSE_Course_ID, 7, 'Deep Learning', 3, 'PCC'),
(@CSE_Course_ID, 7, 'Network Security', 3, 'PCC'),
(@CSE_Course_ID, 7, 'Department Elective - 4', 3, 'PEC'),
(@CSE_Course_ID, 7, 'Department Elective - 5', 3, 'PEC'),
(@CSE_Course_ID, 7, 'Department Elective - 6', 3, 'PEC'),

-- Semester 8
(@CSE_Course_ID, 8, 'Open Elective', 3, 'OEC');

-- Insert Subjects for Mathematics and Computing
INSERT INTO Subjects (course_id, semester_number, subject_name, credits, type) VALUES
-- Semester 1
(@MnC_Course_ID, 1, 'MA111 Calculus', 3, 'Theory'),
(@MnC_Course_ID, 1, 'MA112 Algebraic Structures', 3, 'Theory'),
(@MnC_Course_ID, 1, 'MA144 Problem Solving and Computer Programming', 3, 'Theory'),
(@MnC_Course_ID, 1, 'HS132 English for Technical Communication', 3, 'Theory'),
(@MnC_Course_ID, 1, 'PH131 Applied Physics', 3, 'Theory'),
(@MnC_Course_ID, 1, 'ME102 Design Thinking', 3, 'Theory'),
(@MnC_Course_ID, 1, 'MA145 Problem Solving and Computer Programming Lab', 1, 'Lab'),
(@MnC_Course_ID, 1, 'PH135 Applied Physics Lab', 1, 'Lab'),

-- Semester 2
(@MnC_Course_ID, 2, 'MA161 Ordinary Differential Equations', 3, 'Theory'),
(@MnC_Course_ID, 2, 'MA162 Computational Linear Algebra', 3, 'Theory'),
(@MnC_Course_ID, 2, 'MA163 Data Structures', 3, 'Theory'),
(@MnC_Course_ID, 2, 'BT171 Biological Computation', 2, 'Theory'),
(@MnC_Course_ID, 2, 'EE131 Basic Electrical Engineering', 3, 'Theory'),
(@MnC_Course_ID, 2, 'EC131 Basic Electronic Engineering', 3, 'Theory'),
(@MnC_Course_ID, 2, 'MA164 Data Structures Lab', 1, 'Lab'),

-- Semester 3
(@MnC_Course_ID, 3, 'MA211 Real and Complex Analysis', 3, 'Theory'),
(@MnC_Course_ID, 3, 'MA212 Fourier Series and PDEs', 3, 'Theory'),
(@MnC_Course_ID, 3, 'MA213 Probability and Statistics', 3, 'Theory'),
(@MnC_Course_ID, 3, 'MA214 Discrete Mathematics', 3, 'Theory'),
(@MnC_Course_ID, 3, 'MA215 Object Oriented Programming', 3, 'Theory'),
(@MnC_Course_ID, 3, 'SM231 Economics and Financial Analysis', 3, 'Theory'),
(@MnC_Course_ID, 3, 'MA216 Probability and Statistics Lab', 1, 'Lab'),
(@MnC_Course_ID, 3, 'MA217 Object Oriented Programming Lab', 1, 'Lab'),

-- Semester 4
(@MnC_Course_ID, 4, 'MA261 Multivariate Calculus and Measure Theory', 3, 'Theory'),
(@MnC_Course_ID, 4, 'MA262 Computer Oriented Numerical Methods', 3, 'Theory'),
(@MnC_Course_ID, 4, 'EC262 Signals and Systems', 3, 'Theory'),
(@MnC_Course_ID, 4, 'MA263 Applied Statistical Methods', 3, 'Theory'),
(@MnC_Course_ID, 4, 'MA264 Graph Theory', 3, 'Theory'),
(@MnC_Course_ID, 4, 'MA265 Database Management Systems', 3, 'Theory'),
(@MnC_Course_ID, 4, 'MA266 Design and Analysis of Algorithms', 3, 'Theory'),
(@MnC_Course_ID, 4, 'MA267 Numerical Methods Lab', 1, 'Lab'),
(@MnC_Course_ID, 4, 'MA268 DBMS Lab', 1, 'Lab'),

-- Semester 5
(@MnC_Course_ID, 5, 'MA311 Operations Research', 4, 'Theory'),
(@MnC_Course_ID, 5, 'MA312 Computational Number Theory', 3, 'Theory'),
(@MnC_Course_ID, 5, 'CS331 Computer Architecture', 3, 'Theory'),
(@MnC_Course_ID, 5, 'MA313 Theory of Computation', 3, 'Theory'),
(@MnC_Course_ID, 5, 'CS332 Operating Systems', 3, 'Theory'),
(@MnC_Course_ID, 5, 'MA314 Mathematics of Machine Learning', 3, 'Theory'),
(@MnC_Course_ID, 5, 'CS333 Operating Systems Lab', 1, 'Lab'),

-- Semester 6
(@MnC_Course_ID, 6, 'MA361 Cryptography and Security', 3, 'Theory'),
(@MnC_Course_ID, 6, 'MA362 Functional Analysis', 3, 'Theory'),
(@MnC_Course_ID, 6, 'MA363 Deep Learning', 3, 'Theory'),
(@MnC_Course_ID, 6, 'MA364 Computational Methods for Optimization', 3, 'Theory'),
(@MnC_Course_ID, 6, 'CS381 Computer Networks', 3, 'Theory'),
(@MnC_Course_ID, 6, 'MA365 Deep Learning Lab', 1, 'Lab'),
(@MnC_Course_ID, 6, 'MA366 Optimization Lab', 1, 'Lab'),

-- Semester 7
(@MnC_Course_ID, 7, 'CS433 Big Data Analytics', 3, 'Theory'),
(@MnC_Course_ID, 7, 'CS434 High Performance Computing', 2, 'Theory'),
(@MnC_Course_ID, 7, 'CS435 High Performance Computing Lab', 1, 'Lab'),
(@MnC_Course_ID, 7, 'MA449 Summer Internship/EPICS', 2, 'Lab'),

-- Semester 8
(@MnC_Course_ID, 8, 'EE471 Linear Systems Theory', 2, 'Theory'),
(@MnC_Course_ID, 8, 'MA498 Seminar', 1, 'Lab'),
(@MnC_Course_ID, 8, 'MA499 Project Work', 4, 'Lab');

-- Insert Grading System Data
INSERT INTO GradingSystem (min_percentage, max_percentage, grade, grade_points, remarks) VALUES
(90.00, 100.00, 'A+', 10.0, 'Outstanding'),
(80.00, 89.99, 'A', 9.0, 'Excellent'),
(70.00, 79.99, 'B+', 8.0, 'Very Good'),
(60.00, 69.99, 'B', 7.0, 'Good'),
(50.00, 59.99, 'C+', 6.0, 'Average'),
(40.00, 49.99, 'C', 5.0, 'Below Average'),
(35.00, 39.99, 'D', 4.0, 'Pass'),
(0.00, 34.99, 'F', 0.0, 'Fail');

-- Inserting Sample Data for New Tables

-- Sample Semester Prerequisites
INSERT INTO SemesterPrerequisites (course_id, current_semester, next_semester, min_credits_required, min_gpa_required) VALUES
(@CSE_Course_ID, 1, 2, 15, 5.0),
(@CSE_Course_ID, 2, 3, 18, 5.5),
(@CSE_Course_ID, 3, 4, 20, 6.0),
(@CSE_Course_ID, 4, 5, 22, 6.5),
(@CSE_Course_ID, 5, 6, 24, 7.0),
(@CSE_Course_ID, 6, 7, 26, 7.5),
(@CSE_Course_ID, 7, 8, 28, 8.0);

-- Sample Payment Gateways
INSERT INTO PaymentGateways (gateway_name, is_active, transaction_fee, supported_currencies) VALUES
('Stripe', TRUE, 2.9, 'USD,EUR,GBP,INR'),
('PayPal', TRUE, 3.5, 'USD,EUR,GBP'),
('Razorpay', TRUE, 2.5, 'INR'),
('Google Pay', TRUE, 1.9, 'USD,INR'),
('Apple Pay', TRUE, 2.0, 'USD,EUR');

-- Insert Sample Data for Donations
INSERT INTO Donations (donor_name, donor_email, amount, purpose) VALUES
('John Doe', 'john.doe@example.com', 1000.00, 'Scholarship Fund'),
('Jane Smith', 'jane.smith@example.com', 500.00, 'General Fund'),
('Alumni Association', NULL, 2000.00, 'Infrastructure Development');

-- Insert Sample Data for Scholarships
INSERT INTO Scholarships (student_id, scholarship_name, amount) VALUES
(1, 'Merit Scholarship', 5000.00),
(2, 'Need-Based Scholarship', 3000.00);

-- Insert Sample Data for Medals
INSERT INTO Medals (student_id, medal_type, academic_year) VALUES
(1, 'Branch Topper', 2023),
(2, 'University Topper', 2023);

-- Insert Sample Data for Student Profiles
INSERT INTO StudentProfiles (student_id, photo_url, leetcode_ranking, leetcode_questions_solved, codeforces_ranking, codeforces_questions_solved, other_platform_ranking, other_platform_questions_solved) VALUES
(1, '/photos/student1.jpg', 1200, 150, 1300, 200, 1400, 100),
(2, '/photos/student2.jpg', 1100, 100, 1250, 150, 1350, 80);

-- Insert Sample Data for Skills
INSERT INTO Skills (student_id, skill_name, skill_level, skill_rating, certificate_url) VALUES
(1, 'Python Programming', 'Advanced', 4.5, '/certificates/python_cert_1.pdf'),
(1, 'Data Structures', 'Expert', 5.0, '/certificates/ds_cert_1.pdf'),
(2, 'Java Programming', 'Intermediate', 3.8, '/certificates/java_cert_2.pdf'),
(2, 'Algorithms', 'Advanced', 4.2, '/certificates/algorithms_cert_2.pdf');

-- Insert Sample Data for Ratings
INSERT INTO Ratings (user_id, rating, feedback) VALUES
(1, 4.5, 'Great app, very user-friendly!'),
(2, 4.0, 'Good experience, but could use some improvements.');

-- Insert Sample Data for Login History
INSERT INTO LoginHistory (user_id, login_time, location) VALUES
(1, CURRENT_TIMESTAMP, 'New York, USA'),
(2, CURRENT_TIMESTAMP, 'London, UK');

-- Insert Sample Data for Grades
INSERT INTO Grades (student_id, subject_id, professor_id, grade) VALUES
(1, 101, 201, 'A'),
(2, 102, 202, 'B+');

-- Insert Sample Data for Course and Professor Ratings
INSERT INTO CourseProfessorRatings (student_id, course_id, professor_id, course_rating, professor_rating, feedback) VALUES
(1, 301, 401, 4.8, 4.9, 'Excellent course and professor!'),
(2, 302, 402, 4.2, 4.5, 'Good course, but the professor could explain better.');

-- Insert Sample Data for Teaching Assistants
INSERT INTO TeachingAssistants (user_id, professor_id, assigned_courses) VALUES
(101, 201, '["CSE101", "CSE102"]'), -- TA assisting Professor 201 for courses CSE101 and CSE102
(102, 202, '["CSE201", "CSE202"]'); -- TA assisting Professor 202 for courses CSE201 and CSE202

-- Insert Sample Data for Doubts
INSERT INTO Doubts (student_id, course_id, ta_id, doubt_text) VALUES
(1, 301, 101, 'Can you explain the concept of binary trees?'),
(2, 302, 102, 'I am having trouble understanding dynamic programming.');

-- Insert Sample Data for Counselling Requests
INSERT INTO CounsellingRequests (student_id, ta_id, request_text) VALUES
(1, 101, 'I need help with time management for my assignments.'),
(2, 102, 'I would like guidance on preparing for the upcoming exams.');

-- Insert Sample Data for Notifications
INSERT INTO Notifications (user_id, notification_type, message) VALUES
(1, 'email', 'Your quiz score has been updated.'),
(2, 'sms', 'Reminder: Your assignment deadline is tomorrow.');

-- Insert Sample Data for Live Classes
INSERT INTO LiveClasses (course_id, professor_id, start_time, end_time, topic, student_count) VALUES
(301, 401, '2023-10-01 10:00:00', '2023-10-01 12:00:00', 'Introduction to Machine Learning', 50),
(302, 402, '2023-10-02 14:00:00', '2023-10-02 16:00:00', 'Advanced Algorithms', 30);

-- Insert Sample Data for Revenue
INSERT INTO Revenue (source, amount) VALUES
('course_fee', 5000.00),
('donation', 2000.00);

-- Insert Sample Data for E-Resources
INSERT INTO EResources (title, type, author, publication_date, description, file_url) VALUES
('Introduction to Algorithms', 'e-book', 'Thomas H. Cormen', '2020-01-15', 'A comprehensive guide to algorithms.', '/resources/algorithms_book.pdf'),
('Linear Algebra and Its Applications', 'e-journal', 'Gilbert Strang', '2018-06-10', 'A journal on linear algebra applications.', '/resources/linear_algebra_journal.pdf'),
('Machine Learning Research Paper', 'research-paper', 'Andrew Ng', '2022-03-05', 'A research paper on machine learning advancements.', '/resources/ml_research_paper.pdf');

-- Insert Sample Data for Third-Party Links
INSERT INTO ThirdPartyLinks (resource_id, link_type, url, description) VALUES
(1, 'book', 'https://example.com/algorithms-book', 'External link to purchase the algorithms book.'),
(2, 'journal', 'https://example.com/linear-algebra-journal', 'External link to access the linear algebra journal.'),
(NULL, 'referral', 'https://example.com/referral-code-cse', 'Referral link for discounts on CSE courses.');

-- Insert Sample Data for Course Discounts
INSERT INTO CourseDiscounts (course_id, referral_code, discount_percentage, valid_from, valid_until) VALUES
(1, 'CSE123', 15.00, '2023-10-01', '2023-12-31'), -- 15% discount for Data Structures and Algorithms course
(2, 'MATH456', 10.00, '2023-11-01', '2024-01-31'); -- 10% discount for Linear Algebra course

-- Insert Sample Data for Faculty Details
INSERT INTO FacultyDetails (user_id, email, phone_number, research_area, current_publications, research_id, room_number, designation) VALUES
(201, 'prof.john@example.com', '+1234567890', 'Artificial Intelligence, Machine Learning', 'Paper on Deep Learning, Paper on AI Ethics', 'ORCID12345', 'Room 101', 'Professor'),
(202, 'prof.jane@example.com', '+0987654321', 'Quantum Computing, Cryptography', 'Paper on Quantum Algorithms, Paper on Post-Quantum Cryptography', 'SCOPUS67890', 'Room 102', 'Assistant Professor');

-- Insert Sample Data for Users with Updated Roles
INSERT INTO Users (fname, mail, pwd_hash, slt, rl) VALUES
('Pabitra Das', 'pabitra.das@example.com', 'hashed_password_1', 'salt_1', '2nd_year_senior'),
('Purabi Sen', 'purabi.sen@example.com', 'hashed_password_2', 'salt_2', 'professor'),
('Mansa Roy', 'mansa.roy@example.com', 'hashed_password_3', 'salt_3', 'HOD'),
('Anirban Ghosh', 'anirban.ghosh@example.com', 'hashed_password_4', 'salt_4', '3rd_year_senior'),
('Sutapa Dutta', 'sutapa.dutta@example.com', 'hashed_password_5', 'salt_5', '4th_year_senior');

-- Insert Sample Data for Courses Related to Mathematics and CSE
INSERT INTO Courses (cname, desc, cat, prc) VALUES
('Data Structures and Algorithms', 'Comprehensive course on data structures and algorithms', 'CSE', 1000.00),
('Linear Algebra', 'Course on linear algebra and its applications in computer science', 'Mathematics', 800.00);

-- Insert Sample Data for Guidance Sessions
INSERT INTO GuidanceSessions (senior_id, junior_id, topic, feedback) VALUES
(4, 1, 'Introduction to Data Structures', 'Very helpful session!'),
(5, 2, 'Tips for Operating Systems Lab', 'Great guidance on lab preparation.');

-- Insert Sample Data for Part-Time Professors
INSERT INTO Users (fname, mail, pwd_hash, slt, rl, act) VALUES
('Dr. Alice Brown', 'alice.brown@example.com', 'hashed_pwd_6', 'slt_6', 'part_time_professor', TRUE),
('Dr. Bob Smith', 'bob.smith@example.com', 'hashed_pwd_7', 'slt_7', 'part_time_professor', TRUE);

INSERT INTO PartTimeProfessorPayments (prof_id, hr_rate, hrs) VALUES
((SELECT uid FROM Users WHERE mail = 'alice.brown@example.com'), 50.00, 20),
((SELECT uid FROM Users WHERE mail = 'bob.smith@example.com'), 60.00, 15);

-- Insert Sample Data for Dual Degree Students
UPDATE Users
SET dual_deg = TRUE
WHERE fname IN ('Pabitra Das', 'Anirban Ghosh'); -- Example dual degree students

-- Procedure to Process Course Dropout and Calculate Refund
DELIMITER //
CREATE PROCEDURE DropProc(
    IN sid INT, -- Student ID
    IN cid INT, -- Course ID
    IN rsn TEXT -- Reason for dropping out
)
BEGIN
    DECLARE et TIMESTAMP; -- Enrollment timestamp
    DECLARE dur INT; -- Total course duration in days
    
    -- Fetch the enrollment timestamp for the student in the specified course
    SELECT etime INTO et 
    FROM Enrollments 
    WHERE sid = sid AND cid = cid;
    
    -- Assume the course duration is 180 days (can be customized)
    SET dur = 180;
    
    -- Insert a record into the CourseDropouts table
    INSERT INTO CourseDropouts (
        student_id, 
        course_id, 
        enrollment_date, 
        total_course_duration, 
        completed_duration, 
        reason
    ) VALUES (
        sid, 
        cid, 
        et, 
        dur, 
        DATEDIFF(CURRENT_TIMESTAMP, et), -- Calculate completed duration
        rsn
    );
    
    -- Remove the student from the Enrollments table
    DELETE FROM Enrollments 
    WHERE sid = sid AND cid = cid;
END;
//
DELIMITER ;

-- Trigger to Automatically Generate Completion Certificate
DELIMITER //
CREATE TRIGGER CertTrig 
AFTER UPDATE ON CourseProgress 
FOR EACH ROW 
BEGIN
    -- Check if the student's progress percentage is 90% or higher
    IF NEW.progress_percentage >= 90.0 THEN
        INSERT INTO Certificates (student_id, course_id, certificate_type, certificate_url)
        VALUES (
            NEW.student_id, 
            NEW.course_id, 
            'Completion', 
            CONCAT('/certs/', NEW.student_id, '_', NEW.course_id, '_', CURRENT_TIMESTAMP, '.pdf')
        );
    END IF;
END;
//
DELIMITER ;

-- Create Views for Different Roles

-- View for Technical Officer: Allows managing users and courses
CREATE VIEW TechView AS
SELECT 
    uid, -- User ID
    fname, -- Full name
    mail, -- Email
    rl, -- Role
    act, -- Active status
    ctime -- Account creation timestamp
FROM Users
WHERE rl = 'technical_officer';

-- View for Students: Allows viewing their profile and enrolled courses
CREATE VIEW StuView AS
SELECT 
    u.uid, -- User ID
    u.fname, -- Full name
    u.mail, -- Email
    u.rl, -- Role
    e.cid, -- Course ID
    c.cname, -- Course name
    c.desc, -- Course description
    c.cat, -- Course category
    c.prc -- Course price
FROM Users u
JOIN Enrollments e ON u.uid = e.sid
JOIN Courses c ON e.cid = c.cid
WHERE u.rl IN ('student', '2nd_year_senior', '3rd_year_senior', '4th_year_senior');

-- View for Professors: Allows viewing their assigned courses and students
CREATE VIEW ProfView AS
SELECT 
    u.uid AS pid, -- Professor ID
    u.fname AS pname, -- Professor name
    u.mail AS pmail, -- Professor email
    c.cid, -- Course ID
    c.cname, -- Course name
    e.sid, -- Student ID
    s.fname AS sname, -- Student name
    s.mail AS smail -- Student email
FROM Users u
JOIN Courses c ON u.uid = c.cid
LEFT JOIN Enrollments e ON c.cid = e.cid
LEFT JOIN Users s ON e.sid = s.uid
WHERE u.rl = 'professor';

-- View for HOD: Allows viewing department-level activities
CREATE VIEW HODView AS
SELECT 
    u.uid AS hid, -- HOD ID
    u.fname AS hname, -- HOD name
    u.mail AS hmail, -- HOD email
    c.cid, -- Course ID
    c.cname, -- Course name
    c.cat, -- Course category
    COUNT(e.sid) AS tot_stu -- Total students enrolled
FROM Users u
JOIN Courses c ON u.uid = c.cid
LEFT JOIN Enrollments e ON c.cid = e.cid
WHERE u.rl = 'HOD'
GROUP BY u.uid, c.cid;

-- View for Admin: Provides full access to all users and courses
CREATE VIEW AdmView AS
SELECT 
    u.uid, -- User ID
    u.fname, -- Full name
    u.mail, -- Email
    u.rl, -- Role
    u.act, -- Active status
    c.cid, -- Course ID
    c.cname, -- Course name
    c.cat, -- Course category
    c.prc -- Course price
FROM Users u
LEFT JOIN Courses c ON u.uid = c.cid;

-- View for Faculty Advisor: Allows advising students
CREATE VIEW AdvView AS
SELECT 
    u.uid AS aid, -- Advisor ID
    u.fname AS aname, -- Advisor name
    u.mail AS amail, -- Advisor email
    e.sid, -- Student ID
    s.fname AS sname, -- Student name
    s.mail AS smail, -- Student email
    c.cid, -- Course ID
    c.cname -- Course name
FROM Users u
JOIN Enrollments e ON u.uid = e.sid
JOIN Courses c ON e.cid = c.cid
JOIN Users s ON e.sid = s.uid
WHERE u.rl = 'faculty_advisor';

