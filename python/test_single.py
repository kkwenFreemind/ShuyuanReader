#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
手動測試單個 EPUB 檔案的處理
"""

import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

def test_single_epub():
    """測試單個 EPUB 檔案"""
    epub_path = Path(__file__).parent.parent / "epub3" / "一夢漫言.epub"
    
    with zipfile.ZipFile(epub_path, 'r') as epub_zip:
        # 讀取 OPF 檔案
        opf_content = epub_zip.read('OEBPS/content.opf')
        print("=== OPF 內容 ===")
        print(opf_content.decode('utf-8'))
        
        root = ET.fromstring(opf_content)
        
        # 定義命名空間
        namespaces = {
            'opf': 'http://www.idpf.org/2007/opf',
            'dc': 'http://purl.org/dc/elements/1.1/'
        }
        
        # 查找 metadata - 嘗試不同方式
        print("\n=== 查找 Metadata ===")
        metadata_elem = root.find('.//opf:metadata', namespaces)
        if metadata_elem is None:
            metadata_elem = root.find('.//metadata')
        
        if metadata_elem is not None:
            print("找到 metadata 元素")
            for elem in metadata_elem:
                tag_name = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
                print(f"標籤: {tag_name}, 文字: {elem.text}, 屬性: {elem.attrib}")
                
                # 特別檢查 meta 標籤
                if tag_name == 'meta':
                    name = elem.get('name', '')
                    content = elem.get('content', '')
                    print(f"  -> Meta: name='{name}', content='{content}'")
        else:
            print("找不到 metadata 元素")
        
        # 查找 manifest
        print("\n=== 查找 Manifest ===")
        manifest = root.find('.//opf:manifest', namespaces)
        if manifest is None:
            manifest = root.find('.//manifest')
            
        if manifest is not None:
            print("找到 manifest 元素")
            for item in manifest.findall('.//item'):
                print(f"ID: {item.get('id')}, HREF: {item.get('href')}, Type: {item.get('media-type')}, Properties: {item.get('properties', '')}")
        else:
            print("找不到 manifest 元素")

if __name__ == "__main__":
    test_single_epub()