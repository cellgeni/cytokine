FROM rocker/shiny:3.6.1

# install some R required stuff
RUN apt-get update -y --no-install-recommends \
    && apt-get -y install -f \
       zlib1g-dev \
       libssl-dev \
       libcurl4-openssl-dev \
       wget \
       && apt-get clean && \
       rm -rf /var/lib/apt/lists/*

RUN Rscript -e 'install.packages("ggplot2")'

RUN rm -rf /srv/shiny-server/*
COPY bulk-expression-shiny/ /srv/shiny-server/
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

CMD ["shiny-server"]
