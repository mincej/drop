DROP - Detection of RNA Outliers Pipeline
==========================================

DROP is intended to help researchers use RNA-Seq data in order to detect genes with aberrant expression,
aberrant splicing, mono-allelic expression, and RNA-Seq variant calling. It consists of 4 independent modules for each of those strategies.
After installing DROP, the user needs to fill in the config file and sample annotation table (:doc:`prepare`).
Then, DROP can be executed in multiple ways (:doc:`pipeline`).

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   prepare
   pipeline
   output
   license
   help

Quickstart
-----------

DROP is available on `bioconda <https://anaconda.org/bioconda/drop>`_.
We recommend using a dedicated conda environment. (installation time: ~ 10min)
Use `mamba` instead of `conda` as it provides more reliable and faster dependency solving.

.. code-block:: bash

    mamba create -n drop -c conda-forge -c bioconda drop

Test installation with demo project

.. code-block:: bash

    mkdir ~/drop_demo
    cd ~/drop_demo
    drop demo

The pipeline can be run using `snakemake <https://snakemake.readthedocs.io/>`_ commands

.. code-block:: bash

    snakemake --cores 1 -n # dryrun
    snakemake --cores 1

Expected runtime: 25 min

For more information on different installation options, refer to :doc:`installation`.
