import xml.etree.cElementTree as ET
import os, re,sys, glob, pprint
"""
Script checking if the definition of a launcher in 'public' section is importing
some 'slash' from the central file.
The good practice is to have in one place all slash that are used in different
anchors and import those anchors.
"""
pp = pprint.PrettyPrinter(indent=4)
root_dir = sys.argv[1] # folder $APP_DIR/fs/public/mxres/common
public_dir = os.path.join(root_dir,'fs/public/mxres/common')
murex_dir = os.path.join(root_dir,'fs/murex/mxres')

default_bin = re.compile(r'<DefaultBinary>mx<\/DefaultBinary>')
native_svc = dict()

# define a dictionary containing the list of nickName with binary of type mx
# dict key is folder name corresponding to <Code> value
# for each dir we look at launcher/launcher.mxres and store
# NickName as dic values
for dir in os.listdir(murex_dir):
    native_svc[dir.upper()] = []
    murex_launcher = os.path.join(murex_dir,dir,'launcher','launcher.mxres')
    try:
        with open(murex_launcher,'r') as f:
            content = f.read()
        if default_bin.search(content):
            #print 'native process found in ', murex_launcher
            tree = ET.ElementTree(file=murex_launcher)
            for elem in tree.iter(tag='AvailableProcess'):
                if elem.find('DefaultBinary') is not None:
                    native_svc[dir.upper()].append(elem.find('NickName').text)
    except:
        pass
#pp.pprint(native_svc)

for mxres_file in glob.glob(os.path.join(public_dir,'launcher*mxres')):
    #print '--',mxres_file
    tree = ET.ElementTree(file=mxres_file)
    for elem in tree.iter(tag='AvailableService'):
        #print 'Element: ', elem
        found = False
        for sub in elem.iterfind('Import/Customize/DefaultCommands/') :
            #print 'sub ', sub
            if (sub.tag == 'MxAnchor' or sub.tag == 'MxInclude') \
            and'public.mxres.common.common_anchors.mxres' in sub.attrib['MxAnchor'] :
                found = True
                break
        if not found: # the service does not include pressettings file
            # check if corresponding service/process is a mx binary in dict
            alert = False
            message = 'file: %s' %(mxres_file)
            if elem.find('Import') is None: # the service imports nothing
            # if murex code contains any service using mx then raise a message
                if elem.find('Code').text in native_svc \
                and native_svc[elem.find('Code').text]: # dict value is not empty
                    alert = True
                    message += ' Code: %s' %(elem.find('Code').text)
            else: # the service imports config of a specific refNickName
                # check if this specific RefNickName is a mx binary
                if elem.find('Code').text in native_svc and \
                elem.find('Import/RefNickName').text in native_svc[elem.find('Code').text]:
                    alert = True
                    if elem.find('Import/NickName') is None:
                        message += ' RefNickName: %s' %(elem.find('Import/RefNickName').text)
                    else:
                        message += ' NickName: %s' %(elem.find('Import/NickName').text)
            message += ' has no anchor inclusion defined'
            if alert:
                print message