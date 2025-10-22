import 'package:flutter/material.dart';
import '../../domain/entities/prediction_result.dart';

/// Widget displaying prediction results in a grid
class PredictionResultGrid extends StatelessWidget {
  final List<PredictionResult> predictions;

  const PredictionResultGrid({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Predictions:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: predictions.length > 6 ? 6 : predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return _PredictionCard(prediction: prediction, rank: index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionResult prediction;
  final int rank;

  const _PredictionCard({required this.prediction, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTopPrediction = rank == 1;
    final isHighConfidence = prediction.isHighConfidence;

    return Material(
      color: isTopPrediction
          ? const Color(0xFF2A2A2A)
          : const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to kanji detail if exists in database
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: ${prediction.character}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTopPrediction
                  ? (isHighConfidence ? Colors.green : Colors.orange)
                  : Colors.white24,
              width: isTopPrediction ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rank badge
              if (isTopPrediction)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isHighConfidence ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isHighConfidence ? 'HIGH' : 'MEDIUM',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Kanji character
              Text(
                prediction.character,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans JP',
                ),
              ),
              const SizedBox(height: 8),

              // Confidence
              Text(
                prediction.confidencePercentage,
                style: TextStyle(
                  color: isTopPrediction
                      ? (isHighConfidence ? Colors.green : Colors.orange)
                      : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Rank number
              Text(
                '#$rank',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
