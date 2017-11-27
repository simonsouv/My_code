import sys, os, fnmatch, re
# --- FUNCTIONS ---
def exit_on_error(errMsg):
    print(errMsg)
    exit()

def check_args():
    if len(sys.argv) < 2:
        exit_on_error("The script needs one argument:\n  -directory containing"+
              "import log files and Config tempaltes xml files")

def folder_exists(folder):
    if not os.path.exists(folder):
        exit_on_error("Directory {} does not exist".format(folder))

def read_file(file):
    if not os.path.isfile(file):
        exit_on_error("File {} does not exist".format(file))
    with open(file,'r') as f:
        content = f.read()
    return content

def find_zipFile_name(input):
    zipPat = re.compile(r'Read file from .*[\./](?P<zipFile>\w*\.zip$)', re.MULTILINE)
    return zipPat.search(input).group("zipFile")

def find_template_name(input):
    templatePat = re.compile(r'Template Name: (?P<templateName>\w+)')
    return templatePat.search(input).group("templateName")

def find_config_imported(input):
    configPat = re.compile('''
                           INFO\s-\s\[START\]\sMX
                           (?P<objName>.*)-(?P<objId>.*)
                           ''', re.VERBOSE)
    return configPat.finditer(input)

def find_config_defined(input):
    configPat = re.compile(r"""
                             <configuration-item\sname="
                             (?P<objName>((\w+(\s\w+)*)\.)+(\w+(\s\w+)*))"\s
                             object-id="(?P<objId>CM\.\d{1,3})
                            """, re.DOTALL | re.VERBOSE)
    return configPat.finditer(input)

def check_config_already_imported(input,config):
    #print("Inside function check_config_already_imported: {}".format(config))
    pattern="Item "+config+".*was already imported and will be skipped"
    configPat = re.compile(pattern)
    return configPat.search(input)

def get_file_list(dir,ext):
    list_of_all_files = os.listdir(dir)
    return [ entry for entry in list_of_all_files \
            if fnmatch.fnmatch(entry, ext) ]

def compare_xml_log(dir,logFile,zipFile,xmlTemplate,xmlDict,logDict,logContent):
    with open(os.path.join(dir, 'result_diff.csv'), 'a+') as f:
        #f.write("log file;zip file;template name;missing object\n")
        imported = sorted(logDict.keys())
        defined = sorted(xmlDict.keys())
        diff = set(defined) - set(imported)
        if diff:
            for i in diff:
                if not check_config_already_imported(logContent,i):
                    f.write("{};{};{};{};\n".\
                             format(logFile,zipFile,xmlTemplate,i))
                else:
                    f.write("{};{};{};{};already imported\n".\
                             format(logFile,zipFile,xmlTemplate,i))

# --- MAIN ---
check_args()
folder_exists(sys.argv[1])
rootDir = sys.argv[1]
logFiles = get_file_list(rootDir,"*.log")
templateFiles = get_file_list(rootDir,"*.xml")

with open(os.path.join(rootDir, 'result_diff.csv'), 'w') as f:
    f.write("log file;zip file;template name;missing object;comment\n")

for currentLog in logFiles:
    print("current log file: {}".format(currentLog))
    resultsLog = {}
    resultsTemplate = {}
    contentLog = read_file(os.path.join(rootDir,currentLog))
    zipImported = find_zipFile_name(contentLog)
    templateImported = find_template_name(contentLog) + ".xml"
    if (not zipImported) or (not templateImported):
        print("Log file {}\nCannot find .zip and template references".
              format(currentLog))
        continue
    contentTemplate = read_file(os.path.join(rootDir,templateImported))
    for m in find_config_imported(contentLog):
        #print("Item found: {}".format(match.group("objName")))
        resultsLog[m.group("objId")] = m.group("objName")
    for m in find_config_defined(contentTemplate):
        resultsTemplate[m.group("objId")] = m.group("objName")
    print("  Objects imported: {}".format(sorted(resultsLog.keys())))
    print("  Objects defined : {}".format(sorted(resultsTemplate.keys())))
    compare_xml_log(rootDir,currentLog, zipImported, templateImported, \
                    resultsTemplate, resultsLog, contentLog)
print("Check content of file result_diff.csv in "+rootDir)
