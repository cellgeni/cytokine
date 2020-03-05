FROM rocker/shiny:3.6.1

RUN Rscript -e 'install.packages("ggplot2")'

RUN rm -rf /srv/shiny-server/*
COPY bulk-expression-shiny/ /srv/shiny-server/
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

CMD ["shiny-server"]
