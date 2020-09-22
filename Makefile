.PHONY: clean
SHELL: /bin/bash

clean:
	rm -f derived_data/*.csv
	rm -f figures/*.png
	rm -f report.pdf

# figures for README
figures/incidence_pop_all.png\
 figures/incidence_pop_zoom.png\
 figures/mdr_counts_country.png\
 figures/world_inc.png: 
	Rscript code/prelim_figures.R