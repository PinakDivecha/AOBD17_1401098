import csv
import re
import codecs
from collections import Counter
#s = "Java (8 years), Javascript (5 years), Css (5 years), Html (5 years), Angularjs (2 years), Jquery (5 years), junit (8 years), Seleniun (5 years)"
#s = s.split(',' )
#print s[3]

#c_reader = csv.reader(open('result.csv', 'r'), delimiter=',')
# say you want the second column, only...
#col_2 = list(zip(*c_reader))[1] # keeping in mind that python is 0-indexed
# or if you want to come back for more later on, you can just do...
#columns = list(zip(*c_reader))


import csv

with open('Senior Software Engineer.csv', 'rb') as f:
    c_id=[]
    skill=[]
    combine=[]
    combinen=[]
    sepskill=[]
    python = 0
    C = 0
    cplus = 0
    matlab = 0
    Java = 0
    
    reader = csv.reader(f, delimiter=',')
    for column in reader:
        c_id.append(column[0])
        skill.append(column[2])
    combine=zip(c_id,skill)
    for i in range(len(skill)):
        sepskill.append(skill[i].split(','))
    combinen=zip(c_id,sepskill)
    for elem in combinen:
        print elem 

    #print combinen[3][1][1]
    #print combinen[5][1][0]
    #print len(skill)

    #vat= "vatsalpatel"
    #if "vat" in vat:
    #    print "successful"

    #print combinen[1][1][0]
    #if 'C'  in combinen[1][1][0]:
    #    print "It detects"
    
    #for j in range(len(skill)):
    #    if ' python' in combinen[j][1][0:] or 'python' in combinen[j][1][0:]:
    #        python = python + 1

    #for k in range(len(skill)):
    #    if ' Java' in combinen[k][1][0:] or 'Java' in combinen[k][1][0:]: 
    #        Java = Java + 1
            
    #for j in range(len(skill)):
    #    print combinen[j][1][0:]
    #    if 'C (1 year)' in combinen[j][1][0:] or 'C' in combinen[j][1][0:]:
    #        C = C + 1
        #if re.match(r'^C', combinen[j][1][0:]):
            
#print "Python user: " , python
#print "C user: " , C
#print "Java user: " , Java

with open("new.csv", "wb") as f:
    writer = csv.writer(f, delimiter=',')
    writer.writerows(combinen)
