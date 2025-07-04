# 🏫 E_Versity

## 📄 Description

**E_Versity** is an SQL-based database project designed for a university providing both online and regular courses. It contains a robust schema covering user management, course structures, enrolments, and session tracking. The design supports:

- Student, faculty, and admin role-based management
- Secure user authentication with password hashing and salts
- Password reset mechanisms
- Active user session tracking and login history
- Course, semester, and subject definitions
- Student course enrolments

---

## 🗂️ Database Tables Overview

1. **Users**
   - Stores user details with roles such as student, instructor, admin, professor, teaching assistant, HOD, mentors, seniors, and part-time profiles.
   - Includes secure password hashes, salts, and account status flags.

2. **PasswordResets**
   - Handles password reset requests with tokens and expiration.

3. **UserSessions**
   - Tracks active login sessions with tokens, IP addresses, and expiry.

4. **LoginHistory**
   - Records login and logout timestamps along with user location data.

5. **Courses**
   - Defines available courses with name, description, category, and price.

6. **Semesters**
   - Links semesters to courses with names and numbering.

7. **Subjects**
   - Lists subjects for each semester with type classification (Theory, Lab, BSC, HSC, PCC, PEC, OEC, MNC).

8. **Enrollments**
   - Manages student enrolments into courses with timestamps.

