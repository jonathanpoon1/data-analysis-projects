import os

#open file1 in reading mode
file1 = open('SW_EpisodeIV.txt', 'r')
#open file2 in writing mode
file2 = open('SW_EpisodesIV-VI.txt','w')

#dont want the firstline (with headers) being used since it has no dialogue
firstline = True
for line in file1:
    if not firstline:
        line = '"IV" ' + line
        file2.write(line)
    else:
        line = '"movie number"' + line
        file2.write(line)
        firstline = False
    
#close file1 
file1.close()

file1 = open('SW_EpisodeV.txt', 'r')
firstline = True
for line in file1:
    if not firstline:
        line = '"V" ' + line
        file2.write(line)
    firstline = False

file1.close()

file1 = open('SW_EpisodeVI.txt', 'r')
firstline = True
for line in file1:
    if not firstline:
        line = '"VI" ' + line
        file2.write(line)
    firstline = False

#close file1 and file2
file1.close()
file2.close()