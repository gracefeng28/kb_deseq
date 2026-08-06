FROM --platform=linux/amd64 kbase/sdkpython:3.8.0
MAINTAINER KBase Developer

ENV MAMBA_ROOT_PREFIX=/opt/conda

RUN apt-get update && \
    apt-get install -y g++ curl bzip2 && \
    curl -Ls https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64 -o /usr/local/bin/micromamba && \
    chmod +x /usr/local/bin/micromamba


ENV MAMBA_ROOT_PREFIX=/opt/conda

RUN micromamba create -y -n r-env -c conda-forge -c bioconda \
        r-base \
        bioconductor-deseq2 && \
    micromamba clean -afy

RUN ln -s /opt/conda/envs/r-env/bin/R /usr/local/bin/R && \
    ln -s /opt/conda/envs/r-env/bin/Rscript /usr/local/bin/Rscript
RUN R -q -e 'install.packages("getopt",  repos="http://cran.us.r-project.org")' && \
    R -q -e 'if (!require("getopt")) {quit(status=1)}'
RUN Rscript -e 'library(DESeq2); packageVersion("DESeq2")'

RUN pip install --upgrade pip \
    && python --version

RUN pip install coverage==5.5 && \
    pip install requests==2.26.0 && \
    pip install Jinja2==3.0.1 && \
    pip install JSONRPCBase==0.2.0 && \
    pip install nose==1.3.7

COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]