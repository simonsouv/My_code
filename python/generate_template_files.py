import re, os.path
from shutil import copyfile
from string import Template

def addToListAndCopyFile(dest_l,source_f):
    dest_f = re.sub(r".*\\(?P<keep>fs\\public\\.*)$",\
                    r"D:\\Tmp\\UBS_RC\\app\\\g<keep>",source_f)
    dest_l.append(dest_f)
    copyfile(source_f,dest_f)

############
### MAIN ###
############

mxres_files_list = []
jms_files_list = []
db_files_list = []
sourceDir='D:\\Murex\\UBS_RC\\ubsrc\\appdir\\'
targetDir='D:\\Tmp\\UBS_RC\\app\\'
rootDir = sourceDir + 'fs\\public\\mxres\\mxinterfaces\\ubs\\'

# regexp pattern used for search
jms_pattern_to_detect_file = re.compile(r"<Property name=\"JMS Provider\">")
db_pattern_to_detect_file = re.compile(r"<Property name=\"JDBC url\">")
jms_pattern_factory = re.compile(r"""
                                  (?P<bef>\s*?\<Item\s+value=")
                                  .*?
                                  (?P<aft>"\s+key="java.naming.factory.initial"/>)
                                  """, re.MULTILINE|re.VERBOSE)
jms_pattern_provider = re.compile(r"""
                                  (?P<bef>\s*?\<Item\s+value=")
                                  .*?
                                  (?P<aft>"\s+key="java.naming.provider.url"/>)
                                  """, re.MULTILINE|re.VERBOSE)
jms_pattern_user = re.compile(r"""
                                  (?P<bef>\s*\<Item\s+value=")
                                  .*?
                                  (?P<aft>"\s+key="java.naming.security.principal"/>)
                                  """, re.MULTILINE|re.VERBOSE)
jms_pattern_pwd = re.compile(r"""
                                  (?P<bef>\s*\<Item\s+value=")
                                  .*?
                                  (?P<aft>"\s+key="java.naming.security.credentials"/>)
                                  """, re.MULTILINE|re.VERBOSE)
db_pattern_driver = re.compile(r"""
                                  (?P<bef>\s*<Property\s+name="Driver\sclass\sname">)
                                  .*?
                                  (?P<aft></Property>)
                                  """, re.MULTILINE|re.VERBOSE)
db_pattern_url = re.compile(r"""
                                  (?P<bef>\s*<Property\s+name="JDBC\surl">)
                                  .*?
                                  (?P<aft></Property>)
                                  """, re.MULTILINE|re.VERBOSE)
db_pattern_user = re.compile(r"""
                                  (?P<bef>\s*<Property\s+name="User\sname">)
                                  (?P<user>.*?)
                                  (?P<aft></Property>)
                                  """, re.MULTILINE|re.VERBOSE)
db_pattern_pwd = re.compile(r"""
                                  (?P<bef>\s*<Property\s+name="Password">)
                                  .*?
                                  (?P<aft></Property>)
                                  """, re.MULTILINE|re.VERBOSE|re.DOTALL)

# get the list of .mxres files
print("get the list of mxres files from source dir: {}".format(rootDir))
for dirName, subdirList, fileList in os.walk(rootDir):
    for fname in fileList:
        if 'mxres' in fname:
            mxres_files_list.append(os.path.join(dirName,fname))

# search files related to JMS or DB files to be copied in our working dir
print("classify .mxres files as jms or db files")
for file in mxres_files_list:
    with open(file,'r') as f:
        input = f.read()
    if jms_pattern_to_detect_file.search(input):
        addToListAndCopyFile(jms_files_list,file)
    if db_pattern_to_detect_file.search(input):
        addToListAndCopyFile(db_files_list,file)

# replace values in every template file
print("Templatize .mxres files corresponding to jms task")
for file in jms_files_list:
    with open(file,'r') as f:
        input = f.read()
    input = jms_pattern_factory.sub(r"\g<bef>${jms_factory}\g<aft>",input)
    input = jms_pattern_provider.sub(r"\g<bef>${jms_url}\g<aft>",input)
    input = jms_pattern_user.sub(r"\g<bef>${jms_user}\g<aft>",input)
    input = jms_pattern_pwd.sub(r"\g<bef>${jms_password}\g<aft>",input)
    target_file = file.replace('.mxres','.template')
    with open(target_file,'w') as f:
        f.write(input)
    del input
print("Templatize .mxres files corresponding to db task")
for file in db_files_list:
    with open(file,'r') as f:
        input = f.read()
    db_type='mx'
    if '_DM' in db_pattern_user.search(input).group("user"):
        db_type='dm'
    temp_dict = {}
    temp_dict[db_pattern_url] = r"\g<bef>${db_jdbc_url_" + db_type + r"}\g<aft>"
    temp_dict[db_pattern_user] = r"\g<bef>${db_user_" + db_type + r"}\g<aft>"
    temp_dict[db_pattern_pwd] = r"\g<bef>${db_password_" + db_type + r"}\g<aft>"
    input = db_pattern_url.sub(temp_dict[db_pattern_url],input)
    input = db_pattern_user.sub(temp_dict[db_pattern_user],input)
    input = db_pattern_pwd.sub(temp_dict[db_pattern_pwd],input)
    target_file = file.replace('.mxres','.template')
    with open(target_file,'w') as f:
        f.write(input)
