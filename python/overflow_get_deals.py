import re

input_fileName='D:/Tmp/BBVA/cases/case_699882/npid_16273/mxwarehouse_service.log' #warehouse log file to analyze
output_fileName='D:/Tmp/BBVA/cases/case_699882/npid_16273/guilty_deals.log' #output file containing deal numbers

err_pat = re.compile (r'ERROR - Subwarehouse failed to insert events')
#trade_pat= re.compile(r'tradeNumber=(?P<M_NB>\d+)')
trade_pat= re.compile(r'(?<=tradeNumber=)(?P<M_NB>\d+)')

guilty_deals = {}

with open(input_fileName,'r') as f:
    for line in f:
        if err_pat.search(line):
            for i in trade_pat.finditer(line):
                guilty_deals[i.group("M_NB")] = 1


#print(sorted(guilty_deals.keys()))
with open(output_fileName,'w') as res:
    [res.write(deal+"\n") for deal in sorted(guilty_deals.keys()) ]
