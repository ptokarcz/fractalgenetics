# how to run fro ./:
# snakemake -s phenotypes.smk --jobs 5000 --latency-wait 30 --cluster-config config/cluster.json --cluster 'bsub -J {cluster.name} -q {cluster.queue} -n {cluster.n} -R {cluster.resources} -M {cluster.memory}  -o {cluster.output} -e  {cluster.error}' --keep-going --rerun-incomplete

configfile: "config/config_phenotypes.yaml"

rule all:
    input:
        expand("{ukb}/rawdata/ukb22219.enc_ukb",
            ukb=config["ukbdir"]),
        expand("{ukb}/rawdata/ukb22219.html",
            ukb=config["ukbdir"]),
        expand("{ukb}/rawdata/ukb22219.tab",
            ukb=config["ukbdir"]),
        expand("{ukb}/rawdata/ukb22219.r",
            ukb=config["ukbdir"]),
        expand("{ukb}/phenotypes/FD_phenotypes_bgenie.csv",
            ukb=config["ukbdir"]),
        expand("{ukb}/phenotypes/FD_covariates_bgenie.csv",
            ukb=config["ukbdir"])

rule formatUKB:
    input:
        enc=expand("{ukb}/rawdata/ukb22219.enc",
            ukb=config["ukbdir"])
    output:
        dec="{dir}/rawdata/ukb22219.enc_ukb",
        html="{dir}/rawdata/ukb22219.html",
        tab="{dir}/rawdata/ukb22219.tab",
        r="{dir}/rawdata/ukb22219.r",
    shell:
        """
        ukb_unpack {input.enc} key
        ukb_conv {output.dec} r
        ukb_conv {output.dec} docs
        """

rule processUKB:
    input:
        ukbdir="{dir}/rawdata",
        outdir="{dir}/phenotypes",
        pheno="{dir}/rawdata/FD.csv",
        samples="{dir}/rawdata/ukb18545_imp_chr1_v3_s487378.sample",
        relatedness="{dir}/rawdata/ukb18545_rel_s488346.dat",
        europeans="{dir}/ancestry/European_samples.csv",
        pcs="{dir}/ancestry/ukb_imp_genome_v3_maf0.1.pruned.European.pca"
    output:
        "{dir}/phenotypes/FD_phenotypes_bgenie.csv",
        "{dir}/phenotypes/FD_covariates_bgenie.csv"
    shell:
        "Rscript 'phenotypes/preparePheno.r' -u={input.ukbdir} \
            -o={input.outdir} \
            -p={input.pheno} \
            -s={input.samples} \
            -r={input.relatedness} \
            -e={input.europeans} \
            -pcs={input.pcs}"

