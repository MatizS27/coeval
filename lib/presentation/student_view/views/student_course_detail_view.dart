import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/student_home_controller.dart';
import 'evaluate_peers_view.dart';

class StudentCourseDetailView extends StatefulWidget {
  final TeacherCourseOverview course;

  const StudentCourseDetailView({super.key, required this.course});

  @override
  State<StudentCourseDetailView> createState() => _StudentCourseDetailViewState();
}

class _StudentCourseDetailViewState extends State<StudentCourseDetailView> {
  final StudentHomeController _controller = Get.find<StudentHomeController>();
  final AuthController _authController = Get.find<AuthController>();

  final _pendingEvaluations = <PendingEvaluationInfo>[].obs;
  final _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadPendingEvaluations();
  }

  Future<void> _loadPendingEvaluations() async {
    _isLoading.value = true;
    try {
      final allPending = await _controller.getPendingEvaluations();
      final forThisCourse = allPending.where((p) => 
        p.cycle.courseId == widget.course.id
      ).toList();
      _pendingEvaluations.assignAll(forThisCourse);
    } finally {
      _isLoading.value = false;
    }
  }

  String get _currentEmail => 
      _authController.currentUser.value?.email.trim().toLowerCase() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: Text(widget.course.name, style: const TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingEvaluations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPendingEvaluationsSection(),
              const SizedBox(height: 16),
              _buildMyGroupsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingEvaluationsSection() {
    return Obx(() {
      if (_isLoading.value) {
        return const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFFF76900),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Evaluaciones Pendientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const Spacer(),
                  if (_pendingEvaluations.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF76900),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingEvaluations.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_pendingEvaluations.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 40,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes evaluaciones pendientes',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._pendingEvaluations.map((pending) {
                  return _buildPendingEvaluationCard(pending);
                }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPendingEvaluationCard(PendingEvaluationInfo pending) {
    final pendingCount = pending.pendingCount;
    final totalPeers = pending.peersToEvaluate.length;
    final completedCount = totalPeers - pendingCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: pendingCount > 0 
              ? const Color(0xFFF76900).withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: pendingCount > 0
              ? () async {
                  await Get.to(() => EvaluatePeersView(pendingInfo: pending));
                  _loadPendingEvaluations();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pending.cycle.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pendingCount > 0 
                            ? const Color(0xFFF76900).withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pendingCount > 0 
                            ? '$pendingCount pendiente${pendingCount > 1 ? 's' : ''}'
                            : 'Completada',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: pendingCount > 0 
                              ? const Color(0xFFF76900)
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${pending.categoryName} - ${pending.group.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalPeers > 0 ? completedCount / totalPeers : 0,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(
                    pendingCount > 0 ? const Color(0xFFF76900) : Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedCount de $totalPeers compañeros evaluados',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (pending.cycle.closesAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Cierra: ${_formatDate(pending.cycle.closesAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyGroupsSection() {
    final myCategories = widget.course.categories.where((cat) {
      return cat.groups.any((group) {
        return group.students.any((s) => 
          s.email.trim().toLowerCase() == _currentEmail
        );
      });
    }).toList();

    if (myCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  color: Color(0xFF2D2D2D),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Mis Grupos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...myCategories.map((category) {
              final myGroups = category.groups.where((group) {
                return group.students.any((s) => 
                  s.email.trim().toLowerCase() == _currentEmail
                );
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...myGroups.map((group) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${group.name} (${group.code})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...group.students.map((student) {
                            final isMe = student.email.trim().toLowerCase() == _currentEmail;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    isMe ? Icons.person : Icons.person_outline,
                                    size: 16,
                                    color: isMe 
                                        ? const Color(0xFFF76900)
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${student.name.isEmpty ? student.email : student.name}${isMe ? ' (Tú)' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMe 
                                            ? const Color(0xFFF76900)
                                            : Colors.grey.shade700,
                                        fontWeight: isMe 
                                            ? FontWeight.w600 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
