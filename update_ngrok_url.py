#!/usr/bin/env python3
"""
Script to update ngrok URL in Flutter app configuration files
Usage: python update_ngrok_url.py <new_ngrok_url>
"""

import sys
import re
import os

def update_file(file_path, old_url_pattern, new_url):
    """Update ngrok URL in a file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace the URL using regex pattern
        updated_content = re.sub(old_url_pattern, new_url, content)
        
        if content != updated_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(updated_content)
            print(f"✅ Updated {file_path}")
            return True
        else:
            print(f"⚠️ No changes needed in {file_path}")
            return False
    except Exception as e:
        print(f"❌ Error updating {file_path}: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python update_ngrok_url.py <new_ngrok_url>")
        print("Example: python update_ngrok_url.py https://abc123.ngrok-free.app")
        sys.exit(1)
    
    new_url = sys.argv[1]
    
    # Validate URL format
    if not new_url.startswith('https://') or '.ngrok' not in new_url:
        print("❌ Invalid ngrok URL format. Should be like: https://abc123.ngrok-free.app")
        sys.exit(1)
    
    print(f"🔄 Updating ngrok URL to: {new_url}")
    print()
    
    # Files to update
    files_to_update = [
        {
            'path': 'lib/services/ats_service.dart',
            'pattern': r"defaultValue: 'https://[^']+\.ngrok[^']*'",
            'replacement': f"defaultValue: '{new_url}'"
        },
        {
            'path': 'lib/models/ats_models.dart', 
            'pattern': r"defaultValue: 'https://[^']+\.ngrok[^']*'",
            'replacement': f"defaultValue: '{new_url}'"
        },
        {
            'path': 'Semantic_ranker/config.py',
            'pattern': r'NGROK_URL = "https://[^"]+\.ngrok[^"]*"',
            'replacement': f'NGROK_URL = "{new_url}"'
        }
    ]
    
    updated_count = 0
    for file_info in files_to_update:
        if os.path.exists(file_info['path']):
            if update_file(file_info['path'], file_info['pattern'], file_info['replacement']):
                updated_count += 1
        else:
            print(f"⚠️ File not found: {file_info['path']}")
    
    print()
    if updated_count > 0:
        print(f"✅ Successfully updated {updated_count} files")
        print("🔄 Restart your Flutter app to use the new URL")
    else:
        print("⚠️ No files were updated")

if __name__ == "__main__":
    main()

