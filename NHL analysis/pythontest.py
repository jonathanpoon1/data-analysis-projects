import pandas as pd
import matplotlib.pyplot as plt

#data is list of games from 2000 to 2020 (2004-2005 season was not played), playoffs started being tracked in 2010-2011 season
data = pd.read_csv('game.csv')

#data has duplicate game ids
data.drop_duplicates(inplace = True)

#select only those where Toronto plays
data = data[(data.away_team_id == 10) | (data.home_team_id == 10)] 
data.sort_values(by=['game_id'],inplace=True)

#since outcome shows if it was on in ot or not, can use this to see how many points they get per season

#add points column
print(data)
data = data.drop(columns=['venue_link','venue_time_zone_id', 'venue_time_zone_offset', 'venue_time_zone_tz', 'home_rink_side_start'])
print(data)

all_games = data

def point(row):
    if row['type'] == 'P':
        return 0
    if row['away_team_id'] == 10:
        #toronto is away team
        if row['outcome'] == 'home win REG':
            return 0
        if (row['outcome'] == 'away win REG') | (row['outcome'] == 'away win OT') | (row['outcome'] == 'away win tbc'):
            return 2
        else:
            return 1
    else:
        #toronto is home team
        if row['outcome'] == 'away win REG':
            return 0
        if (row['outcome'] == 'home win REG') | (row['outcome'] == 'home win OT') | (row['outcome'] == 'home win tbc'):
            return 2
        else:
            return 1
                   
data["points"]=data.apply(point, axis=1)
print(data)
#same points as https://records.nhl.com/franchises/toronto-maple-leafs/season-by-season-record
data = data.groupby(['season'])['points'].sum()
print(data)

#want to graph points per game per season
#need a count of how many regular season games were played each season
regular_games = all_games
regular_games = regular_games[(regular_games.type == 'R')]
print(regular_games)
regular_games_counts = regular_games.season.value_counts(sort=False)
print(regular_games_counts)

points_per_season = pd.concat([data,regular_games_counts],axis=1)
print(points_per_season)
points_per_season['avg points'] = points_per_season.apply(lambda x: x.points/x.season, axis=1)
print(points_per_season)
index = list(range(20))
index = [x+2000 for x in index]
index.remove(2004)
print(index)

points_per_season['Season'] = index

points_per_season.set_index('Season', inplace = True)

print (points_per_season)
points_per_season['avg points'].plot(xticks=index)
plt.xlabel('Season')
plt.ylabel('Points per game')
plt.show()

#want to see how well they do in each arena, see if there are arenas they do better than others
arena_counts = regular_games.venue.value_counts(sort=True)
print(arena_counts)

#want to remove arenas with less than 10 games played

arena_counts = arena_counts[arena_counts.values >= 10]
print(arena_counts)
#need total points played in each arena
arena_points = regular_games.groupby(['venue'])['points'].sum()
print(arena_points)
main = pd.concat([arena_points,arena_counts],axis=1)
print(main)
#need to drop rows with Na values
main = main.dropna()
main['avg points'] = main.apply(lambda x: x.points/x.venue, axis=1)
main =  main.sort_values(by=['avg points'], ascending=False)
main.rename(columns={'venue':'games'}, inplace=True)
print(main.to_string())
