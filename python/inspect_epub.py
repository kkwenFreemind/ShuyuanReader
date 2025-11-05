#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EPUB 檔案結構檢查工具 - 用於診斷封面提取問題
"""

import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

def inspect_epub(epub_path: str):
    """檢查 EPUB 檔案的內部結構"""
    print(f"\n=== 檢查 EPUB: {epub_path} ===")
    
    try:
        with zipfile.ZipFile(epub_path, 'r') as epub_zip:
            print("\n檔案列表:")
            file_list = epub_zip.namelist()
            for file in sorted(file_list):
                print(f"  {file}")
            
            # 檢查 container.xml
            print("\n=== container.xml ===")
            try:
                container_data = epub_zip.read('META-INF/container.xml')
                print(container_data.decode('utf-8'))
            except Exception as e:
                print(f"無法讀取 container.xml: {e}")
            
            # 查找並檢查 content.opf
            print("\n=== 查找 content.opf ===")
            opf_files = [f for f in file_list if f.endswith('.opf')]
            print(f"找到的 OPF 檔案: {opf_files}")
            
            if opf_files:
                opf_path = opf_files[0]
                print(f"\n=== {opf_path} 內容 ===")
                try:
                    opf_data = epub_zip.read(opf_path)
                    opf_content = opf_data.decode('utf-8')
                    print(opf_content[:2000] + "..." if len(opf_content) > 2000 else opf_content)
                except Exception as e:
                    print(f"無法讀取 OPF 檔案: {e}")
            
            # 查找圖片檔案
            print("\n=== 圖片檔案 ===")
            image_files = [f for f in file_list if any(f.lower().endswith(ext) for ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp'])]
            print(f"找到的圖片檔案: {image_files}")
            
    except Exception as e:
        print(f"檢查 EPUB 時發生錯誤: {e}")

def main():
    """主函數"""
    # 檢查幾個樣本檔案
    epub_dir = Path(__file__).parent.parent / "epub3"
    sample_files = [
        "一夢漫言.epub",
        "論語.epub",  # 如果存在
        "三世因果目蓮救母經.epub"
    ]
    
    for filename in sample_files:
        epub_path = epub_dir / filename
        if epub_path.exists():
            inspect_epub(str(epub_path))
        else:
            print(f"檔案不存在: {epub_path}")

if __name__ == "__main__":
    main()