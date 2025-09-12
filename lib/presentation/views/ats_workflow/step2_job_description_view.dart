import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_container.dart';
import '../../../models/ats_workflow_models.dart';
import 'package:uuid/uuid.dart';

class Step2JobDescriptionView extends StatefulWidget {
  final ATSWorkflowState workflowState;
  final Function(ATSWorkflowState) onStateUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2JobDescriptionView({
    super.key,
    required this.workflowState,
    required this.onStateUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2JobDescriptionView> createState() =>
      _Step2JobDescriptionViewState();
}

class _Step2JobDescriptionViewState extends State<Step2JobDescriptionView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final List<String> _requiredSkills = [];
  final TextEditingController _skillController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workflowState.jobDescription != null) {
      final job = widget.workflowState.jobDescription!;
      _titleController.text = job.title;
      _descriptionController.text = job.description;
      _experienceController.text = job.experienceLevel;
      _requiredSkills.addAll(job.requiredSkills);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_requiredSkills.contains(skill)) {
      setState(() {
        _requiredSkills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _requiredSkills.remove(skill);
    });
  }

  void _continueToRanking() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in job title and description';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobId = const Uuid().v4();
      final jobDescription = JobDescription(
        id: jobId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requiredSkills: _requiredSkills,
        experienceLevel: _experienceController.text.trim(),
        createdAt: DateTime.now(),
      );

      final newState = widget.workflowState.copyWith(
        jobId: jobId,
        jobDescription: jobDescription,
        currentStep: 2,
      );

      widget.onStateUpdate(newState);
      widget.onNext();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save job description: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title and description
        GlowCard(
          glowColor: AppTheme.glowPurple,
          title: 'Step 2: Job Description',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provide detailed job information to enable semantic matching with resumes.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryGray),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.glowPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The more detailed your job description, the better the semantic matching will be.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.glowPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Job Title
        GlowCard(
          glowColor: AppTheme.glowBlue,
          title: 'Job Title',
          child: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'e.g., Senior Full Stack Developer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.glowBlue.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.glowBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),

        const SizedBox(height: 24),

        // Job Description
        GlowCard(
          glowColor: AppTheme.glowGreen,
          title: 'Job Description',
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText:
                  'Paste the complete job description here...\n\nInclude:\n- Role responsibilities\n- Required qualifications\n- Preferred skills\n- Company information',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.glowGreen.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.glowGreen, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),

        const SizedBox(height: 24),

        // Experience Level
        GlowCard(
          glowColor: AppTheme.glowOrange,
          title: 'Experience Level',
          child: TextFormField(
            controller: _experienceController,
            decoration: InputDecoration(
              hintText: 'e.g., 3-5 years, Senior level, Entry level',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.glowOrange.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.glowOrange, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),

        const SizedBox(height: 24),

        // Required Skills
        GlowCard(
          glowColor: AppTheme.accentPurple,
          title: 'Required Skills (Optional)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add specific skills to help with filtering later',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryGray),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillController,
                      decoration: InputDecoration(
                        hintText: 'e.g., React, Python, AWS',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.accentPurple.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.accentPurple,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onFieldSubmitted: (_) => _addSkill(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlowButton(
                    onPressed: _addSkill,
                    glowColor: AppTheme.accentPurple,
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              if (_requiredSkills.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _requiredSkills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            skill,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.accentPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeSkill(skill),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
              flex: 2,
              child: GlowButton(
                onPressed: !_isLoading ? _continueToRanking : null,
                glowColor: AppTheme.glowPurple,
                isLoading: _isLoading,
                child: Text(
                  _isLoading ? 'Saving...' : 'Continue to Semantic Ranking',
                ),
              ),
            ),
          ],
        ),

        // Job preview if available
        if (widget.workflowState.jobDescription != null) ...[
          const SizedBox(height: 32),
          GlowCard(
            glowColor: AppTheme.glowGreen,
            title: 'Job Preview',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workflowState.jobDescription!.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (widget
                    .workflowState
                    .jobDescription!
                    .experienceLevel
                    .isNotEmpty) ...[
                  Text(
                    'Experience: ${widget.workflowState.jobDescription!.experienceLevel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  widget.workflowState.jobDescription!.description.length > 200
                      ? '${widget.workflowState.jobDescription!.description.substring(0, 200)}...'
                      : widget.workflowState.jobDescription!.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget
                    .workflowState
                    .jobDescription!
                    .requiredSkills
                    .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Required Skills:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget
                        .workflowState
                        .jobDescription!
                        .requiredSkills
                        .map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.glowGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.glowGreen),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                GlowButton(
                  onPressed: widget.onNext,
                  glowColor: AppTheme.glowGreen,
                  child: const Text('Continue to Semantic Ranking'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
