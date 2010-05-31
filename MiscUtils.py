'''MiscUtils.py - Miscellaneous Utilities
This a general purpose, random toolbox for stuff I 
normally do in Python. Some of the functions/scripts
are *not* fully tested. 

Type MiscUtils.[function name]? in iPython to read
the documentation on each of them...
    >>> MiscUtils.quickQuery?
    >>> MiscUtils.dict2Array?
    etc...
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | RIDE YOUR BIKE!         (_)/ (_)  |
    +-----------------------------------+
'''

#--------------------------------------------- 
def quickQuery(cnn, cmd, cols=[], rns=True):
    ''' QUICKLY QUERY MS SQL-SERVER
    Input:
        cnn  - (object) connection to an MS SQL Server using the pymssql package
        cmd  - (string) the T-SQL command to be executed
        cols - (int array) columns - indexed at zero - to be output
        rns  - (optional boolean) determines if row numbers should be printed 
            to screen with the data or not (default=True).
            
    Output:
        data - this is the value returned by the fetchall() method of the SQL
            cursor. it will either be a tuple or a dictionary, depending on 
            how the SQL connection variable (cnn) set up.
            
    Example:
        >>> import pymssql as db
        >>> import MiscUtils as mu
        >>> cnn = db.connect(host='PMPRoject-01', database='prjTahoe', 
                user='user', password='psswrd')
        >>> cmd = 'Select * FROM Table1'
        >>> data = mu.quickQuery(cnn, cmd, [0,1,3,9], False)
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/06/30              (_)/ (_)  |
    +-----------------------------------+
    '''
    from numpy import log10, ceil
    cur = cnn.cursor()
    cur.execute(cmd)
    data = cur.fetchall()
    
    
    rows = len(data)
    n = ceil(log10(len(data)))
    
    if len(cols) > 1:
        for r in range(rows):
            if rns:
                s = 'row ' + leadingZeros(r+1,n) + ':'
            else:
                s = ''
            for c in cols:
                s += '\t' + str(data[r][c])
                
            print s
    
    return data
    
 
#---------------------------------------------
def dict2Array(dict, index):
    '''CONVERT DICTIONARY COLUMN TO NUMPY ARRAY
    You must use numeric data for columns in a numpy array,
    so don't try any funny stuff with strings or DATETIME
    objects or anything like that.
    
    Input:
        dict  - the dictionary that has what you want
        index - the list columns of the dictionary. can be 
            either a list of the columns' names (strings) 
            OR as list of column indices (integers) OR a
            combination of the two (dictionaries are neat)
            
    Output:
        out   - the NumPy array of all the data you wanted.
        
    Example:
        >>> from MiscUtils import dict2Array
        >>> data = dict2Array(MyDict, [1, 2, 'val']
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/07/17              (_)/ (_)  |
    +-----------------------------------+
    '''
    from numpy import zeros             # bring in zeros method
    N = len(dict)                       # number of rows in dictionary
    M = len(index)                      # number of columns you want
    out = zeros([N,M])                  # initialize output array as 0's
    for m in range(M):                  # go through each column you want
        for n in range(N):                  # go through each row of dictionary
            out[n][m] = dict[n][index[m]]       # put stuff into the output array
    return out                          # output full array


#---------------------------------------------
def dict2List(dict, index):
    '''CONVERT DICTIONARY COLUMN TO PYTHON LIST
    Any kind of data can go into a standard Python list,
    so try all kinds of funny stuff with strings or DATETIME
    objects or anything like that.
    
    Input:
        dict  - the dictionary that has what you want
        index - the list columns of the dictionary. can be 
            either a list of the columns' names (strings) 
            OR as list of column indices (integers) OR a
            combination of the two (dictionaries are neat)
            
    Output:
        out   - the Python list of all the data you wanted.
        
    Example:
        >>> from MiscUtils import dict2Array
        >>> data = dict2List(MyDict, [1, 2, 'val']
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/07/17              (_)/ (_)  |
    +-----------------------------------+
    '''
    N = len(dict)                       # number of rows in dictionary
    M = len(index)                      # number of columns you want
    N = len(dict)                       # number of rows in dictionary
    out = []                            # initialize output list
    for n in range(N):                  # go through each row of dictionary
        tmp = []                            # temporary list for this row
        for m in range(M):                  # go through each column
            tmp.append(dict[n][index[m]])       # add data in each column to the row
        out.append(tmp)                     # append each row to the output
    return out                          # return full list    
    x
    



#---------------------------------------------
def wellVolume(d, zTC, zGW, L):
    '''
    Returns the volume of a well (or any cyclinder, I guess).
    Use inches, feet, and gallons for Engligh units and use 
    millimeters, meters, and liters to be like a real scientist.
    
    >>> print vol[0] # prints answer when using English units
    >>> print vol[1] # prints answer when using SI units
    
    Input:
        d   | float:
            inner diameter of the pipe (in or mm)
        
        zTC | float:
            elevation of the top of the well casing (ft or m)
        
        zGW | float:
            groundwater elevation in the well (ft or m)
            
        L   | float:
            Length of the entire well casing (ft or m)
            
    Output:
        vol | 2x1 numpy array, dtype=float
            Volume of water inside the well. You need to select
            vol[0] if you input your data in enlish units and 
            choose vol[1] if you used SI units.
            
    Example:
        >>> from MiscUtils import wellVolume
        >>> d = 3.0     # well casing diameter (in)
        >>> zTC = 1576. # well casing elevation (ft)
        >>> zGW = 1530. # groundwater elevation (ft)
        >>> L = 57.8    # well casing length (ft)
        >>> vol = wellVolume(d,zTC,zGW,L)
        >>> 
        >>> # this will print the answer in gallons
        >>> print vol[0]
        >>>
        >>> # this will print complete garbage
        >>> vol[1]
        
        If the input had been in SI units vol[0] would be 
        garbage and vol[1] would be the volume was water in 
        the well (liters).
    '''
    from numpy import array, pi
    r = array([d/(2.0 * 12.0), d/(2.0 * 1000)])
    area = pi*(r**2.0)
    vol = (zGW - zTC + L) * area
    
    return vol
    

#---------------------------------------------
def renamePhotos(path):
    '''
    
    '''
    for file in os.listdir(path):
        
        newPath = '%s/%s' % (basePath, folder)
        os.chdir(newPath)
        
        cnt = 0
        for photo in os.listdir(newPath):
            cnt += 1
            oldFileName = photo.split('.')
            newFileName = '%s%04d.%s' % (folder, cnt, oldFileName[-1])
            os.rename(photo, newFileName)

#---------------------------------------------
def formatTables(xlFileIn):
    import xlrd
    import xlwt
    import types
    wbIn = xlrd.open_workbook(xlFileIn)
    wbOut= xlwt.Workbook()
    
    xlFileOut = xlFileIn.split('.')[0] + '_out.xls'

    ezxf = xlwt.easyxf 
    style = {"detect" : ezxf('font: bold on, name times new roman; align: vert centre, horiz center'),
             "exceed" : ezxf('font: bold on, name times new roman; pattern: pattern solid, fore_color yellow; align: vert centre, horiz center'),
             "excdND" : ezxf('font: name times new roman; pattern: pattern solid, fore_color yellow; align: vert centre, horiz center'),
             "header" : ezxf('font: bold on, name times new roman; align: wrap yes, vert center, horiz center'),
             "normal" : ezxf('font: name times new roman; align: vert center, horiz center')}

    for shtName in wbIn.sheet_names():
        shtOut = wbOut.add_sheet(shtName)
        shtIn = wbIn.sheet_by_name(shtName)
        
        for r in range(shtIn.nrows):
            
            for c in range(shtIn.ncols):
                tmp = shtIn.cell_value(rowx=r,colx=c)
                
                
                # colum headers
                if r == 0 or (r < 3 and c < 5):
                    shtOut.write(r, c, tmp, style['header'])
                    
                # row headers
                elif (c < 5 and r > 0) or (c >= 5 and (r ==1 or r == 2)):
                    shtOut.write(r, c, tmp, style['normal'])
                    
                # data
                else:
                    # missing data
                    if type(tmp) == types.FloatType and tmp == 0.0:
                        shtOut.write(r, c, "--", style['normal'])
                        
                    # non-missing data
                    else:
                        val, flag = tmp.split(' ')
                    
                        try:
                            limit = float(shtIn.cell_value(rowx=r, colx=2))
                        except:
                            limit = 1e9
                            
                        # non-decects
                        if flag == 'U':
                            
                            # DL exceeds screening value
                            if float(val) >= limit:
                                shtOut.write(r, c, tmp, style['excdND'])
                                
                            # plain ol' NDs
                            else:
                                shtOut.write(r, c, tmp, style['normal'])
                                
                        # detects
                        elif flag <> 'U':
                            
                            # result exceeds screening value
                            if float(val) >= limit:
                                shtOut.write(r, c, tmp, style['exceed'])
                                
                            # result is below screening value
                            else:
                                shtOut.write(r, c, tmp, style['detect'])
                                
    wbOut.save(xlFileOut)




# ---------- DEPRECATED FUNCTIONS ------------
#---------------------------------------------
def wholeFloor(val, order):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    N = nu.wholeFloor(val, order)
    return N
    
    
#---------------------------------------------
def wholeCeil(val, order):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    N = nu.wholeCeil(val,order)
    return N
    
#---------------------------------------------
def findNonZeros(x):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    X = nu.findNonZeros(x)
    return x[N]


    
#--------------------------------------------- 
def linInterp(X,Y,x):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    
    import NumUtils as nu
    y = nu.linInterp(X,Y,x)
    return y
   

#---------------------------------------------   
def planeInterp(X,Y,Z,x,y):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    z = nu.planeInterp(X,Y,Z, x,y)
    return z

#--------------------------------------------- 
def smoothData(x, d):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')       
    import NumUtils as nu
    X = nu.smoothData(x,d)
    return X

#---------------------------------------------
def smooth(x,window_len=11,window='hanning'):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    y = nu.smooth(x, window_len=window_len, window=window)
    return y

#--------------------------------------------- 
def resampleData(t1, x1, d):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    t3, x3 = nu.resampleData(t1,x1,d)
    return t3, x3
#---------------------------------------------
def bootstrapMedian(data, N=5000):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    import NumUtils as nu
    med, CI, estimate = nu.bootstrapMedian(data, N=N)    
    return med, CI, estimate
    
#---------------------------------------------
def censoredProbPlot(data, mask):
    '''
    Deprecated. Please update yr code to call this from FigUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from FigUtils.py')
    import FigUtils as fu
    maskedProbPlot = fu.censoredProbPlot(data,mask)
    return maskedProbPlot


#---------------------------------------------
def connect_bbox(bbox1, bbox2, loc1a, loc2a, loc1b, loc2b, 
                 prop_lines, prop_patches=None):
    '''
    Deprecated. Please update yr code to call this from FigUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from FigUtils.py')
    import FigUtils as fu
    c1,c2,bbox_patch1,bbox_patch2,p = fu.connect_bbox(bbox1, bbox2, loc1a, 
                                                      loc2a, loc1b, loc2b, 
                                                      prop_lines, 
                                                      prop_patches=prop_patches)
    return c1, c2, bbox_patch1, bbox_patch2, p


#---------------------------------------------
def zoom_effect(ax1, ax2, xmin, xmax, **kwargs):
    '''
    Deprecated. Please update yr code to call this from FigUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from FigUtils.py')
    import FigUtils as fu
    c1, c2, bbox_patch1, bbox_patch2, p = fu.zoom_effect(ax1, ax2, xmin, xmax, **kwargs)
    return c1, c2, bbox_patch1, bbox_patch2, p
    

#---------------------------------------------
def zoom_effect_2(ax1, ax2, **kwargs):
    '''
    Deprecated. Please update yr code to call this from FigUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from FigUtils.py')
    import FigUtils as fu
    c1, c2, bbox_patch1, bbox_patch2, p = fu.zoom_effect2(ax1, ax2, **kwargs)
    return c1, c2, bbox_patch1, bbox_patch2, p