from bs4 import BeautifulSoup
import requests
import pandas as pd

#changes to the pokemon list in order to use their urls

#replace nidoran symbols with -f, -m
#remove farfetch'd apostrophe (and sirfetch'd)
#replace mr.mime with mr-mime, mime jr. with mime-jr, same with mr. rime
#flabébé with flabebe
#type: null with type-null

#summary: remove apostrophe, colons, periods
#replace spaces with -, é with e
#nidoran symbols done manually
pokemon_list = []
f = open('pokemon list.txt')
for x in f:
    line = x.replace("Ã©", "e").replace(" ","-").replace("'","").replace(":","").replace(".","")
    pokemon_list.append(line)

df = pd.DataFrame()
for pokemon in pokemon_list:
    pokemon = pokemon.strip()
    url = 'https://pokemondb.net/pokedex/' + pokemon
    page = requests.get(url)
    #just to see which pokemon doesnt work
    print(pokemon)

    soup = BeautifulSoup(page.text,features="html.parser")

    #since each pokemon has a different number of forms, the table we are looking for later will not always be the second one,
    #thus we need to count each pokemon's number of forms
    forms_table = soup.find_all('div', class_ = 'sv-tabs-tab-list')[0]

    forms = forms_table.find_all('a')
    forms_count = len(forms)

    table = soup.find_all('div', class_ = 'grid-col span-md-12 span-lg-8')[forms_count]

    for br in table.find_all("br"):
        br.replace_with("\n")

    games = table.find_all('th')
    games2 = [title.text.splitlines() for title in games]
    games3 = [item for sublist in games2 for item in sublist]
    games3.insert(0,'Name')

    locations = table.find_all('tr')

    #have a dictionary, with keys being the games, values being their location
    #dictionary should have 38 elements 
    values = [None] * 38
    dictionary = dict(zip(games3, values)) 

    #go through locations, for each game, put the data in the dictionary

    table_rows = [title.text.strip() for title in locations]

    pairs_list = []

    for x in table_rows:
        newlines = len(x.splitlines()) - 1

        for y in range(newlines):
            pair = {x.splitlines()[y]:x.splitlines()[newlines]}
            pairs_list.append(pair)

    #add values to dictionary
    for x in pairs_list:
        dictionary.update(x)

    pair = {'Name':pokemon}
    dictionary.update(pair)

    #this table will find us each pokemon's type(s)
    table2 = soup.find_all('table', class_ = 'vitals-table')[0]

    type1 = table2.find_all('a')[0].text
    type2 = table2.find_all('a')[1].text

    types_list = ['Normal','Fire','Water','Electric','Grass','Ice','Fighting','Poison','Ground','Flying','Psychic','Bug','Rock','Ghost','Dragon','Dark','Steel','Fairy']

    #if the pokemon only has one type, type2 will be something else, we can just set it to 'None'
    if type2 not in types_list:
        type2 = 'None'

    pair1 = {'Type1': type1}
    pair2 = {'Type2': type2}
    dictionary.update(pair1)
    dictionary.update(pair2)

    temp_df = pd.DataFrame([dictionary])

    df = pd.concat([df, temp_df], ignore_index=True)


#rearrange the dataframe to make Name, Type1, Type2 be the first 3 columns respectively
names = df.pop("Name")
df.insert(0,"Name", names)
type1s = df.pop("Type1")
df.insert(1,"Type1", type1s)
type2s = df.pop("Type2")
df.insert(2,"Type2", type2s)

print(df)
df.to_csv(r'C:\Users\jonat\Documents\to website\web scraping project (pokemon)\data.csv', index = False)