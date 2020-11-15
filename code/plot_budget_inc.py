#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Michael Jetsupphasuk
"""

# import libraries
import numpy as np
import pandas as pd

import matplotlib.pyplot as plt
import seaborn as sns

# load data
burden = pd.read_csv('data/source_data/TB_burden_countries_2020-09-07.csv')
budget = pd.read_csv('data/source_data/TB_budget_2020-09-07.csv')

# only keep relevant columns and rows, choose year 2018
burden = burden[burden.year==2018][['country', 'iso3', 'e_inc_100k']]
budget = budget[budget.year==2018][['iso3', 'budget_tot']]
budget = budget[pd.notnull(budget.budget_tot)]

# inner join (so only keep countries w/ data for both)
tb = pd.merge(burden, budget, how = 'inner', on = 'iso3')

# %% Scatter plot

# plot
ax = plt.axes()
sns.scatterplot(
    x = 'budget_tot',
    y = 'e_inc_100k',
    alpha = 0.5,
    palette = 'colorblind',
    data = tb,
    ax = ax
)
ax.set_title('Figure 8: TB incidence against budget, 2018')
plt.xlabel('Budget (USD)')
plt.ylabel('Incidence per 100k')

# save plot
plt.savefig('figures/budget_inc.png', dpi=300)

