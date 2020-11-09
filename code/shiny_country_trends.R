# shiny_country_trends.R
# Builds a shiny app that shows time trends by country

# handle command line arguments
args = commandArgs(trailingOnly=T)
port = as.numeric(args[[1]])

# set up
source('code/load_libraries.R')

# load data
burden = read_csv('data/source_data/TB_burden_countries_2020-09-07.csv')
tb_data = read_csv('data/derived_data/reg_data.csv')

# join data
tb_data = left_join(tb_data, burden %>% select(country, year, e_inc_100k_lo, e_inc_100k_hi,
                                               e_mort_100k, e_mort_100k_lo, e_mort_100k_hi))

# create an overall incidence row
world_burden = burden %>%
  group_by(year) %>%
  summarize(e_inc_100k = (sum(e_inc_num) / sum(e_pop_num))*100000,
            e_inc_100k_lo = (sum(e_inc_num_lo) / sum(e_pop_num))*100000,
            e_inc_100k_hi = (sum(e_inc_num_hi) / sum(e_pop_num))*100000,
            e_mort_100k = (sum(e_mort_num) / sum(e_pop_num))*100000,
            e_mort_100k_lo = (sum(e_mort_num_lo) / sum(e_pop_num))*100000,
            e_mort_100k_hi = (sum(e_mort_num_hi) / sum(e_pop_num))*100000) %>%
  mutate(country = 'World')

world_indicators = tb_data %>%
  group_by(year) %>%
  summarize(NY.GDP.PCAP.KD = sum(NY.GDP.PCAP.KD),
            SP.POP.TOTL = sum(SP.POP.TOTL))

tb_data = bind_rows(tb_data, left_join(world_burden, world_indicators))

# make year an integer
tb_data = tb_data %>% mutate(year = as.integer(year))


# UI ----------------------------------------------------------------------

ui <- fluidPage(
  
  # App title ----
  titlePanel("TB statistics over time by country"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      # div("How do super hero powers depend on their moral alignment?"),
      
      # Input:
      selectInput('country', 'Country', unique(tb_data$country), selected = 'World'),
      
      sliderInput("year", label = "Year", min = 2000, 
                  max = 2018, value = c(2000, 2018))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: 
      plotOutput("all_plots")
      
    )
  )
)


# Server ------------------------------------------------------------------

server <- function(input, output) {
  
  output$all_plots <- renderPlot({
    
    # convert min/max years to a range
    years = input$year
    all_years = seq(years[1], years[2], by = 1)
    
    # filter data accordingly
    tmp_dat = tb_data %>% filter(country==input$country, year %in% all_years)
    
    # make incidence plot
    gg_inc = ggplot(data = tmp_dat, 
                    mapping = aes(x = year)) +
      geom_point(aes(y = e_inc_100k)) +
      geom_line(aes(y = e_inc_100k)) + 
      geom_line(aes(y = e_inc_100k_lo), linetype = 2) +
      geom_line(aes(y = e_inc_100k_hi), linetype = 2) +
      labs(title = 'TB Incidence per 100k', y = '', x = '')
    
    # make deaths plot
    gg_deaths = ggplot(data = tmp_dat, 
                       mapping = aes(x = year)) +
      geom_point(aes(y = e_mort_100k)) +
      geom_line(aes(y = e_mort_100k)) + 
      geom_line(aes(y = e_mort_100k_lo), linetype = 2) +
      geom_line(aes(y = e_mort_100k_hi), linetype = 2) +
      labs(title = 'TB Deaths per 100k', y = '', x = '')
    
    # make population plot
    gg_pop = ggplot(data = tmp_dat, 
                    mapping = aes(x = year)) +
      geom_point(aes(y = SP.POP.TOTL)) +
      geom_line(aes(y = SP.POP.TOTL)) + 
      labs(title = 'Population', y = '', x = '')
    
    # make gdp plot
    gg_gdp = ggplot(data = tmp_dat, 
                    mapping = aes(x = year)) +
      geom_point(aes(y = NY.GDP.PCAP.KD)) +
      geom_line(aes(y = NY.GDP.PCAP.KD)) + 
      labs(title = 'GDP', y = '', x = '')
    
    # combine plots
    gg_all = grid.arrange(grobs = list(gg_inc, gg_deaths, gg_pop, gg_gdp), nrow = 2, ncol = 2)
    
    # print
    print(gg_all)
    
  })
  
}


# Run app -----------------------------------------------------------------

print(sprintf("Starting shiny on port %d", port))
shinyApp(ui = ui, server = server, options = list(port=port, host="0.0.0.0"))
# shinyApp(ui = ui, server = server)