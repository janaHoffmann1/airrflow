process GET_READS_PER_UMI {
    tag 'pars'
    label 'process_low'

    conda "bioconda::pandas=1.1.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.1.5' :
        'biocontainers/pandas:1.1.5' }"

    input:
    path("UMI_clusterinfo/*")
    path("UMI_rnaseq/*")
    val library_generation_method

    output:
    path("reads_per_UMI.csv"), emit: readUMI

    script:
    if (library_generation_method == 'trust4') {
        """
        for file in UMI_rnaseq/*assembled_reads.fa; do
            sample=\${file##*/}
            sample=\${sample%%_assembled_reads.fa}
            grep '^>' \${file} | sed 's/.* barcode/barcode/g' | sort | uniq -c | sed 's/^ *//; s/ /,/g' | cut -d"," -f1 | sort | uniq -c | sed 's/^ *//; s/ /,/g' > \${sample}.csv
        done

        reads_per_umi_parser.py -rs
        """
    } else {
        """
        reads_per_umi_parser.py -as
        """
    }
}