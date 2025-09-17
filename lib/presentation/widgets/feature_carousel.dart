import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';

class FeatureCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final bool autoplay;
  final Duration autoplayInterval;
  final double height;
  final double itemSpacing;
  final bool showIndicators;
  final bool showNavigationArrows;

  const FeatureCarousel({
    super.key,
    required this.items,
    this.autoplay = true,
    this.autoplayInterval = const Duration(seconds: 3),
    this.height = 300,
    this.itemSpacing = 16,
    this.showIndicators = true,
    this.showNavigationArrows = true,
  });

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  int _currentIndex = 0;
  Timer? _autoplayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start the animation immediately
    _animationController.forward();

    if (widget.autoplay) {
      _startAutoplay();
    }
  }

  void _startAutoplay() {
    _autoplayTimer = Timer.periodic(widget.autoplayInterval, (timer) {
      if (mounted) {
        _nextPage();
      }
    });
  }

  void _stopAutoplay() {
    _autoplayTimer?.cancel();
  }

  void _nextPage() {
    if (_currentIndex < widget.items.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = widget.items.length - 1;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTap(CarouselItem item) {
    _showFeaturePopup(item);
  }

  void _showFeaturePopup(CarouselItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getResponsiveContainerWidth(
                context,
                mobile: 300,
                tablet: 400,
                desktop: 500,
                largeDesktop: 600,
                extraLargeDesktop: 700,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(item.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                            largeDesktop: 26,
                            extraLargeDesktop: 28,
                          ),
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                            largeDesktop: 17,
                            extraLargeDesktop: 18,
                          ),
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A9096),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                            largeDesktop: 17,
                            extraLargeDesktop: 18,
                          ),
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _autoplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Container(
          height: widget.height,
          child: Column(
            children: [
              // Carousel
              Expanded(
                child: Stack(
                  children: [
                    // PageView
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return _buildCarouselItem(item, index);
                      },
                    ),

                    // Navigation arrows
                    if (widget.showNavigationArrows) ...[
                      // Previous arrow
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _buildNavigationArrow(
                            icon: Icons.chevron_left,
                            onTap: _previousPage,
                          ),
                        ),
                      ),

                      // Next arrow
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _buildNavigationArrow(
                            icon: Icons.chevron_right,
                            onTap: _nextPage,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Indicators
              if (widget.showIndicators) ...[
                const SizedBox(height: 16),
                _buildIndicators(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(CarouselItem item, int index) {
    return GestureDetector(
      onTap: () => _onItemTap(item),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: widget.itemSpacing / 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Image
                Positioned.fill(
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: ${item.imagePath}');
                      print('Error: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              item.imagePath,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                            extraLargeDesktop: 24,
                          ),
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to learn more',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                            largeDesktop: 15,
                            extraLargeDesktop: 16,
                          ),
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _stopAutoplay();
        onTap();
        _startAutoplay();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.primaryBlack, size: 24),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppTheme.accentBlue
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class CarouselItem {
  final String imagePath;
  final String title;
  final String description;

  const CarouselItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
