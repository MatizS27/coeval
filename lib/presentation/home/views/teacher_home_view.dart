import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Teacher homepage built from Figma (TeacherDashboard.tsx). Displays the list
/// of courses the instructor is teaching, with summary stats.  Tapping a card
/// navigates to the course page.  Colours, spacing and icons match the React
/// prototype exactly.

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: const Text('My Courses', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: _CourseList(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: replace with proper creation logic
      },
      backgroundColor: const Color(0xFFF76900),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class _CourseList extends StatelessWidget {
  _CourseList({Key? key}) : super(key: key);

  final List<Course> _courses = [
    Course(
      id: '1',
      name: 'Software Engineering',
      code: 'CS 4320',
      semester: 'Winter 2026',
      groups: 8,
      activities: 3,
    ),
    Course(
      id: '2',
      name: 'Web Development',
      code: 'CS 3380',
      semester: 'Winter 2026',
      groups: 6,
      activities: 2,
    ),
    Course(
      id: '3',
      name: 'Database Systems',
      code: 'CS 3710',
      semester: 'Winter 2026',
      groups: 10,
      activities: 4,
    ),
    Course(
      id: '4',
      name: 'Human-Computer Interaction',
      code: 'CS 4440',
      semester: 'Winter 2026',
      groups: 5,
      activities: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final c = _courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed('/teacher/course/${c.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2D2D2D),
                                  )),
                              const SizedBox(height: 4),
                              Text(c.code,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF777777),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(c.semester,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.group, size: 16, color: const Color(0xFF777777)),
                        const SizedBox(width: 4),
                        Text('${c.groups} Groups',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            )),
                        const SizedBox(width: 16),
                        Icon(Icons.article, size: 16, color: const Color(0xFF777777)),
                        const SizedBox(width: 4),
                        Text('${c.activities} Activities',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Course {
  final String id;
  final String name;
  final String code;
  final String semester;
  final int groups;
  final int activities;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.semester,
    required this.groups,
    required this.activities,
  });
}
