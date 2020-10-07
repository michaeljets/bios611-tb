# incidence_models.R

# read data
source('code/load_libraries.R')
country_indicators = read_csv('data/derived_data/country_indicators.csv')

# prep data for linear regression use
country_indicators_2018 = country_indicators %>% filter(year==2018)
meta = country_indicators_2018 %>% select(`Series Name`, `Series Code`) %>% distinct()
country_indicators_2018 = country_indicators_2018 %>%
  select(-year, -`Series Name`) %>%
  pivot_wider(names_from = `Series Code`, values_from = value)

# join in TB data
dat = inner_join(country_indicators_2018, 
                 burden %>% filter(year==2018) %>% select(iso3, e_inc_100k), 
                 by = c('Country Code' = 'iso3'))

# plot distribution of outcome
inc_hist = ggplot(dat, aes(e_inc_100k)) +
  geom_histogram(bins = 20, color = 'black', fill = 'grey') +
  labs(title = 'Histogram of incidence per 100k',
       x = '',
       y = 'Frequency') +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0))

# pairwise scatter plots
pairs(dat %>% select(-`Country Name`, -`Country Code`), labels = c(meta$`Series Name`, 'TB incidence'))

# fit data by linear regression
reg_data1 = dat %>% select(-`Country Name`, -`Country Code`) %>% drop_na()
lm_fit1 = lm(e_inc_100k ~ ., data = reg_data1)
summary(lm_fit1)

reg_data2 = reg_data1 %>% select(-HD.HCI.OVRL) %>% drop_na()
lm_fit2 = lm(e_inc_100k ~ ., data = reg_data2)
summary(lm_fit2)

# how much better does the model with HCI fit compared to without? compare cv errors
set.seed(78273498)
k = 5

# define k folds
n = nrow(reg_data1)
tmp_ind = c(rep(1:k, floor(n/k)), rep(1, n - k*floor(n/k)))
k_folds_ind1 = sample(tmp_ind, n, replace=FALSE)
k_folds_ind2 = sample(tmp_ind, n, replace=FALSE)

errors1 = c()
errors2 = c()
for (i in 1:k) {
  # define sets set
  hold_out_dat1 = reg_data1[k_folds_ind1==i, ]
  train_dat1 = reg_data1[k_folds_ind1!=i, ]
  
  hold_out_dat2 = reg_data2[k_folds_ind2==i, ]
  train_dat2 = reg_data2[k_folds_ind2!=i, ]
  
  # fit model on training
  lm_tmp1 = lm(e_inc_100k ~ ., data = train_dat1)
  lm_tmp2 = lm(e_inc_100k ~ ., data = train_dat2)
  
  # get predictions for test set
  pred_tmp1 = predict(lm_tmp1, newdata = hold_out_dat1)
  pred_tmp2 = predict(lm_tmp2, newdata = hold_out_dat2)
  
  # get mean squared error
  errors1[i] = mean((hold_out_dat1$e_inc_100k - pred_tmp1)^2)
  errors2[i] = mean((hold_out_dat2$e_inc_100k - pred_tmp2)^2)
}

mean(errors1)
mean(errors2)


# do a random forest for fun (rf has built-in validation to find best rf)
set.seed(7814173)

rf_fit1 = randomForest(e_inc_100k ~., data = reg_data1, ntree=500, importance=TRUE)  # default hyperparameters
mean((rf_fit1$predicted - reg_data1$e_inc_100k)^2)

rf_fit2 = randomForest(e_inc_100k ~., data = reg_data2, ntree=500, importance=TRUE)  # default hyperparameters
mean((rf_fit2$predicted - reg_data1$e_inc_100k)^2)


# save
ggsave('figures/inc_hist.png', inc_hist, scale = 1.5)
png('figures/pair_scatter.png', width = 1800, height = 1000)
pairs(dat %>% select(-`Country Name`, -`Country Code`), labels = c(meta$`Series Name`, 'TB incidence'))
dev.off()

write_csv(country_indicators_2018, 'data/derived_data/country_indicators_reg.csv')
write_csv(meta, 'data/derived_data/country_indicators_reg_meta.csv')

saveRDS(lm_fit1, 'models/lm_fit_yes_hci.rds')
saveRDS(lm_fit2, 'models/lm_fit_no_hci.rds')
saveRDS(rf_fit1, 'models/rf_fit_yes_hci.rds')
saveRDS(rf_fit2, 'models/rf_fit_yes_hci.rds')

error_tab = data.frame(model = c(rep('Linear regression', 2), rep('Random forest', 2)),
                       include_hci = c('Yes', 'No', 'Yes', 'No'),
                       cv_error = c(mean(errors1), mean(errors2), 
                                    mean((rf_fit1$predicted - reg_data1$e_inc_100k)^2), 
                                    mean((rf_fit2$predicted - reg_data1$e_inc_100k)^2)))

saveRDS(error_tab, 'models/inc_model_comparison.rds')






# x = outcomes %>% filter(year==2015)
# View(x %>% select(starts_with('mdr'), starts_with('tbhiv')))
# xx = x %>% select(starts_with('mdr'), starts_with('tbhiv'))
# xx[is.na(xx)] = 0
# svd(xx)