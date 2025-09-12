import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../models/ats_workflow_models.dart';
import '../../services/ats_service.dart';

class AtsResultsView extends StatefulWidget {
  final List<PlatformFile> files;
  final String jobTitle;
  final String jobDescription;
  final int atsThreshold;

  const AtsResultsView({
    super.key,
    required this.files,
    required this.jobTitle,
    required this.jobDescription,
    required this.atsThreshold,
  });

  @override
  State<AtsResultsView> createState() => _AtsResultsViewState();
}

class _AtsResultsViewState extends State<AtsResultsView> {
  late final AtsService _atsService;
  bool _loading = false;
  String? _error;
  ATSProcessingResult? _processing;
  SemanticRankingResult? _ranking;
  final Set<String> _skillFilters = <String>{};
  bool _gmailOnly = true;
  late final String _workspaceId;
  bool _chatMode = false;
  RankedResume? _activeResume;
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  List<String> _suggested = <String>[];
  bool _isDragOver = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    final ts = DateTime.now().millisecondsSinceEpoch;
    _workspaceId = 'ws_${ts.toString()}';
    _startPipeline();
  }

  Future<void> _startPipeline() async {
    _safeSetState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Quick reachability check to surface backend/network issues early
      try {
        await _atsService.health();
      } catch (e) {
        _safeSetState(() => _error = 'Backend unreachable: $e');
        return;
      }

      final processedJson = await _atsService.processResumes(
        files: widget.files,
        threshold: widget.atsThreshold,
      );
      final processing = ATSProcessingResult.fromJson(processedJson);

      final acceptedIds = processing.resumes
          .where((r) => r.status.toLowerCase() == 'accepted')
          .map((r) => r.id)
          .toSet();

      final rankingJson = await _atsService.semanticRanking(
        jobDescription: widget.jobDescription,
        resumes: processing.resumes,
      );
      final ranking = SemanticRankingResult.fromJson(rankingJson);

      final sorted = ranking.rankedResumes
          .where((r) => acceptedIds.contains(r.id))
          .toList()
        ..sort((a, b) => b.semanticScore.compareTo(a.semanticScore));

      _safeSetState(() {
        _processing = processing;
        _ranking = ranking;
      });

      // Store job description for RAG context
      try {
        await _atsService.ragStoreJd(
          workspaceId: _workspaceId,
          jobDescription: widget.jobDescription,
        );
      } catch (e) {
        print('Failed to store JD: $e');
      }

      await _ingestAcceptedToRag();
    } catch (e) {
      _safeSetState(() => _error = e.toString());
    } finally {
      _safeSetState(() => _loading = false);
    }
  }

  Future<void> _ingestAcceptedToRag() async {
    if (_processing == null || _ranking == null) return;
    final accepted = _baseAcceptedSorted();

    final idToProcessed = {for (final p in _processing!.resumes) p.id: p};

    final resumesPayload = <Map<String, dynamic>>[];
    for (final r in accepted) {
      final p = idToProcessed[r.id];
      if (p == null || (p.fullText == null || p.fullText!.isEmpty)) continue;
      resumesPayload.add({
        'id': r.id,
        'text': p.fullText,
        'candidate': r.candidate,
        'email': r.email,
        'skills': r.skills,
        'experience': r.experience,
        'rank': r.rank,
      });
    }
    if (resumesPayload.isEmpty) return;
    try {
      await _atsService.ragIngest(workspaceId: _workspaceId, resumes: resumesPayload);
    } catch (_) {}
  }

  List<RankedResume> _applyLocalFilters(List<RankedResume> base) {
    Iterable<RankedResume> items = base;

    if (_gmailOnly) {
      items = items.where((r) => r.email.contains('@'));
    }

    if (_skillFilters.isNotEmpty) {
      items = items.where((r) {
        final resumeSkills = r.skills.map((s) => s.toLowerCase()).toList();
        for (final req in _skillFilters) {
          final reqLower = req.toLowerCase();
          if (!resumeSkills.any((s) => s.contains(reqLower))) return false;
        }
        return true;
      });
    }

    return items.toList();
  }

  void _toggleSkill(String skill, bool selected) {
    _safeSetState(() {
      if (selected) {
        _skillFilters.add(skill);
      } else {
        _skillFilters.remove(skill);
      }
    });
  }

  List<RankedResume> _baseAcceptedSorted() {
    if (_ranking == null || _processing == null) return const <RankedResume>[];
    final acceptedIds = _processing!.resumes
        .where((r) => r.status.toLowerCase() == 'accepted')
        .map((r) => r.id)
        .toSet();
    final sorted = _ranking!.rankedResumes
        .where((r) => acceptedIds.contains(r.id))
        .toList()
      ..sort((a, b) => b.semanticScore.compareTo(a.semanticScore));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
        ),
        title: Text(
          'Analysis Results',
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
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildChatPanel(BuildContext context) {
    return DragTarget<RankedResume>(
      onWillAccept: (_) {
        _safeSetState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => _safeSetState(() => _isDragOver = false),
      onAccept: (data) async {
        _safeSetState(() {
          _isDragOver = false;
          _activeResume = data;
          _chatMode = true;
        });
        try {
          final res = await _atsService.ragSuggest(
            workspaceId: _workspaceId,
            resumeId: data.id,
          );
          _safeSetState(() => _suggested = List<String>.from(res['questions'] ?? const <String>[]));
        } catch (_) {}
      },
      builder: (context, candidate, rejects) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _activeResume != null ? 'Chat: ${_activeResume!.candidate}' : 'Chat with AI',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _chatMode = false),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  if (_suggested.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggested.take(4).map((q) => ActionChip(label: Text(q), onPressed: () => _sendQuery(q))).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        return Align(
                          alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: m.isUser ? AppTheme.accentBlue.withOpacity(0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(m.text),
                          ),
                        );
                      },
                    ),
                  ),
                  _ChatInput(onSend: (text) => _sendQuery(text)),
                ],
              ),
              if (_isDragOver)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentBlue, width: 2),
                    ),
                    child: const Center(
                      child: Text('Drop candidate here', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendQuery(String text) async {
    if (text.trim().isEmpty) return;
    _safeSetState(() => _messages.add(_ChatMessage(text: text, isUser: true)));
    try {
      final res = await _atsService.ragQuery(
        workspaceId: _workspaceId,
        message: text,
        resumeId: _activeResume?.id,
        chatId: _activeResume?.id,
      );
      final answer = (res['answer'] ?? '').toString();
      _safeSetState(() => _messages.add(_ChatMessage(text: answer, isUser: false)));
    } catch (e) {
      _safeSetState(() => _messages.add(_ChatMessage(text: 'Error: $e', isUser: false)));
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppTheme.accentRed),
        ),
      );
    }
    if (_processing == null || _ranking == null) {
      return const SizedBox.shrink();
    }

    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildCandidatesList(context)),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 24,
                  largeDesktop: 28,
                  extraLargeDesktop: 32,
                ),
              ),
              Expanded(flex: 1, child: _chatMode ? _buildChatPanel(context) : _buildFilters(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCandidatesList(BuildContext context) {
    final items = _applyLocalFilters(_baseAcceptedSorted());
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Filtered Candidates (${items.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = items[index];
                  return Draggable<RankedResume>(
                    data: r,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(r.candidate, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.4,
                      child: _CandidateTile(resume: r),
                    ),
                    child: _CandidateTile(resume: r),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final jdSkills = _ranking?.jdSkills ?? const <String>[];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _chatMode = true),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat with AI'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _gmailOnly,
                  onChanged: (v) => setState(() => _gmailOnly = v),
                  activeColor: AppTheme.accentBlue,
                ),
                const SizedBox(width: 8),
                const Text('Only resumes with email'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'JD Skills',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: jdSkills.map((skill) {
                final selected = _skillFilters.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: selected,
                  onSelected: (v) => _toggleSkill(skill, v),
                  selectedColor: AppTheme.accentBlue.withOpacity(0.15),
                  checkmarkColor: AppTheme.accentBlue,
                  labelStyle: TextStyle(color: selected ? AppTheme.accentBlue : AppTheme.primaryBlack),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final RankedResume resume;
  const _CandidateTile({required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryGray.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentBlue,
            child: Text(
              resume.rank.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resume.candidate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    _RatingStars(
                      atsScore: resume.atsScore.toDouble(),
                      semanticScore: resume.semanticScore,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  resume.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.secondaryGray),
                ),
                const SizedBox(height: 8),
                Text(
                  resume.skills.join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double atsScore;
  final double semanticScore;

  const _RatingStars({required this.atsScore, required this.semanticScore});

  double _combinedScore() {
    final semanticPct = (semanticScore.clamp(0.0, 1.0)) * 100.0;
    final atsPct = atsScore.clamp(0.0, 100.0);
    return semanticPct * 0.7 + atsPct * 0.3;
  }

  int _starsFilled() {
    final combined = _combinedScore();
    final outOfFive = combined / 20.0;
    return outOfFive.floor().clamp(0, 5);
  }

  bool _hasHalfStar() {
    final combined = _combinedScore();
    final outOfFive = combined / 20.0;
    final fractional = outOfFive - outOfFive.floor();
    return fractional >= 0.25 && fractional < 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final filled = _starsFilled();
    final half = _hasHalfStar();
    final total = 5;

    List<Widget> icons = [];
    for (int i = 0; i < total; i++) {
      if (i < filled) {
        icons.add(const Icon(Icons.star, color: AppTheme.accentGreen, size: 18));
      } else if (i == filled && half) {
        icons.add(const Icon(Icons.star_half, color: AppTheme.accentGreen, size: 18));
      } else {
        icons.add(Icon(Icons.star_border, color: AppTheme.secondaryGray.withOpacity(0.8), size: 18));
      }
    }

    return Row(children: icons);
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _ChatInput extends StatefulWidget {
  final Function(String) onSend;
  const _ChatInput({required this.onSend});
  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Ask about the candidate...'),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final text = _controller.text;
              _controller.clear();
              widget.onSend(text);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}