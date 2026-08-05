process GET_READS_PER_UMI {
    tag 'pars'
    label 'process_low'

    conda "bioconda::pandas=1.1.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.1.5' :
        'biocontainers/pandas:1.1.5' }"

    input:
    path('UMI_clusterinfo/*') 

    output:
    path("*.csv"), emit: readUMI

    script:
    """
    #!/usr/bin/env python3 
    import pandas as pd
    import glob

    sample_counts = []

    for i, file in enumerate(glob.glob('UMI_clusterinfo/*R1_table.tab')):
        df = pd.read_csv(file, sep='\t')
        sample_counts.append(df['SEQCOUNT'].value_counts().rename(file.split('/')[-1].split('_R1_table.tab')[0]))
        
    reads_per_umi_df = pd.concat(sample_counts, axis=1)
    reads_per_umi_df.to_csv('reads_per_UMI.csv')
    """
}