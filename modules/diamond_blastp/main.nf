process DIAMOND_BLASTP_WITH_CONCATENATION {
    tag "${meta.id}_vs_${meta2.id}"
    label 'process_high'

    conda "bioconda::diamond=2.1.12"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/diamond:2.1.12--hdb4b4cc_1'
        : 'biocontainers/diamond:2.1.12--hdb4b4cc_1'}"

    input:
    tuple val(meta), path(fastas)
    tuple val(meta2), path(db)
    val outfmt
    val blast_columns
    
    output:
    tuple val(meta), val(meta2), path("*.{txt,tsv}"), emit: results
    path "versions.yml", emit: versions
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_vs_${meta2.id}"
    def columns = blast_columns ? "${blast_columns}" : ''
    def extension = outfmt == 6 ? "txt" : "tsv"
    
    """
    # Create temporary concatenated file
    TEMP_FASTA=\$(mktemp --suffix=.fasta)
    
    # Concatenate all FASTA files
    cat ${fastas.join(' ')} > \$TEMP_FASTA
    
    # Run DIAMOND BLASTP
    diamond \\
        blastp \\
        --threads ${task.cpus} \\
        --db ${db} \\
        --query \$TEMP_FASTA \\
        --outfmt ${outfmt} ${columns} \\
        --max-target-seqs 1 \\
        ${args} \\
        --out ${prefix}.${extension}
    
    # Clean up temporary file
    rm \$TEMP_FASTA
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamond: \$(diamond --version 2>&1 | tail -n 1 | sed 's/^diamond version //')
        module: ${module_version}
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_vs_${meta2.id}"
    def extension = outfmt == 6 ? "txt" : "tsv"
    
    """
    touch ${prefix}.${extension}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamond: \$(diamond --version 2>&1 | tail -n 1 | sed 's/^diamond version //')
        module: ${module_version}
    END_VERSIONS
    """
}