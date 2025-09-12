import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_container.dart';
import '../../../models/ats_workflow_models.dart';
import '../../../services/ats_service.dart';

class Step4SkillsFilterView extends StatefulWidget {
  final ATSWorkflowState workflowState;
  final Function(ATSWorkflowState) onStateUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4SkillsFilterView({
    super.key,
    required this.workflowState,
    required this.onStateUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step4SkillsFilterView> createState() => _Step4SkillsFilterViewState();
}

class _Step4SkillsFilterViewState extends State<Step4SkillsFilterView> {
  List<String> _availableSkills = [];
  List<String> _selectedSkills = [];
  String _experienceFilter = '';
  bool _isLoadingSkills = false;
  bool _isFiltering = false;
  String? _errorMessage;
  final TextEditingController _experienceController = TextEditingController();
  late final AtsService _atsService;

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    _loadAvailableSkills();

    // Pre-populate with job description skills if available
    if (widget.workflowState.jobDescription != null) {
      _selectedSkills.addAll(
        widget.workflowState.jobDescription!.requiredSkills,
      );
      _experienceController.text =
          widget.workflowState.jobDescription!.experienceLevel;
      _experienceFilter = widget.workflowState.jobDescription!.experienceLevel;
    }
  }

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSkills() async {
    if (widget.workflowState.rankingResult == null) return;

    setState(() {
      _isLoadingSkills = true;
      _errorMessage = null;
    });

    try {
      final result = await _atsService.getAvailableSkills(
        resumes: widget.workflowState.rankingResult!.rankedResumes,
      );

      setState(() {
        _availableSkills = result['availableSkills'] ?? [];
        _isLoadingSkills = false;
      });

      // Update workflow state with available skills
      final newState = widget.workflowState.copyWith(
        availableSkills: result['availableSkills'] ?? [],
      );
      widget.onStateUpdate(newState);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load available skills: $e';
        _isLoadingSkills = false;
      });
    }
  }

  Future<void> _applyFilters() async {
    if (widget.workflowState.rankingResult == null) return;

    setState(() {
      _isFiltering = true;
      _errorMessage = null;
    });

    try {
      final result = await _atsService.filterResumes(
        resumes: widget.workflowState.rankingResult!.rankedResumes,
        skillFilters: _selectedSkills,
        experienceFilter: _experienceFilter,
      );

      // Convert the result to FilterResult
      final filterResult = FilterResult.fromJson(result);

      final newState = widget.workflowState.copyWith(
        filterResult: filterResult,
        currentStep: 4,
      );

      widget.onStateUpdate(newState);
      widget.onNext();
    } catch (e) {
      setState(() {
        _errorMessage = 'Filtering failed: $e';
        _isFiltering = false;
      });
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rankingResult = widget.workflowState.rankingResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title and description
        GlowCard(
          glowColor: AppTheme.glowOrange,
          title: 'Step 4: Skills Filter',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter candidates by mandatory skills and experience requirements.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryGray),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 16,
                    color: AppTheme.glowOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select mandatory skills to filter out candidates who don\'t meet requirements.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.glowOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Current candidates summary
        if (rankingResult != null) ...[
          GlowCard(
            glowColor: AppTheme.glowBlue,
            title: 'Current Candidates',
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Candidates',
                    rankingResult.rankedResumes.length.toString(),
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
                Expanded(
                  child: _buildSummaryItem(
                    'Good Matches',
                    rankingResult.summary.goodMatches.toString(),
                    AppTheme.glowOrange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],

        // Experience filter
        GlowCard(
          glowColor: AppTheme.glowPurple,
          title: 'Experience Filter',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by experience keywords (optional)',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryGray),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(
                  hintText: 'e.g., senior, 5+ years, lead, manager',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.glowPurple.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.glowPurple,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  _experienceFilter = value;
                },
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Skills selection
        GlowCard(
          glowColor: AppTheme.glowGreen,
          title: 'Mandatory Skills',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select skills that candidates MUST have (ALL selected skills required)',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryGray),
              ),
              const SizedBox(height: 16),

              if (_isLoadingSkills) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_availableSkills.isEmpty) ...[
                Text(
                  'No skills found in candidate profiles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                // Selected skills
                if (_selectedSkills.isNotEmpty) ...[
                  Text(
                    'Selected Skills (${_selectedSkills.length}):',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.glowGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.glowGreen,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.glowGreen.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _toggleSkill(skill),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Available skills
                Text(
                  'Available Skills (tap to add):',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSkills
                      .where((skill) => !_selectedSkills.contains(skill))
                      .map((skill) {
                        return GestureDetector(
                          onTap: () => _toggleSkill(skill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.glowGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.glowGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  skill,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.glowGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppTheme.glowGreen,
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

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
          const SizedBox(height: 24),
        ],

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
              child: GlowButton(
                onPressed: _selectedSkills.isEmpty && _experienceFilter.isEmpty
                    ? widget
                          .onNext // Skip filtering if no filters selected
                    : null,
                glowColor: AppTheme.secondaryGray,
                child: const Text('Skip Filtering'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GlowButton(
                onPressed: !_isFiltering ? _applyFilters : null,
                glowColor: AppTheme.glowOrange,
                isLoading: _isFiltering,
                child: Text(
                  _isFiltering ? 'Filtering...' : 'Apply Filters & Continue',
                ),
              ),
            ),
          ],
        ),

        // Filter preview
        if (_selectedSkills.isNotEmpty || _experienceFilter.isNotEmpty) ...[
          const SizedBox(height: 24),
          GlowCard(
            glowColor: AppTheme.accentPurple,
            title: 'Filter Preview',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedSkills.isNotEmpty) ...[
                  Text(
                    'Required Skills: ${_selectedSkills.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (_experienceFilter.isNotEmpty) ...[
                  if (_selectedSkills.isNotEmpty) const SizedBox(height: 8),
                  Text(
                    'Experience Filter: $_experienceFilter',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Candidates must have ALL selected skills and match experience criteria.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
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
}
