#!/usr/bin/env python3
"""
list.py - List available NextFlow modules
"""
import sys
import urllib.request
import tarfile
import tempfile
import os

def list_modules(args):
    """List all available modules in the repository"""
    repository_url = "https://api.github.com/repos/jolespin/nf-modules/tarball"
    
    try:
        print("Fetching module list...")
        
        with tempfile.NamedTemporaryFile(suffix='.tar.gz', delete=False) as temporary_file:
            with urllib.request.urlopen(repository_url) as response:
                # Only read headers first to get content length for progress
                total_size = int(response.headers.get('content-length', 0))
                downloaded = 0
                
                while True:
                    chunk = response.read(8192)
                    if not chunk:
                        break
                    temporary_file.write(chunk)
                    downloaded += len(chunk)
                    
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\rDownloading: {percent:.1f}%", end='', flush=True)
                
            temporary_file_path = temporary_file.name
        
        print("\nExtracting module information...")
        
        # Extract and find all module directories
        modules = set()
        with tarfile.open(temporary_file_path, 'r:gz') as tarball:
            for member in tarball.getmembers():
                if member.isdir() and "/modules/" in member.name:
                    # Split path and look for modules directory
                    path_parts = member.name.split('/')
                    if len(path_parts) >= 3 and path_parts[-2] == "modules":
                        module_name = path_parts[-1]
                        if module_name and not module_name.startswith('.'):
                            modules.add(module_name)
        
        # Apply filter if specified
        if hasattr(args, 'filter') and args.filter:
            filtered_modules = {module for module in modules if args.filter.lower() in module.lower()}
            modules = filtered_modules
        
        if modules:
            if hasattr(args, 'format') and args.format == 'detailed':
                print(f"\nAvailable modules ({len(modules)}):")
                print("=" * 50)
                for module in sorted(modules):
                    print(f"Module: {module}")
                    print(f"  - Can be fetched with: nf-modules fetch -o modules/external {module}")
                    print()
            else:
                print(f"\nAvailable modules ({len(modules)}):")
                print("-" * 40)
                for module in sorted(modules):
                    print(f"  {module}")
        else:
            if hasattr(args, 'filter') and args.filter:
                print(f"No modules found matching filter '{args.filter}'")
            else:
                print("No modules found in repository")
        
    except Exception as exception:
        print(f"\nError: {exception}")
        sys.exit(1)
    
    finally:
        # Clean up temp file
        try:
            os.unlink(temporary_file_path)
        except:
            pass