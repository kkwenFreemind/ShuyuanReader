import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import 'widgets/logo_widget.dart';
import 'widgets/loading_widget.dart';

/// 啟動畫面頁面
/// 
/// 顯示應用啟動時的歡迎畫面，包含：
/// - Logo 動畫
/// - 應用標題和副標題
/// - 加載動畫
/// - 版本號信息
/// 
/// 在初始化完成後會自動跳轉到主頁面
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    final controller = Get.put(SplashController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 上方彈性空間（佔 2 份）
              const Spacer(flex: 2),
              
              // Logo 組件（帶淡入動畫）
              const LogoWidget(),
              
              // Logo 與標題間距
              const SizedBox(height: 24),
              
              // 應用標題（中文）
              const Text(
                '書苑閱讀器',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              // 標題間距
              const SizedBox(height: 8),
              
              // 應用副標題（英文）
              const Text(
                'ShuyuanReader',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF424242),
                ),
              ),
              
              // 副標題與加載動畫間距
              const SizedBox(height: 48),
              
              // 加載動畫組件
              const LoadingWidget(),
              
              // 下方彈性空間（佔 3 份）
              const Spacer(flex: 3),
              
              // 版本號（響應式顯示）
              Obx(() => Text(
                controller.version.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              )),
              
              // 底部間距
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
