#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EPUB 處理器 - 自動提取書籍元數據和封面圖片
"""

import os
import json
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
import shutil
import urllib.parse
import hashlib
from typing import Dict, List, Optional, Tuple

class EPUBProcessor:
    def __init__(self, epub_dir: str, covers_dir: str, catalog_dir: str):
        """
        初始化 EPUB 處理器
        
        Args:
            epub_dir: EPUB 檔案所在目錄
            covers_dir: 封面圖片輸出目錄 
            catalog_dir: 目錄檔案輸出目錄
        """
        self.epub_dir = Path(epub_dir)
        self.covers_dir = Path(covers_dir)
        self.catalog_dir = Path(catalog_dir)
        
        # 確保目錄存在
        self.covers_dir.mkdir(exist_ok=True)
        self.catalog_dir.mkdir(exist_ok=True)
        
        # XML 命名空間
        self.namespaces = {
            'container': 'urn:oasis:names:tc:opendocument:xmlns:container',
            'opf': 'http://www.idpf.org/2007/opf',
            'dc': 'http://purl.org/dc/elements/1.1/'
        }

    def get_container_path(self, epub_zip: zipfile.ZipFile) -> Optional[str]:
        """從 META-INF/container.xml 獲取 content.opf 路徑"""
        try:
            container_data = epub_zip.read('META-INF/container.xml')
            container_root = ET.fromstring(container_data)
            
            # 查找 rootfile 元素
            rootfile = container_root.find('.//container:rootfile', self.namespaces)
            if rootfile is not None:
                return rootfile.get('full-path')
            
            # 備用方法：查找沒有命名空間的 rootfile
            for elem in container_root.iter():
                if elem.tag.endswith('rootfile'):
                    return elem.get('full-path')
                    
        except Exception as e:
            print(f"無法讀取 container.xml: {e}")
            
        return None

    def parse_opf_metadata(self, opf_content: bytes) -> Dict:
        """解析 OPF 檔案的 metadata 區段"""
        try:
            root = ET.fromstring(opf_content)
            metadata = {}
            
            # 查找 metadata 元素
            metadata_elem = root.find('.//opf:metadata', self.namespaces)
            if metadata_elem is None:
                # 備用：查找沒有命名空間的 metadata
                metadata_elem = root.find('.//metadata')
            
            if metadata_elem is not None:
                # 提取基本元數據
                for elem in metadata_elem:
                    tag_name = elem.tag.split('}')[-1]  # 移除命名空間前綴
                    
                    if tag_name in ['title', 'creator', 'subject', 'description', 
                                  'publisher', 'date', 'language', 'identifier']:
                        if elem.text:
                            metadata[tag_name] = elem.text.strip()
                    elif tag_name == 'meta':
                        # 處理 meta 標籤
                        name = elem.get('name', '')
                        content = elem.get('content', '')
                        if name == 'cover' and content:
                            metadata['cover_id'] = content
            
            return metadata
            
        except Exception as e:
            print(f"解析 OPF metadata 失敗: {e}")
            return {}

    def find_cover_item(self, opf_content: bytes, cover_id: Optional[str] = None) -> Optional[str]:
        """在 manifest 中查找封面檔案路徑"""
        try:
            root = ET.fromstring(opf_content)
            
            # 查找 manifest 元素
            manifest = root.find('.//opf:manifest', self.namespaces)
            if manifest is None:
                manifest = root.find('.//manifest')
            
            if manifest is not None:
                # 方法1: 通過 cover_id 查找
                if cover_id:
                    for item in manifest:
                        if item.tag.endswith('item') and item.get('id') == cover_id:
                            return item.get('href')
                
                # 方法2: 查找 properties="cover-image" 的項目 (EPUB3)
                for item in manifest:
                    if item.tag.endswith('item'):
                        properties = item.get('properties', '')
                        if 'cover-image' in properties:
                            return item.get('href')
                
                # 方法3: 查找常見的封面檔案名稱或 ID
                cover_patterns = ['cover', 'Cover', 'COVER']
                for item in manifest:
                    if item.tag.endswith('item'):
                        item_id = item.get('id', '')
                        href = item.get('href', '')
                        media_type = item.get('media-type', '')
                        
                        # 檢查是否為圖片且檔名包含 cover
                        if media_type.startswith('image/'):
                            for pattern in cover_patterns:
                                if (pattern in item_id or pattern in href):
                                    return href
                                
        except Exception as e:
            print(f"查找封面項目失敗: {e}")
            
        return None

    def extract_cover_image(self, epub_zip: zipfile.ZipFile, opf_path: str, 
                          cover_href: str, output_path: Path) -> bool:
        """提取封面圖片"""
        try:
            # 計算封面檔案的完整路徑
            opf_dir = os.path.dirname(opf_path)
            if opf_dir:
                cover_path = f"{opf_dir}/{cover_href}"
            else:
                cover_path = cover_href
            
            # URL 解碼
            cover_path = urllib.parse.unquote(cover_path)
            
            # 嘗試不同的路徑組合
            possible_paths = [
                cover_path,
                cover_href,
                f"OEBPS/{cover_href}",
                f"EPUB/{cover_href}"
            ]
            
            for path in possible_paths:
                try:
                    cover_data = epub_zip.read(path)
                    with open(output_path, 'wb') as f:
                        f.write(cover_data)
                    print(f"✓ 成功提取封面: {output_path}")
                    return True
                except KeyError:
                    continue
            
            print(f"✗ 無法找到封面檔案，嘗試過的路徑: {possible_paths}")
            return False
            
        except Exception as e:
            print(f"提取封面失敗: {e}")
            return False

    def generate_book_id(self, epub_file: Path) -> str:
        """生成書籍 ID（基於檔名）"""
        # 移除副檔名並清理檔名
        name = epub_file.stem
        # 可以在這裡添加更多的清理邏輯
        return name

    def get_image_extension(self, epub_zip: zipfile.ZipFile, cover_path: str) -> str:
        """根據檔案內容判斷圖片格式"""
        try:
            # 嘗試讀取檔案開頭來判斷格式
            cover_data = epub_zip.read(cover_path)
            if cover_data.startswith(b'\xff\xd8\xff'):
                return '.jpg'
            elif cover_data.startswith(b'\x89PNG'):
                return '.png'
            elif cover_data.startswith(b'GIF'):
                return '.gif'
            elif cover_data.startswith(b'RIFF') and b'WEBP' in cover_data[:12]:
                return '.webp'
            else:
                # 從原檔名推測
                _, ext = os.path.splitext(cover_path.lower())
                return ext if ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp'] else '.jpg'
        except:
            return '.jpg'

    def process_epub(self, epub_file: Path) -> Optional[Dict]:
        """處理單個 EPUB 檔案"""
        print(f"\n處理: {epub_file.name}")
        
        try:
            with zipfile.ZipFile(epub_file, 'r') as epub_zip:
                # 1. 獲取 content.opf 路徑
                opf_path = self.get_container_path(epub_zip)
                if not opf_path:
                    print(f"✗ 無法找到 content.opf 路徑")
                    return None
                
                # 2. 讀取並解析 OPF 檔案
                opf_content = epub_zip.read(opf_path)
                metadata = self.parse_opf_metadata(opf_content)
                
                if not metadata:
                    print(f"✗ 無法解析 metadata")
                    return None
                
                # 3. 生成書籍資訊
                book_id = self.generate_book_id(epub_file)
                book_info = {
                    "id": book_id,
                    "title": metadata.get('title', epub_file.stem),
                    "author": metadata.get('creator', '未知作者'),
                    "language": metadata.get('language', 'zh-Hant'),
                    "description": metadata.get('description', ''),
                    "publisher": metadata.get('publisher', ''),
                    "date": metadata.get('date', ''),
                    "epubUrl": f"epub3/{epub_file.name}",
                    "coverUrl": "",  # 稍後設置
                    "metadata": metadata  # 保留完整 metadata 供調試
                }
                
                # 4. 查找並提取封面
                cover_id = metadata.get('cover_id')
                cover_href = self.find_cover_item(opf_content, cover_id)
                
                if cover_href:
                    # 確定封面檔案格式
                    ext = self.get_image_extension(epub_zip, 
                                                 f"{os.path.dirname(opf_path)}/{cover_href}" if os.path.dirname(opf_path) else cover_href)
                    cover_filename = f"{book_id}{ext}"
                    cover_output_path = self.covers_dir / cover_filename
                    
                    if self.extract_cover_image(epub_zip, opf_path, cover_href, cover_output_path):
                        book_info["coverUrl"] = f"covers/{cover_filename}"
                    else:
                        print(f"✗ 封面提取失敗")
                else:
                    print(f"✗ 未找到封面定義")
                
                print(f"✓ 處理完成: {book_info['title']} - {book_info['author']}")
                return book_info
                
        except Exception as e:
            print(f"✗ 處理 {epub_file.name} 時發生錯誤: {e}")
            return None

    def process_all_epubs(self) -> List[Dict]:
        """處理所有 EPUB 檔案"""
        books = []
        epub_files = list(self.epub_dir.glob("*.epub"))
        
        print(f"找到 {len(epub_files)} 個 EPUB 檔案")
        
        for epub_file in epub_files:
            book_info = self.process_epub(epub_file)
            if book_info:
                books.append(book_info)
        
        return books

    def generate_catalog(self, books: List[Dict]) -> None:
        """生成 books.json 目錄檔案"""
        catalog = {
            "metadata": {
                "title": "書苑閱讀器書目",
                "description": "自動生成的書籍目錄",
                "generated_at": "2025-11-05",
                "total_books": len(books)
            },
            "books": books
        }
        
        catalog_file = self.catalog_dir / "books.json"
        with open(catalog_file, 'w', encoding='utf-8') as f:
            json.dump(catalog, f, ensure_ascii=False, indent=2)
        
        print(f"\n✓ 生成目錄檔案: {catalog_file}")
        print(f"✓ 共處理 {len(books)} 本書籍")

    def run(self):
        """執行完整的處理流程"""
        print("=== EPUB 處理器開始執行 ===")
        
        if not self.epub_dir.exists():
            print(f"✗ EPUB 目錄不存在: {self.epub_dir}")
            return
        
        # 處理所有 EPUB 檔案
        books = self.process_all_epubs()
        
        if books:
            # 生成目錄檔案
            self.generate_catalog(books)
        else:
            print("✗ 沒有成功處理任何書籍")
        
        print("\n=== 處理完成 ===")


def main():
    """主函數"""
    # 設定路徑（相對於專案根目錄）
    project_root = Path(__file__).parent.parent
    epub_dir = project_root / "epub3"
    covers_dir = project_root / "covers"
    catalog_dir = project_root / "catalog"
    
    # 創建處理器並執行
    processor = EPUBProcessor(epub_dir, covers_dir, catalog_dir)
    processor.run()


if __name__ == "__main__":
    main()