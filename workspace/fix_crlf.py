import os

def fix_line_endings(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.sh'):
                filepath = os.path.join(root, file)
                print(f"Fixing {filepath}...")
                with open(filepath, 'rb') as f:
                    content = f.read()
                
                # Replace CRLF (\r\n) with LF (\n)
                new_content = content.replace(b'\r\n', b'\n')
                
                if new_content != content:
                    with open(filepath, 'wb') as f:
                        f.write(new_content)
                    print(f"  Fixed: Converted CRLF to LF.")
                else:
                    print(f"  Skipped: Already using LF or no line endings found.")

if __name__ == "__main__":
    workspace_dir = os.path.join(os.getcwd(), 'workspace')
    if os.path.exists(workspace_dir):
        fix_line_endings(workspace_dir)
    else:
        print(f"Error: {workspace_dir} not found. Please run this script in the root of the hadoop-cluster project.")
