select top 10 * from dbo.mytable

--cleaning data

alter table dbo.mytable
drop column event_id, event_start_date, event_end_date, stage_start_date, stage_end_date, map_id, ballchasing_id;

alter table dbo.blue_teams
drop column team_id, team_slug,	ball_possession_time,	ball_time_in_side,	core_shots,	core_goals,	core_saves,	core_assists,	core_score,	core_shooting_percentage,
boost_bpm,	boost_bcpm,	boost_avg_amount,	boost_amount_collected,	boost_amount_stolen,	boost_amount_collected_big,	boost_amount_stolen_big,	boost_amount_collected_small,
boost_amount_stolen_small,	boost_count_collected_big,	boost_count_stolen_big,	boost_count_collected_small,	boost_count_stolen_small,	boost_amount_overfill,	boost_amount_overfill_stolen,
boost_amount_used_while_supersonic,	boost_time_zero_boost,	boost_time_full_boost,	boost_time_boost_0_25,	boost_time_boost_25_50,	boost_time_boost_50_75,	boost_time_boost_75_100,
movement_total_distance,	movement_time_supersonic_speed,	movement_time_boost_speed,	movement_time_slow_speed,	movement_time_ground,	movement_time_low_air,	movement_time_high_air,
movement_time_powerslide,	movement_count_powerslide,	positioning_time_defensive_third,	positioning_time_neutral_third,	positioning_time_offensive_third,	positioning_time_defensive_half,
positioning_time_offensive_half,	positioning_time_behind_ball,	positioning_time_in_front_ball,	demo_inflicted,	demo_taken;

alter table dbo.orange_teams
drop column team_id, team_slug,	ball_possession_time,	ball_time_in_side,	core_shots,	core_goals,	core_saves,	core_assists,	core_score,	core_shooting_percentage,
boost_bpm,	boost_bcpm,	boost_avg_amount,	boost_amount_collected,	boost_amount_stolen,	boost_amount_collected_big,	boost_amount_stolen_big,	boost_amount_collected_small,
boost_amount_stolen_small,	boost_count_collected_big,	boost_count_stolen_big,	boost_count_collected_small,	boost_count_stolen_small,	boost_amount_overfill,	boost_amount_overfill_stolen,
boost_amount_used_while_supersonic,	boost_time_zero_boost,	boost_time_full_boost,	boost_time_boost_0_25,	boost_time_boost_25_50,	boost_time_boost_50_75,	boost_time_boost_75_100,
movement_total_distance,	movement_time_supersonic_speed,	movement_time_boost_speed,	movement_time_slow_speed,	movement_time_ground,	movement_time_low_air,	movement_time_high_air,
movement_time_powerslide,	movement_count_powerslide,	positioning_time_defensive_third,	positioning_time_neutral_third,	positioning_time_offensive_third,	positioning_time_defensive_half,
positioning_time_offensive_half,	positioning_time_behind_ball,	positioning_time_in_front_ball,	demo_inflicted,	demo_taken;


--different regions only play each other at lan, so remove all online games

delete from dbo.mytable 
where stage_is_lan like 'False'


-- have to add data, some is missing 
-- for blue_teams, all NULL values in team_region should be Middle East & North Africa

update dbo.blue_teams
set team_region = 'Middle East & North Africa'
where team_region is null

-- for orange teams, The Club and Falcons are missing, should be South America and Middle East & North Africa

update dbo.orange_teams
set team_region = 'Middle East & North Africa'
where team_name = 'TEAM FALCONS'

update dbo.orange_teams
set team_region = 'South America'
where team_name = 'THE CLUB'

-- test to make sure no more null values exist
select * from dbo.blue_teams where team_region is null
select * from dbo.orange_teams where team_region is null

--need to rename column names in blue_teams and orange_team to prepare for joins
-- could be done manually through object explorer

--need to merge tables by game_id in order to see who played who and which teams won

select * into main_table from 
(select dbo.mytable.game_id, dbo.blue_teams.blue_team_name, dbo.blue_teams.blue_team_region, dbo.blue_teams.blue_winner,
dbo.orange_teams.orange_team_name, dbo.orange_teams.orange_team_region, dbo.orange_teams.orange_winner
from dbo.mytable
inner join dbo.blue_teams on dbo.mytable.game_id = dbo.blue_teams.game_id 
inner join dbo.orange_teams on dbo.mytable.game_id = dbo.orange_teams.game_id) t

select top 10 * from dbo.main_table


--as an example, we want to see how north america does against other regions

select count(*) as NorthAmerica_Wins
from dbo.main_table
where (blue_team_region = 'North America' and blue_winner = 'TRUE' and orange_team_region != 'North America')
or ((orange_team_region = 'North America' and orange_winner = 'TRUE' and blue_team_region != 'North America'))

select count(*) as NorthAmerica_Losses
from dbo.main_table
where (blue_team_region = 'North America' and blue_winner = 'FALSE' and orange_team_region != 'North America')
or ((orange_team_region = 'North America' and orange_winner = 'FALSE' and blue_team_region != 'North America'))

-- need to do it this way because North America can play against another North America team, need to not include those rows

select(
select count(*)from dbo.main_table
where (blue_team_region = 'North America' and orange_team_region != 'North America')) +
(select count(*) from dbo.main_table
where (orange_team_region = 'North America' and blue_team_region != 'North America')) as NorthAmerica_Games

select
((select count(*) as NorthAmerica_Wins
from dbo.main_table
where (blue_team_region = 'North America' and blue_winner = 'TRUE' and orange_team_region != 'North America')
or ((orange_team_region = 'North America' and orange_winner = 'TRUE' and blue_team_region != 'North America'))) * 2.0) /
((select(
select count(*)from dbo.main_table
where (blue_team_region = 'North America' and orange_team_region != 'North America')) +
(select count(*) from dbo.main_table
where (orange_team_region = 'North America' and blue_team_region != 'North America')) as NorthAmerica_Games) * 2.0) as NorthAmerica_WinPercentage

--region v region comparison

select count(*) as NorthAmerica_Wins_Against_Europe
from dbo.main_table
where (blue_team_region = 'North America' and blue_winner = 'TRUE' and orange_team_region = 'Europe')
or ((orange_team_region = 'North America' and orange_winner = 'TRUE' and blue_team_region = 'Europe'))

select count(*) as NorthAmerica_Losses_Against_Europe
from dbo.main_table
where (blue_team_region = 'North America' and blue_winner = 'FALSE' and orange_team_region = 'Europe')
or ((orange_team_region = 'North America' and orange_winner = 'FALSE' and blue_team_region = 'Europe'))


select(
select count(*)from dbo.main_table
where (blue_team_region = 'North America' and orange_team_region = 'Europe')) +
(select count(*) from dbo.main_table
where (orange_team_region = 'North America' and blue_team_region = 'Europe')) as NorthAmerica_Games_Against_Europe

select
((select count(*) as NorthAmerica_Wins
from dbo.main_table
where (blue_team_region = 'North America' and blue_winner = 'TRUE' and orange_team_region = 'Europe')
or ((orange_team_region = 'North America' and orange_winner = 'TRUE' and blue_team_region = 'Europe'))) * 2.0) /
((select(
select count(*)from dbo.main_table
where (blue_team_region = 'North America' and orange_team_region = 'Europe')) +
(select count(*) from dbo.main_table
where (orange_team_region = 'North America' and blue_team_region = 'Europe')) as NorthAmerica_Games) * 2.0) as NorthAmerica_WinPercentage_Against_Europe
