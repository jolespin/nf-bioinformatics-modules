#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

def module_version = "2025.9.4"

process PYHMMSEARCH {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pyhmmsearch:2024.10.20--pyh7e72e81_0' :
        'biocontainers/pyhmmsearch:2024.10.20--pyh7e72e81_0' }"

    input:
    tuple val(meta), path(hmmdb), path(fasta), val(write_reformatted_output) //, val(write_target), val(write_domain)

    output:
    tuple val(meta), path('*.tsv.gz')   , emit: output
    tuple val(meta), path('*.reformatted.tsv.gz')   , emit: reformatted_output    , optional: true
    // tuple val(meta), path('*.tblout.gz'), emit: tblout, optional: true
    // tuple val(meta), path('*.domtblout.gz'), emit: domtblout, optional: true
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args       = task.ext.args   ?: ''
    def prefix     = task.ext.prefix ?: "${meta.id}"
    reformatted_argument = write_reformatted_output    ? "reformat_pyhmmsearch -i ${prefix}.tsv -o ${prefix}.reformatted.tsv.gz" : ''
    target_argument = write_target    ? "--tblout ${prefix}.tblout.gz" : ''
    domain_argument = write_domain    ? "--domtblout ${prefix}.domtblout.gz" : ''


    """
    pyhmmsearch \\
        $args \\
        --n_jobs $task.cpus \\
        "-i" \\
        $fasta \\
        "-d" \\ 
        $hmmdb \\
        -o ${prefix}.tsv \\
        // $target_summary \\
        // $domain_summary \\

    ${reformatted_argument}

    gzip -n -f -v ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pyhmmsearch: \$(pyhmmsearch --version')
        module: ${module_version}
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch "${prefix}.tsv.gz"
    ${write_reformatted_output ? "touch ${prefix}.reformatted.tsv.gz" : ''} \\
    // ${write_target ? "touch ${prefix}.tblout.gz" : ''} \\
    // ${write_domain ? "touch ${prefix}.domtblout.gz" : ''}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pyhmmsearch: \$(pyhmmsearch --version')
        module: ${module_version}
    END_VERSIONS
    """
}