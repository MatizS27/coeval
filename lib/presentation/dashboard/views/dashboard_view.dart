import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme.dart';
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Promedio del Grupo:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                consolidated.groupAverage.toStringAsFixed(2),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Estudiante')),
                DataColumn(label: Text('Promedio')),
                DataColumn(label: Text('Evaluadores')),
                DataColumn(label: Text('Estado')),
              ],
              rows: consolidated.results.map((res) => DataRow(
                cells: [
                  DataCell(Text(res.evaluatee.uid)), // Cambiar a nombre real si está disponible
                  DataCell(Text(res.averageTotal.toStringAsFixed(1))),
                  DataCell(Text(res.totalEvaluators.toString())),
                  DataCell(Icon(
                    res.isOutstanding ? Icons.star : Icons.person_outline,
                    color: res.isOutstanding ? Colors.amber : Colors.grey,
                  )),
                ],
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }
}
