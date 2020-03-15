import re
import numpy as np

with open('dbg.log', 'r') as f:
    content = f.read()

np_timings = np.array([float(f) for f in re.findall(r'Finished get_page in (\d+\.\d+)', content)])

print "mean: %s\nstd: %s\nvar: %s" % (np_timings.mean(),
                                      np_timings.std(),
                                      np_timings.var())