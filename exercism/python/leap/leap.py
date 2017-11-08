def is_leap_year(y):
    if ( not y % 4): #year can be divided by 4
        if ( not y % 100): #year can be divided by 100
            if ( not y % 400): #year can be divided by 400
                return True
            else:
                return False
        else:
            return True
    else:
        return False
    #return True if ( ((not y % 4) and (y % 100)) or ((not y % 4) and (not y % 100) and (not y % 400)) ) else False
