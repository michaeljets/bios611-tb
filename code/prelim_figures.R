# Preliminary figures
# Author: Michael Jetsupphasuk

# =========================================================================


# Setup -------------------------------------------------------------------

library(tidyverse)

burden = read_csv('data/source_data/TB_burden_countries_2020-09-07.csv')
mdr_tb = read_csv('data/source_data/TB_dr_surveillance_2020-09-07.csv')


# Worldwide incidence over time -------------------------------------------

world_burden = burden %>%
  group_by(year) %>%
  summarize(incidence = (sum(e_inc_num) / sum(e_pop_num))*100000,
            incidence_low = (sum(e_inc_num_lo) / sum(e_pop_num))*100000,
            incidence_high = (sum(e_inc_num_hi) / sum(e_pop_num))*100000,
            deaths = (sum(e_mort_num) / sum(e_pop_num))*100000,
            deaths_low = (sum(e_mort_num_lo) / sum(e_pop_num))*100000,
            deaths_high = (sum(e_mort_num_hi) / sum(e_pop_num))*100000,)

gg_world_inc = ggplot(data = world_burden,
       mapping = aes(x = year)) +
  geom_point(aes(y = incidence)) +
  geom_line(aes(y = incidence)) + 
  geom_line(aes(y = incidence_low), linetype = 2) +
  geom_line(aes(y = incidence_high), linetype = 2) +
  labs(y = 'incidence per 100k',
       title = 'Figure 1: Worldwide incidence of TB per 100k from 2000-2018')

gg_world_deaths = ggplot(data = world_burden,
                         mapping = aes(x = year)) +
  geom_point(aes(y = deaths)) +
  geom_line(aes(y = deaths)) + 
  geom_line(aes(y = deaths_low), linetype = 2) +
  geom_line(aes(y = deaths_high), linetype = 2) +
  labs(y = 'deaths per 100k',
       title = 'Figure 2: Worldwide deaths from TB per 100k from 2000-2018')



# Incidence vs. population ------------------------------------------------

gg_pop1 = ggplot(burden %>% filter(year==2018),
       aes(x = e_pop_num, y = e_inc_100k)) +
  geom_point() +
  labs(x = 'population',
       y = 'incidence per 100k',
       title = 'Figure 2a: Incidence of TB per 100k compared against population, 2018')

gg_pop2 = ggplot(burden %>% filter(year==2018, !(country %in% c('China', 'India'))),
                 aes(x = e_pop_num, y = e_inc_100k)) +
  geom_point() +
  labs(x = 'population',
       y = 'incidence per 100k',
       title = 'Figure 2b: Incidence of TB per 100k compared against population, 2018 (China and India removed)')



# MDR-TB ------------------------------------------------------------------

mdr_tb2 = mdr_tb %>% filter(year==2018, mdr_dst_rlt>100) %>% arrange(desc(mdr_dst_rlt)) %>% mutate(country = factor(country, levels = country, ordered=T))

gg_mdr = ggplot(mdr_tb2,
       aes(x = country, y = mdr_dst_rlt)) +
  geom_bar(stat = 'identity') + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(x = 'country',
       y = 'MDR-TB cases',
       title = 'Figure 3: MDR-TB cases by country if cases > 100, in 2018')



# Save plots --------------------------------------------------------------

ggsave('figures/world_inc.png', gg_world_inc, width = 5, height = 3, units = 'in', scale = 2)
ggsave('figures/world_deaths.png', gg_world_deaths, width = 5, height = 3, units = 'in', scale = 2)
# ggsave('figures/incidence_pop_all.png', gg_pop1, width = 5, height = 3, units = 'in', scale = 2)
# ggsave('figures/incidence_pop_zoom.png', gg_pop2, width = 5, height = 3, units = 'in', scale = 2)
# ggsave('figures/mdr_counts_country.png', gg_mdr, width = 5, height = 3, units = 'in', scale = 2)
