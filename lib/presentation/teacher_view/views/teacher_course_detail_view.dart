import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../controllers/teacher_home_controller.dart';

class TeacherCourseDetailView extends StatefulWidget {
  final TeacherCourseOverview course;

  const TeacherCourseDetailView({super.key, required this.course});

  @override
  State<TeacherCourseDetailView> createState() => _TeacherCourseDetailViewState();
}

class _TeacherCourseDetailViewState extends State<TeacherCourseDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TeacherHomeController _controller = Get.find<TeacherHomeController>();

  final _evaluationCycles = <EvaluationCycleData>[].obs;
  final _isLoadingCycles = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvaluationCycles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvaluationCycles() async {
    _isLoadingCycles.value = true;
    try {
      final cycles = await _controller.getEvaluationCyclesByCourse(widget.course.id);
      _evaluationCycles.assignAll(cycles);
    } finally {
      _isLoadingCycles.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: Text(widget.course.name, style: const TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF76900),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Grupos'),
            Tab(text: 'Evaluaciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupsTab(),
          _buildEvaluationsTab(),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    if (widget.course.categories.isEmpty) {
      return Center(
        child: Text(
          'Este curso no tiene categorías todavía.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.course.categories.length,
      itemBuilder: (context, index) {
        final category = widget.course.categories[index];
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
    );
  }

  Widget _buildEvaluationsTab() {
    return Stack(
      children: [
        Obx(() {
          if (_isLoadingCycles.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.course.categories.isEmpty) {
            return Center(
              child: Text(
                'Crea categorías y grupos primero para poder crear evaluaciones.',
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_evaluationCycles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay evaluaciones todavía',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presiona el botón + para crear una nueva evaluación',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final cyclesByGroup = <String, List<EvaluationCycleData>>{};
          for (final cycle in _evaluationCycles) {
            cyclesByGroup.putIfAbsent(cycle.groupId, () => []).add(cycle);
          }

          return RefreshIndicator(
            onRefresh: _loadEvaluationCycles,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.course.categories.length,
              itemBuilder: (context, catIndex) {
                final category = widget.course.categories[catIndex];
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                    ...category.groups.map((group) {
                      final groupCycles = cyclesByGroup[group.id] ?? [];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
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
                                    Expanded(
                                      child: Text(
                                        group.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F6F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${groupCycles.length} eval.',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${group.code} · ${group.activeStudentsCount} estudiantes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (groupCycles.isEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Sin evaluaciones para este grupo',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 12),
                                  ...groupCycles.map((cycle) {
                                    return _buildCycleItem(cycle);
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        }),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showCreateEvaluationDialog(context),
            backgroundColor: const Color(0xFFF76900),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCycleItem(EvaluationCycleData cycle) {
    final isOpen = cycle.isOpen;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cycle.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                isOpen ? 'Abierta' : 'Cerrada',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isOpen ? Colors.green.shade700 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (cycle.rubrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: cycle.rubrics.map((rubric) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF76900).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rubric,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFF76900),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (cycle.closesAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Cierra: ${_formatDate(cycle.closesAt!)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateEvaluationDialog(BuildContext context) {
    final groupsWithCategory = <({GroupOverview group, String categoryName})>[];
    for (final cat in widget.course.categories) {
      for (final group in cat.groups) {
        groupsWithCategory.add((group: group, categoryName: cat.name));
      }
    }

    if (groupsWithCategory.isEmpty) {
      Get.snackbar(
        'Error',
        'Debes crear categorías y grupos antes de crear evaluaciones',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final rubricCtrl = TextEditingController();
    final selectedGroupEntry = Rx<({GroupOverview group, String categoryName})?>(
      groupsWithCategory.first,
    );
    final selectedDate = Rxn<DateTime>();
    final rubrics = <String>[].obs;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.assignment_add, color: Color(0xFFF76900)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nueva Evaluación',
                  style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 18),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Título de la evaluación',
                      hintText: 'Ej: Corte 1 - Sprint 2',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Grupo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return DropdownButtonFormField<int>(
                      value: groupsWithCategory.indexOf(selectedGroupEntry.value!),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: groupsWithCategory.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return DropdownMenuItem(
                          value: idx,
                          child: Text(
                            '${item.categoryName} > ${item.group.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (idx) {
                        if (idx != null) {
                          selectedGroupEntry.value = groupsWithCategory[idx];
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Rúbrica (criterios a evaluar)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rubricCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ej: Comunicación',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              rubrics.add(value.trim());
                              rubricCtrl.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final value = rubricCtrl.text.trim();
                          if (value.isNotEmpty) {
                            rubrics.add(value);
                            rubricCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add_circle, color: Color(0xFFF76900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (rubrics.isEmpty) {
                      return Text(
                        'Agrega al menos un criterio',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: rubrics.asMap().entries.map((entry) {
                        return Chip(
                          label: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            rubrics.removeAt(entry.key);
                          },
                          backgroundColor: const Color(0xFFF6F6F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Fecha de cierre (opcional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: dialogContext,
                            initialTime: const TimeOfDay(hour: 23, minute: 59),
                          );
                          if (time != null) {
                            selectedDate.value = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate.value != null
                                    ? _formatDate(selectedDate.value!)
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: selectedDate.value != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            if (selectedDate.value != null)
                              InkWell(
                                onTap: () => selectedDate.value = null,
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            Obx(() {
              final canCreate = rubrics.isNotEmpty;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCreate 
                      ? const Color(0xFFF76900)
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: canCreate
                    ? () async {
                        final title = titleCtrl.text.trim();
                        final entry = selectedGroupEntry.value;

                        if (title.isEmpty || entry == null) {
                          return;
                        }

                        Navigator.of(dialogContext).pop();
                        await _controller.createEvaluationCycle(
                          courseId: widget.course.id,
                          groupId: entry.group.id,
                          title: title,
                          rubrics: rubrics.toList(),
                          closesAt: selectedDate.value,
                        );
                        await _loadEvaluationCycles();
                      }
                    : null,
                child: const Text('Crear'),
              );
            }),
          ],
        );
      },
    );
  }
}
