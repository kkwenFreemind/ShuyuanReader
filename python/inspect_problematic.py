#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
詳細檢查缺少封面的 EPUB 檔案
"""

import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

def inspect_problematic_epub(epub_path: str):
    """詳細檢查有問題的 EPUB 檔案"""
    print(f"\n{'='*50}")
    print(f"檢查：{Path(epub_path).name}")
    print(f"{'='*50}")
    
    try:
        with zipfile.ZipFile(epub_path, 'r') as epub_zip:
            # 檢查檔案結構
            file_list = epub_zip.namelist()
            print(f"檔案數量：{len(file_list)}")
            
            # 檢查是否有 container.xml
            if 'META-INF/container.xml' not in file_list:
                print("❌ 缺少 META-INF/container.xml")
                print("這不是標準的 EPUB 檔案")
                return
            
            # 讀取 container.xml
            container_data = epub_zip.read('META-INF/container.xml')
            container_root = ET.fromstring(container_data)
            
            # 找到 OPF 檔案
            rootfile = container_root.find('.//{urn:oasis:names:tc:opendocument:xmlns:container}rootfile')
            if rootfile is None:
                rootfile = container_root.find('.//rootfile')
            
            if rootfile is None:
                print("❌ 無法找到 rootfile")
                return
            
            opf_path = rootfile.get('full-path')
            print(f"OPF 檔案：{opf_path}")
            
            # 讀取 OPF 檔案
            opf_data = epub_zip.read(opf_path)
            opf_root = ET.fromstring(opf_data)
            
            # 檢查 metadata
            print("\n--- Metadata ---")
            metadata_elem = opf_root.find('.//{http://www.idpf.org/2007/opf}metadata')
            if metadata_elem is None:
                metadata_elem = opf_root.find('.//metadata')
            
            if metadata_elem is not None:
                # 顯示基本資訊
                for elem in metadata_elem:
                    tag_name = elem.tag.split('}')[-1]
                    if tag_name in ['title', 'creator', 'language']:
                        print(f"{tag_name}: {elem.text}")
                
                # 檢查 cover meta
                cover_found = False
                for meta in metadata_elem:
                    if meta.tag.endswith('meta'):
                        name = meta.get('name', '')
                        content = meta.get('content', '')
                        if name == 'cover':
                            print(f"✓ 找到 cover meta: {content}")
                            cover_found = True
                
                if not cover_found:
                    print("❌ 沒有找到 cover meta 標籤")
            
            # 檢查 manifest
            print("\n--- Manifest 圖片檔案 ---")
            manifest = opf_root.find('.//{http://www.idpf.org/2007/opf}manifest')
            if manifest is None:
                manifest = opf_root.find('.//manifest')
            
            if manifest is not None:
                image_items = []
                for item in manifest:
                    if item.tag.endswith('item'):
                        media_type = item.get('media-type', '')
                        if media_type.startswith('image/'):
                            image_items.append({
                                'id': item.get('id'),
                                'href': item.get('href'),
                                'type': media_type,
                                'properties': item.get('properties', '')
                            })
                
                if image_items:
                    print(f"找到 {len(image_items)} 個圖片檔案：")
                    for img in image_items:
                        cover_indicator = " (可能是封面)" if any(word in img['id'].lower() or word in img['href'].lower() 
                                                              for word in ['cover', '封面', 'title']) else ""
                        print(f"  - ID: {img['id']}, 檔案: {img['href']}, 類型: {img['type']}{cover_indicator}")
                        if 'cover-image' in img['properties']:
                            print(f"    ✓ 這個檔案標記為 cover-image")
                else:
                    print("❌ 沒有找到任何圖片檔案")
            
    except Exception as e:
        print(f"❌ 檢查檔案時發生錯誤：{e}")

def main():
    """檢查所有有問題的檔案"""
    epub_dir = Path(__file__).parent.parent / "epub3"
    
    problematic_files = [
        "佛說大乘無量壽莊嚴清淨平等覺經.epub",
        "因果報應錄.epub", 
        "國易堂易經.epub",
        "彌勒收圓1.epub",
        "止.epub",
        "涵三雜詠.epub"
    ]
    
    print("=== 詳細檢查缺少封面的 EPUB 檔案 ===")
    
    for epub_file in problematic_files:
        epub_path = epub_dir / epub_file
        if epub_path.exists():
            inspect_problematic_epub(str(epub_path))
        else:
            print(f"\n❌ 檔案不存在：{epub_file}")

if __name__ == "__main__":
    main()