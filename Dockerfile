FROM rocker/verse
MAINTAINER Michael Jetsupphasuk <jetsupphasuk@unc.edu>

# these things need to be installed for the spatial libraries in R
RUN apt update && apt-get install -y libudunits2-dev
RUN apt update && apt-get install -y libgdal-dev

RUN R -e "install.packages('sf')"
RUN R -e "install.packages('rnaturalearth')"
RUN R -e "install.packages('rnaturalearthdata')"
RUN R -e "install.packages('rgeos')"
RUN R -e "install.packages('gridExtra')"
RUN R -e "install.packages('randomForest')"
RUN R -e "install.packages('kableExtra')"