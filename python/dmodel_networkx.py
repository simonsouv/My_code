# _*_ coding:Utf8 _*_   #define the encoding type
# python version : 2.7

import networkx as nx
import logging

def generate_dmodel() :
    """
    generate_dmodel will read the model available in a flat 'csv' like file
    It keeps the content in a networkx oriented graph
    """
    global nx_graph
    nx_graph = nx.MultiDiGraph() #multiDiGraph is an oriented graph that can have several edges between two nodes
    st_filename = 'datamodel.txt'
    try:
        f_dmodel = open(st_filename,'r')
    except:
        print ("ERROR - cannot open file %s",st_filename)
        exit(-1)
    
    #each line of the file contains the information t1;col1;t2;col2
    st_curline = f_dmodel.readline().strip() #read the first line of the file and
    while st_curline != '' :
        l_curline = st_curline.split(';') #convert the string containing the current line into a list
        s_edgeLabel = l_curline[1]+'--'+l_curline[3]
        nx_graph.add_edge(l_curline[0],l_curline[2],label=s_edgeLabel)
        st_curline = f_dmodel.readline().strip()

def search_shortest (start_node,end_node):
    """
    search_shortest will search if a path exist between one starting point and one ending point
    """
    try :
        path_exists = nx.all_shortest_paths(nx_graph,start_node,end_node)
        print([p for p in path_exists])
    except nx.NetworkXNoPath:
        print 'There are no paths between', start_node,' and ', end_node

def search_all_paths (start_node,end_node):
    """
    search_all_paths will search for all_paths between one starting point and one ending point
    """
    try :
        path_exists = nx.all_simple_paths(nx_graph,start_node,end_node)
        print([p for p in path_exists])
    except nx.NetworkXNoPath:
        print 'There are no paths between', start_node,' and ', end_node
            
def main ():
    generate_dmodel()
    #print nx_graph.nodes()
    #print nx_graph.edges()
    s_startT = raw_input("what's the source table? : ").upper().strip() #you can use TRN_ENTSL_DBF as a test
    s_endT = raw_input("what's the target table? : ").upper().strip() #you can use RT_LOAN_DBF as a test
    if not nx_graph.has_node(s_startT):
	    print 'Start node ',s_startT,' does not exist'
	    exit(1)
    if not nx_graph.has_node(s_endT):
        print 'End node ',s_endT,' does not exist'
        exit(1)
    #search_shortest(s_startT,s_endT)
    search_all_paths(s_startT,s_endT)
    
	
#
# MAIN PROGRAM
#
if __name__ =="__main__":
    main()
    
