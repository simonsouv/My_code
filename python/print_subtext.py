#
# This program opens a file and print a sub-part delimited by two patterns
#
import os, re

#files used for input and output
input_filename='D:/Tmp/BBVA/cases/case-654997/RunningServices.log'
output_filename='d:/python_subtext.log'
#Pattern we use for delimitation
pattern_start=re.compile(r"<MX_MIDDLEWARE_SERVICES>" )
pattern_end=re.compile(r"<\/MX_MIDDLEWARE_SERVICES>" )
#boolean variables used to flag when the pattern are found.
#This is necessary if we those pattern appear several times in the file and I only want the first occurence
pattern_start_found=False
pattern_end_found=False

#modify the filepath for the file you want to open and the file tat will store results
with open(input_filename) as infile, open(output_filename, 'w') as outfile:
    copy = False
    for line in infile:
        if pattern_start_found and pattern_end_found:
            print "both START and END patterns found, exit\nResults are in file %s" %  output_filename
            break
        elif pattern_start.search(line) is not None:
            print "Pattern %s found!,copy will %s" % ('START','begin') 
            copy = True
            pattern_start_found=True
        elif pattern_end.search(line) is not None:
            print "Pattern %s found!,copy will %s" % ('END','stop') 
            copy = False
            pattern_end_found=True
        elif copy:
            #print 'copy line to output file'
            outfile.write(line)

