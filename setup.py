from setuptools import setup, find_packages

# Read version from __init__.py
with open("nf_modules/__init__.py", "r") as f:
    for line in f:
        if line.startswith("__version__"):
            version = line.split("=")[-1].strip().strip('"\'')
            break
    else:
        raise RuntimeError("Could not find version in nf_modules/__init__.py")

setup(
    name="nf-modules",
    version=version,
    description="Nextflow bioinformatics modules",
    author="Josh L. Espinoza",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "nf-modules=nf_modules.cli:main",
        ],
    },
    python_requires=">=3.6",
)