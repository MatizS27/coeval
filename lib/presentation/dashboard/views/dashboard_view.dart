import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme.dart';
import '../../../domain/entities/dashboard_stats.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final String? cycleId; // Opcional, necesario para profesores

  const DashboardView({super.key, this.cycleId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    // Cargar datos al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDashboardData(cycleId: cycleId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de Evaluación'),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isTeacher) {
          return _buildTeacherDashboard(controller);
        } else {
          return _buildStudentDashboard(controller);
        }
      }),
    );
  }

  Widget _buildStudentDashboard(DashboardController controller) {
    if (controller.studentResults.isEmpty) {
      return const Center(child: Text('No tienes resultados de evaluaciones todavía.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.studentResults.length,
      itemBuilder: (context, index) {
        final result = controller.studentResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evaluación: ${result.cycleId}', // Idealmente mostrar título del ciclo
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Promedio General:'),
                    Text(
                      result.averageTotal.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(result.averageTotal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...result.rubricScores.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(e.value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
                if (result.comments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Comentarios de tus pares:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...result.comments.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• "$c"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                  )),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeacherDashboard(DashboardController controller) {
    final consolidated = controller.teacherConsolidated.value;
    if (consolidated == null) {
      return const Center(child: Text('Selecciona una evaluación para ver los resultados.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          consolidated.cycleTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.9,
          children: [
            _buildKpiCard('Promedio general', consolidated.groupAverage.toStringAsFixed(2), _getScoreColor(consolidated.groupAverage)),
            _buildKpiCard('Estudiantes evaluados', '${consolidated.evaluatedStudents}/${consolidated.totalStudents}', AppColors.primary),
            _buildKpiCard('Pendientes', consolidated.pendingStudents.toString(), consolidated.pendingStudents > 0 ? Colors.orange : Colors.green),
            _buildKpiCard('Evaluaciones enviadas', consolidated.totalEvaluationsSubmitted.toString(), Colors.blueGrey),
          ],
        ),
        const SizedBox(height: 16),
        _buildCoverageCard(consolidated.completionRate),
        const SizedBox(height: 16),
        if (consolidated.rubricAverages.isNotEmpty) ...[
          const Text('Promedio por criterio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...consolidated.rubricAverages.entries.map((entry) {
            return _buildRubricRow(entry.key, entry.value);
          }),
          const SizedBox(height: 16),
        ],
        if (consolidated.groupStats.isNotEmpty) ...[
          const Text('Promedio por grupo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...consolidated.groupStats.map(_buildGroupStatsCard),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: _buildRankingCard('Top rendimiento', consolidated.topStudents, emptyText: 'Sin datos'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRankingCard('Requieren apoyo', consolidated.lowStudents, emptyText: 'Sin datos'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Detalle por estudiante', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Grupo')),
              DataColumn(label: Text('Promedio')),
              DataColumn(label: Text('Evaluadores')),
              DataColumn(label: Text('Estado')),
            ],
            rows: consolidated.results.map((res) => DataRow(
              cells: [
                DataCell(Text(res.evaluatee.name.isEmpty ? res.evaluatee.uid : res.evaluatee.name)),
                DataCell(Text(res.groupName.isEmpty ? '-' : res.groupName)),
                DataCell(Text(res.averageTotal.toStringAsFixed(2))),
                DataCell(Text(res.totalEvaluators.toString())),
                DataCell(Icon(
                  res.isOutstanding ? Icons.star : Icons.person_outline,
                  color: res.isOutstanding ? Colors.amber : Colors.grey,
                )),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.9))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCoverageCard(double completionRate) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cobertura de la actividad', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (completionRate / 100).clamp(0, 1),
              color: completionRate >= 70 ? Colors.green : Colors.orange,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 6),
            Text('${completionRate.toStringAsFixed(1)}% completado'),
          ],
        ),
      ),
    );
  }

  Widget _buildRubricRow(String rubric, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(rubric)),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _getScoreColor(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupStatsCard(GroupStats stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(stats.groupName.isEmpty ? 'Grupo' : stats.groupName),
        subtitle: Text(
          'Evaluados: ${stats.evaluatedStudents}/${stats.totalStudents}  •  Pendientes: ${stats.pendingStudents}',
        ),
        trailing: Text(
          stats.averageScore.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(stats.averageScore),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingCard(String title, List<EvaluationResult> students, {required String emptyText}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (students.isEmpty)
              Text(emptyText, style: TextStyle(color: Colors.grey.shade600))
            else
              ...students.map((student) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.evaluatee.name.isEmpty
                              ? student.evaluatee.uid
                              : student.evaluatee.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        student.averageTotal.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(student.averageTotal),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }
}
