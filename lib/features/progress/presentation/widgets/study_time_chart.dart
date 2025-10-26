import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';

class StudyTimeChart extends StatefulWidget {
  const StudyTimeChart({super.key});

  @override
  State<StudyTimeChart> createState() => _StudyTimeChartState();
}

class _StudyTimeChartState extends State<StudyTimeChart> {
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    context.read<ProgressBloc>().add(LoadStudyTime(period: _selectedPeriod));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Study Time',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '7d', child: Text('Week')),
                    DropdownMenuItem(value: '30d', child: Text('Month')),
                    DropdownMenuItem(value: '90d', child: Text('3 Months')),
                    DropdownMenuItem(value: '1y', child: Text('Year')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                      context.read<ProgressBloc>().add(
                        LoadStudyTime(period: value),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ProgressBloc, ProgressState>(
              builder: (context, state) {
                if (state is ProgressLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is StudyTimeLoaded) {
                  final studyTime = state.studyTime;
                  final hours = (studyTime.totalTime / 60).floor();
                  final minutes = studyTime.totalTime % 60;

                  return Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (hours > 0) ...[
                            Text(
                              hours.toString(),
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('hr', style: theme.textTheme.titleMedium),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            minutes.toString(),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('min', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total study time',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  );
                }

                if (state is ProgressError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.message,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No data available'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
