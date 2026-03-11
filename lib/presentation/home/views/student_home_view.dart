import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coeval/presentation/home/widgets/home_components.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({Key? key}) : super(key: key);

  @override
  _StudentHomeViewState createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  String _activeTab = 'pending';

  final List<StudentActivity> _pending = [
    StudentActivity(
      id: '1',
      name: 'Sprint 1 Peer Evaluation',
      courseName: 'CS 4320 - Software Engineering',
      dueDate: 'Feb 28, 2026',
      status: ActivityStatus.pending,
      progress: '2 of 4 completed',
    ),
    StudentActivity(
      id: '2',
      name: 'Mid-Term Team Assessment',
      courseName: 'CS 4320 - Software Engineering',
      dueDate: 'Feb 25, 2026',
      status: ActivityStatus.pending,
      progress: '0 of 4 completed',
    ),
    StudentActivity(
      id: '3',
      name: 'Project Review',
      courseName: 'CS 3380 - Web Development',
      dueDate: 'Feb 27, 2026',
      status: ActivityStatus.pending,
      progress: '1 of 3 completed',
    ),
  ];

  final List<StudentActivity> _completed = [
    StudentActivity(
      id: '4',
      name: 'Sprint 0 Evaluation',
      courseName: 'CS 4320 - Software Engineering',
      dueDate: 'Feb 10, 2026',
      status: ActivityStatus.completed,
    ),
    StudentActivity(
      id: '5',
      name: 'Team Formation Survey',
      courseName: 'CS 3380 - Web Development',
      dueDate: 'Feb 5, 2026',
      status: ActivityStatus.completed,
    ),
  ];

  void _onTab(String id) {
    setState(() {
      _activeTab = id;
    });
  }

  void _handleActivityTap(String id, ActivityStatus status) {
    if (status == ActivityStatus.completed) {
      Get.toNamed('/student/results/$id');
    } else {
      Get.toNamed('/student/evaluate/$id');
    }
  }

  List<StudentActivity> get _activities =>
      _activeTab == 'pending' ? _pending : _completed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Activities', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      {'id': 'pending', 'label': 'Pending'},
      {'id': 'completed', 'label': 'Completed'},
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: tabs.map((t) {
          final active = t['id'] == _activeTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTab(t['id'] as String),
              child: Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Center(
                        child: Text(
                          t['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: active
                                ? const Color(0xFFF76900)
                                : const Color(0xFF777777),
                          ),
                        ),
                      ),
                    ),
                    if (active)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFF76900)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_activities.isEmpty) {
      final icon = _activeTab == 'pending' ? Icons.access_time : Icons.check_circle;
      final message = _activeTab == 'pending'
          ? "You're all caught up!"
          : 'Complete activities to see them here';
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2F3F5),
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF999999)),
            ),
            const SizedBox(height: 16),
            Text(
              'No $_activeTab activities',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: List.generate(_activities.length, (index) {
          final a = _activities[index];
          return Column(
            children: [
              ListItem(
                title: a.name,
                subtitle: a.courseName,
                metadata: a.status == ActivityStatus.pending
                    ? 'Due ${a.dueDate}${a.progress != null ? ' • ${a.progress}' : ''}'
                    : 'Completed ${a.dueDate}',
                rightContent: Icon(
                  a.status == ActivityStatus.pending ? Icons.access_time : Icons.check_circle,
                  color: a.status == ActivityStatus.pending ? const Color(0xFF006FBF) : const Color(0xFF46A647),
                  size: 20,
                ),
                showChevron: true,
                onTap: () => _handleActivityTap(a.id, a.status),
              ),
              if (index < _activities.length - 1)
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
            ],
          );
        }),
      ),
    );
  }
}

/// --- support models -------------------------------------------------------

enum ActivityStatus { pending, completed }

class StudentActivity {
  final String id;
  final String name;
  final String courseName;
  final String dueDate;
  final ActivityStatus status;
  final String? progress;

  StudentActivity({
    required this.id,
    required this.name,
    required this.courseName,
    required this.dueDate,
    required this.status,
    this.progress,
  });
}
