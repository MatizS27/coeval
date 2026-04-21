import 'academic_entities.dart';

class EvaluationResult {
  final String id;
  final String cycleId;
  final StudentOverview evaluatee;
  final Map<String, double> rubricScores;
  final double averageTotal;
  final List<String> comments;
  final int totalEvaluators;

  EvaluationResult({
    required this.id,
    required this.cycleId,
    required this.evaluatee,
    required this.rubricScores,
    required this.averageTotal,
    required this.comments,
    required this.totalEvaluators,
  });

  bool get isOutstanding => averageTotal >= 4.0;
}

class DashboardConsolidated {
  final String cycleTitle;
  final List<EvaluationResult> results;
  final double groupAverage;

  DashboardConsolidated({
    required this.cycleTitle,
    required this.results,
    required this.groupAverage,
  });
}
