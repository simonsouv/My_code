# _*_ coding:Utf8 _*_   #define the encoding type
# python version : 2.7

import networkx as nx
import logging
import matplotlib.pyplot as plt
from random import randint

def generate_dmodel() :
    """
    generate_dmodel will read the model available in a flat 'csv' like file
    It keeps the content in a networkx oriented graph
    """
    global nx_graph
    nx_graph = nx.MultiDiGraph() #multiDiGraph is an oriented graph that can have several edges between two nodes
<<<<<<< HEAD
    st_filename = 'datamodel_mx.txt' #the file opened contains an extract of RDBCNSTR_DBF
=======
    st_filename = 'datamodel_mx.txt'
>>>>>>> a3303cb8b92e8d91bb1dbc9efff9835e27bbcd82
    try:
        f_dmodel = open(st_filename,'r')
    except:
        print "ERROR - cannot open file ",st_filename
        exit(-1)
<<<<<<< HEAD
    
    #each line of the file contains the information t1;col1;t2;col2
    st_curline = f_dmodel.readline().strip() #read the first line of the file and
    while st_curline != '' :
        l_curline = st_curline.split(';') #convert the string containing the current line into a list
        s_edgeLabel = l_curline[1]+'-->'+l_curline[3]
        nx_graph.add_edge(l_curline[0],l_curline[2],label=s_edgeLabel)
        st_curline = f_dmodel.readline().strip()
	
=======
    l_lines = set(f_dmodel.readlines()) # l_ines will contain all lines from the input files without the duplicated ones
    for x in l_lines:
		l_curline = x.split(';') #convert the string containing the current line into a list
		s_edgeLabel = l_curline[1]+'--'+l_curline[3]
		nx_graph.add_edge(l_curline[0],l_curline[2],label=s_edgeLabel)
>>>>>>> a3303cb8b92e8d91bb1dbc9efff9835e27bbcd82

def search_shortest (start_node,end_node):
    """
    search_shortest will search all shortest paths between one starting point and one ending point
    """
    
    try :
<<<<<<< HEAD
        path_exists = nx.shortest_path(nx_graph,start_node,end_node) #path_exists will be of type list
        #print path_exists,type(path_exists)
        #p = next(path_exists)
        #print p, type(p)
        #Let's construct a new DiGraph based on the shortest path
        nx_finalGraph = nx.DiGraph()
        edgesAttributes = nx.get_edge_attributes(nx_graph,'label')
        #print edgesAttributes
        while len(path_exists) > 1:
            current = path_exists.pop(0)
            next = path_exists[0]
            nx_finalGraph.add_edge(current,next,label=edgesAttributes[current,next,0])		
        #Let's draw the new graph
        pos = nx.circular_layout(nx_finalGraph)
        plt.style.use('ggplot')
        nx.draw(nx_finalGraph, pos, with_labels=True)
        edge_labels = nx.get_edge_attributes(nx_finalGraph,'label')
        nx.draw_networkx_edge_labels(nx_finalGraph, pos, edge_labels = edge_labels)
        random_value = str(randint(0,1000000))
        plt.savefig('path_'+random_value+'.png')
        print 'A graphical representation of path between ', start_node, ' and ', end_node, ' is saved under path'+random_value+'.png'
        plt.show()
=======
        path_exists = nx.all_shortest_paths(nx_graph,start_node,end_node) #nx.all_shortest_paths returns all shortest path. This method returns a generator
>>>>>>> a3303cb8b92e8d91bb1dbc9efff9835e27bbcd82
    except nx.NetworkXNoPath:
        print 'There are no paths between', start_node,' and ', end_node
        return(1)
    
    result_graph = nx.MultiDiGraph()
    for p in path_exists: #path_exists is a generator of list, each list is a path between the two nodes. Basically is list is a subgraph
		result_graph.add_edges_from(nx_graph.subgraph(p).edges(data=True)) #add the sub_graph to the result_graph
    
    for i in result_graph.nodes() : # remove self edge, basically a loop on a node
	    while result_graph.has_edge(i,i) :
			result_graph.remove_edge(i,i)

    print result_graph.edges(data=True)

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
    search_shortest(s_startT,s_endT)
    #search_all_paths(s_startT,s_endT)
    
	
#
# MAIN PROGRAM
#
if __name__ =="__main__":
    main()
    
