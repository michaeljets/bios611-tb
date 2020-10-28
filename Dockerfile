FROM rocker/verse
MAINTAINER Michael Jetsupphasuk <jetsupphasuk@unc.edu>

# these things need to be installed for the spatial libraries in R
RUN apt update && apt-get install -y libudunits2-dev
RUN apt update && apt-get install -y libgdal-dev

# R packages
RUN R -e "install.packages('sf')"
RUN R -e "install.packages('rnaturalearth')"
RUN R -e "install.packages('rnaturalearthdata')"
RUN R -e "install.packages('rgeos')"
RUN R -e "install.packages('gridExtra')"
RUN R -e "install.packages('randomForest')"
RUN R -e "install.packages('kableExtra')"
RUN R -e "install.packages('stargazer')"
RUN R -e "install.packages('gbm')"
RUN R -e "install.packages('caret')"

# python stuff
RUN apt update -y && apt install -y python3-pip
RUN pip3 install jupyter jupyterlab
RUN pip3 install numpy pandas sklearn plotnine matplotlib pandasql bokeh seaborn
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt update -y && apt install -y nodejs 
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install @bokeh/jupyter_bokeh