# _*_ coding:Utf8 _*_   #define the encoding type
from collections import defaultdict, deque
import logging

	
def generate_dmodel():
    """
    generate_dmodel will read the model available in a flat 'csv' like file
    It keeps the content in a defaultdict structure
    """
    global dd_dmodel, d_nodeToID, d_IdToNode
    dd_dmodel = defaultdict(list) #dd_dmodel will contain the graph, for each t -- which is unique -- we store a list containing t.col-next_t-next_t.col
    #the next two dictionaries is to store a unique ID per couple t-t_col:uniqueID and the reverse uniqueID:t-t_col
    d_nodeToID =  {}
    d_IdToNode = {}
    st_filename = 'datamodel.txt'
    try:
        f_dmodel = open(st_filename,'r')
    except:
        print "ERROR - cannot open file ",st_filename
        exit(-1)
    
    #each line of the file contains the information t1;col1;t2;col2
    st_curline = f_dmodel.readline().strip() #read the first line of the file and remove the cariage return at the end with strip()
    while st_curline != '' :
        l_curline = st_curline.split(';') #convert the string containing the current line into a list
        #the next 2 if instructions is to construct a dictionary to assign a unique ID to each t.
        if (l_curline[0]) not in d_nodeToID:
            d_nodeToID[l_curline[0]] = len(d_nodeToID)
        if (l_curline[2]) not in d_nodeToID:
            d_nodeToID[l_curline[2]] = len(d_nodeToID)

        #dd_model stores for a node the list of successors
        dd_dmodel[l_curline[0]].append(l_curline[1]+'-'+l_curline[2]+'-'+l_curline[3]) # 
        st_curline = f_dmodel.readline().strip()
        
    logging.info('graph representation of dmodel is : %s',dd_dmodel)
    d_IdToNode = {v: k for k, v in d_nodeToID.items()}
    logging.info('d_nodeToID size is : %s',len(d_nodeToID))
    logging.info('d_nodeToID content is  : %s',d_nodeToID)
    logging.info('d_IdToNode size is : %s',len(d_IdToNode))
    logging.info('d_IdToNode content is  : %s',d_IdToNode)
    f_dmodel.close()


def get_result(start_node,end_node,predecessor,level):
    """
    get_result() will contruct the node chain based on the dictionaries of predecessors, levels
    and the starting and ending points
    -start_node and end_node are the IDS of the node to search the path
    Algo is:
    -check the level for end node if 0 - meaning it's the starting point
    -if not I get the the predecessor of the end_node and loop recursively
    """
    global s_nodeChain
    #s_nodeChain will contain the reverse order of the path -- from end-point to start point
    #basically it' ll be like <-> current_t.current_c <-> predecessor_t. predecessot.c
    #as it is a recursive call at the end it should contain the whole path in reverse order
    if level[end_node] > 0 : #did not reach the starting point yet
        logging.info('%s has a predecessor. put the information in s_nodeChain',d_IdToNode[end_node])
        s_nodeChain += ';<->;'+d_IdToNode[end_node]+'.'+predecessor[end_node][2]+';<->;'+d_IdToNode[predecessor[end_node][0]]+'.'+predecessor[end_node][1]
        logging.info('s_nodeChain content is : %s',s_nodeChain)
        get_result(start_node,predecessor[end_node][0],predecessor,level)
    else :# we reached the starting point we can return the resulting chain
        logging.info('Starting node %s reached',d_IdToNode[start_node])
    
    
def search_graph(start_node,end_node):
    """
    search_graph() will search if a path exist between one starting point and one ending point
    """
    global d_predecessor, d_color, d_level
    d_predecessor = d_IdToNode.copy() # this dict will contain the predecessor of the node referenced as key in the graph
    d_color = d_IdToNode.copy() #this dict will store the color (see http://liris.cnrs.fr/csolnon/polyGraphes.pdf; page 26)
    d_level = d_IdToNode.copy() #this dic will store the level of each node
    dq_myfifo = deque()
    
    for i in d_predecessor.keys():
        d_predecessor[i] = 'null'
    for i in d_color.keys():
        d_color[i] = 'b' # b stands for blanc
    for i in d_level.keys():
        d_level[i] = -1
    
    print'STARTING POINT is ',start_node,' and ENDING POINT is ',end_node
    if start_node == end_node:
        print "starting node and ending node can't be identical"
        return False
    if start_node not in d_nodeToID:
        print 'starting node ',start_node,' does not exist. QUIT'
        return False
    if end_node not in d_nodeToID:
        print 'ending node ',end_node,' does not exist. QUIT'
        return False
    logging.info('d_predecessor size is : %s',len(d_predecessor))
    logging.info('d_predecessor content is : %s',d_predecessor)
    logging.info('d_color size is : %s',len(d_color))
    logging.info('d_color content is : %s',d_color)
    logging.info('d_level size is : %s',len(d_level))
    logging.info('d_level content is : %s',d_level)
    #search in the representation of our graph -- dd_dmodel -- where the starting point is referenced. If it exists we store the list
    #else we quit
    
    if start_node not in dd_dmodel:
        print 'starting point ',start_node,' does not have any successors'
        return False
    l_curList = dd_dmodel.get(start_node,-1)
    d_predecessor[d_nodeToID[start_node]] = 'START'
    d_level[d_nodeToID[start_node]] = 0
    dq_myfifo.appendleft(d_nodeToID[start_node])
    d_color[d_nodeToID[start_node]] = 'g' #g stands for gris
    find_it = False
    logging.info('starting point is %s, its ID is %s, its level is %s, and its color is %s',start_node,d_nodeToID[start_node],d_level[d_nodeToID[start_node]],d_color[d_nodeToID[start_node]])
    logging.info('content of the fifo is : %s', dq_myfifo)
    
    while dq_myfifo and not find_it :
        s_curNode=dq_myfifo.pop() #be carefull at this level dq_myfifo contains the id of the current node
        logging.info('-- current node is %s, its name is %s',s_curNode,d_IdToNode[s_curNode])
        if d_IdToNode[s_curNode] in dd_dmodel:
            l_curList = dd_dmodel.get(d_IdToNode[s_curNode],-1) #we get the list of successors of s_curNode with its name through d_nodeToID
            logging.info('-- list of next node for %s : %s',d_IdToNode[s_curNode], l_curList)
            for j in l_curList:
                k = j.split('-')
                logging.info('--- current successor is: %s',k)
                if d_color[d_nodeToID[k[1]]] == 'b': #the current sucessors was never visited
                    logging.info('---- successor %s with ID %s with ID  never checked before. Adding it to the FIFO and changed its color to g',k[1],d_nodeToID[k[1]])
                    logging.info('---- current color is %s',d_color[d_nodeToID[k[1]]])
                    dq_myfifo.appendleft(d_nodeToID[k[1]])
                    d_color[d_nodeToID[k[1]]] = 'g'
                    logging.info('---- new color is %s',d_color[d_nodeToID[k[1]]])
                    logging.info('---- content of FIFO is %s',dq_myfifo)
                    #the information stored in predecessor is a list containing
                    #-the nodeID of the predecessor through s_curNode
                    #-the col of the predessor --stored in k[0] -- making the relationship with the sucessor
                    #-the col of the sucessor -- stored in k[2] -- linked to the col of the predecessor
                    logging.info('---- successor %s has the level %s',k[1],d_level[d_nodeToID[k[1]]])
                    logging.info('---- predecessor of %s with ID %s is %s',k[1],d_nodeToID[k[1]],d_predecessor[s_curNode])
                    logging.info('---- changing the predecessor for id %s',d_nodeToID[k[1]])
                    d_predecessor[d_nodeToID[k[1]]] =(s_curNode,k[0],k[2])
                    logging.info('---- predecessor of %s with ID %s is %s',k[1],d_nodeToID[k[1]],d_predecessor[s_curNode])
                    d_level[d_nodeToID[k[1]]] = d_level[s_curNode] + 1
                    logging.info('---- successor %s has the following information as predecessor %s',k[1],d_predecessor[d_nodeToID[k[1]]])
                    logging.info('---- successor %s has now the level %s',k[1],d_level[d_nodeToID[k[1]]])
                    logging.info('d_predecessor content is : %s',d_predecessor)
                    logging.info('d_color content is : %s',d_color)
                    logging.info('d_level content is : %s',d_level)
            logging.info('-- all successors of %s  were checked. Let''s change its color to n',s_curNode)
            logging.info('-- its current color is %s',d_color[s_curNode])
            d_color[s_curNode] = 'n' #n stands for noir, it means all the sucessors where visited.
            logging.info('-- its new color is %s',d_color[s_curNode])
            #let's check if the END POINT was found    
            logging.info('Predecessor of %s is %s',end_node,d_predecessor[d_nodeToID[end_node]])
            if d_predecessor[d_nodeToID[end_node]] != 'null' :#in this case we reach the end point
                print end_node,' is reached!'
                find_it = True
        else:
            logging.info('-- %s with ID %s has no successors',d_IdToNode[s_curNode], s_curNode)
    return find_it    
        
def main():
    global s_nodeChain
    logging.basicConfig(filename='mygraph.log', filemode='w', format='%(asctime)s:%(levelname)s:%(message)s', level=logging.DEBUG)
    s_startT = raw_input("what's the source table? : ").upper().strip() #you can use TRN_ENTSL_DBF as a test
    s_endT = raw_input("what's the target table? : ").upper().strip() #you can use RT_LOAN_DBF as a test
    s_nodeChain='' 
    generate_dmodel()
    if search_graph(s_startT,s_endT):
        get_result(d_nodeToID[s_startT],d_nodeToID[s_endT],d_predecessor,d_level)
        #print s_nodeChain
        #remember s_nodeChain is a string contaiing the reverse order ot the path -- starting with end_point and finishing with start_point
        #therefore we need to reverse it. So to do so we need to convert it as a list with split() then reverse the order with [::-1]
        #finally the resulting list is converting back to a string with join() and we remove the last 4 characters containing '<-> ' 
        print "CHAINAGE POSSIBLE EST ",' '.join(s_nodeChain.split(';')[::-1])[:-4]
    else:
        print "PAS DE CHAINAGE ENTRE ",s_startT," ET ",s_endT  
    
    
#
# MAIN PROGRAM
#
if __name__ =="__main__":
    main()
    