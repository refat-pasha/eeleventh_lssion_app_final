# 11th Lesson — Project Report

**Codebase:** `eeleventh_lssion_app_final` (Flutter + Firebase)
**SRS:** 11th Lesson — Software Requirements Specification, Version 1.0 (Team RedBlack, 01/02/26)
**Report date:** 2026-04-18
**Scope:** Module-by-module mapping of the current Flutter codebase to each SRS functional requirement (FR-1 … FR-7) and non-functional requirement (NFR-1 … NFR-5), plus Firebase schema, known gaps, and recommended follow-ups.

---

## 1. Executive Summary

11th Lesson is a cross-platform mobile learning application for university students and teachers. The SRS defines **seven functional features** (Dashboard, Assignment, Progress, Offline, Demo Quiz, Collaborative Learning, Publication) and **five non-functional requirements** (Performance, Security, Usability, Scalability, Reliability), built on **Flutter (Dart) + Firebase (Auth / Firestore / Storage / Analytics)**.

The codebase implements all seven FRs at some depth, with Firestore as the primary data backend and Google Drive as the file-storage backend for teacher-uploaded materials (in place of Firebase Storage, which is what the SRS originally called for — see [§6. Gaps vs SRS](#6-gaps-vs-srs)). State management is **GetX** (`GetxController` + `Obx` + dependency injection via `Get.put`/`Get.find`).

Architecture at a glance:

```
main.dart
  └─ GetMaterialApp (routes from app/routes/app_pages.dart)
        ├─ InitialBinding       →  FirebaseProvider, SyncService, Repositories, top-level Controllers
        ├─ Splash → Auth → SetupProfile → Dashboard (MainNavigationView)
        └─ Feature routes: quiz, assignment, publication, offline, progress, collaborative, profile subpages
```

Per-route dependency injection uses **GetX bindings** (one `*_binding.dart` per module), and per-route screens are **`GetView<Controller>` widgets** that read `Rx` state via `Obx`.

---

## 2. Architecture & Directory Overview

```
lib/
├── main.dart                         App entry; Firebase.initializeApp, GetStorage.init, theme
├── app/
│   ├── app.dart                      (widget shell)
│   ├── bindings/initial_binding.dart Root DI: providers, repos, SyncService, common controllers
│   ├── routes/app_routes.dart        Route name constants
│   ├── routes/app_pages.dart         GetPage registry (splash, auth, dashboard, features, settings)
│   └── theme/                        colors.dart, text_styles.dart, app_theme.dart
├── core/
│   ├── constants/                    api_constants, app_constants, storage_keys
│   ├── network/                      api_client, api_response (generic HTTP helpers — currently unused by Firebase paths)
│   ├── services/
│   │   ├── firebase_service.dart     Firebase init wrapper
│   │   ├── auth_service.dart         Auth helpers
│   │   ├── google_drive_service.dart Upload/download against a fixed Drive folder for materials
│   │   ├── sync_service.dart         FR-4 offline queue + connectivity probe + replay
│   │   ├── storage_service.dart      get_storage wrapper
│   │   ├── file_service.dart         Filesystem helpers
│   │   ├── download_service.dart     URL-to-local downloader
│   │   ├── export_service.dart       FR-3 CSV export (path_provider + open_file)
│   │   └── notification_service.dart Local/Firebase notifications plumbing
│   └── utils/                        validators, helpers, date_utils
├── data/
│   ├── models/                       user, course, assignment, assignment_submission,
│   │                                 material, question, quiz, progress, group, group_message, thread
│   ├── providers/
│   │   ├── firebase_provider.dart    Firestore collection handles + Storage upload + Auth shortcuts
│   │   └── local_storage_provider.dart get_storage typed wrapper
│   └── repositories/                 auth, course, assignment, quiz, material
└── modules/                          11 feature modules — each has bindings/ controllers/ views/
    ├── splash/
    ├── auth/                         login, register, setup_profile
    ├── navigation/                   MainNavigationView + bottom tab bar
    ├── dashboard/                    DashboardView + widgets (course_card, stats_tile, progress_ring)
    ├── profile/                      profile + account_settings + academic_profile + appearance
    ├── assignment/                   list, create, submit, my_submissions, grade_submissions
    ├── quiz/                         quiz_view, add_question_view + widgets
    ├── publication/                  upload_material_view (teacher-only)
    ├── collaborative/                study_groups_view, group_detail_view, thread_detail_view
    ├── progress/                     progress dashboard + CSV export
    └── offline/                      offline library / sync controls
└── widgets/                          bottom_nav_bar, custom_app_bar, custom_button,
                                      empty_state, loading_widget
```

### 2.1 Cross-cutting glue

- **[lib/main.dart](lib/main.dart)** — bootstraps Firebase, `GetStorage`, and the appearance controller, then hands off to `GetMaterialApp` with `InitialBinding()` and the route table from [app_pages.dart](lib/app/routes/app_pages.dart).
- **[lib/app/bindings/initial_binding.dart](lib/app/bindings/initial_binding.dart)** — `Get.put`s `FirebaseProvider` + `SyncService` as permanent singletons; `Get.lazyPut`s all repositories and three shared controllers (`DashboardController`, `ProgressController`, `PublicationController`) with `fenix: true` so they can be recreated on demand after dispose.
- **[lib/data/providers/firebase_provider.dart](lib/data/providers/firebase_provider.dart)** — the single source of truth for Firestore *collection handles*; every repository and controller goes through this class, which keeps collection names in one place (`users`, `courses`, `assignments`, `quizzes`, `materials`, `groups`, `material_views`, `quiz_attempts`, `assignment_submissions`, nested `threads`/`replies`/`messages`).
- **[lib/data/models/user_model.dart](lib/data/models/user_model.dart)** — superset of the SRS user attributes (name, email, role, xp, level, streak, achievements, enrolledCourses, subjects, university, department, semester).

---

## 3. Firebase Schema (as used by the code)

Firestore collections and subcollections (each row = collection → key fields actually read/written by the code):

| Collection | Key fields | Read by | Written by |
|---|---|---|---|
| `users/{uid}` | name, email, role (`student`/`teacher`/`admin`), xp, level, streak, achievements, enrolledCourses[], subjects[], university, department, semester, createdAt | AuthRepository, Dashboard, Progress, Assignment, Publication, Profile | AuthController.saveProfile, academic_profile_controller, progress (`streak` update), quiz (`xp` increment) |
| `courses/{id}` | title, code, description, teacherId, thumbnail, createdAt | Dashboard (student+teacher), CourseRepository | Dashboard `createCourse` (teacher) |
| `materials/{id}` | title, description, category, courseId, visibility, tags[], fileName, fileUrl, fileId, uploadedBy, createdAt | Dashboard recommendations, Progress (per-course), Offline library | PublicationController.uploadMaterial |
| `material_views/{auto}` | userId, courseId, materialId, viewedAt | Dashboard (continue-learning), Progress (% complete) | ProgressController.markMaterialViewed, SyncService replay |
| `assignments/{id}` | title, description, fileUrl, dueDate, courseId, createdAt | AssignmentController (list + realtime) | AssignmentController.createAssignment (teacher) |
| `assignment_submissions/{auto}` | assignmentId, userId, courseId, answer, fileUrl, marks, feedback, status, submittedAt, gradedAt | my_submissions_view, grade_submissions_view | AssignmentController.submitAssignment (student), gradeSubmission (teacher) |
| `quizzes/{id}` | title, … | QuizController, ProgressController | (seeded manually / admin) |
| `quiz_attempts/{auto}` | userId, quizId, score, totalQuestions, percentage, submittedAt | ProgressController | QuizController._saveQuizResult |
| `activity/{uid}` | weekly{Mon..Sun}, lastActive | ProgressController weekly chart | ProgressController.updateWeeklyActivity |
| `groups/{id}` | name, description, members[], createdAt | CollaborativeController | createGroup / join / leave / delete |
| `groups/{id}/threads/{tid}` | title, body, authorId, authorName, createdAt, replyCount | watchThreads stream | createThread, replyCount increment |
| `groups/{id}/threads/{tid}/replies/{rid}` | body, authorId, authorName, createdAt | watchReplies stream | addReply |
| `groups/{id}/messages/{mid}` | senderId, senderName, text, createdAt, isAnnouncement | watchMessages stream | sendMessage |
| `_health/probe` | (any doc) | SyncService.checkOnline | — |

### 3.1 Composite indexes required

The code issues compound queries whose execution will require composite Firestore indexes:

- `assignment_submissions` where `userId == ?` orderBy `submittedAt desc` — used by `fetchMySubmissions`.
- `assignment_submissions` where `assignmentId == ?` orderBy `submittedAt desc` — used by `fetchSubmissionsByAssignment`.
- `quiz_attempts` where `userId == ?` orderBy `submittedAt desc limit 5` — used by `_loadQuizResults`.
- `material_views` where `userId == ?` orderBy `viewedAt desc` — **intentionally avoided** via client-side sort in `generateRecommendations` to skip the index requirement (see the comment in `dashboard_controller.dart`).

### 3.2 File storage

The SRS lists **Firebase Storage** under the technology stack. In practice, material uploads go through **Google Drive** ([lib/core/services/google_drive_service.dart](lib/core/services/google_drive_service.dart), fixed folder `1cMEymw_YfPGIYjBvjxnRC2b9vt9_QPP4`) and the resulting `fileId` + `fileUrl` are saved into the `materials/{id}` Firestore doc. `FirebaseProvider.uploadFile` exists and supports Firebase Storage, but it is not called anywhere today.

---

## 4. Functional Requirements — Module Mapping

### FR-1 — Dashboard *(owner per SRS: Shoeb)*
> *"Provide students and teachers with a central hub for all their learning activities."*

**Code:**
- [lib/modules/dashboard/controllers/dashboard_controller.dart](lib/modules/dashboard/controllers/dashboard_controller.dart)
- [lib/modules/dashboard/views/dashboard_view.dart](lib/modules/dashboard/views/dashboard_view.dart)
- [lib/modules/dashboard/widgets/](lib/modules/dashboard/widgets/) (`course_card.dart`, `stats_tile.dart`, `progress_ring.dart`)
- [lib/modules/navigation/views/main_navigation_view.dart](lib/modules/navigation/views/main_navigation_view.dart) — hosts the bottom-tab shell that keeps DashboardView as tab 0.

**SRS coverage:**
- **REQ-1 Personalized user profile** → Header row shows avatar/name/role greeting ([dashboard_view.dart:33-51](lib/modules/dashboard/views/dashboard_view.dart#L33-L51)); XP / streak / badges stat cards ([dashboard_view.dart:55-63](lib/modules/dashboard/views/dashboard_view.dart#L55-L63)). User profile is loaded via `AuthRepository.getUserProfile` in `DashboardController.loadDashboard` ([dashboard_controller.dart:37-88](lib/modules/dashboard/controllers/dashboard_controller.dart#L37-L88)).
- **REQ-2 Progress tracking overview** → Handled jointly with FR-3 (ProgressView); dashboard shows the lightweight streak/XP chips.
- **REQ-3 Upcoming deadlines and alerts** → Partially present (assignments with `dueDate` are listed in the Assignments tab) but the SRS's deadline widget on the dashboard itself is not implemented. See [§6. Gaps](#6-gaps-vs-srs).
- **REQ-4 Quick navigation shortcuts** → `Quick Access` grid with Quiz / Progress / Offline / Assignments tiles at [dashboard_view.dart:153-163](lib/modules/dashboard/views/dashboard_view.dart#L153-L163), plus the MainNavigationView bottom bar for Dashboard, Progress, Assignments, Publication, Study Groups, Profile.
- **REQ-5 Notifications panel** → Stub only: `core/services/notification_service.dart` exists but the dashboard has no notifications widget. See [§6. Gaps](#6-gaps-vs-srs).

**Role behaviour:** `isTeacher` gates title (`My Courses` vs `Continue Learning`), the `+` course-create button, and the empty-state copy. Teachers see `getCoursesByTeacher`; students see their `enrolledCourses` filtered from `getCourses()` with an all-courses fallback when none are enrolled.

**Recent fixes (2026-04-18):** dashboard was fetching only `getCourses()` regardless of role; it now branches. Teacher-only `Create Course` dialog was added ([dashboard_view.dart:233-267](lib/modules/dashboard/views/dashboard_view.dart#L233-L267)) invoking `controller.createCourse(...)`.

**Caveats:** XP bar scaling is hard-coded to `/3500` in ProgressController. Badges count is hard-coded `"4"` in the dashboard header.

---

### FR-2 — Assignment *(owner per SRS: Ridita)*
> *"Assignment submission, review, and grading feature."*

**Code:**
- [lib/modules/assignment/controllers/assignment_controller.dart](lib/modules/assignment/controllers/assignment_controller.dart)
- [lib/modules/assignment/views/assignment_view.dart](lib/modules/assignment/views/assignment_view.dart)
- [lib/modules/assignment/views/submission_view.dart](lib/modules/assignment/views/submission_view.dart)
- [lib/modules/assignment/views/my_submissions_view.dart](lib/modules/assignment/views/my_submissions_view.dart)
- [lib/modules/assignment/views/grade_submissions_view.dart](lib/modules/assignment/views/grade_submissions_view.dart)
- [lib/data/models/assignment_model.dart](lib/data/models/assignment_model.dart), [lib/data/models/assignment_submission_model.dart](lib/data/models/assignment_submission_model.dart)
- [lib/data/repositories/assignment_repository.dart](lib/data/repositories/assignment_repository.dart)

**SRS coverage:**
- **REQ-1 Upload assignments** → Students submit a text answer via `submitAssignment`; teachers create assignments via `createAssignment` (title, description, Google-Drive link, dueDate, courseId). [assignment_controller.dart:110-148](lib/modules/assignment/controllers/assignment_controller.dart#L110-L148).
- **REQ-2 Deadline management** → Every assignment stores `dueDate` and displays `Due: yyyy-mm-dd` ([assignment_view.dart:60-63](lib/modules/assignment/views/assignment_view.dart#L60-L63)). No automatic reminder/notification is triggered.
- **REQ-3 Teacher feedback and grades** → `gradeSubmission(submissionId, marks, feedback)` updates `status=graded` + `gradedAt` ([assignment_controller.dart:204-225](lib/modules/assignment/controllers/assignment_controller.dart#L204-L225)); teacher-side UI in `GradeSubmissionsView`.
- **REQ-4 Progress updates** → Submission status flows through `assignment_submissions.status` (`submitted` → `graded`); student's MySubmissions view shows the current status.
- **REQ-5 Notifications** → Not implemented.

**Role gating:** `AssignmentController.isTeacher` + `Obx` wrappers in `assignment_view.dart` hide `+ Create`, `Grade`, and `Delete` actions from students; `Upload answer` is hidden from teachers. Role is read from `users/{uid}.role` in `fetchUserRole()`.

**Realtime:** `listenToAssignments()` subscribes to `assignments` snapshots ordered by `createdAt desc` so new teacher postings appear without refresh.

---

### FR-3 — Progress *(owner per SRS: Refat)*
> *"Track, analyze, and visualize academic/learning progress."*

**Code:**
- [lib/modules/progress/controllers/progress_controller.dart](lib/modules/progress/controllers/progress_controller.dart)
- [lib/modules/progress/views/progress_view.dart](lib/modules/progress/views/progress_view.dart)
- [lib/data/models/progress_model.dart](lib/data/models/progress_model.dart)
- [lib/core/services/export_service.dart](lib/core/services/export_service.dart)

**SRS coverage:**
- **REQ-1 Dashboards and statistics** → `loadAllProgress` pulls user profile + courses + per-course completion % + last 5 quiz results + weekly activity array; `ProgressView` renders XP bar, streak, per-course progress bars, last quizzes list, and a weekly bar chart.
- **REQ-2 Achievements/milestones** → `UserModel.achievements` field is persisted and read (currently displayed as badges), but there is no automatic awarding logic.
- **REQ-3 Weekly reports** → `updateWeeklyActivity()` in `ProgressController` maintains `activity/{uid}.weekly` with counts per weekday and updates `users/{uid}.streak` based on consecutive-day deltas.
- **REQ-4 Data export** → `exportMyProgressCsv()` (student) and `exportTeacherAnalyticsCsv()` (teacher) both use `ExportService.exportCsv` ([export_service.dart](lib/core/services/export_service.dart)) to write to app-documents dir and offer `openFile` via the `open_file` package.
- **REQ-5 Performance recommendations** → Not implemented (no heuristics/ML suggestions).

**Course completion %** = `count(material_views for userId+courseId) / count(materials for courseId)`. `markMaterialViewed` dedupes by (userId, materialId) before writing.

**Cross-module hook:** `QuizController._saveQuizResult` calls `Get.find<ProgressController>().updateWeeklyActivity()` after every quiz finish, so activity and streak update regardless of which tab the user is on.

---

### FR-4 — Offline Mode *(owner per SRS: Refat)*
> *"Allow users to learn even without an internet connection."*

**Code:**
- [lib/modules/offline/controllers/offline_controller.dart](lib/modules/offline/controllers/offline_controller.dart)
- [lib/modules/offline/views/offline_view.dart](lib/modules/offline/views/offline_view.dart)
- [lib/modules/dashboard/views/offline_library_view.dart](lib/modules/dashboard/views/offline_library_view.dart)
- [lib/core/services/sync_service.dart](lib/core/services/sync_service.dart)
- [lib/core/services/download_service.dart](lib/core/services/download_service.dart)
- [lib/data/providers/local_storage_provider.dart](lib/data/providers/local_storage_provider.dart)
- [lib/core/constants/storage_keys.dart](lib/core/constants/storage_keys.dart)

**SRS coverage:**
- **REQ-1 Offline content access** → Materials are persisted in `GetStorage` under `StorageKeys.offlineMaterials`; `OfflineController` exposes `saveMaterialOffline` / `removeOfflineMaterial` / `loadOfflineMaterials` and serializes `MaterialModel.toMap()` per item.
- **REQ-2 Cached notes/videos** → Covered as above; `DownloadService` (lib/core/services/download_service.dart) provides the URL→local-file mechanism for on-device file caching.
- **REQ-3 Limited functionality while offline** → The app degrades gracefully because the GetX controllers don't throw on Firestore errors — they catch and show snackbars. Offline library uses purely local data.
- **REQ-4 Local data storage** → `LocalStorageProvider` wraps `GetStorage` with typed read/write/remove/hasKey/getKeys.
- **REQ-5 Sync when online** → `SyncService` ([sync_service.dart](lib/core/services/sync_service.dart)) is the central FR-4 REQ-5 implementation. It:
  - enqueues `material_view` / `quiz_attempt` / `assignment_submission` payloads to `pendingSyncQueue` in GetStorage,
  - polls connectivity every 30s via a Firestore `_health/probe` read with 4s timeout,
  - replays queued items with `syncedFromOffline: true` stamps, leaves failed items in queue, and records `lastSyncAt`.

**Offline queue is wired to:** `OfflineController.queueMaterialView` exposes the most common offline write; the same path is available for quizzes and submissions when called by their controllers.

**Caveats:** The Firestore SDK's built-in offline persistence is also active by default; the SyncService layer is explicit on top of that. Video caching is not yet implemented end-to-end (no video player integration in this build).

---

### FR-5 — Demo Quiz *(owner per SRS: Sumaiya)*
> *"Interactive demo quiz feature to test and reinforce learning."*

**Code:**
- [lib/modules/quiz/controllers/quiz_controller.dart](lib/modules/quiz/controllers/quiz_controller.dart)
- [lib/modules/quiz/views/quiz_view.dart](lib/modules/quiz/views/quiz_view.dart)
- [lib/modules/quiz/views/add_question_view.dart](lib/modules/quiz/views/add_question_view.dart)
- [lib/modules/quiz/widgets/option_tile.dart](lib/modules/quiz/widgets/option_tile.dart), [lib/modules/quiz/widgets/question_card.dart](lib/modules/quiz/widgets/question_card.dart)
- [lib/data/models/quiz_model.dart](lib/data/models/quiz_model.dart), [lib/data/models/question_model.dart](lib/data/models/question_model.dart)
- [lib/data/repositories/quiz_repository.dart](lib/data/repositories/quiz_repository.dart)

**SRS coverage:**
- **REQ-1 MCQ with timer** → `QuizController.startTimer(minutes)` runs a `Timer.periodic`, decrements `remainingSeconds`, and calls `finishQuiz()` at 0 with a snackbar. Default is 10 minutes; quizId is read from `Get.arguments`.
- **REQ-2 Instant feedback on answers** → After `finishQuiz`, `quizFinished.value = true`, `QuizView` flips to a result screen showing score / total / percentage.
- **REQ-3 Tracks student performance** → `_saveQuizResult` writes a `quiz_attempts` doc and increments `users/{uid}.xp` by 50, then calls `ProgressController.updateWeeklyActivity()`.
- **REQ-4 Randomized questions** → Not implemented; questions are served in storage order from `QuizRepository.getQuestionsByQuiz`.
- **REQ-5 Shared across courses** → Question bank is a single `quizzes` collection, not tied to `courses/{id}` today.

**Teacher authoring:** `AddQuestionView` exists as a scaffold for adding questions to a quiz doc.

---

### FR-6 — Collaborative Learning *(owner per SRS: Shoeb)*
> *"Online platform for students to collaborate with peers and teachers."*

**Code:**
- [lib/modules/collaborative/controllers/collaborative_controller.dart](lib/modules/collaborative/controllers/collaborative_controller.dart)
- [lib/modules/collaborative/views/study_groups_view.dart](lib/modules/collaborative/views/study_groups_view.dart)
- [lib/modules/collaborative/views/group_detail_view.dart](lib/modules/collaborative/views/group_detail_view.dart)
- [lib/modules/collaborative/views/thread_detail_view.dart](lib/modules/collaborative/views/thread_detail_view.dart)
- [lib/data/models/group_model.dart](lib/data/models/group_model.dart), [lib/data/models/thread_model.dart](lib/data/models/thread_model.dart), [lib/data/models/group_message_model.dart](lib/data/models/group_message_model.dart)

**SRS coverage:**
- **REQ-1 Group study sessions** → `createGroup` / `joinGroup` / `leaveGroup` via the `groups` collection with a `members[]` array.
- **REQ-2 Peer-to-peer discussions** → `watchThreads(groupId)` stream of `groups/{id}/threads` ordered `createdAt desc`; `createThread` writes author uid + display name + createdAt + replyCount=0.
- **REQ-3 Shared notes/resources** → Materials are shared app-wide via `materials.visibility` (`My Courses` / `Public` / `Private`) — not per-group sharing.
- **REQ-4 Chat/messaging** → Labelled `FR-6 REQ-4: DISCUSSION FORUM` in code. Threads + replies with server-timestamped `createdAt`; `addReply` uses a `WriteBatch` to `set` the reply and `update` the parent thread's `replyCount`.
- **REQ-5 Group messaging** → Separate `groups/{id}/messages` subcollection; `watchMessages` stream + `sendMessage` with optional `isAnnouncement` flag.
- **REQ-6 Member management** → `removeMember` strips a uid from `members[]` (teacher/admin only in UI convention — not enforced server-side).

**Caveats:** All access is through Firestore security rules you define. The code itself doesn't restrict `removeMember` or `deleteGroup` by role.

---

### FR-7 — Publication *(owner per SRS: Safayet)*
> *"Enable teachers/authors to publish and share materials."*

**Code:**
- [lib/modules/publication/controllers/publication_controller.dart](lib/modules/publication/controllers/publication_controller.dart)
- [lib/modules/publication/views/upload_material_view.dart](lib/modules/publication/views/upload_material_view.dart)
- [lib/data/models/material_model.dart](lib/data/models/material_model.dart)
- [lib/data/repositories/material_repository.dart](lib/data/repositories/material_repository.dart)
- [lib/core/services/google_drive_service.dart](lib/core/services/google_drive_service.dart) (file upload backend)

**SRS coverage:**
- **REQ-1 Teacher/author publishing** → `PublicationController.uploadMaterial` is the single entry point; `userRole != "teacher"` branch denies access.
- **REQ-2 Categorization (lectures, notes, articles)** → `category` dropdown: `Lecture Notes`, `Slides`, `Assignment`, `Exam Prep`. Tags stored as array derived from comma-separated input.
- **REQ-3 Reader feedback / likes** → Not implemented.
- **REQ-4 Visibility control (public/private/course)** → `visibility` field persisted (`My Courses` / `Public` / `Private`); enforcement today is advisory only (no Firestore rule shown in this repo).
- **REQ-5 Citation / references** → Not implemented.

**Upload flow:** File picker (`file_picker` package, `withData: true`) → bytes → temp file → `GoogleDriveService.uploadFile` (fixed folder, sets `permissions.create(type=anyone, role=reader)` so the Drive file is publicly readable) → stores `{fileId, fileUrl, ...}` in `materials` Firestore doc.

**Caveats:** Course dropdown hard-codes `CSE 221`, `MATH 301`, `CSE 341`. `selectedCourse` is saved as `courseId` literal string, not a real course id — this blocks cross-module joins (materials ↔ courses ↔ material_views) for non-matching ids.

---

## 5. Non-Functional Requirements

### NFR-1 — Performance
> *"Load within 3 seconds and handle multiple users simultaneously."*

- `main.dart` boots with only Firebase + GetStorage + `AppearanceController`; feature controllers are `Get.lazyPut`, so tab switches pay the controller-creation cost only on first hit.
- `InitialBinding` registers `FirebaseProvider` and `SyncService` as permanent singletons, avoiding re-instantiation during navigation.
- `DashboardController.generateRecommendations` deliberately sorts `material_views` client-side to avoid requiring a Firestore composite index (trading a bit of in-memory work for no-migration deploys).
- `ProgressController._loadQuizResults` limits results to 5, then fetches quiz titles one-by-one with a cache in `exportTeacherAnalyticsCsv`. A more aggressive optimization (batch `whereIn` on quizIds) would reduce round-trips on large data sets.
- Realtime listeners (`Assignments`, threads, replies, messages) let Firestore push deltas rather than polling.

### NFR-2 — Security
> *"Secure login (Firebase Auth), role-based access for students/teachers/admins."*

- **Auth** via `FirebaseAuth.instance` inside `AuthRepository` and `FirebaseProvider`.
- **Role** stored in `users/{uid}.role` ∈ `{student, teacher, admin}`, read at startup by every major controller (`DashboardController`, `AssignmentController.fetchUserRole`, `PublicationController.fetchUserRole`).
- **Client-side gating** — `isTeacher` controls the visibility of create/grade/delete/upload actions across Assignment, Dashboard, Publication.
- **Server-side enforcement** must be implemented via Firestore Security Rules (not present in this repo). Without them, a determined client could still write teacher-only collections. See [§6. Gaps](#6-gaps-vs-srs).

### NFR-3 — Usability
> *"Simple UI, easy navigation, accessible for students unfamiliar with technology."*

- Consistent GetX screen pattern: `GetView<Controller>` + `Obx` for reactive rebuilds.
- Theme abstraction via `Theme.of(context)` — dark/light both defined in `main.dart` and controlled by `AppearanceController` ([lib/modules/profile/controllers/appearance_controller.dart](lib/modules/profile/controllers/appearance_controller.dart)).
- Bottom-tab navigation (6 tabs: Dashboard, Progress, Assignments, Publication, Study Groups, Profile) in [main_navigation_view.dart](lib/modules/navigation/views/main_navigation_view.dart).
- Empty states + loading indicators (`CircularProgressIndicator`) everywhere a query runs.
- Pull-to-refresh on Dashboard (`RefreshIndicator` → `controller.refreshDashboard`).

### NFR-4 — Scalability
> *"Scales with growing users/courses."*

- Firestore is horizontally scalable by design; the schema uses top-level collections keyed by uid / auto ids.
- Subcollections for group threads/replies/messages keep writes localized and allow per-group indexing.
- `material_views` uses a single auto-id collection with `userId` + `courseId` filters — works for realistic class sizes but the dashboard client-side sort trades query scalability for deploy simplicity.

### NFR-5 — Reliability
> *"System stable with minimum downtime, backup/recovery mechanism."*

- Controllers universally wrap Firestore calls in `try/catch` with `Get.snackbar` user feedback.
- `SyncService` guards `tryFlush` with `isSyncing` re-entrance and keeps failed items in the queue rather than dropping them.
- Firebase handles its own backup/DR; there's no application-level export/backup beyond the CSV export in FR-3.

---

## 6. Gaps vs SRS

| SRS item | Status | Notes |
|---|---|---|
| FR-1 REQ-3 Deadlines widget on Dashboard | ❌ | Dates are in Assignments tab, not the dashboard itself. |
| FR-1 REQ-5 Notifications panel | ❌ | `notification_service.dart` is a stub; no dashboard widget. |
| FR-2 REQ-5 Assignment notifications | ❌ | No push/local notifications on assignment creation or grading. |
| FR-3 REQ-2 Automatic achievements awarding | ❌ | `achievements` field exists but no rule that grants them. |
| FR-3 REQ-5 Personalized performance recommendations | ❌ | Not implemented. |
| FR-5 REQ-4 Randomized quiz questions | ❌ | Questions returned in repository order. |
| FR-5 REQ-5 Share quizzes across courses | ⚠️ | Technically shareable because `quizzes` isn't course-scoped, but discovery UX isn't exposed. |
| FR-6 REQ-3 Shared notes per group | ❌ | Materials are per-course/public/private, not per-group. |
| FR-7 REQ-3 Feedback/likes on publications | ❌ | Not implemented. |
| FR-7 REQ-5 Citation/references | ❌ | Not implemented. |
| NFR-2 Firestore Security Rules | ⚠️ | Not present in repo; all enforcement is client-side today. |
| SRS tech: Firebase Storage | ⚠️ | `FirebaseProvider.uploadFile` is wired but unused — materials go to Google Drive. |
| Publication course dropdown | 🐞 | Hard-coded `CSE 221 / MATH 301 / CSE 341` strings, not real `courses/{id}` ids. |
| Badges count on dashboard | 🐞 | Hard-coded `"4"`. |
| XP bar denominator | 🐞 | Hard-coded `/3500`. |

---

## 7. Known Bugs / Follow-ups (from 2026-04-18 teacher-role E2E run)

Fixed during that run (see memory `teacher_role_findings_2026_04_18.md`):

- Dashboard now branches on role (teacher sees `getCoursesByTeacher`).
- Assignment view hides create/grade/delete/upload actions per role via `isTeacher` getter + `Obx`.
- Profile view no longer renders fake `CSE` / `DIU` tags when `department`/`university` are empty.
- Course list de-duplicates by `code` (case-insensitive) in `CourseRepository.getCourses`.
- `generateRecommendations` sorts `material_views` client-side so the missing `(userId asc + viewedAt desc)` index no longer throws `failed-precondition`.
- Teacher-only **Create Course** dialog added to DashboardView + `DashboardController.createCourse` method (previously `CourseRepository.createCourse` existed but had no UI caller).

Still outstanding: `pubspec` lists `avoid_print` info warnings in controllers (left as-is; non-blocking). `printSnackbar` usage on recoverable errors might obscure root causes in production builds — consider wiring `FirebaseAnalytics`/Crashlytics.

---

## 8. Runbook Notes

- **Run on emulator:** `flutter run` (emulator-5554, 1080×2400 as per memory `role_testing_workflow.md`).
- **adb from Git-Bash:** prefix any `adb` command touching `/sdcard/...` with `MSYS_NO_PATHCONV=1` (memory `adb_git_bash_paths.md`).
- **Package id:** `com.example.eeleventh_lssion_app_final`.
- **Firebase project:** configured via `firebase_core.initializeApp()` in `main.dart` (platform config files are outside `lib/`).

---

## 9. Requirement-to-File Index (quick lookup)

| SRS requirement | Primary file(s) |
|---|---|
| FR-1 Dashboard | [dashboard_controller.dart](lib/modules/dashboard/controllers/dashboard_controller.dart), [dashboard_view.dart](lib/modules/dashboard/views/dashboard_view.dart) |
| FR-2 Assignment | [assignment_controller.dart](lib/modules/assignment/controllers/assignment_controller.dart), [assignment_view.dart](lib/modules/assignment/views/assignment_view.dart), [grade_submissions_view.dart](lib/modules/assignment/views/grade_submissions_view.dart), [my_submissions_view.dart](lib/modules/assignment/views/my_submissions_view.dart) |
| FR-3 Progress | [progress_controller.dart](lib/modules/progress/controllers/progress_controller.dart), [progress_view.dart](lib/modules/progress/views/progress_view.dart), [export_service.dart](lib/core/services/export_service.dart) |
| FR-4 Offline | [offline_controller.dart](lib/modules/offline/controllers/offline_controller.dart), [sync_service.dart](lib/core/services/sync_service.dart), [local_storage_provider.dart](lib/data/providers/local_storage_provider.dart) |
| FR-5 Demo Quiz | [quiz_controller.dart](lib/modules/quiz/controllers/quiz_controller.dart), [quiz_view.dart](lib/modules/quiz/views/quiz_view.dart) |
| FR-6 Collaborative | [collaborative_controller.dart](lib/modules/collaborative/controllers/collaborative_controller.dart), [study_groups_view.dart](lib/modules/collaborative/views/study_groups_view.dart), [group_detail_view.dart](lib/modules/collaborative/views/group_detail_view.dart), [thread_detail_view.dart](lib/modules/collaborative/views/thread_detail_view.dart) |
| FR-7 Publication | [publication_controller.dart](lib/modules/publication/controllers/publication_controller.dart), [upload_material_view.dart](lib/modules/publication/views/upload_material_view.dart), [google_drive_service.dart](lib/core/services/google_drive_service.dart) |
| NFR-2 Auth/Roles | [auth_controller.dart](lib/modules/auth/controllers/auth_controller.dart), [auth_repository.dart](lib/data/repositories/auth_repository.dart), [firebase_provider.dart](lib/data/providers/firebase_provider.dart), [user_model.dart](lib/data/models/user_model.dart) |
| Routing / DI backbone | [app_pages.dart](lib/app/routes/app_pages.dart), [app_routes.dart](lib/app/routes/app_routes.dart), [initial_binding.dart](lib/app/bindings/initial_binding.dart) |

---

*End of report.*
