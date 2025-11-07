import 'package:flutter/material.dart';

/// 啟動畫面加載動畫組件
/// 
/// 顯示一個圓形進度指示器和 "Loading..." 文字
/// 用於啟動畫面的加載狀態提示
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        // 圓形進度指示器
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.blue,
          ),
        ),
        
        // 間距
        SizedBox(height: 16),
        
        // Loading 文字
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}
