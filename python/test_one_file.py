#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
測試單個檔案處理
"""

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent))

from epub_processor import EPUBProcessor

def main():
    project_root = Path(__file__).parent.parent
    epub_dir = project_root / "epub3"
    covers_dir = project_root / "covers"
    catalog_dir = project_root / "catalog"
    
    processor = EPUBProcessor(epub_dir, covers_dir, catalog_dir)
    
    # 測試單個檔案
    epub_file = epub_dir / "一夢漫言.epub"
    result = processor.process_epub(epub_file)
    
    if result:
        print(f"處理結果: {result}")
    else:
        print("處理失敗")

if __name__ == "__main__":
    main()