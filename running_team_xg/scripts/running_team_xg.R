library(tidyverse)
library(lubridate)
library(gghighlight)

theme_set(theme_bw())

data <- read_csv("running_team_xg/data/team_stats_2017-10-16.csv")

df <- data %>%
  mutate(team = Team,
         date = ymd(Date),
         xg_pm = `xG+/-`,
         situation = "ES") %>% 
  select(situation, team, date, xg_pm) %>% 
  arrange(team, date) %>% 
  group_by(team) %>% 
  mutate(game_number = dense_rank(date),
         xg_pm_cum = cumsum(xg_pm))

df %>% 
  gghighlight_line(aes(game_number, xg_pm_cum, group = team), last(abs(xg_pm_cum)) > 2) +
  #scale_x_continuous(expand = c(0,0)) +
  labs(x = "Game Number",
       y = "Cumulative xG Differential")