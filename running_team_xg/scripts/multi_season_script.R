library(tidyverse)
library(lubridate)
library(gghighlight)

theme_set(theme_bw())

rm(list = ls())

files <- list.files(path = "running_team_xg/data", pattern = "season")
data <- lapply(paste0("running_team_xg/data/", files), read_csv)
names(data) <- list("2014_2015", "2015_2016", "2016_2017", "2017_2018")
names(data)
df <- bind_rows(data, .id = "season")

df <- df %>% 
  mutate(team = Team,
         date = ymd(Date),
         xg_pm = `xG+/-`,
         situation = "ES") %>% 
  select(season, situation, team, date, xg_pm) %>% 
  arrange(team, date) %>% 
  group_by(season, team) %>% 
  mutate(game_number = dense_rank(date),
         xg_pm_cum = cumsum(xg_pm)) %>% 
  ungroup() %>% 
  mutate(is_current_season = (season == "2017_2018"))

df %>% 
  #ungroup() %>% 
  filter(season == "2017_2018") %>% 
  gghighlight_line(aes(game_number, xg_pm_cum, group = team), last(abs(xg_pm_cum)) > 4) +
  geom_hline(yintercept = 0,
             size = .25,
             linetype = 2) +
  scale_x_continuous(expand = c(0.01,0),
                     breaks = 1:max(df$game_number)) +
  facet_wrap(~season,
             ncol = 1) +
  labs(x = "Game Number",
       y = "Cumulative xG Differential",
       caption = "@Null_HHockey, data from corsica.ca",
       title = "NHL",
       subtitle = "Even Strength") +
  theme(panel.grid.minor = element_blank())

df %>% 
  filter(season == "2017_2018") %>% 
  gghighlight_line(aes(game_number, xg_pm_cum, group = team), unique(team) == "VGK") +
  geom_hline(yintercept = 0,
             size = .25,
             linetype = 2) +
  scale_x_continuous(expand = c(0.01,0),
                     breaks = 1:max(df$game_number)) +
  facet_wrap(~season,
             ncol = 1) +
  labs(x = "Game Number",
       y = "Cumulative xG Differential")

df %>% 
  filter(team %in% c("PIT", "WSH", "CBJ", "CAR", "NYR", "NYI", "N.J", "PHI")) %>% 
  ggplot(aes(game_number, xg_pm_cum, color = season, alpha = is_current_season)) +
  geom_hline(yintercept = 0, 
             linetype = 2) +
  geom_line(size = 1) +
  #geom_point() +
  facet_wrap(~team) +
  scale_alpha_discrete(range = c(.25, 1)) +
  labs(x = "Game Number",
       y = "Cumulative xG Differential",
       caption = "@Null_HHockey, data from corsica.ca",
       title = "NHL",
       subtitle = "Even Strength")