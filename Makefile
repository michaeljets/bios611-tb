.PHONY: clean
SHELL: /bin/bash

clean:
	rm -f derived_data/*.csv
	rm -f figures/*.png
	rm -f models/*.rds
	rm -f report.pdf

# figures for README
figures/incidence_pop_all.png\
 figures/incidence_pop_zoom.png\
 figures/mdr_counts_country.png\
 figures/world_inc.png:
	Rscript code/prelim_figures.R

# derived data
data/derived_data/country_indicators.csv:\
code/clean_data.R\
code/load_libraries.R
	Rscript code/clean_data.R
data/derived_data/country_indicators_reg.csv\
 data/derived_data/country_indicators_reg_meta.csv:\
 code/clean_data.R\
 code/load_libraries.R\
 code/incidence_models.R
	Rscript code/incidence_models.R

# figures for report
figures/incidence_maps.png\
 figures/incidence_maps_2018.png:\
 code/incidence_map.R\
 code/clean_data.R\
 code/load_libraries.R
	Rscript code/incidence_map.R
figures/inc_hist.png\
 figures/pair_scatter.png:\
 code/incidence_models.R\
 code/clean_data.R\
 code/load_libraries.R
	Rscript code/incidence_models.R

# models
models/lm_fit_yes_hci.rds\
 models/lm_fit_no_hci.rds\
 models/rf_fit_yes_hci.rds\
 models/rf_fit_no_hci.rds\
 models/inc_model_comparison.rds:\
 code/incidence_models.R\
 code/clean_data.R\
 code/load_libraries.R
	Rscript code/incidence_models.R

# generate report
report.pdf:\
 report.Rmd\
 models/*\
 figures/*
	Rscript -e "rmarkdown::render('report.Rmd')"