FROM rocker/verse
MAINTAINER Michael Jetsupphasuk <jetsupphasuk@unc.edu>
RUN R -e "install.packages('questionr')"