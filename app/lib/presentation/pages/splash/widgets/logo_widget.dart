import 'package:flutter/material.dart';

/// Logo 组件 - 带淡入动画
/// 
/// 用于启动画面，显示应用的 Logo 标识
/// 包含 500ms 的淡入动画效果
class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key});

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // 创建动画控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 创建淡入动画 (从 0.0 到 1.0)
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    
    // 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    // 释放动画控制器，防止内存泄漏
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            '📚',
            style: TextStyle(fontSize: 64),
          ),
        ),
      ),
    );
  }
}
