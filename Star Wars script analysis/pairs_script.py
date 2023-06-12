import os

file1 = open('SW_EpisodesIV-VI.txt', 'r')
file2 = open('SW_EpisodesIV-VI_pairs.txt','w')

firstline = True
count = 1
for line in file1:
    if not firstline:
        data = line.split("\"")

        data[7] = (data[7].replace("."," "))
        data[7] = (data[7].replace(","," "))
        data[7] = (data[7].replace("!"," "))
        data[7] = (data[7].replace("?"," "))

        data2 = data[7].split()

        for i in range(len(data2)):
            #need to check if at the last word of a given line in the dialgue
            if ((i+1) < len(data2)):
                word = data2[i]
                pair = word + "," + data2[i+1]
                pair = pair.lower()
                pair += "\n"
                file2.write(pair)  
    firstline=False

file1.close()
file2.close()