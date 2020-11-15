.PHONY: clean
.PHONY: shiny_app
SHELL: /bin/bash

clean:
	rm -f data/derived_data/*.csv
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
 code/load_libraries.R
	Rscript code/clean_data.R

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
figures/budget_inc.png:
	python3 code/plot_budget_inc.py

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
 figures/budget_inc.png\
 data/derived_data/country_indicators_reg_meta.csv\
 code/clean_data.R
	Rscript -e "rmarkdown::render('report.Rmd')"

# shiny app
shiny_app:\
 data/derived_data/reg_data.csv
	Rscript code/shiny_country_trends.R ${PORT}