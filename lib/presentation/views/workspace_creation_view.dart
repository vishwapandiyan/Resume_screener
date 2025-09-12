import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glow_container/glow_container.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import 'ats_results_view.dart';

class WorkspaceCreationView extends StatefulWidget {
  const WorkspaceCreationView({super.key});

  @override
  State<WorkspaceCreationView> createState() => _WorkspaceCreationViewState();
}

class _WorkspaceCreationViewState extends State<WorkspaceCreationView> {
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  double _atsScore = 50.0;
  List<PlatformFile> _selectedFiles = [];
  bool _isGeneratingTitle = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: _buildAppBar(context),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          if (screenSize == ScreenSize.mobile) {
            return _buildMobileLayout(context);
          } else if (screenSize == ScreenSize.tablet) {
            return _buildTabletLayout(context);
          }
          return _buildDesktopLayout(context);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundWhite,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
      ),
      title: Text(
        'Create New Workspace',
        style: TextStyle(
          color: AppTheme.primaryBlack,
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
            largeDesktop: 24,
            extraLargeDesktop: 26,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildJobDetailsCard(context),
          const SizedBox(height: 20),
          _buildResumeUploadCard(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Job Details
              Expanded(flex: 1, child: _buildJobDetailsCard(context)),
              const SizedBox(width: 20),
              // Right side - Resume Upload
              Expanded(flex: 1, child: _buildResumeUploadCard(context)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Job Details
          Expanded(flex: 1, child: _buildJobDetailsCard(context)),
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
              largeDesktop: 28,
              extraLargeDesktop: 32,
            ),
          ),
          // Right side - Resume Upload
          Expanded(flex: 1, child: _buildResumeUploadCard(context)),
        ],
      ),
    );
  }

  Widget _buildJobDetailsCard(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
            largeDesktop: 18,
            extraLargeDesktop: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Details',
            style: TextStyle(
              color: AppTheme.primaryBlack,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
                largeDesktop: 24,
                extraLargeDesktop: 26,
              ),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Job Title Field
          _buildJobTitleField(context),
          const SizedBox(height: 20),

          // Job Description Field
          _buildJobDescriptionField(context),
          const SizedBox(height: 20),

          // ATS Score Meter
          _buildATSMeter(context),
        ],
      ),
    );
  }

  Widget _buildJobTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Title',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 15,
              desktop: 16,
              largeDesktop: 17,
              extraLargeDesktop: 18,
            ),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _jobTitleController,
          decoration: InputDecoration(
            hintText: 'Enter job title (e.g., Senior Software Engineer)',
            hintStyle: TextStyle(
              color: AppTheme.secondaryGray,
              fontFamily: 'Inter',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.secondaryGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.accentBlue,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: AppTheme.primaryBlack,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildJobDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Job Description',
              style: TextStyle(
                color: AppTheme.primaryBlack,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                  largeDesktop: 17,
                  extraLargeDesktop: 18,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_jobDescriptionController.text.isNotEmpty &&
                _jobTitleController.text.isEmpty)
              TextButton.icon(
                onPressed: _isGeneratingTitle ? null : _generateJobTitle,
                icon: _isGeneratingTitle
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 16),
                label: Text(
                  _isGeneratingTitle ? 'Generating...' : 'Generate Title',
                  style: const TextStyle(
                    color: AppTheme.accentBlue,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _jobDescriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText:
                'Enter job description. If no title is provided, we\'ll generate one using AI.',
            hintStyle: TextStyle(
              color: AppTheme.secondaryGray,
              fontFamily: 'Inter',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.secondaryGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.accentBlue,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: AppTheme.primaryBlack,
            fontFamily: 'Inter',
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildATSMeter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ATS Score',
              style: TextStyle(
                color: AppTheme.primaryBlack,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                  largeDesktop: 17,
                  extraLargeDesktop: 18,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppTheme.accentBlue,
                  AppTheme.accentPurple,
                  AppTheme.accentRed,
                  AppTheme.accentOrange,
                  AppTheme.accentYellow,
                  AppTheme.accentGreen,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                '${_atsScore.round()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                    largeDesktop: 17,
                    extraLargeDesktop: 18,
                  ),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: AppTheme.secondaryGray.withOpacity(0.3),
          ),
          child: Stack(
            children: [
              // Gradient portion (active track)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width:
                    (_atsScore / 100) *
                    MediaQuery.of(context).size.width *
                    0.8, // Adjust based on container width
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentBlue,
                        AppTheme.accentPurple,
                        AppTheme.accentRed,
                        AppTheme.accentOrange,
                        AppTheme.accentYellow,
                        AppTheme.accentGreen,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: AppTheme.accentBlue,
                  overlayColor: AppTheme.accentBlue.withOpacity(0.2),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                ),
                child: Slider(
                  value: _atsScore,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      _atsScore = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strict',
              style: TextStyle(
                color: AppTheme.secondaryGray,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Flexible',
              style: TextStyle(
                color: AppTheme.secondaryGray,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumeUploadCard(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
            largeDesktop: 18,
            extraLargeDesktop: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Centered Upload Container
          Expanded(child: Center(child: _buildGlowUploadButton(context))),

          // Selected Files List
          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSelectedFilesList(context),
          ],

          // Action Buttons
          const SizedBox(height: 20),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Files (${_selectedFiles.length})',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 15,
              desktop: 16,
              largeDesktop: 17,
              extraLargeDesktop: 18,
            ),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.secondaryGray.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(file.extension),
                      color: AppTheme.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              color: AppTheme.primaryBlack,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatFileSize(file.size),
                            style: TextStyle(
                              color: AppTheme.secondaryGray,
                              fontFamily: 'Inter',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedFiles.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.accentRed,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlowUploadButton(BuildContext context) {
    return GestureDetector(
      onTap: _pickFiles,
      child: GlowContainer(
        gradientColors: [
          const Color(0xFF4285F4),
          const Color(0xFFEA4335),
          const Color(0xFFFBBC04),
          const Color(0xFF34A853),
        ],
        rotationDuration: Duration(seconds: 4),
        glowRadius: ResponsiveUtils.getResponsiveSpacing(
          context,
          mobile: 4,
          tablet: 5,
          desktop: 6,
          largeDesktop: 7,
          extraLargeDesktop: 8,
        ),
        containerOptions: ContainerOptions(
          width: 400,
          height: 300,
          borderRadius: 20,
          backgroundColor: Colors.transparent,
          borderSide: BorderSide(width: 3, color: AppTheme.accentBlue),
        ),
        child: Container(
          width: 400,
          height: 300,
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'Upload your Document',
                style: TextStyle(
                  color: AppTheme.primaryBlack,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                    largeDesktop: 26,
                    extraLargeDesktop: 28,
                  ),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Drag and Drop Zone
              Container(
                width: 320,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDADCE0),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 32,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Drag and drop your document',
                      style: TextStyle(
                        color: const Color(0xFF5F6368),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                          largeDesktop: 17,
                          extraLargeDesktop: 18,
                        ),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ATS Analysis Button
        GestureDetector(
          onTap: _canProcess() ? _navigateToAtsAnalysis : null,
          child: _canProcess()
              ? GlowContainer(
                  gradientColors: [
                    const Color(0xFF8B5CF6), // Purple
                    const Color(0xFF3B82F6), // Blue
                    const Color(0xFF10B981), // Green
                    const Color(0xFFF59E0B), // Orange
                  ],
                  rotationDuration: Duration(seconds: 3),
                  glowRadius: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 3,
                    tablet: 4,
                    desktop: 5,
                    largeDesktop: 6,
                    extraLargeDesktop: 7,
                  ),
                  containerOptions: ContainerOptions(
                    width: 160,
                    height: 50,
                    borderRadius: 25,
                    backgroundColor: Colors.transparent,
                    borderSide: BorderSide(
                      width: 2,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                  child: Container(
                    width: 160,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics,
                          color: AppTheme.backgroundWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ATS Analysis',
                          style: TextStyle(
                            color: AppTheme.backgroundWhite,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: 160,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGray,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics,
                        color: AppTheme.backgroundWhite,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ATS Analysis',
                        style: TextStyle(
                          color: AppTheme.backgroundWhite,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        // Next Button
        GestureDetector(
          onTap: _canProcess() ? _processWorkspace : null,
          child: _canProcess()
              ? GlowContainer(
                  gradientColors: [
                    const Color(0xFF4285F4), // Blue
                    const Color(0xFFEA4335), // Red
                    const Color(0xFFFBBC04), // Yellow
                    const Color(0xFF34A853), // Green
                  ],
                  rotationDuration: Duration(seconds: 3),
                  glowRadius: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 3,
                    tablet: 4,
                    desktop: 5,
                    largeDesktop: 6,
                    extraLargeDesktop: 7,
                  ),
                  containerOptions: ContainerOptions(
                    width: 120,
                    height: 50,
                    borderRadius: 25,
                    backgroundColor: Colors.transparent,
                    borderSide: BorderSide(
                      width: 2,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                  child: Container(
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: AppTheme.backgroundWhite,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: AppTheme.backgroundWhite,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGray,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          color: AppTheme.backgroundWhite,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.backgroundWhite,
                        size: 18,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  bool _canProcess() {
    return _selectedFiles.isNotEmpty &&
        (_jobTitleController.text.isNotEmpty ||
            _jobDescriptionController.text.isNotEmpty) &&
        !_isProcessing;
  }

  void _navigateToAtsAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AtsResultsView(
          files: _selectedFiles,
          jobTitle: _jobTitleController.text,
          jobDescription: _jobDescriptionController.text,
          atsThreshold: _atsScore.round(),
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking files: $e');
    }
  }

  Future<void> _generateJobTitle() async {
    if (_jobDescriptionController.text.isEmpty) return;

    setState(() {
      _isGeneratingTitle = true;
    });

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate title using local logic
      final generatedTitle = _generateMockTitle(_jobDescriptionController.text);
      _jobTitleController.text = generatedTitle;

      _showSuccessSnackBar('Job title generated successfully!');
    } catch (e) {
      _showErrorSnackBar('Error generating job title');
    } finally {
      setState(() {
        _isGeneratingTitle = false;
      });
    }
  }

  String _generateMockTitle(String description) {
    // Simple mock title generation based on keywords
    final keywords = description.toLowerCase();
    if (keywords.contains('software') && keywords.contains('engineer')) {
      return 'Software Engineer';
    } else if (keywords.contains('data') && keywords.contains('scientist')) {
      return 'Data Scientist';
    } else if (keywords.contains('product') && keywords.contains('manager')) {
      return 'Product Manager';
    } else if (keywords.contains('designer')) {
      return 'UI/UX Designer';
    } else if (keywords.contains('marketing')) {
      return 'Marketing Specialist';
    } else {
      return 'Professional Role';
    }
  }

  Future<void> _processWorkspace() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));

      // Prepare data for local processing
      final filesData = _selectedFiles
          .map(
            (file) => {
              'name': file.name,
              'size': file.size,
              'extension': file.extension,
            },
          )
          .toList();

      // Process workspace locally (UI-only mode)
      // In a real implementation, this would save to local storage
      print('Processing workspace:');
      print('Job Title: ${_jobTitleController.text}');
      print('Job Description: ${_jobDescriptionController.text}');
      print('ATS Score: ${_atsScore.round()}');
      print('Files: ${filesData.length} files');

      _showSuccessSnackBar('Workspace processed successfully!');

      // Navigate back to dashboard
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error processing workspace: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
