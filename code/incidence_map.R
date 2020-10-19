# incidence_map.R
# Maps of TB incidence

# set up
source('code/load_libraries.R')
source('code/clean_data.R')

# load world data
world = ne_countries(scale = 'medium', returnclass = 'sf')

# join data of interest
world_inc_allyears = world %>% right_join(burden %>% select(iso3, year, e_inc_100k), by = c('iso_a3' = 'iso3'))

# some country-years are missing - fill them in
world_inc_allyears = world_inc_allyears %>%
  mutate(countryyear = paste0(iso_a3, '-', year))

# plot incidence maps for all years
gg_inc_maps = ggplot(data = world_inc_allyears) +
  geom_sf(aes(fill = e_inc_100k), size = 0.25) +
  scale_fill_viridis_c(option = 'plasma', trans = 'sqrt') + 
  facet_wrap(vars(year), ncol=4, drop=T) +
  labs(title = 'Estimated incidence per 100k') +
  theme(legend.position = 'bottom',
        legend.title = element_blank(),
        legend.key.width = unit(0.1, 'npc'),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# save it
ggsave('figures/incidence_maps.png', plot = gg_inc_maps, scale = 1.5)

# also do a version of the most recent data
gg_inc_maps_2018 = ggplot(data = world_inc_allyears %>% filter(year==2018)) +
  geom_sf(aes(fill = e_inc_100k), size = 0.5) +
  scale_fill_viridis_c(option = 'plasma', trans = 'sqrt') + 
  labs(title = 'Estimated incidence per 100k, 2018') +
  theme(legend.position = 'bottom',
        legend.title = element_blank(),
        legend.key.width = unit(0.1, 'npc'))

# save it
ggsave('figures/incidence_maps_2018.png', plot = gg_inc_maps_2018, scale = 1.5)
