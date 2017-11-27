import sys, os, fnmatch
from xml.etree import ElementTree

if len(sys.argv) < 2:
    print("The script needs one argument corresponding to the directory containing the .mxres files")
    exit()

if not os.path.exists(sys.argv[1]):
    print("Directory {} does not exist".format(sys.argv[1]))
    exit()

rootDir=sys.argv[1]
listF = []
nickNames = {}

# get list of .mxres file in the current directory
listOfFiles = os.listdir(rootDir) 
pattern = "*.mxres"

for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        listF.append(entry)
#print (listF)

# for each file we check the different nicknames declared
# we generate a dictionary having:
# key: NickName value
# value: list of files where the key is referenced
for currF in listF:
    #print("current file: {}. Type: {}".format(currF, type(currF)))
    with open(os.path.join(rootDir, currF),'r') as f:
        xml = ElementTree.parse(f)
    for node in xml.iter('NickName'):
        if not node.text in nickNames:
            nickNames[node.text] = []
        nickNames[node.text].append(currF)

#print (nickNames)

# print a message is a nickName is defined in several files
for item in nickNames:
    if len(nickNames[item])>1:
        print ("Nickname {} is defined in files {}". format(item, nickNames[item]))