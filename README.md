

Project 1 Bios 611
==================

Tuberculosis dataset
--------------------


### Project description

This project explores tuberculosis (TB) data published by the World Health Organization (WHO) and relates it to development indicators from the World Bank. The intention of this project is to be purely exploratory and descriptive. No causal or policy implications should be inferred from the results presented here. The purpose of this project is to explore recent TB data and get a better sense of incidence and how it varies by country and type of country. 

A summary of the analyses are presented in `report.pdf`. 


### Getting Started

The project uses Docker and Make to be reproducible. Docker is a software that manages environments and Make is a tool that builds files produced by the code, including the `report.pdf`, the summary of my analyses. 

Source data is included in this repository so the project should be self-contained without external dependencies. See below for more details on the data sources.


#### Docker

To run Docker, you need to install the software on your device and have the ability to run it as your current user. To build the container:

	> docker build --tag project-env .

To run the container on Rstudio server (change the password to your choosing),

	> docker run -v "`pwd`":/home/rstudio -p 8787:8787 -e PASSWORD="helloworld" -t project-env

Then, connect to port 8787 on your device. 

#### Make

You can also use Make to reproduce any elements of the analysis created by the code. For example, to build the final report use:

	> make report.pdf

You can also build any individual target. For example, 

	> make figures/incidence_maps.png


### Data sources

This project uses two data sources: the World Health Organization (WHO) and the World Bank. These data are located in `data/source_data/`.


#### WHO data

The data was downloaded [here](https://www.who.int/tb/country/data/download/en/) on September 07, 2020 (mostly, the dates of download are indicated in the filenames). Note that the data published on that page is subject to change so the code available in this repository may break with future iterations of the data. 

The filenames are associated with the following links on the WHO page:

| Filename                                  | Text                                                                                                     | Link                                                                    |
|-------------------------------------------|----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| MDR_RR_TB_burden_estimates_2020-09-07.csv | Download WHO MDR/RR-TB burden estimates for 2019 [30kb]                                                  | https://extranet.who.int/tme/generateCSV.asp?ds=mdr_rr_estimates        |
| TB_budget_2020-09-07.csv                  | Download TB budgets since fiscal year 2018 [0.1Mkb]                                                      | https://extranet.who.int/tme/generateCSV.asp?ds=budget                  |
| TB_burden_age_sex_2020-10-19.csv          | Download WHO TB incidence estimates disaggregated by age, sex and risk factor [0.6Mb]                    | https://extranet.who.int/tme/generateCSV.asp?ds=estimates_age_sex       |
| TB_burden_countries_2020-09-07.csv        | Download WHO TB burden estimates [0.8Mb]                                                                 | https://extranet.who.int/tme/generateCSV.asp?ds=estimates               |
| TB_community_engagement_2020-09-07.csv    | Download community engagement activities for TB [40kb]                                                   | https://extranet.who.int/tme/generateCSV.asp?ds=community               |
| TB_data_dictionary_2020-09-07.csv         | Download the data dictionary [csv 0.1Mb]                                                                 | https://extranet.who.int/tme/generateCSV.asp?ds=dictionary              |
| TB_dr_surveillance_2020-09-07.csv         | Download drug resistance testing in bacteriologically confirmed pulmonary TB patients since 2017 [0.1Mb] | https://extranet.who.int/tme/generateCSV.asp?ds=dr_surveillance         |
| TB_expenditure_utilisation_2020-10-19.csv | Download TB expenditure and utilization of health services since fiscal year 2017 [0.1Mb]                | https://extranet.who.int/tme/generateCSV.asp?ds=expenditure_utilisation |
| TB_outcomes_2020-09-07.csv                | Download treatment outcomes [0.8Mb]                                                                      | https://extranet.who.int/tme/generateCSV.asp?ds=outcomes                |


#### World Bank data

The World Bank data was downloaded [here](https://databank.worldbank.org/source/world-development-indicators#). There are two files in the `data/source_data/` directory, one with the actual data and one with metadata that describes that dataset. See the meta dataset for which indicators were chosen. All countries and years 2000-2018 were chosen. 