import os

def generate_directory_tree(root_dir, output_file, indent=""):
    with open(output_file, 'a', encoding='utf-8') as f:
        for item in sorted(os.listdir(root_dir)):
            item_path = os.path.join(root_dir, item)
            if os.path.isdir(item_path):
                if item.startswith('.') or item in ['__pycache__', '.git', '.vscode', 'node_modules']:
                    continue
                f.write(f"{indent}|-- {item}\n")
                generate_directory_tree(item_path, output_file, indent + "    ")
            else:
                if item.startswith('.') or item.endswith(('.log', '.tmp')):
                    continue
                f.write(f"{indent}|-- {item}\n")

def main():
    # Directory to start from (current directory by default)
    root_dir = "."

    # Output file name
    output_file = "file_tree.txt"

    # Clear the output file if it exists
    if os.path.exists(output_file):
        os.remove(output_file)

    # Write the initial directory path
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"Directory tree for: {os.path.abspath(root_dir)}\n")

    # Generate directory tree
    generate_directory_tree(root_dir, output_file)

    print(f"Directory tree saved to {output_file}")

if __name__ == "__main__":
    main()
