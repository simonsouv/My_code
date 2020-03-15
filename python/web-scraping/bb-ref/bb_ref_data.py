class Data(object):
    def __init__(self):
        self.data = {}

    def __copy__(self):
        new = type(self)
        new.data = self.data.copy()
        return new
