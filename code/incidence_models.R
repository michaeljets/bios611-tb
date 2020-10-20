# incidence_models.R


# Setup -------------------------------------------------------------------

# read data
source('code/load_libraries.R')
burden = read_csv('data/source_data/TB_burden_countries_2020-09-07.csv')
country_indicators = read_csv('data/derived_data/country_indicators.csv')

# prep data for linear regression use
meta = country_indicators %>% select(`Series Name`, `Series Code`) %>% distinct()
country_indicators_wide = country_indicators %>%
  filter(`Series Code` != 'HD.HCI.OVRL') %>%
  select(-`Series Name`) %>%
  pivot_wider(names_from = `Series Code`, values_from = value)

# join in TB data
dat = inner_join(country_indicators_wide, 
                 burden %>% select(iso3, e_inc_100k, year), 
                 by = c('Country Code' = 'iso3', 'year'))

# drop observations with missingness and prep for model
reg_data = dat %>% 
  select(-`Country Code`) %>% 
  rename(country = `Country Name`) %>%
  mutate(year = factor(year)) %>% 
  drop_na()


# pairwise scatter plots for select features
select_indicators = c('NY.GDP.PCAP.KD', 'SP.POP.TOTL', 'SP.RUR.TOTL.ZS', 'SL.UEM.TOTL.ZS')
pairs(reg_data %>% filter(year=='2018') %>% select_at(c('e_inc_100k', select_indicators)), 
      labels = c('TB incidence', meta$`Series Name`[meta$`Series Code` %in% select_indicators]),
      main = 'Pairwise scatter plots, 2018 only')


# OLS ---------------------------------------------------------------------

# define a test/train sets
set.seed(73277711)
countries = unique(reg_data$country)
countries_holdout = countries[sample(1:length(countries), 35, replace = F)]
test_set = reg_data %>% filter(country %in% countries_holdout) %>% select(-country)
train_set = anti_join(reg_data, test_set) %>% select(-country)

# all predictors
lm_fit1 = lm(e_inc_100k ~ ., data = train_set)
summary(lm_fit1)

# only the five in the scatter plots + year
lm_fit2 = lm(e_inc_100k ~ ., data = train_set %>% select_at(c(select_indicators, 'year', 'e_inc_100k')))
summary(lm_fit2)

# without year fixed effects
lm_fit3 = lm(e_inc_100k ~ . -year, data = train_set)
summary(lm_fit3)

# # compare these three models using 5-fold cv error
# set.seed(78273498)
# k = 5
# 
# # define k folds
# n = nrow(reg_data)
# tmp_ind = c(rep(1:k, floor(n/k)), rep(1, n - k*floor(n/k)))
# k_folds_ind1 = sample(tmp_ind, n, replace=FALSE)
# k_folds_ind2 = sample(tmp_ind, n, replace=FALSE)
# k_folds_ind3 = sample(tmp_ind, n, replace=FALSE)
# 
# errors1 = c()
# errors2 = c()
# errors3 = c()
# for (i in 1:k) {
#   # define sets set
#   hold_out_dat1 = reg_data[k_folds_ind1==i, ]
#   train_dat1 = reg_data[k_folds_ind1!=i, ]
#   
#   hold_out_dat2 = reg_data[k_folds_ind2==i, ]
#   train_dat2 = reg_data[k_folds_ind2!=i, ]
#   
#   hold_out_dat3 = reg_data[k_folds_ind3==i, ]
#   train_dat3 = reg_data[k_folds_ind3!=i, ]
#   
#   # fit model on training
#   lm_tmp1 = lm(e_inc_100k ~ ., data = train_dat1 %>% select(-country))
#   lm_tmp2 = lm(e_inc_100k ~ ., data = train_dat2 %>% select_at(c(select_indicators, 'year', 'e_inc_100k')))
#   lm_tmp3 = lm(e_inc_100k ~ ., data = train_dat3 %>% select(-country, -year))
#   
#   # get predictions for test set
#   pred_tmp1 = predict(lm_tmp1, newdata = hold_out_dat1 %>% select(-country))
#   pred_tmp2 = predict(lm_tmp2, newdata = hold_out_dat2 %>% select_at(c(select_indicators, 'year', 'e_inc_100k')))
#   pred_tmp3 = predict(lm_tmp3, newdata = hold_out_dat3 %>% select(-country, -year))
#   
#   # get mean squared error
#   errors1[i] = mean((hold_out_dat1$e_inc_100k - pred_tmp1)^2)
#   errors2[i] = mean((hold_out_dat2$e_inc_100k - pred_tmp2)^2)
#   errors3[i] = mean((hold_out_dat3$e_inc_100k - pred_tmp3)^2)
# }
# 
# mean(errors1)
# mean(errors2)
# mean(errors3)



# Random forest -----------------------------------------------------------

# do a random forest for fun (rf has built-in validation to find best rf)
set.seed(7814173)

rf_fit1 = randomForest(e_inc_100k ~ ., data = train_set, ntree=500, mtry=3, importance=TRUE)  # default hyperparameters
rf_fit2 = randomForest(e_inc_100k ~ ., data = train_set, ntree=1000, mtry=3, importance=TRUE)
rf_fit3 = randomForest(e_inc_100k ~ ., data = train_set, ntree=1500, mtry=3, importance=TRUE)
rf_fit4 = randomForest(e_inc_100k ~ ., data = train_set, ntree=500, mtry=5, importance=TRUE)
rf_fit5 = randomForest(e_inc_100k ~ ., data = train_set, ntree=1000, mtry=5, importance=TRUE)
rf_fit6 = randomForest(e_inc_100k ~ ., data = train_set, ntree=1500, mtry=5, importance=TRUE)



# Model errors ------------------------------------------------------------

errors1 = mean((test_set$e_inc_100k - predict(lm_fit1, newdata = test_set))^2)
errors2 = mean((test_set$e_inc_100k - predict(lm_fit2, newdata = test_set))^2)
errors3 = mean((test_set$e_inc_100k - predict(lm_fit3, newdata = test_set))^2)

error_tab = data.frame(Model = c(rep('Linear regression', 3), 'Random forest', 'Naive'),
                       Features = c('All', 'Subset (see text)', 'All except year', 'All', 'None'),
                       Error = c(errors1, errors2, errors3, 
                                 mean((test_set$e_inc_100k - predict(rf_fit2, newdata = test_set))^2),
                                 mean((test_set$e_inc_100k - mean(train_set$e_inc_100k))^2)))


# Save --------------------------------------------------------------------

# scatter plot
png('figures/pair_scatter.png', width = 1100, height = 800)
pairs_labs = c('TB incidence', meta$`Series Name`[meta$`Series Code` %in% select_indicators])
pairs_labs[pairs_labs=="Unemployment, total (% of total labor force) (modeled ILO estimate)"] = "Unemployment, total (% of total labor force)\n(modeled ILO estimate)"
pairs(reg_data %>% filter(year=='2018') %>% select_at(c('e_inc_100k', select_indicators)), 
      labels = pairs_labs,
      main = 'Pairwise scatter plots, 2018 only',
      cex.labels = 1.2)
dev.off()

# data
write_csv(reg_data, 'data/derived_data/reg_data.csv')
write_csv(meta, 'data/derived_data/country_indicators_reg_meta.csv')

# models
saveRDS(list(lm_fit1, lm_fit2, lm_fit3, rf_fit2), 'models/models.rds')

# model comparison table
saveRDS(error_tab, 'models/inc_model_comparison.rds')
