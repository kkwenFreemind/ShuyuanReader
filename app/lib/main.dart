import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';

/// 應用程序入口
/// 
/// 初始化 Flutter 框架並啟動應用
void main() async {
  // 確保 Flutter 框架初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  
  // 運行應用
  runApp(const MyApp());
}

/// 應用程序根組件
/// 
/// 配置應用的主題、路由等全局設置
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 應用標題
      title: '書苑閱讀器',
      
      // 主題配置
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      // 關閉調試標籤
      debugShowCheckedModeBanner: false,
      
      // 初始路由
      initialRoute: AppPages.INITIAL,
      
      // 路由配置
      getPages: AppPages.routes,
    );
  }
}
