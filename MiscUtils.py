'''MiscUtils.py - Miscellaneous Utilities
'''

def connectToDB(cmd=None):
    '''Connect to Erosiondatabase
    General function to connect to erosion database

    Inputs: NONE
    Outputs: cnn (psycopg2 connection object)
    Usage:
        import geotech
        cnn = geotech.connectToDB()
    '''
    import psycopg2 as db
    f = open('puppies', 'r')
    puppies = f.readline()
    cnn = db.connect(host='localhost', user='paul', 
                     password=puppies, database='erosion')
    cur = cnn.cursor()
    if cmd:
        cur.execute(cmd)

    return cnn, cur
    
def getCalibFactors(calib_type):
    cmd = """SELECT * FROM calib
             WHERE calib_type = %d""" % (calib_type)
    cnn, cur = connectToDB(cmd)
    CF = cur.fetchone()[1:]
    
    cur.close()
    cnn.close()
    return CF
