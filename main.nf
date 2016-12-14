#!/usr/bin/env nextflow

println params.fastq_path
fastqs = Channel.fromPath(params.fastq_path)

process sketch_files {

    input:
    file query from fastqs

    output:
    file "${query}.msh" into sketches

    """
    mash sketch -m 2G -k 31 -s 400 ${query}
    """
}

process combine_sketch_files {
    
    input:
    file sketch from sketches.toList()

    output:
    file "output.msh" into output

    publishDir "."

    """
    mash paste output ${sketch}
    """
}


sketches.subscribe { print "Received: $it" }


workflow.onComplete {
    println "Pipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}