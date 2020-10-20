.PHONY: clean
SHELL: /bin/bash

clean:
	rm -f derived_data/*.csv
	rm -f figures/*.png
	rm -f models/*.rds
	rm -f report.pdf


# derived data
data/derived_data/country_indicators.csv:\
 code/clean_data.R\
 code/load_libraries.R
	Rscript code/clean_data.R
data/derived_data/reg_data.csv\
 data/derived_data/country_indicators_reg_meta.csv:\
 code/clean_data.R\
 code/load_libraries.R\
 code/incidence_models.R
	Rscript code/incidence_models.R

# figures for report
figures/incidence_maps.png\
 figures/incidence_maps_2018.png\
 figures/death_maps.png\
 figures/death_maps_2018.png:\
 code/maps.R\
 code/clean_data.R\
 code/load_libraries.R
	Rscript code/maps.R
figures/pair_scatter.png:\
 code/incidence_models.R\
 code/clean_data.R\
 code/load_libraries.R\
 data/derived_data/country_indicators.csv
	Rscript code/incidence_models.R
figures/world_inc.png\
 figures/world_deaths.png:
	Rscript code/prelim_figures.R

# models
models/models.rds\
models/inc_model_comparison.rds:\
 code/incidence_models.R\
 code/clean_data.R\
 code/load_libraries.R\
 data/derived_data/country_indicators.csv
	Rscript code/incidence_models.R

# generate report
report.pdf:\
 report.Rmd\
 models/inc_model_comparison.rds\
 figures/incidence_maps.png\
 figures/incidence_maps_2018.png\
 figures/death_maps.png\
 figures/death_maps_2018.png\
 figures/pair_scatter.png\
 figures/world_deaths.png\
 figures/world_inc.png\
 data/derived_data/country_indicators_reg_meta.csv\
 code/clean_data.R
	Rscript -e "rmarkdown::render('report.Rmd')"