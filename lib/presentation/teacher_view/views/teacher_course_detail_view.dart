import 'package:flutter/material.dart';

import '../../../domain/entities/academic_entities.dart';

class TeacherCourseDetailView extends StatelessWidget {
  final TeacherCourseOverview course;

  const TeacherCourseDetailView({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: Text(course.name, style: const TextStyle(color: Colors.white)),
      ),
      body: course.categories.isEmpty
          ? Center(
              child: Text(
                'Este curso no tiene categorías todavía.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: course.categories.length,
              itemBuilder: (context, index) {
                final category = course.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${category.groups.length} grupos · ${category.activeStudentsCount} estudiantes',
                      ),
                      children: [
                        if (category.groups.isEmpty)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Sin grupos en esta categoría'),
                            ),
                          )
                        else
                          ...category.groups.map((group) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    8,
                                  ),
                                  title: Text(group.name),
                                  subtitle: Text(
                                    '${group.code} · ${group.activeStudentsCount} estudiantes',
                                  ),
                                  children: [
                                    if (group.students.isEmpty)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text('Sin estudiantes activos'),
                                        ),
                                      )
                                    else
                                      ...group.students.map((student) {
                                        return ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Icon(
                                            Icons.person_outline,
                                          ),
                                          title: Text(
                                            student.name.isEmpty
                                                ? student.email
                                                : student.name,
                                          ),
                                          subtitle: Text(
                                            '${student.email}${student.studentId.isNotEmpty ? ' · ${student.studentId}' : ''}',
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
