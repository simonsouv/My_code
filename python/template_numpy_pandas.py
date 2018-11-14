# import numpy and pandas, and DataFrame / Series
import numpy as np
import pandas as pd
from pandas import DataFrame, Series

# set some pandas options
pd.set_option('display.notebook_repr_html', False)
pd.set_option('display.max_columns', 10)
pd.set_option('display.max_rows', 10)

# and some items for matplotlib
%matplotlib inline
import matplotlib.pyplot as plt
pd.options.display.mpl_style = 'default'