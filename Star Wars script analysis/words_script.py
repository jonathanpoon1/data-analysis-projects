import os

file1 = open('SW_EpisodesIV-VI.txt', 'r')
file2 = open('SW_EpisodesIV-VI_words.txt','w')

firstline = True
count = 1
for line in file1:
    if not firstline:
        data = line.split("\"")

        #data[1] has the movie number
        
        #data[7] is the line of dialogue i want, need to split them all into words

        #remove all periods, commas, exclamation marks, question marks
        data[7] = (data[7].replace("."," "))
        data[7] = (data[7].replace(","," "))
        data[7] = (data[7].replace("!"," "))
        data[7] = (data[7].replace("?"," "))

        #now need to separate by whitespace
        data2 = data[7].split()

        for word in data2:
            word = word.lower()
            word = str(count) + "," + data[1] + "," + word
            word += "\n"
            file2.write(word)
            count += 1

    firstline=False

#close file1 and file2
file1.close()
file2.close()