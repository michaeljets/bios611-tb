#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Michael Jetsupphasuk
"""

# import libraries
import numpy as np
import pandas as pd

from sklearn.manifold import TSNE

import matplotlib.pyplot as plt
import seaborn as sns

# load data
superhero = pd.read_csv('superhero_stats.csv')

# filter out the observations with missing alignment
superhero = superhero.dropna()

# %% Fitting TSNE model and writing to csv (Q3)

# TSNE model, use default hyperparameters
tsne = TSNE(random_state = 8971019)

# fit model
superhero_tsne = tsne.fit_transform(superhero.select_dtypes(include='int64'))

# write data
superhero_tsne = pd.DataFrame(superhero_tsne)
superhero_tsne.columns = ['x1', 'x2']
superhero_tsne.to_csv('superhero_tsne_results.csv', header=False, index=False)


# %% Plotting results (Q4)

# add in labels
superhero_tsne['alignment'] = superhero[['Alignment']]

# plot
ax = plt.axes()
sns.scatterplot(
    x = 'x1',
    y = 'x2',
    hue = 'alignment',
    alpha = 0.5,
    palette = 'colorblind',
    data = superhero_tsne,
    ax = ax
)
ax.set_title('TSNE components')

# save plot
plt.savefig('tsne_fig_py.png', dpi=300)
