import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/academic_entities.dart';
import '../controllers/student_home_controller.dart';

class EvaluatePeersView extends StatefulWidget {
  final PendingEvaluationInfo pendingInfo;

  const EvaluatePeersView({super.key, required this.pendingInfo});

  @override
  State<EvaluatePeersView> createState() => _EvaluatePeersViewState();
}

class _EvaluatePeersViewState extends State<EvaluatePeersView> {
  final StudentHomeController _controller = Get.find<StudentHomeController>();

  final _rubricScores = <String, Map<int, int>>{}.obs;
  final _comments = <String, String>{}.obs;
  final _isSubmitting = false.obs;
  final _submittedUids = <String>{}.obs;

  List<String> get rubrics => widget.pendingInfo.cycle.rubrics;

  @override
  void initState() {
    super.initState();
    _submittedUids.addAll(widget.pendingInfo.alreadyEvaluatedUids);
    
    for (final peer in widget.pendingInfo.peersToEvaluate) {
      _rubricScores[peer.uid] = {};
      for (int i = 0; i < rubrics.length; i++) {
        _rubricScores[peer.uid]![i] = 3;
      }
      _comments[peer.uid] = '';
    }
  }

  List<StudentOverview> get _pendingPeers {
    return widget.pendingInfo.peersToEvaluate
        .where((p) => !_submittedUids.contains(p.uid))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.pendingInfo.cycle.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              widget.pendingInfo.group.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final pendingPeers = _pendingPeers;

        if (pendingPeers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Has evaluado a todos tus compañeros',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gracias por completar la evaluación',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF76900),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: pendingPeers.length,
          itemBuilder: (context, index) {
            final peer = pendingPeers[index];
            return _buildPeerEvaluationCard(peer);
          },
        );
      }),
    );
  }

  Widget _buildPeerEvaluationCard(StudentOverview peer) {
    return Obx(() {
      final isSubmitting = _isSubmitting.value;
      final peerScores = _rubricScores[peer.uid] ?? {};

      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
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
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF76900).withAlpha(25),
                    child: Text(
                      _getInitials(peer.name, peer.email),
                      style: const TextStyle(
                        color: Color(0xFFF76900),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peer.name.isEmpty ? peer.email : peer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        if (peer.name.isNotEmpty)
                          Text(
                            peer.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildAverageScoreBadge(peerScores),
                ],
              ),
              const SizedBox(height: 20),
              
              if (rubrics.isEmpty)
                _buildSingleScoreSlider(peer, isSubmitting)
              else
                ...rubrics.asMap().entries.map((entry) {
                  return _buildRubricSlider(
                    peer: peer,
                    rubricIndex: entry.key,
                    rubricName: entry.value,
                    currentScore: peerScores[entry.key] ?? 3,
                    isSubmitting: isSubmitting,
                  );
                }),
              
              const SizedBox(height: 8),
              const Text(
                'Comentarios (opcional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                enabled: !isSubmitting,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Escribe un comentario sobre el desempeño...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFF76900),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  _comments[peer.uid] = value;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _submitEvaluation(peer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76900),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar Evaluación',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAverageScoreBadge(Map<int, int> scores) {
    if (scores.isEmpty) return const SizedBox.shrink();
    
    final avg = scores.values.reduce((a, b) => a + b) / scores.length;
    final color = _getScoreColor(avg.toDouble());
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Prom: ${avg.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSingleScoreSlider(StudentOverview peer, bool isSubmitting) {
    final scores = _rubricScores[peer.uid] ?? {};
    final score = (scores[0] ?? 3).toDouble();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Puntuación general',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        _buildScoreSlider(
          score: score,
          onChanged: isSubmitting
              ? null
              : (value) {
                  final map = Map<int, int>.from(_rubricScores[peer.uid] ?? {});
                  map[0] = value.round();
                  _rubricScores[peer.uid] = map;
                },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRubricSlider({
    required StudentOverview peer,
    required int rubricIndex,
    required String rubricName,
    required int currentScore,
    required bool isSubmitting,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFF76900).withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${rubricIndex + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF76900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rubricName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getScoreColor(currentScore.toDouble()).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$currentScore',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(currentScore.toDouble()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildScoreSlider(
          score: currentScore.toDouble(),
          onChanged: isSubmitting
              ? null
              : (value) {
                  final map = Map<int, int>.from(_rubricScores[peer.uid] ?? {});
                  map[rubricIndex] = value.round();
                  _rubricScores[peer.uid] = map;
                },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildScoreSlider({
    required double score,
    required void Function(double)? onChanged,
  }) {
    return Row(
      children: [
        Text(
          '1',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF76900),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xFFF76900),
              overlayColor: const Color(0xFFF76900).withAlpha(50),
              valueIndicatorColor: const Color(0xFFF76900),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: score,
              min: 1,
              max: 5,
              divisions: 4,
              label: score.toStringAsFixed(0),
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          '5',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Future<void> _submitEvaluation(StudentOverview peer) async {
    _isSubmitting.value = true;
    try {
      final peerScores = _rubricScores[peer.uid] ?? {};
      final comment = _comments[peer.uid] ?? '';

      final scoresList = <int>[];
      if (rubrics.isEmpty) {
        scoresList.add(peerScores[0] ?? 3);
      } else {
        for (int i = 0; i < rubrics.length; i++) {
          scoresList.add(peerScores[i] ?? 3);
        }
      }

      final success = await _controller.submitEvaluation(
        cycleId: widget.pendingInfo.cycle.id,
        evaluateeUid: peer.uid,
        scores: scoresList,
        comments: comment.isEmpty ? null : comment,
      );

      if (success) {
        _submittedUids.add(peer.uid);
        Get.snackbar(
          'Evaluación enviada',
          'Has evaluado a ${peer.name.isEmpty ? peer.email : peer.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  String _getInitials(String name, String email) {
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return email.substring(0, email.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getScoreColor(double score) {
    switch (score.round()) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
