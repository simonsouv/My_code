from bb_ref_data import Data


class Stats(Data):
    def __init__(self):
        super(Stats, self).__init__()
        self.data['2P'] = ''
        self.data['2P%'] = ''
        self.data['2PA'] = ''
        self.data['3P'] = ''
        self.data['3%'] = ''
        self.data['3PA'] = ''
        self.data['AST'] = ''
        self.data['BLK'] = ''
        self.data['DRB'] = ''
        self.data['FG'] = ''
        self.data['FG%'] = ''
        self.data['FGA'] = ''
        self.data['FT'] = ''
        self.data['FT%'] = ''
        self.data['FTA'] = ''
        self.data['G'] = ''
        self.data['MP'] = ''
        self.data['ORB'] = ''
        self.data['PF'] = ''
        self.data['STL'] = ''
        self.data['TOV'] = ''
        self.data['TRB'] = ''
