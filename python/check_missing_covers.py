#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
檢查缺少封面的電子書
"""

import json
from pathlib import Path

def check_missing_covers():
    """檢查缺少封面的電子書"""
    # 讀取 books.json
    catalog_file = Path(__file__).parent.parent / "catalog" / "books.json"
    
    try:
        with open(catalog_file, 'r', encoding='utf-8') as f:
            catalog_data = json.load(f)
        
        books = catalog_data.get('books', [])
        missing_covers = []
        
        print("=== 檢查缺少封面的電子書 ===\n")
        
        for book in books:
            title = book.get('title', '未知書名')
            cover_url = book.get('coverUrl', '')
            epub_url = book.get('epubUrl', '')
            
            if not cover_url:  # 沒有封面 URL
                missing_covers.append({
                    'title': title,
                    'epub_file': epub_url,
                    'author': book.get('author', '未知作者')
                })
        
        if missing_covers:
            print(f"找到 {len(missing_covers)} 本書籍缺少封面圖檔：\n")
            
            for i, book in enumerate(missing_covers, 1):
                print(f"{i:2d}. 書名：{book['title']}")
                print(f"    作者：{book['author']}")
                print(f"    檔案：{book['epub_file']}")
                print()
            
            # 生成重新處理的檔案列表
            epub_files = [book['epub_file'].replace('epub3/', '') for book in missing_covers]
            
            print("=== 需要重新檢查的 EPUB 檔案 ===")
            for epub_file in epub_files:
                print(f"  {epub_file}")
            
            print(f"\n總共需要檢查 {len(missing_covers)} 個檔案")
            
        else:
            print("✓ 所有書籍都有封面圖檔！")
        
        # 統計資訊
        total_books = len(books)
        books_with_covers = total_books - len(missing_covers)
        
        print(f"\n=== 統計資訊 ===")
        print(f"總書籍數量：{total_books}")
        print(f"有封面的書籍：{books_with_covers}")
        print(f"缺少封面的書籍：{len(missing_covers)}")
        print(f"封面提取成功率：{books_with_covers/total_books*100:.1f}%")
        
        return missing_covers
        
    except Exception as e:
        print(f"讀取書籍目錄時發生錯誤：{e}")
        return []

if __name__ == "__main__":
    missing_covers = check_missing_covers()