import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _edgeController;
  late Animation<double> _edgeAnimation;

  @override
  void initState() {
    super.initState();
    _edgeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _edgeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _edgeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _edgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF424242),
                  Color(0xFF212121),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 100,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Camera Preview',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _edgeAnimation,
              builder: (context, child) {
                return Container(
                  width: 280,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                              left: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                              right: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                              left: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                              right: BorderSide(
                                color: Colors.green.withAlpha((_edgeAnimation.value * 255).round()),
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Position receipt within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}