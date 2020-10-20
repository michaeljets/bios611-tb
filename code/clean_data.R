# clean_data.R
# Read source data perform simple cleaning operations

# load libraries
source('code/load_libraries.R')

# read WHO data
burden = read_csv('data/source_data/TB_burden_countries_2020-09-07.csv')
mdr_tb = read_csv('data/source_data/TB_dr_surveillance_2020-09-07.csv')
outcomes = read_csv('data/source_data/TB_outcomes_2020-09-07.csv')
budget = read_csv('data/source_data/TB_budget_2020-09-07.csv')

# read World Bank data
country_indicators = read_csv('data/source_data/world_bank_data_2020-10-06.csv')

# last few lines are nothing, remove them
country_indicators = country_indicators %>% filter(!is.na(`Country Code`))

# convert WB data to be long
colnames(country_indicators) = c(colnames(country_indicators)[1:4], as.character(seq(2000, 2018, by=1)))
country_indicators = country_indicators %>%
  pivot_longer(`2000`:`2018`, names_to = 'year', values_to = 'value')

# clean up missing values
country_indicators = country_indicators %>%
  mutate(value = ifelse(value=='..', NA, value),
         value = as.numeric(value))

# remove indicators where there's not enough data and tb data
rm_ind = c('SE.ADT.LITR.ZS', 'SE.PRM.NENR', 'SI.POV.GINI', 'GC.DOD.TOTL.GD.ZS', 'VC.BTL.DETH', 
           'SH.XPD.CHEX.GD.ZS', 'SH.STA.DIAB.ZS', 'SH.DYN.AIDS.ZS', 'BN.CAB.XOKA.GD.ZS', 'SI.POV.MDIM.XQ', 
           'SI.POV.MDIM', 'SH.TBS.CURE.ZS', 'SH.HIV.ARTC.ZS', 'SH.HIV.INCD.ZS',
           'SH.TBS.INCD', 'SH.TBS.DTEC.ZS')
country_indicators = country_indicators %>% filter(!(`Series Code` %in% rm_ind))

# save it
write_csv(country_indicators, 'data/derived_data/country_indicators.csv')
