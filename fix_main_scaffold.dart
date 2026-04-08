import 'dart:io';

void main() {
  final file = File('lib/screens/main_scaffold.dart');
  file.writeAsStringSync('''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _hoveredIndex = -1;
  bool _isLoading = false;

  void _onTabChanged(int index) {
    if (index == widget.navigationShell.currentIndex) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF9C8A8), // Peach background
      body: Stack(
        children: [
          widget.navigationShell,
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF9C8A8), // Peach overlay
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Lottie.asset(
                        'lib/lotties/Baby loading.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildDock(),
    );
  }

  Widget _buildDock() {
    final items = [
      Icons.home,
      Icons.search,
      Icons.map,
      Icons.chat_bubble,
      Icons.person,
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              return _buildDockItem(index, items[index]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(int index, IconData icon) {
    bool isSelected = index == widget.navigationShell.currentIndex;
    bool isHovered = index == _hoveredIndex;

    double scale = isHovered ? 1.1 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutQuad,
          transform: Matrix4.identity()..scale(scale),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: isSelected
                ? BoxDecoration(
                    color: const Color(0xFFF18698), // Pink Pop
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  )
                : const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
''');
}
