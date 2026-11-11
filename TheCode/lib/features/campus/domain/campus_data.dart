class CampusCourse {
  const CampusCourse(
    this.id,
    this.code,
    this.title,
    this.instructor,
    this.room,
  );
  final String id, code, title, instructor, room;
}

class CampusEvent {
  const CampusEvent(this.courseId, this.title, this.when, this.detail);
  final String courseId, title, when, detail;
}

class CampusData {
  const CampusData({
    this.courses = const [],
    this.classes = const [],
    this.deadlines = const [],
  });
  final List<CampusCourse> courses;
  final List<CampusEvent> classes, deadlines;
}

// Fixed sample week: independent of the device clock and backend.
const sampleCampus = CampusData(
  courses: [
    CampusCourse(
      'software',
      'SWAPD 402',
      'Software Application Development',
      'Dr. Salma Hassan',
      'Lab B-204',
    ),
    CampusCourse(
      'database',
      'CS 305',
      'Database Systems',
      'Dr. Omar Ali',
      'Room A-112',
    ),
    CampusCourse(
      'interaction',
      'CS 318',
      'Human–Computer Interaction',
      'Dr. Nour Adel',
      'Studio C-06',
    ),
  ],
  classes: [
    CampusEvent(
      'software',
      'Prototyping workshop',
      '09:00–10:30',
      'Lab B-204 · Bring your project prototype',
    ),
    CampusEvent(
      'database',
      'Database Systems lecture',
      '12:00–13:30',
      'Room A-112 · Indexes and query planning',
    ),
    CampusEvent(
      'interaction',
      'Usability testing studio',
      '15:00–16:00',
      'Studio C-06 · Peer feedback session',
    ),
  ],
  deadlines: [
    CampusEvent(
      'software',
      'Phase 1 prototype',
      'Thu 12 Nov · 23:59',
      'Submit the working UI and a short demonstration.',
    ),
    CampusEvent(
      'database',
      'SQL practice set 4',
      'Fri 13 Nov · 18:00',
      'Joins, grouping and query optimization exercises.',
    ),
    CampusEvent(
      'interaction',
      'Usability reflection',
      'Sun 15 Nov · 20:00',
      'Summarize three observations from your peer session.',
    ),
  ],
);
