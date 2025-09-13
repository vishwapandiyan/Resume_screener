import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';

class ResumeLibraryView extends StatefulWidget {
  const ResumeLibraryView({super.key});

  @override
  State<ResumeLibraryView> createState() => _ResumeLibraryViewState();
}

class _ResumeLibraryViewState extends State<ResumeLibraryView>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _resumes = [
    {
      'id': '1',
      'name': 'John Doe - Software Engineer',
      'email': 'john.doe@email.com',
      'phone': '+1 (555) 123-4567',
      'uploadDate': DateTime.now().subtract(const Duration(days: 2)),
      'lastModified': DateTime.now().subtract(const Duration(hours: 5)),
      'atsScore': 87,
      'matchRate': 92,
      'fileSize': '2.3 MB',
      'fileType': 'PDF',
      'status': 'Processed',
      'tags': ['Software Engineer', 'Python', 'React', 'AWS'],
      'experience': '5 years',
      'location': 'San Francisco, CA',
      'skills': ['Python', 'JavaScript', 'React', 'Node.js', 'AWS', 'Docker'],
    },
    {
      'id': '2',
      'name': 'Sarah Johnson - Product Manager',
      'email': 'sarah.j@email.com',
      'phone': '+1 (555) 987-6543',
      'uploadDate': DateTime.now().subtract(const Duration(days: 5)),
      'lastModified': DateTime.now().subtract(const Duration(days: 1)),
      'atsScore': 94,
      'matchRate': 88,
      'fileSize': '1.8 MB',
      'fileType': 'DOCX',
      'status': 'Processed',
      'tags': ['Product Manager', 'Agile', 'Analytics', 'Leadership'],
      'experience': '7 years',
      'location': 'New York, NY',
      'skills': [
        'Product Management',
        'Agile',
        'Data Analysis',
        'Leadership',
        'Figma',
      ],
    },
    {
      'id': '3',
      'name': 'Mike Chen - Data Scientist',
      'email': 'mike.chen@email.com',
      'phone': '+1 (555) 456-7890',
      'uploadDate': DateTime.now().subtract(const Duration(days: 7)),
      'lastModified': DateTime.now().subtract(const Duration(days: 3)),
      'atsScore': 91,
      'matchRate': 95,
      'fileSize': '3.1 MB',
      'fileType': 'PDF',
      'status': 'Processing',
      'tags': ['Data Science', 'Machine Learning', 'Python', 'Statistics'],
      'experience': '4 years',
      'location': 'Seattle, WA',
      'skills': [
        'Python',
        'R',
        'Machine Learning',
        'TensorFlow',
        'SQL',
        'Statistics',
      ],
    },
    {
      'id': '4',
      'name': 'Emily Rodriguez - UX Designer',
      'email': 'emily.r@email.com',
      'phone': '+1 (555) 321-0987',
      'uploadDate': DateTime.now().subtract(const Duration(days: 10)),
      'lastModified': DateTime.now().subtract(const Duration(days: 6)),
      'atsScore': 89,
      'matchRate': 90,
      'fileSize': '2.7 MB',
      'fileType': 'PDF',
      'status': 'Processed',
      'tags': ['UX Design', 'UI Design', 'Figma', 'User Research'],
      'experience': '6 years',
      'location': 'Austin, TX',
      'skills': [
        'Figma',
        'Sketch',
        'Adobe XD',
        'User Research',
        'Prototyping',
        'Design Systems',
      ],
    },
    {
      'id': '5',
      'name': 'David Kim - DevOps Engineer',
      'email': 'david.kim@email.com',
      'phone': '+1 (555) 654-3210',
      'uploadDate': DateTime.now().subtract(const Duration(days: 12)),
      'lastModified': DateTime.now().subtract(const Duration(days: 8)),
      'atsScore': 93,
      'matchRate': 87,
      'fileSize': '2.1 MB',
      'fileType': 'DOCX',
      'status': 'Processed',
      'tags': ['DevOps', 'AWS', 'Docker', 'Kubernetes'],
      'experience': '8 years',
      'location': 'Denver, CO',
      'skills': [
        'AWS',
        'Docker',
        'Kubernetes',
        'Terraform',
        'Jenkins',
        'Linux',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
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
        'Resume Library',
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
      actions: [
        IconButton(
          onPressed: _showUploadDialog,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchAndFilters(context),
              const SizedBox(height: 20),
              _buildStatsCards(context),
              const SizedBox(height: 20),
              _buildResumeList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            children: [
              _buildSearchAndFilters(context),
              const SizedBox(height: 24),
              _buildStatsCards(context),
              const SizedBox(height: 24),
              _buildResumeList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left sidebar with filters
              SizedBox(width: 300, child: _buildFilterSidebar(context)),
              const SizedBox(width: 24),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 24),
                    _buildStatsCards(context),
                    const SizedBox(height: 24),
                    _buildResumeList(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        const SizedBox(height: 16),
        _buildFilterChips(context),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search resumes by name, skills, or tags...',
          hintStyle: TextStyle(
            color: AppTheme.secondaryGray,
            fontFamily: 'Inter',
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.accentBlue),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear, color: AppTheme.secondaryGray),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'Processed', 'Processing', 'High Score', 'Recent'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primaryBlack,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: AppTheme.backgroundWhite,
              selectedColor: AppTheme.accentBlue,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.accentBlue
                    : AppTheme.secondaryGray.withOpacity(0.3),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterSidebar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              color: AppTheme.primaryBlack,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterSection('Status', ['All', 'Processed', 'Processing']),
          const SizedBox(height: 20),
          _buildFilterSection('Sort By', ['Recent', 'Name', 'Score', 'Date']),
          const SizedBox(height: 20),
          _buildFilterSection('File Type', ['All', 'PDF', 'DOCX', 'DOC']),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          final isSelected =
              _selectedFilter == option || _selectedSort == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              title: Text(
                option,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.accentBlue
                      : AppTheme.primaryBlack,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              leading: Radio<String>(
                value: option,
                groupValue: title == 'Status' ? _selectedFilter : _selectedSort,
                onChanged: (value) {
                  setState(() {
                    if (title == 'Status') {
                      _selectedFilter = value!;
                    } else {
                      _selectedSort = value!;
                    }
                  });
                },
                activeColor: AppTheme.accentBlue,
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                setState(() {
                  if (title == 'Status') {
                    _selectedFilter = option;
                  } else {
                    _selectedSort = option;
                  }
                });
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final filteredResumes = _getFilteredResumes();
    final totalResumes = filteredResumes.length;
    final avgScore = filteredResumes.isNotEmpty
        ? filteredResumes
                  .map((r) => r['atsScore'] as int)
                  .reduce((a, b) => a + b) /
              totalResumes
        : 0.0;
    final processedCount = filteredResumes
        .where((r) => r['status'] == 'Processed')
        .length;

    return ResponsiveRow(
      children: [
        ResponsiveColumn(
          children: [
            _buildStatCard(
              'Total Resumes',
              totalResumes.toString(),
              Icons.folder_open,
              const Color(0xFF4285F4),
            ),
          ],
        ),
        ResponsiveColumn(
          children: [
            _buildStatCard(
              'Avg ATS Score',
              '${avgScore.toStringAsFixed(1)}%',
              Icons.analytics,
              const Color(0xFF34A853),
            ),
          ],
        ),
        ResponsiveColumn(
          children: [
            _buildStatCard(
              'Processed',
              '$processedCount/$totalResumes',
              Icons.check_circle,
              const Color(0xFFFBBC04),
            ),
          ],
        ),
        ResponsiveColumn(
          children: [
            _buildStatCard(
              'Storage Used',
              '12.4 MB',
              Icons.storage,
              const Color(0xFFEA4335),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppTheme.accentGreen, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryBlack,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.secondaryGray,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeList(BuildContext context) {
    final filteredResumes = _getFilteredResumes();

    if (filteredResumes.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resumes (${filteredResumes.length})',
              style: TextStyle(
                color: AppTheme.primaryBlack,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildViewToggle(context),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredResumes.length,
          itemBuilder: (context, index) {
            return _buildResumeCard(context, filteredResumes[index]);
          },
        ),
      ],
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondaryGray.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewToggleButton(Icons.view_list, true),
          _buildViewToggleButton(Icons.grid_view, false),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : AppTheme.secondaryGray,
        size: 18,
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, Map<String, dynamic> resume) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume['name'],
                      style: TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resume['email'],
                      style: TextStyle(
                        color: AppTheme.secondaryGray,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(resume['status']),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                'ATS Score',
                '${resume['atsScore']}%',
                AppTheme.accentBlue,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                'Match Rate',
                '${resume['matchRate']}%',
                AppTheme.accentGreen,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                'Experience',
                resume['experience'],
                AppTheme.accentOrange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (resume['tags'] as List<String>).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: AppTheme.accentBlue,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded ${_formatDate(resume['uploadDate'])}',
                style: TextStyle(
                  color: AppTheme.secondaryGray,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _viewResume(resume),
                    icon: const Icon(
                      Icons.visibility,
                      color: AppTheme.accentBlue,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _downloadResume(resume),
                    icon: const Icon(
                      Icons.download,
                      color: AppTheme.accentGreen,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteResume(resume),
                    icon: const Icon(
                      Icons.delete,
                      color: AppTheme.accentRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Processed':
        color = AppTheme.accentGreen;
        break;
      case 'Processing':
        color = AppTheme.accentOrange;
        break;
      default:
        color = AppTheme.secondaryGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: AppTheme.accentBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No resumes found',
            style: TextStyle(
              color: AppTheme.primaryBlack,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first resume to get started',
            style: TextStyle(
              color: AppTheme.secondaryGray,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.add),
            label: const Text('Upload Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredResumes() {
    var filtered = _resumes.where((resume) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = resume['name'].toString().toLowerCase();
        final skills = (resume['skills'] as List<String>)
            .join(' ')
            .toLowerCase();
        final tags = (resume['tags'] as List<String>).join(' ').toLowerCase();

        if (!name.contains(query) &&
            !skills.contains(query) &&
            !tags.contains(query)) {
          return false;
        }
      }

      // Status filter
      if (_selectedFilter != 'All' && resume['status'] != _selectedFilter) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'Name':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Score':
        filtered.sort(
          (a, b) => (b['atsScore'] as int).compareTo(a['atsScore'] as int),
        );
        break;
      case 'Date':
        filtered.sort(
          (a, b) => (b['uploadDate'] as DateTime).compareTo(
            a['uploadDate'] as DateTime,
          ),
        );
        break;
      default: // Recent
        filtered.sort(
          (a, b) => (b['lastModified'] as DateTime).compareTo(
            a['lastModified'] as DateTime,
          ),
        );
    }

    return filtered;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Resume'),
        content: const Text('Upload functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _viewResume(Map<String, dynamic> resume) {
    // Implement view resume functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${resume['name']}'),
        backgroundColor: AppTheme.accentBlue,
      ),
    );
  }

  void _downloadResume(Map<String, dynamic> resume) {
    // Implement download resume functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${resume['name']}'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  void _deleteResume(Map<String, dynamic> resume) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Are you sure you want to delete ${resume['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _resumes.removeWhere((r) => r['id'] == resume['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${resume['name']} deleted'),
                  backgroundColor: AppTheme.accentRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
