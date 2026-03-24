class TeacherCourseOverview {
  final String id;
  final String name;
  final String nrc;
  final String term;
  final int categoriesCount;
  final int groupsCount;
  final int activeStudentsCount;
  final List<CategoryOverview> categories;

  TeacherCourseOverview({
    required this.id,
    required this.name,
    required this.nrc,
    required this.term,
    required this.categoriesCount,
    required this.groupsCount,
    required this.activeStudentsCount,
    this.categories = const [],
  });
}

class CategoryOverview {
  final String id;
  final String name;
  final int activeStudentsCount;
  final List<GroupOverview> groups;

  CategoryOverview({
    required this.id,
    required this.name,
    required this.activeStudentsCount,
    required this.groups,
  });
}

class GroupOverview {
  final String id;
  final String code;
  final String name;
  final int activeStudentsCount;
  final List<StudentOverview> students;

  GroupOverview({
    required this.id,
    required this.code,
    required this.name,
    required this.activeStudentsCount,
    this.students = const [],
  });
}

class StudentOverview {
  final String uid;
  final String name;
  final String email;
  final String studentId;

  StudentOverview({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
  });
}

class CsvSyncResult {
  final int createdGroups;
  final int activatedEnrollments;
  final int closedEnrollments;
  final int totalRows;

  CsvSyncResult({
    required this.createdGroups,
    required this.activatedEnrollments,
    required this.closedEnrollments,
    required this.totalRows,
  });
}

class EvaluationCycleData {
  final String id;
  final String title;
  final String status;
  final DateTime openedAt;
  final DateTime? closesAt;

  EvaluationCycleData({
    required this.id,
    required this.title,
    required this.status,
    required this.openedAt,
    required this.closesAt,
  });
}
