import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_container.dart';
import '../../../models/ats_workflow_models.dart';
import '../../../services/ats_service.dart';

class Step3SemanticRankingView extends StatefulWidget {
  final ATSWorkflowState workflowState;
  final Function(ATSWorkflowState) onStateUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3SemanticRankingView({
    super.key,
    required this.workflowState,
    required this.onStateUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step3SemanticRankingView> createState() =>
      _Step3SemanticRankingViewState();
}

class _Step3SemanticRankingViewState extends State<Step3SemanticRankingView> {
  bool _isRanking = false;
  String? _errorMessage;
  late final AtsService _atsService;

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    // Auto-start ranking if we have the required data but no ranking results yet
    if (widget.workflowState.processingResult != null &&
        widget.workflowState.jobDescription != null &&
        widget.workflowState.rankingResult == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSemanticRanking();
      });
    }
  }

  Future<void> _performSemanticRanking() async {
    if (widget.workflowState.processingResult == null ||
        widget.workflowState.jobDescription == null) {
      setState(() {
        _errorMessage = 'Missing required data for semantic ranking';
      });
      return;
    }

    setState(() {
      _isRanking = true;
      _errorMessage = null;
    });

    try {
      final result = await _atsService.semanticRanking(
        jobDescription: widget.workflowState.jobDescription!.description,
        resumes: widget.workflowState.processingResult!.resumes,
      );

      // Convert the result to SemanticRankingResult
      final rankingResult = SemanticRankingResult.fromJson(result);

      final newState = widget.workflowState.copyWith(
        rankingResult: rankingResult,
        currentStep: 3,
      );

      widget.onStateUpdate(newState);
      setState(() {
        _isRanking = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ranking failed: $e';
        _isRanking = false;
      });
    }
  }

  Color _getMatchStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent match':
        return AppTheme.glowGreen;
      case 'good match':
        return AppTheme.glowBlue;
      case 'moderate match':
        return AppTheme.glowOrange;
      default:
        return AppTheme.glowRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankingResult = widget.workflowState.rankingResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title and description
        GlowCard(
          glowColor: AppTheme.glowGreen,
          title: 'Step 3: Semantic Ranking',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI-powered semantic analysis matches resumes to your job description.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryGray),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 16,
                    color: AppTheme.glowGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using advanced NLP to understand context and meaning beyond keyword matching.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.glowGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Loading state
        if (_isRanking) ...[
          GlowCard(
            glowColor: AppTheme.glowBlue,
            title: 'Processing Semantic Analysis',
            child: Column(
              children: [
                const SizedBox(height: 16),
                GlowContainer(
                  glowColor: AppTheme.glowBlue,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(32),
                  isAnimated: true,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.glowBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analyzing semantic similarity...',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.glowBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This may take a few moments',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error message
        if (_errorMessage != null) ...[
          GlowContainer(
            glowColor: AppTheme.glowRed,
            borderRadius: 12,
            padding: const EdgeInsets.all(16),
            backgroundColor: AppTheme.glowRed.withOpacity(0.05),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.glowRed, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.glowRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowButton(
            onPressed: _performSemanticRanking,
            glowColor: AppTheme.glowBlue,
            child: const Text('Retry Semantic Ranking'),
          ),
        ],

        // Results
        if (rankingResult != null && !_isRanking) ...[
          // Summary statistics
          GlowCard(
            glowColor: AppTheme.glowPurple,
            title: 'Ranking Summary',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Total Candidates',
                        rankingResult.summary.totalCandidates.toString(),
                        AppTheme.glowBlue,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Excellent Matches',
                        rankingResult.summary.excellentMatches.toString(),
                        AppTheme.glowGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Good Matches',
                        rankingResult.summary.goodMatches.toString(),
                        AppTheme.glowOrange,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Avg Score',
                        '${(rankingResult.summary.avgSemanticScore * 100).toStringAsFixed(1)}%',
                        AppTheme.glowPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ranked candidates
          GlowCard(
            glowColor: AppTheme.glowGreen,
            title: 'Ranked Candidates',
            child: Column(
              children: [
                ...rankingResult.rankedResumes.take(10).map((resume) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GlowContainer(
                      glowColor: _getMatchStatusColor(resume.matchStatus),
                      borderRadius: 16,
                      padding: const EdgeInsets.all(20),
                      isAnimated: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Rank badge
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getMatchStatusColor(
                                    resume.matchStatus,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${resume.rank}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resume.candidate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      resume.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.secondaryGray,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Match status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getMatchStatusColor(
                                    resume.matchStatus,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getMatchStatusColor(
                                      resume.matchStatus,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  resume.matchStatus,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: _getMatchStatusColor(
                                          resume.matchStatus,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Scores
                          Row(
                            children: [
                              Expanded(
                                child: _buildScoreItem(
                                  'ATS Score',
                                  '${resume.atsScore}%',
                                  AppTheme.glowBlue,
                                ),
                              ),
                              Expanded(
                                child: _buildScoreItem(
                                  'Semantic Score',
                                  '${(resume.semanticScore * 100).toStringAsFixed(1)}%',
                                  AppTheme.glowGreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Found skills
                          if (resume.foundSkills.isNotEmpty) ...[
                            Text(
                              'Matching Skills:',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: resume.foundSkills.take(8).map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getMatchStatusColor(
                                      resume.matchStatus,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    skill,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: _getMatchStatusColor(
                                            resume.matchStatus,
                                          ),
                                        ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),

                if (rankingResult.rankedResumes.length > 10) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Showing top 10 candidates. Continue to see filtering options.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryGray,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  onPressed: widget.onBack,
                  glowColor: AppTheme.secondaryGray,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: GlowButton(
                  onPressed: widget.onNext,
                  glowColor: AppTheme.glowGreen,
                  child: const Text('Continue to Skills Filter'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryGray),
          ),
        ],
      ),
    );
  }
}
