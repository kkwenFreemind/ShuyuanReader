#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
快速執行腳本 - 處理所有 EPUB 檔案
"""

import sys
import os
from pathlib import Path

# 添加 python 目錄到路徑
sys.path.append(str(Path(__file__).parent))

from epub_processor import EPUBProcessor

def main():
    """快速執行主函數"""
    print("=== 書苑閱讀器 EPUB 批次處理工具 ===\n")
    
    # 設定路徑
    project_root = Path(__file__).parent.parent
    epub_dir = project_root / "epub3"
    covers_dir = project_root / "covers"
    catalog_dir = project_root / "catalog"
    
    print(f"EPUB 目錄: {epub_dir}")
    print(f"封面目錄: {covers_dir}")
    print(f"目錄檔案: {catalog_dir}")
    
    # 檢查 EPUB 目錄
    if not epub_dir.exists():
        print(f"\n❌ 錯誤: EPUB 目錄不存在 ({epub_dir})")
        print("請確認專案結構正確")
        return 1
    
    epub_count = len(list(epub_dir.glob("*.epub")))
    print(f"\n📚 找到 {epub_count} 個 EPUB 檔案")
    
    if epub_count == 0:
        print("❌ 沒有找到任何 EPUB 檔案")
        return 1
    
    # 詢問是否繼續
    response = input(f"\n是否開始處理這些 EPUB 檔案？(y/N): ").strip().lower()
    if response not in ['y', 'yes', '是']:
        print("已取消處理")
        return 0
    
    # 執行處理
    try:
        processor = EPUBProcessor(epub_dir, covers_dir, catalog_dir)
        processor.run()
        
        print(f"\n🎉 處理完成！")
        print(f"📁 封面圖片已保存到: {covers_dir}")
        print(f"📄 書籍目錄已保存到: {catalog_dir / 'books.json'}")
        
        return 0
        
    except Exception as e:
        print(f"\n❌ 處理過程中發生錯誤: {e}")
        return 1

if __name__ == "__main__":
    exit_code = main()
    
    # 在 Windows 下暫停，讓使用者看到結果
    if os.name == 'nt':
        input("\n按 Enter 鍵退出...")
    
    sys.exit(exit_code)