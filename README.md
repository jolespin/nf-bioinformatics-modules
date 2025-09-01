# nf-modules

NextFlow bioinformatics modules management tool

## Overview

nf-modules is a command-line tool for managing NextFlow bioinformatics modules from the [nf-modules repository](https://github.com/jolespin/nf-modules). It provides simple commands to list available modules and fetch them for use in your NextFlow workflows.  Many of these modules are modifications from [`nf-core`](https://github.com/nf-core/modules/).  For official `nf-core` modules, please use `nf-core` cli. 

## Installation

PyPI
```bash
pip install nf-modules
```

## Usage
Recommended `NextFlow` project directory structure: 
```
├── nextflow.config
├── main.nf
├── modules/
│   ├── external/ # nf-modules or other external modules
│   ├── local/ # Your custom modules (e.g., assembly/main.nf)
│   └── nf-core/ # Official nf-core modules
├── bin/
├── .gitignore
└── README.md
```

### List available modules

```bash
# List all modules (names only)
nf-modules list

# Export as YAML format
nf-modules list -f yaml

# Filter modules by name
nf-modules list --filter spades
```

### Fetch modules

```bash
# Fetch modules to default directory (modules/external)
nf-modules fetch pyrodigal spades

# Fetch to custom directory
nf-modules fetch -o modules/external pyrodigal spades

# Fetch from specific git tag/branch
nf-modules fetch -t v1.0.0 pyrodigal spades
```

## Commands

### list

List all available modules in the repository.

**Options:**
- `-f, --format {list-name,list-version,yaml}`: Output format (default: list-name)
- `--filter FILTER`: Filter modules by name pattern (case-insensitive substring match)

**Output Formats:**
* list-name
    ```
    barrnap
    flye
    pyrodigal
    spades
    trnascanse
    ```

* yaml
    ```yaml
    name: nf-modules
    dependencies:
    - barrnap=0.9--hdfd78af_4[2025.9.1]
    - flye=2.9.5--d577924c8416ccd8[2025.9.1]
    - pyrodigal=3.6.3.post1--py310h1fe012e_1[2025.9.1]
    ```

### fetch

Download modules from the repository to a local directory.

**Options:**
- `-o, --output-directory DIR`: Output directory (default: modules/external)
- `-t, --tag TAG`: Git tag or branch to fetch from (default: main)
- `modules`: One or more module names to fetch

**Examples:**
```bash
nf-modules fetch pyrodigal
nf-modules fetch pyrodigal spades flye
nf-modules fetch -o modules/external -t v1.0.0 pyrodigal spades
```

## Requirements

- Python 3.6+
- PyYAML

## Repository

The modules are sourced from: https://github.com/jolespin/nf-modules

## License

Apache 2.0