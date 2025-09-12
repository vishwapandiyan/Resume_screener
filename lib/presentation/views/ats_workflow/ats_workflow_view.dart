import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_container.dart';
import '../../../models/ats_workflow_models.dart';
import 'step1_resume_upload_view.dart';
import 'step2_job_description_view.dart';
import 'step3_semantic_ranking_view.dart';
import 'step4_skills_filter_view.dart';
import 'step5_final_results_view.dart';

class ATSWorkflowView extends StatefulWidget {
  const ATSWorkflowView({super.key});

  @override
  State<ATSWorkflowView> createState() => _ATSWorkflowViewState();
}

class _ATSWorkflowViewState extends State<ATSWorkflowView> {
  ATSWorkflowState _workflowState = const ATSWorkflowState(currentStep: 0);

  final List<String> _stepTitles = [
    'Upload Resumes',
    'Job Description',
    'Semantic Ranking',
    'Skills Filter',
    'Final Results',
  ];

  final List<IconData> _stepIcons = [
    Icons.upload_file,
    Icons.work_outline,
    Icons.analytics_outlined,
    Icons.filter_list,
    Icons.check_circle_outline,
  ];

  void _updateWorkflowState(ATSWorkflowState newState) {
    setState(() {
      _workflowState = newState;
    });
  }

  void _goToStep(int step) {
    setState(() {
      _workflowState = _workflowState.copyWith(currentStep: step);
    });
  }

  Widget _buildCurrentStepView() {
    switch (_workflowState.currentStep) {
      case 0:
        return Step1ResumeUploadView(
          workflowState: _workflowState,
          onStateUpdate: _updateWorkflowState,
          onNext: () => _goToStep(1),
        );
      case 1:
        return Step2JobDescriptionView(
          workflowState: _workflowState,
          onStateUpdate: _updateWorkflowState,
          onNext: () => _goToStep(2),
          onBack: () => _goToStep(0),
        );
      case 2:
        return Step3SemanticRankingView(
          workflowState: _workflowState,
          onStateUpdate: _updateWorkflowState,
          onNext: () => _goToStep(3),
          onBack: () => _goToStep(1),
        );
      case 3:
        return Step4SkillsFilterView(
          workflowState: _workflowState,
          onStateUpdate: _updateWorkflowState,
          onNext: () => _goToStep(4),
          onBack: () => _goToStep(2),
        );
      case 4:
        return Step5FinalResultsView(
          workflowState: _workflowState,
          onStateUpdate: _updateWorkflowState,
          onBack: () => _goToStep(3),
          onRestart: () => _goToStep(0),
        );
      default:
        return const Center(child: Text('Invalid step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            _buildHeader(),
            
            // Step indicator
            _buildStepIndicator(),
            
            // Current step view
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStepView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryGray.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlowContainer(
                glowColor: AppTheme.glowPurple,
                borderRadius: 12,
                padding: const EdgeInsets.all(12),
                isAnimated: false,
                child: const Icon(
                  Icons.psychology_outlined,
                  color: AppTheme.glowPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATS Workflow',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlack,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step ${_workflowState.currentStep + 1} of ${_stepTitles.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryGray,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlowProgressIndicator(
            progress: (_workflowState.currentStep + 1) / _stepTitles.length,
            glowColor: AppTheme.glowBlue,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _workflowState.currentStep;
          final isCompleted = index < _workflowState.currentStep;
          final canNavigate = index <= _workflowState.currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: canNavigate ? () => _goToStep(index) : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    GlowContainer(
                      glowColor: isActive
                          ? AppTheme.glowBlue
                          : isCompleted
                              ? AppTheme.glowGreen
                              : AppTheme.secondaryGray,
                      borderRadius: 25,
                      padding: const EdgeInsets.all(12),
                      isAnimated: isActive,
                      backgroundColor: isActive
                          ? AppTheme.glowBlue
                          : isCompleted
                              ? AppTheme.glowGreen
                              : AppTheme.secondaryGray.withOpacity(0.1),
                      child: Icon(
                        isCompleted ? Icons.check : _stepIcons[index],
                        color: isActive || isCompleted
                            ? Colors.white
                            : AppTheme.secondaryGray,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _stepTitles[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isActive
                                ? AppTheme.glowBlue
                                : isCompleted
                                    ? AppTheme.glowGreen
                                    : AppTheme.secondaryGray,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
