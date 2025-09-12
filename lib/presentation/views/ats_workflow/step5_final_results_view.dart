import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_container.dart';
import '../../../models/ats_workflow_models.dart';

class Step5FinalResultsView extends StatefulWidget {
  final ATSWorkflowState workflowState;
  final Function(ATSWorkflowState) onStateUpdate;
  final VoidCallback onBack;
  final VoidCallback onRestart;

  const Step5FinalResultsView({
    super.key,
    required this.workflowState,
    required this.onStateUpdate,
    required this.onBack,
    required this.onRestart,
  });

  @override
  State<Step5FinalResultsView> createState() => _Step5FinalResultsViewState();
}

class _Step5FinalResultsViewState extends State<Step5FinalResultsView> {
  int _selectedCandidateIndex = 0;

  List<RankedResume> get _finalCandidates {
    if (widget.workflowState.filterResult != null) {
      return widget.workflowState.filterResult!.filteredResumes;
    }
    return widget.workflowState.rankingResult?.rankedResumes ?? [];
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

  void _copyEmailsToClipboard() {
    final emails = _finalCandidates.map((c) => c.email).where((e) => e.isNotEmpty).join(', ');
    Clipboard.setData(ClipboardData(text: emails));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_finalCandidates.length} email addresses copied to clipboard'),
        backgroundColor: AppTheme.glowGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportResults() {
    // In a real app, this would generate a CSV or PDF report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality would be implemented here'),
        backgroundColor: AppTheme.glowBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterResult = widget.workflowState.filterResult;
    final rankingResult = widget.workflowState.rankingResult;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title and description
        GlowCard(
          glowColor: AppTheme.glowGreen,
          title: 'Step 5: Final Results',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review your final candidate selection and take action.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryGray,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.celebration_outlined,
                    size: 16,
                    color: AppTheme.glowGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Workflow complete! Your candidates are ranked and ready for review.',
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

        // Results summary
        GlowCard(
          glowColor: AppTheme.glowPurple,
          title: 'Results Summary',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Final Candidates',
                      _finalCandidates.length.toString(),
                      AppTheme.glowBlue,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Original Total',
                      widget.workflowState.processingResult?.totalProcessed.toString() ?? '0',
                      AppTheme.secondaryGray,
                    ),
                  ),
                ],
              ),
              
              if (filterResult != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Filter Efficiency',
                        '${((filterResult.filteredResumes.length / filterResult.filterSummary.totalInput) * 100).toStringAsFixed(1)}%',
                        AppTheme.glowOrange,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Avg Semantic Score',
                        '${(rankingResult?.summary.avgSemanticScore ?? 0 * 100).toStringAsFixed(1)}%',
                        AppTheme.glowPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: GlowButton(
                onPressed: _copyEmailsToClipboard,
                glowColor: AppTheme.glowBlue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Copy Emails (${_finalCandidates.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlowButton(
                onPressed: _exportResults,
                glowColor: AppTheme.glowGreen,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Export Results'),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Final candidates list
        if (_finalCandidates.isNotEmpty) ...[
          GlowCard(
            glowColor: AppTheme.glowGreen,
            title: 'Final Candidates',
            child: Column(
              children: [
                // Candidate selector tabs
                if (_finalCandidates.length > 1) ...[
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _finalCandidates.length,
                      itemBuilder: (context, index) {
                        final candidate = _finalCandidates[index];
                        final isSelected = index == _selectedCandidateIndex;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCandidateIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? _getMatchStatusColor(candidate.matchStatus)
                                  : _getMatchStatusColor(candidate.matchStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _getMatchStatusColor(candidate.matchStatus).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#${candidate.rank}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: isSelected 
                                            ? Colors.white 
                                            : _getMatchStatusColor(candidate.matchStatus),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  candidate.candidate.split(' ').first,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: isSelected 
                                            ? Colors.white 
                                            : _getMatchStatusColor(candidate.matchStatus),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Selected candidate details
                if (_finalCandidates.isNotEmpty) ...[
                  _buildCandidateDetail(_finalCandidates[_selectedCandidateIndex]),
                ],
              ],
            ),
          ),
        ] else ...[
          GlowCard(
            glowColor: AppTheme.glowRed,
            title: 'No Candidates Found',
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppTheme.glowRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'No candidates match your filtering criteria.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.glowRed,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Consider relaxing your filter requirements or reviewing the previous steps.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryGray,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: GlowButton(
                onPressed: widget.onBack,
                glowColor: AppTheme.secondaryGray,
                child: const Text('Back to Filters'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlowButton(
                onPressed: widget.onRestart,
                glowColor: AppTheme.glowBlue,
                child: const Text('Start New Workflow'),
              ),
            ),
          ],
        ),

        // Workflow summary
        const SizedBox(height: 32),
        GlowCard(
          glowColor: AppTheme.accentPurple,
          title: 'Workflow Summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkflowStep(
                '1. Resume Upload',
                '${widget.workflowState.processingResult?.totalProcessed ?? 0} resumes processed',
                AppTheme.glowBlue,
                true,
              ),
              const SizedBox(height: 12),
              _buildWorkflowStep(
                '2. Job Description',
                widget.workflowState.jobDescription?.title ?? 'Job description added',
                AppTheme.glowPurple,
                true,
              ),
              const SizedBox(height: 12),
              _buildWorkflowStep(
                '3. Semantic Ranking',
                '${widget.workflowState.rankingResult?.rankedResumes.length ?? 0} candidates ranked',
                AppTheme.glowGreen,
                true,
              ),
              const SizedBox(height: 12),
              _buildWorkflowStep(
                '4. Skills Filter',
                filterResult != null 
                    ? '${filterResult.filteredResumes.length} candidates after filtering'
                    : 'No filters applied',
                AppTheme.glowOrange,
                true,
              ),
              const SizedBox(height: 12),
              _buildWorkflowStep(
                '5. Final Results',
                '${_finalCandidates.length} final candidates ready for review',
                AppTheme.glowGreen,
                true,
              ),
            ],
          ),
        ),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryGray,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateDetail(RankedResume candidate) {
    return GlowContainer(
      glowColor: _getMatchStatusColor(candidate.matchStatus),
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      isAnimated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getMatchStatusColor(candidate.matchStatus),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    '#${candidate.rank}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      candidate.candidate,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      candidate.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.secondaryGray,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getMatchStatusColor(candidate.matchStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getMatchStatusColor(candidate.matchStatus).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  candidate.matchStatus,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _getMatchStatusColor(candidate.matchStatus),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Scores
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  'ATS Score',
                  '${candidate.atsScore}%',
                  AppTheme.glowBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScoreItem(
                  'Semantic Score',
                  '${(candidate.semanticScore * 100).toStringAsFixed(1)}%',
                  AppTheme.glowGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Skills
          if (candidate.skills.isNotEmpty) ...[
            Text(
              'Skills:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: candidate.skills.take(10).map((skill) {
                final isMatchingSkill = candidate.foundSkills.contains(skill);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMatchingSkill 
                        ? _getMatchStatusColor(candidate.matchStatus).withOpacity(0.2)
                        : AppTheme.secondaryGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isMatchingSkill 
                        ? Border.all(color: _getMatchStatusColor(candidate.matchStatus).withOpacity(0.5))
                        : null,
                  ),
                  child: Text(
                    skill,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isMatchingSkill 
                              ? _getMatchStatusColor(candidate.matchStatus)
                              : AppTheme.secondaryGray,
                          fontWeight: isMatchingSkill ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          if (candidate.experience.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Experience:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              candidate.experience.length > 300
                  ? '${candidate.experience.substring(0, 300)}...'
                  : candidate.experience,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryGray,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
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
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryGray,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(String title, String description, Color color, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? color : AppTheme.secondaryGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGray,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
