# CampusCore - University Management System (Flutter)

Mobile + Desktop + Web from one codebase. Built for VS Code.

## Your Registration Format
`BACS/M/25D/UG/001`
- BACS = Program code (from Programs table)
- M = Gender M/F
- 25D = Year + Session combined (25 = 2025, D=Day, E=Evening, W=Weekend)
- UG = Nationality
- 001 = Personal number auto-increment per PROGRAM+SESSION group

## How to run in VS Code

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Open VS Code, install Flutter extension
3. Open folder `campuscore_flutter` in VS Code
4. Terminal:
```
flutter pub get
flutter run -d chrome    # for web preview
flutter run -d android   # for android
flutter run -d windows   # for windows desktop
flutter run
```

5. No hard-coded data. First run goes to Admin > Data Builder to create your faculties, programs, etc.

## Project Structure
- lib/main.dart - App entry, bottom nav, theme, roles
- lib/utils/reg_generator.dart - Your BACS/M/25D/UG/001 generator
- lib/models/ - Student, Program, CourseUnit models
- lib/services/database_service.dart - Local storage (shared_preferences), replace with your backend later
- lib/screens/ - All pages
- lib/widgets/reg_preview_widget.dart - Visual preview with color-coded segments

## Pages Included
- Onboarding (3 slides)
- Login with role selector Student/Lecturer/Admin/Parent + 2FA
- Student Home, Courses organized by Course Unit, Attendance, Fees, Profile
- Lecturer: Notify Class (Today online lecture, Deadline, Marks), Mark Attendance, Enter Marks, Upload Material
- Admin: Dashboard, Data Builder (Faculties, Programs, Reg Pattern), Users, Events & Room Booking, Announcements
- Parent portal

## Replace with your backend
In `database_service.dart` swap shared_preferences with your API / Firebase / Supabase. All data models are ready for your own tables.

## No sensitive info shown
Rate limiting, IPs, encryption keys are not displayed in UI - handled backend only.
