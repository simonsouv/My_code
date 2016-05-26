# _*_ coding:Utf8 _*_   #define the encoding type
import lxml
import xml.etree.ElementTree as etree

if __name__ =="__main__":
    """
    This program will parse two xml file, let's say FileA and FileB.
    Each file has a fields node containing several sub-node field
    Each field node has a sub-node label
    The idea of this file is to add in fileA all field node having a label not referenced in fileB
    """
    fichierClient=input('Nom du fichier XML du client: ')
    fichierMX=input('Nom du fichier XML MXPress: ')
    fichierRes=input('Nom du fichier resultat: ')
    
    try:
        fClient=open(fichierClient,'r')
    except:
        print('Le fichier ',fichierClient,"n'existe pas")
        exit()
    
    try:
        fMX=open(fichierMX,'r')
    except:
        print('Le fichier ',fichierMX,"n'existe pas")
        exit()
        
    #open the source xml file coming from the client and MX               
    treeClient = etree.parse(fClient) 
    treeMX = etree.parse(fMX)
    
    #go to the root dir for both elementTree of client and MX
    rootClient = treeClient.getroot()                                       
    rootMX = treeMX.getroot()
    
    #get the subtree corresponding to the list of fields for both client and MX
    fieldsClient = rootClient.find('./udtStructures/udtStructure/fields')   
    fieldsMX = rootMX.find('./udtStructures/udtStructure/fields')
    
    # part 1 merge of the structures
    
    #buid a list containing the fields coming from the client UDF
    list_field = []
    for fieldClient in fieldsClient:
            list_field.append(fieldClient.find('label').text)
    print('List of existing fields from the client:  ',list_field)
    
    #parse the list of field in MX and for each element check 
    #if the corresponding label exist in the list 
    #created previously coming from the client fields
    print ('ANALYSE FIELDS FROM MXPress')
    for fieldMX in fieldsMX:                                                
        try:
            print ('Searching for field ',fieldMX.find('label').text)
            #index method returns the position of the string search.
            #if the string is found, it means the field from MXPress already exists in Client so no need to add
            #if not, the method raise an error, this is why the field is added in the except: section
            list_field.index(fieldMX.find('label').text)    
            print ('The field ',fieldMX.find('label').text,' exists, nothing to do')
        except:
            print('the field ',fieldMX.find('label').text,'do not exist. it must be added to the client fields')
            fieldsClient.append(fieldMX)

    # part 2 merge of the layouts.
    # the logic is the same as for the fields.
    
    layoutsClient = rootClient.find('./udtStructures/udtStructure/layouts')   
    layoutsMX = rootMX.find('./udtStructures/udtStructure/layouts')
    
    #buid a list containing the list of layouts in the client layouts as key and its relative position as value
    list_layout=[]
    for layoutClient in layoutsClient:
        list_layout.append(layoutClient.find('label').text)
    print('List of existing layouts from the client: ', list_layout)    
    
    #Now we parse each layout from MXPress and check whether it exists or not on the client side.
    print ('ANALYSE LAYOUTS FROM MXPress')
    for layoutMX in layoutsMX:
        try:
            print ('Searching for layout ', layoutMX.find('label').text)
            #index method returns the position of the string search.
            #if the string is found, it means the layout from MXPress already exists in Client so no need to add
            #if not, the method raise an error, this is why the field is added in the except: section
            list_layout.index(layoutMX.find('label').text)
            print ('The layout ', layoutMX.find('label').text,' exists, nothing to do')
        except:
            print('the layout ',layoutMX.find('label').text,'do not exist. it must be added to the client layouts')
            layoutsClient.append(layoutMX)
    #write the final XML into a new output file
    treeClient.write(fichierRes)