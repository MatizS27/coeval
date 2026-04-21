import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'roble_datasource.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/academic_entities.dart';

class DashboardRemoteDatasource {
  final RobleDatasource _robleDatasource;

  DashboardRemoteDatasource(this._robleDatasource);

  static const String _evaluationsTable = 'evaluations';
  static const String _evaluationCyclesTable = 'evaluation_cycles';
  static const String _usersTable = 'users';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_robleDatasource.currentToken != null)
      'Authorization': 'Bearer ${_robleDatasource.currentToken}',
  };

  Future<List<EvaluationResult>> getResultsForStudent(String studentUid) async {
    final query = {
      'tableName': _evaluationsTable,
      'evaluateeUid': studentUid,
    };

    final uri = Uri.parse('${_robleDatasource.databaseUrl}/${_robleDatasource.dbName}/read')
        .replace(queryParameters: query);

    try {
      final response = await _robleDatasource.client.get(uri, headers: _headers);

      if (response.statusCode != 200) return [];

      final data = _parseRobleResponse(response.body);
      
      final Map<String, List<Map<String, dynamic>>> groupedByCycle = {};
      for (var item in data) {
        final cycleId = item['cycleId']?.toString() ?? '';
        if (cycleId.isNotEmpty) {
          groupedByCycle.putIfAbsent(cycleId, () => []).add(item);
        }
      }

      List<EvaluationResult> results = [];
      for (var cycleId in groupedByCycle.keys) {
        final evals = groupedByCycle[cycleId]!;
        final cycleInfo = await _getCycleInfo(cycleId);
        results.add(_processEvaluations(cycleId, studentUid, evals, cycleInfo.rubrics, cycleInfo.title));
      }
      return results;
    } catch (e) {
      if (kDebugMode) print('Error in getResultsForStudent: $e');
      return [];
    }
  }

  Future<DashboardConsolidated> getResultsForTeacher(String cycleId) async {
    try {
      if (kDebugMode) print('[DASHBOARD] Cargando datos para ciclo: $cycleId');
      
      // 1. Obtener info del ciclo (título y rúbricas)
      final cycleInfo = await _getCycleInfo(cycleId);

      // 2. Obtener todas las evaluaciones del ciclo
      final evalsQuery = {'tableName': _evaluationsTable, 'cycleId': cycleId};
      final evalsUri = Uri.parse('${_robleDatasource.databaseUrl}/${_robleDatasource.dbName}/read')
          .replace(queryParameters: evalsQuery);

      final evalsResp = await _robleDatasource.client.get(evalsUri, headers: _headers);
      final allEvals = _parseRobleResponse(evalsResp.body);

      if (kDebugMode) print('[DASHBOARD] Total evaluaciones encontradas: ${allEvals.length}');

      if (allEvals.isEmpty) {
        return DashboardConsolidated(cycleTitle: cycleInfo.title, results: [], groupAverage: 0);
      }

      // 3. Obtener nombres de usuarios
      final Map<String, String> userNames = await _fetchAllUserNames();

      // 4. Procesar resultados por cada estudiante evaluado
      final Map<String, List<Map<String, dynamic>>> byEvaluatee = {};
      for (var ev in allEvals) {
        final uid = ev['evaluateeUid']?.toString() ?? '';
        if (uid.isNotEmpty) {
          byEvaluatee.putIfAbsent(uid, () => []).add(ev);
        }
      }

      List<EvaluationResult> results = [];
      double totalSum = 0;
      for (var uid in byEvaluatee.keys) {
        final res = _processEvaluations(
          cycleId, 
          uid, 
          byEvaluatee[uid]!, 
          cycleInfo.rubrics, 
          cycleInfo.title,
          userName: userNames[uid]
        );
        results.add(res);
        totalSum += res.averageTotal;
      }

      return DashboardConsolidated(
        cycleTitle: cycleInfo.title,
        results: results,
        groupAverage: results.isEmpty ? 0 : totalSum / results.length,
      );
    } catch (e) {
      if (kDebugMode) print('Error in getResultsForTeacher: $e');
      return DashboardConsolidated(cycleTitle: 'Error', results: [], groupAverage: 0);
    }
  }

  Future<({String title, List<String> rubrics})> _getCycleInfo(String cycleId) async {
    try {
      final query = {'tableName': _evaluationCyclesTable, '_id': cycleId};
      final uri = Uri.parse('${_robleDatasource.databaseUrl}/${_robleDatasource.dbName}/read')
          .replace(queryParameters: query);
      
      final resp = await _robleDatasource.client.get(uri, headers: _headers);
      final data = _parseRobleResponse(resp.body);
      
      if (data.isNotEmpty) {
        final cycle = data[0];
        final String title = (cycle['title'] ?? 'Evaluación').toString();
        List<String> rubrics = [];
        final criteria = cycle['criteria'];
        if (criteria != null) {
          final criteriaMap = criteria is String ? jsonDecode(criteria) : criteria;
          if (criteriaMap['rubrics'] != null) {
            rubrics = List<String>.from(criteriaMap['rubrics']);
          }
        }
        return (title: title, rubrics: rubrics);
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching cycle info: $e');
    }
    return (title: 'Evaluación', rubrics: <String>[]);
  }

  Future<Map<String, String>> _fetchAllUserNames() async {
    final Map<String, String> names = {};
    try {
      final uri = Uri.parse('${_robleDatasource.databaseUrl}/${_robleDatasource.dbName}/read?tableName=$_usersTable');
      final resp = await _robleDatasource.client.get(uri, headers: _headers);
      final users = _parseRobleResponse(resp.body);
      
      for (var u in users) {
        final uid = u['uid']?.toString() ?? u['_id']?.toString() ?? '';
        final name = u['name']?.toString() ?? '';
        if (uid.isNotEmpty && name.isNotEmpty) {
          names[uid] = name;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user names: $e');
    }
    return names;
  }

  EvaluationResult _processEvaluations(
    String cycleId, 
    String evaluateeUid, 
    List<dynamic> evals, 
    List<String> realRubrics, 
    String cycleTitle,
    {String? userName}
  ) {
    Map<String, double> rubricsAvg = {};
    List<String> allComments = [];
    int count = 0;

    for (var ev in evals) {
      try {
        final resultsRaw = ev['results'];
        if (resultsRaw == null) continue;
        final resultsMap = resultsRaw is String ? jsonDecode(resultsRaw) : resultsRaw;
        final scores = resultsMap['scores'] as List?;
        if (scores == null) continue;
        
        final comments = ev['comments'] as String?;
        if (comments != null && comments.isNotEmpty) allComments.add(comments);

        for (int i = 0; i < scores.length; i++) {
          final rName = (realRubrics.length > i) ? realRubrics[i] : 'Criterio ${i + 1}';
          rubricsAvg[rName] = (rubricsAvg[rName] ?? 0) + (scores[i] as num).toDouble();
        }
        count++;
      } catch (_) {}
    }

    if (count > 0) {
      rubricsAvg.updateAll((key, value) => value / count);
    }
    
    double totalScoreSum = rubricsAvg.isEmpty ? 0 : rubricsAvg.values.reduce((a, b) => a + b) / rubricsAvg.length;

    return EvaluationResult(
      id: '${cycleId}_$evaluateeUid',
      cycleId: cycleTitle,
      evaluatee: StudentOverview(uid: evaluateeUid, name: userName ?? 'Estudiante', email: '', studentId: ''),
      rubricScores: rubricsAvg,
      averageTotal: totalScoreSum,
      comments: allComments,
      totalEvaluators: count,
    );
  }

  List<Map<String, dynamic>> _parseRobleResponse(String body) {
    try {
      final data = jsonDecode(body);
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          return (data['data'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
        if (data.containsKey('_id') || data.containsKey('id')) {
          return [data];
        }
      }
    } catch (_) {}
    return [];
  }
}
