import pandas as pd

df = pd.read_csv('data.csv')

#end goal is to have games as columns, types as rows to see which games have how many pokemon as types

#replace "Trade/migrate from another game", "Not available in this game", and Na values with 0

df.replace('Trade/migrate from another game', 0, inplace=True)
df.replace('Not available in this game', 0, inplace=True)
df.fillna(0, inplace=True)

#try to replace all non-zero values in columns except first three with 1s 


#these taken from other python file 
games = ['Type', 'Red', 'Blue', 'Yellow', 'Gold', 'Silver', 'Crystal', 'Ruby', 'Sapphire', 'FireRed', 'LeafGreen',
           'Emerald', 'Diamond', 'Pearl', 'Platinum', 'HeartGold', 'SoulSilver', 'Black', 'White', 'Black 2', 'White 2',
             'X', 'Y', 'Omega Ruby', 'Alpha Sapphire', 'Sun', 'Moon', 'Ultra Sun', 'Ultra Moon', "Let's Go Pikachu", "Let's Go Eevee",
               'Sword', 'Shield', 'Brilliant Diamond', 'Shining Pearl', 'Legends: Arceus', 'Scarlet', 'Violet']

types_list = ['Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice', 'Fighting', 'Poison', 'Ground', 'Flying', 'Psychic',
               'Bug', 'Rock', 'Ghost', 'Dragon', 'Dark', 'Steel', 'Fairy']

new_df = pd.DataFrame(columns = games)

games.remove('Type')

for game in games:
    df[game] = df[game].where(df[game] == 0, 1)

#want to see data on those with only one type (second type will always be 'None')
types_list.append('None')

for type in types_list:
    #go through original df, if type is in type1 or type2, add 1
    new_row = []
    new_row.append(type)
    for game in games:
        total = 0
        for index, row in df.iterrows():
            if row['Type1'] == type or row['Type2'] == type:
                #iterate through columns after type2?
                total += row[game]     
        new_row.append(total)
    length = len(new_df)
    new_df.loc[length] = new_row

#want a total row at the end where it shows the total number of pokemon available in each game

total_row = []
total_row.append ("Total")
for game in games:
    total = 0
    for index, row in df.iterrows():
        total += row[game]
    total_row.append(total)

length = len(new_df)
new_df.loc[length] = total_row

#want a Total column that sums up all the other columns (except Type)
new_df['Total'] = ([0] * 20)

for game in games:
   new_df['Total'] = new_df['Total'] + new_df[game]

new_df.to_csv(r'C:\Users\jonat\Documents\to website\web scraping project (pokemon)\type_total_by_game.csv', index = False)

#want to have data with percentages instead of totals to compare

#save total row to add later
totals = new_df.iloc[19]

i=1
for column in new_df:
    if column != 'Type':
        new_df[column] = new_df[column] / new_df.iloc[19][i]
        i += 1

new_df.loc[19] = totals

new_df.to_csv(r'C:\Users\jonat\Documents\to website\web scraping project (pokemon)\type_percentages_by_game.csv', index = False)