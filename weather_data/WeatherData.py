'''
DOWNLOAD WEATHER DATA
This Python utility contains a functions to acquire and use data from
Weatherunderground.com (wunderground) and ASOS stations. Wunderground data are
saved in a in the current working directory based on the convention
[station]_[start]to[end].csv. ASOS data are saved in a file named [station].dat.

There are several function in this file. Most work, some don't. Of the ones that
do work, only a couple are meant to be directly called by the user. Those
non-helper functions are listed below. See the docstring for each individual
function for an explaination.
1) WeatherData.getWeather - compliles data from any personal weather station
    posted or airport available at Wunderground.
2) WeatherData.getASOS - compiles data from any ASOS station.
3) WeatherData.swmmASOS - reads the raw data downloaded by getASOS and creates
    a file of the rainfall time series ready to be read by SWMM.
4) WeatherData.sqlASOS (BROKEN) - this function will one day submit the
    rainfall, wind speed, direction, and gusts, barometric pressure,
    temperature, humidity, dewpoint, and station information all to an SQL
    database where the data can then be queried, pivoted, grouped, etc. Right
    now, it doesn't work (issues with dubplicate days in raw files).

To access the documention for each of these functions, you can do the following
in the standard Python shell (not recommended):
>>> import os
>>> os.chdir(r'p:\users\paul\utils\weather_data')
>>> import WeatherData as wd
>>> help(wd) # print this docstring

If you're using IPython (recommended), you can do the following instead:
In [1]: cd p:\users\paul\utils\weather_data
In [2]: import WeatherData as wd
In [3]: wd? # prints this doc string
In [4]: wd.getWeather? # prints doc string for the getWeather function
In [5]: wd.getASOS? # prints doc string for the getASOS functions
In [6]: wd.swmmASOS?? # prints the doc string and code for the swmmASOS function
etc...
+-----------------------------------+
| Paul M. Hobson             __o    |
| phobson@geosyntec.com    _`\<,_   |
| 2009/11/30              (_)/ (_)  |
+-----------------------------------+
'''

## try:
import urllib as ul
import matplotlib.dates as md
import datetime as dt
import numpy as np
import re
import psycopg2 as db
import os
#import pyodbc as db
## except:
##     print '''Don't have all of the required libraries:
##             Numpy, pyodbc, and matplotlib are the likely problems.'''

def connectToDB(cmd=None)
    cnn = db.connect(database='weather', host='localhost',
                     user='paul', password='violawould')
    cur = cnn.cursor()
    if cmd:
        cur.execute(cmd)

    return cnn, cur


def wgetASOS(sta, year):
    cmd = """
    SELECT filedate
    FROM files
    WHERE filedate BETWEEN %d00 AND %d00
      AND sta = '$s';
    """ % (year, year+1, sta)
    cnn, cur = connectToDB(cmd)
    os.system('')

    cur.close()
    cnn.close()


def fileGetter(STA, date, type, file, header=False):
    '''
    BUILD URL STRINGS FROM DATA DOWNLOADERS (HELPER FUNCTION)
    BASIC USE:
        >>> import WeatherData as WD
        >>> wd.fileGetter(STA, date, type, file, header=False)

    INPUT:
        STA : str
          Station's call sign/handle e.g., 'KORPORTL51', 'KATL'. Navigate to
          the station's Wunderground page to find this out.

        date : integer array, len=3
          This is the date of the data needed e.g, [2002, 5, 1] for
          May 1, 2009

        type : str
          This defines the type of station. Current options are:
          'PWS'         (data from a personal weather station)
          'airport'     (weather data from an airport)
          'ASOS'        (ASOS 5-min weather data)

        file : python open file object
          This is the file to which the data will be written

        header : bool
            Set to True if this is the first file downloaded.
            Otherwise defaults to False.

    EXAMPLE:
        >>> fKPX = open('KPDX_weather.txt')
        >>> wd.fileGetter('KPDX', [2009, 05, 25], 'PWS', fKPX, header=True)
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   |
    | 2009/11/30              (_)/ (_)  |
    +-----------------------------------+
    '''
    # create 'day' strings to construct URLs
    # based on data type
    if type == 'ASOS':
        Y,M = date
        D = 1
        day = '%d/%d' % (Y,M)

    else:
        Y,M,D = date
        day = '%d/%d/%d' % (Y,M,D)

    print 'getting data from %s on %s' % (STA, day)

    # define the basic URL dictionary
    bURL = {
        'ASOS' : 'ftp://ftp.ncdc.noaa.gov/pub/data/asos-fivemin/6401-',
        'PWS' :  'http://www.wunderground.com/weatherstation/WXDailyHistory.asp?ID=',
        'airport' : 'http://www.wunderground.com/history/airport/'}

    # construct the full URL dictionary
    URL = {'ASOS' : '%s%s/64010%s%s%02d.dat' % (bURL[type], Y, STA, Y, M),
            'PWS' :  '%s%s&month=%d&day=%d&year=%d&format=1' % (bURL[type], STA, M, D, Y),
            'airport' : '%s%s/%s/DailyHistory.html?format=1' % (bURL[type], STA, day)}

    # read the URL to variable 'X' with basic exception handling
    try:
        X = ul.urlopen(URL[type]).read()	# read data into a string
        fileWriter(X, file, day, type, header=header) # parse the file

    except:
        print """ERROR downloading %s!! The bad URL:\n%s""" % (day, URL[type])

def fileWriter(X, file, day, type, header=False):
    '''
    WRITE INTERNET WEATHER DATA TO FILES (HELPER FUNCTION)
    BASIC USE:
        >>> import WeatherData as WD
        >>> wd.fileWriter(X, file, day, type, header=False)

    INPUT:
        X : str
          Output from urllib.urlopen called

        file : python open file object
          This is the file to which the data will be written

        type : str
          This defines the type of station. Current options are:
          'PWS'         (data from a personal weather station)
          'airport'     (weather data from an airport)
          'ASOS'        (ASOS 5-min weather data)

        day : str
          String created in wd.fileGetter describing which day is being
          downloaded. Only needed for type='airport', in which case it will have
          the format e.g., '2009/05/25'

        header : bool
            Set to True if this is the first file downloaded.
            Otherwise defaults to False.

    EXAMPLE:
        >>> fKPX = open('KPDX_weather.txt')
        >>> wd.fileGetter('KPDX', [2009, 05, 25], 'airport', fKPX, header=True)
        >>> # fileGetter calls fileWriter -- no need for you do it directly
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   |
    | 2009/11/30              (_)/ (_)  |
    +-----------------------------------+
    '''
    # Wunderground: Personal Weather Station
    if type == 'PWS':
        X = X.split('\n<br>')		# split the URL at line breaks in a list
        X[0] = X[0][1:]			# get rid of very first line break
        tmp = X[0].split('<br>\n')	# split headers from first data line (file comes with strange LB)

        X[0] = '\n' + tmp[1]		# put the first line back in as first list item
        X = X[0:len(X)-1]               # remove garbage at end of file

        if header:                      # if this is the first file to be read
            H = tmp[0]                  # store the headers as string
            file.writelines(H)          # write column headers to the output file
        file.writelines(X)              # write data line to output file

    # Wunderground: Airports
    elif type == 'airport':
        X = X.split('<br />')		# split the URL at funky line breaks into a list
        TZ = X[0][5:8]			# get time zone from file header
        Z = X[1:-1]                     # pull out data (second line to second from last line)
        for i in range(len(Z)):
            Z[i] = Z[i][0] + TZ + ',' + day + ' ' + Z[i][1:]

        if header:                      # if this is the first file to be read
            H = 'Time Zone,Date/time,'+ X[0][9:]
            file.writelines(H)          # write column headers to the output file

        file.writelines(Z)              # write data line to output file

    # ASOS WEATHER DATA
    elif type == 'ASOS':
        file.writelines(X)


def getWeather(STA, start_date, end_date):
    '''DOWNLOAD DATA FROM WUNDERGROUND.COM
    Download data from wunderground weather stations
    BASIC USE:
        >>> import weatherData as WD
        >>> WD.stationRead(STA_ID, start_date, end_date, STA_type)

    INPUT:
        STA : str
          Station's call sign/handle e.g., 'KORPORTL51', 'KATL'. Navigate to
          the station's Wunderground page to find this out.

        start_date : integer array, len=3
          This is the start date of the data needed e.g, [2002, 5, 1] for
          May 1, 2009

        end_date : integer array, len=3
          This is the end date. Identical format to start_date

        type : str
          This defines the type of station. Current options are:
          'PWS'         (data from a personal weather station)
          'airport'     (weather data from an airport)

    EXAMPLE:
    >>> WD.getWeather('KORPORTL51', [2008, 12, 01], [2008, 12, 31])
    (will download all of the data from station KORPORTL51 for the
    month of December in 2008.)
    >>> WD.getWeather('KATL', [2007,01,01], [2008,12,31])
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   |
    | 2009/11/30              (_)/ (_)  |
    +-----------------------------------+
    '''

    # determine the type of station
    if len(STA) < 5:
        type = 'airport'
    else:
        type = 'PWS'

    # split up dates
    y1, m1, d1 = start_date
    y2, m2, d2 = end_date

    # define start and end dates as standard number
    SD = int(md.date2num(dt.datetime(y1, m1, d1)))
    ED = int(md.date2num(dt.datetime(y2, m2, d2)))


    fname = '%s_%i%02d%02dto%i%02d%02d.csv' % (STA, y1, m1, d1, y2, m2, d2)
    f = open(fname, 'w')

    # loop from the start date (SD) to end date (ED)
    for n in range(SD,ED+1):
        Y = (md.num2date(n).year)     # pull out the current year, convert to string
        M = (md.num2date(n).month)    # pull out the month...
        D = (md.num2date(n).day)      # ...and the day...
        day = '%d/%d/%d' % (Y,M,D)

        if n == SD:
            fileGetter(STA, [Y,M,D], type, f, header=True)
        else:
            fileGetter(STA, [Y,M,D], type, f)

    f.close()                           # close the file.
    print 'File saved in ' + fname      # time to go home. we're done here.


def getASOS(STA, SD, ED, mode='w'):
    ''' asos.getASOS(STA_ID, start_date, end_data)
    This function takes an ASOS station handle and a
    range of dates and downloads all of the data into
    single file.

    Input:
        STA_ID = ASOS's handle for the station in quotes(e.g., 'KPDX')
        start_date = dating as list of integers in the form [yyyy, mm]
        end_date = date as list of intergers in the form [yyyy, mm]
        mode = how Python writes to the data file. DO NOT SPECIFY.
            USE DEFAULT VALUE ONLY. TO APPEND TO EXISTING FILE SEE
            asos.updateASOS.
                default value = 'w'

    Output:
        No variables are output to the Python environment. But
        a file (e.g., KPDX.dat) is written to the current
        directory.

    Example:
        >>> import asos
        >>> asos.getASOS('KPDX', [2005,03], [2007,12])

    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   |
    | 2009/05/04              (_)/ (_)  |
    +-----------------------------------+
    '''
    fname = STA + '.dat'                # input filename
    f = open(fname, mode)                # open file for writing


    # loop through each date
    for y in range(SD[0], ED[0]+1):

        # select month range based on the year
        #   opening month
        if y == SD[0]:  # first year
            m1 = SD[1]
        else:           # all other years
            m1 = 1

        #   closing month
        if y == ED[0]:  # last year
            m2 = ED[1]
        else:           # all other years
            m2 = 12

        # for the give year, loop through the months
        for m in range(m1,m2+1):
            fileGetter(STA, [y,m], 'ASOS', f)

    f.close()  # close that file -- close it real good

def rainASOS(x):
    '''get 5-min precip value (cumulative w/i the hour)'''
    p = 0
    m = re.search('[ +]P\d\d\d\d\s', x)
    if m:
        p = int(m.group(0)[2:-1])

    return p

def windASOS(x, errorFile, sql=False):
    '''get 5-min windspeed (s) and direction (d)'''
    if sql:
        d = 'NULL'
        dmax = 'NULL'
        dmin = 'NULL'
        s = 'NULL'
        g = 'NULL'
    else:
        d = None
        dmax = None
        dmin = None
        s = None
        g = None

    # search for gusty (w1), not gusty (w2),
    # variable (w3), and variable + gusty (w4)
    w1 = re.search('[0-3]\d\d\d\dG\d\dKT', x)
    w2 = re.search('[0-3]\d\d\d\dKT', x)
    w3 = re.search('VRB\d\dKT', x)
    w4 = re.search('VRB\d\dG\d\dKT', x)

    if w1:
        w = w1.group(0)
        d = w[:3]
        s = w[3:5]
        g = w[6:8]

    elif w2:
        w = w2.group(0)
        d = w[:3]
        s = w[3:5]

    elif w3:
        w = w3.group(0)
        s = w[3:5]

    elif w4:
        w = w4.group(0)
        s = w[3:5]
        g = w[6:8]

    else:
        errorFile.writelines('Wind error on %s' % x)

    # variable wind directions
    vw = re.search('[0-3][0-6][0-9]V[0-3][0-6][0-9]',x)
    if vw:
        vd = vw.group(0)
        dmin = vd[0:3]
        dmax = vd[-3:]


    # put everything in a dictionary
    wind = {'dir' : d,
            'dmin': dmin,
            'dmax': dmax,
            'spd' : s,
            'gust': g}

    return wind


def tempASOS(x, errorFile, sql=False):
    '''get 5-min termperature value'''
    if sql:
        t = 'NULL'
        d = 'NULL'
        h = 'NULL'
    else:
        t = None
        d = None
        h = None

    cnt = 0
    m = re.search('[ M]\d\d/[M\d]\d[A \d]',x)

    try:
        m = m.group(0).split('/')

        if m[0][0] == 'M':
            t = -1 * int(m[0][1:])
        else:
            t = int(m[0][1:])

        if m[1][0] == 'M':
            d = -1 * int(m[1][1:])

        elif m[1][-1] == 'A':
            d = m[1][:-1]

        else:
            d = int(m[1][:2])

        h = 100 - 5 * (t-d)
    except:
        errorFile.writelines('Temp error on %s' % x)

    tdh = {'temp' : t,
           'dew' : d,
           'humid' : h}
    return tdh

def baroASOS(x, errorFile, sql=False):
    '''get 5-min baro. pressure reading'''

    m = re.search('\sA\d\d\d\d',x)
    try:
        bp = int(m.group(0)[2:])/100.
    except:
        if sql:
            bp = 'NULL'
        else:
            bp = None
        errorFile.writelines('Baro error on %s' % x)
    return bp

def dateASOS(x):
    '''get date/time of asos reading'''
    yr = int(x[13:17])   # year
    mo = int(x[17:19])   # month
    da = int(x[19:21])   # day
    hr = int(x[37:39])   # hour
    mi = int(x[40:42])   # minute

    date = dt.datetime(yr,mo,da,hr,mi)

    return date

def processPrecipASOS(p1, dt, RT=55):
    '''convert 5-min rainfall data from cumuative w/i an hour to 5-min totals
    p = precip data (list)
    dt = list of datetime objects
    RT = point in the hour when the tip counter resets
    #if (p1[n-1] <= p1[n]) and (dt[n].minute != RT):'''

    p2 = np.zeros(len(p1))
    for n in range(1, len(p1)):

        if dt[n].minute != RT:
            p2[n] = (float(p1[n]) - float(p1[n-1]))/100.

        elif dt[n].minute == RT:
            p2[n] = p1[n]/100.

    return p2

def useASOS(fname, RT):
    errorFile = open('%s_use_error_log.txt' % fname.split('.')[0], 'w')

    dataFile = open(fname, 'r')
    STA = fname.split('.')[0]

    dt = []
    wind = []
    bp = []
    tdh = []
    p = []
    for x in dataFile:
        dt.append(dateASOS(x))
        wind.append(windASOS(x, errorFile))
        bp.append(baroASOS(x, errorFile))
        tdh.append(tempASOS(x, errorFile))
        p.append(rainASOS(x))

    dataFile.close()
    errorFile.close()
    return dt, p, wind, bp, tdh

def sqlASOS(fname, uid, pwd, staType='ASOS', RT=55):
    #cnn = db.connect(driver='{SQL Server}',
    #            server='POR-PHOBSON\SQLEXPRESS',
    #            database='weather',
    #            uid='phobson',
    #            pwd='violawould2',
    #            Trusted_Connection='yes')
    cnn = db.connect(database='weather', host='localhost',
                     user=uid, password=pwd)
    cur = cnn.cursor()

    errorFile = open('%s_sql_error_log.txt' % fname.split('.')[0], 'w')

    f = open(fname, 'r')
    STA = fname.split('.')[0]

    for x in f:
        dt = dateASOS(x)
        wind = windASOS(x, errorFile, sql=True)
        bp = baroASOS(x, errorFile, sql=True)
        tdh = tempASOS(x, errorFile, sql=True)
        p = rainASOS(x)

        cmd = """INSERT INTO observations (sta, type, obsdate, obstime, rain, temp,
                humid, dewpnt, baro, windspd, windgust, winddir, winddirmax, winddirmin)
                VALUES ('%s', '%s', '%s', '%s', %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
              """ % (STA, staType, dt.date(), dt.time(), p, tdh['temp'], tdh['humid'],
                    tdh['dew'], bp, wind['spd'], wind['gust'], wind['dir'],
                    wind['dmin'], wind['dmax'])
        cur.execute(cmd)

    cnn.commit()
    f.close()

def swmmASOS(fname, RT=55, IZ=True, ret=False):
    ''' t,p = WeatherData.swmmASOS(file_name [, reset_time, include_zeros])
    This function takes a file generated by asos.getASOS
    and parses it into an 2 input files for SWMM (hourly and 5-min data).

    Input:
        Required:
        file_name = name of the file output by asos.getASOS
            (e.g., 'KPDX_in.dat')

        Optional:
        reset_time (RT) = hourly time at which the bucket tip
            counter resets. typically 55, sometimes 00.
                default value = 55

        include_zeros (IZ) = switches on and off the inclusion
            of zeros in the output file (i.e., True = 'zeros'
            and False = 'no zeros').
                default value = True

    Output:
        t = array of datetime values output to the Python
           environment
        p = array of precipitation values (inches) output
            to the python environment

        Two files are also written to the current directory
            (e.g., KPDX_1hr.dat and KPD_5min.dat)

    Examples:
        [In 1]: import asos
        [In 2]: t,p = asos.parseASOS('KPDX_in.dat', RT=55, IZ=False)
            # KPD_out.dat will be written with no zero values and the time
            # variable output into the Python environment will be a list
            # of datetimes rather than a single array.
        [In 3]: t,p = asos.parseASOS('KPDX.dat', IZ=False) # equiv. to [In 2]
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   |
    | 2009/05/04              (_)/ (_)  |
    +-----------------------------------+
    '''
    f = open(fname, 'r')
    STA = fname.split('.')[0]
    p_tmp = []
    t = []
    for x in f:
        t.append(dateASOS(x))
        p_tmp.append(rainASOS(x))

    p = processPrecipASOS(p_tmp, t, RT)


    fOUT = open('%s_5min.dat' % STA, 'w')
    for n in range(len(p)):
        if IZ or (not IZ and p[n] > 0.00):
            x = (STA, t[n].year, t[n].month, t[n].day, t[n].hour, t[n].minute, p[n])
            line = '%s\t%02d\t%02d\t%02d\t%02d\t%02d\t%1.2f\n' % x
            fOUT.writelines(line)
        else:
            pass

    fOUT.close()

    if ret:
        return t, pfname

def readWeather(fname, type):
    f = open(fname, 'r')
    if type == 'airport':
        date = []
        temp = np.array([])
        dewpnt = np.array([])
        humid = np.array([])
        baro = np.array([])
        vis = np.array([])
        winddir = np.array([])
        windspd = np.array([])
        windgst = np.array([])
        precip = np.array([])
        events = []
        cond = []

        x = f.readline() # discard headers
        x = f.readline()
        while x:
            y = x.split(',')
            date.append(md.num2date(md.datestr2num(y[1])))
            temp = np.hstack([temp, y[2]])
            dewpnt = np.hstack([dewpnt, y[3]])
            humid = np.hstack([humid, y[4]])
            baro = np.hstack([baro, y[5]])
            vis = np.hstack([vis, y[6]])
            winddir = np.hstack([winddir, windBins(y[7])])

            if y[8] == 'calm' or y[8] == 'Calm':
                windspd = np.hstack([windspd, np.nan])
            else:
                windspd = np.hstack([windspd, y[8]])

            if y[9] == '-':
                windgst = np.hstack([windspd, np.nan])
            else:
                windspd = np.hstack([windspd, y[9]])

            if y[10] == 'N/A':
                precip = np.hstack([precip, np.nan])
            else:
                precip = np.hstack([precip, y[10]])

            events.append(y[11])
            cond.append(y[12][:-1])

            x = f.readline()

        output = {'date'    : date,
                  'temp'    : temp,
                  'dewpnt'  : dewpnt,
                  'humid'   : humid,
                  'baro'    : baro,
                  'visib'   : vis,
                  'winddir' : np.ma.masked_array(winddir, np.isnan(winddir)),
                  'windspd' : np.ma.masked_array(windspd, np.isnan(windspd)),
                  'windgst' : np.ma.masked_array(windgst, np.isnan(windgst)),
                  'precip'  : precip,
                  'events'  : events,
                  'cond'    : cond}

    # elif type == 'pws':
        # output = None

    # else:
        # output = None

    f.close()
    return output

def sqlWeather(fname, type, cnn=None):
    f = open(fname, 'r')
    if type == 'airport':
        date = []
        temp = np.array([])
        dewpnt = np.array([])
        humid = np.array([])
        baro = np.array([])
        vis = np.array([])
        winddir = np.array([])
        windspd = np.array([])
        windgst = np.array([])
        precip = np.array([])
        events = []
        cond = []

        x = f.readline()
        x = f.readline()
        cnt = 0
        while x:
            y = x.split('\n')
            y = y[0].split(',')
            date = (md.num2date(md.datestr2num(y[1])))
            temp = y[2]
            dewpnt = y[3]
            humid = y[4]
            baro = y[5]
            vis = y[6]
            winddir = windBins(y[7], calmVar=0)
            if y[8] == 'calm' or y[8] == 'Calm':
                windspd = 'NULL'
            else:
                windspd = y[8]

            if y[9] == '-':
                windgst = 'NULL'
            else:
                windspd = y[9]

            if y[10] == 'N/A':
                precip = 0
            else:
                precip = y[10]

            if len(events = y[11]) < 2:
                events = 'NULL'
            else:
                events = y[11]

            cond = y[12][:-1]

            cmd = """INSERT INTO test_%s
            (date, time, temp, dewpnt, humid, baro, vis, winddir,
            windspd, windgst, precip, events, cond)
            VALUES
            ('%s', '%s', %s, %s, %s, %s, %s, %s, %s, %s, %s, '%s', '%s')""" \
            % (type, str(date.date()), str(date.time()), temp, dewpnt, humid,
            baro, vis, winddir, windspd, windgst, precip, events,cond)

            print(cmd)
            x = f.readline()
            #cur.execute(cmd)
    # elif type == 'pws':
        # output = None

    # else:
        # output = None

    f.close()
    # cnn.commit()
    # cnn.close()


def windBins(windDir, calmVar=np.nan):
    '''
    This takes a string describing a direction and converts it to a degree
    relative to North. Input strings can be like "North" or "N" for the
    cardinal directions and "NE", "SSW" for everything else.
    '''
    if windDir == 'North' or windDir == 'N':
        bin = 0
    elif windDir == 'South' or windDir == 'S':
        bin = 180.0
    elif windDir == 'East' or windDir == 'E':
        bin = 90.0
    elif windDir == 'West' or windDir == 'W':
        bin = 270.0
    elif windDir == 'NE':
        bin = 45.0
    elif windDir == 'SE':
        bin = 135.0
    elif windDir == 'SW':
        bin = 225.0
    elif windDir == 'NW':
        bin = 315.0
    elif windDir == 'NNE':
        bin = 22.5
    elif windDir == 'ENE':
        bin = 67.5
    elif windDir == 'ESE':
        bin = 112.5
    elif windDir == 'SSE':
        bin = 157.5
    elif windDir == 'SSW':
        bin = 202.5
    elif windDir == 'WSW':
        bin = 247.5
    elif windDir == 'WNW':
        bin = 292.5
    elif windDir == 'NNW':
        bin = 337.5
    elif windDir == 'calm' or windDir == 'Calm' or 'Variable' or 'variable':
        bin = calmVar

    return bin


def tideAnalysis(fname):
    '''This function reads tidal data like the one
    from the URL below:
    http://tinyurl.com/ceo3dr

    Save the text file in your Python path, then:
    >>> from weaterData import tideAnalysis
    >>> P,M = tideAnalysis(fname)

    Input:
        fname : str
            This is the name of the file containing NOAA tidal data

    Output:
        P : array, float
            This is a numpy array of the predicted water surface elevation
        M : array, float
            This is a numpy array of the measured water surface elevation
     +-----------------------------------+
     | Paul M. Hobson             __o    |
     | phobson@geosyntec.com    _`\<,_   |
     | 2009/03/11              (_)/ (_)  |
     +-----------------------------------+
    '''

    f = open(fname)                     # open the file
    X = f.readlines()                   # read the file
    f.close()                           # close the file
    X = X[7:]                           # skip the first 7 lines
    P = np.zeros([len(X),1])               # set up the predicted WS elev
    M = np.zeros([len(X),1])               # set up the measured WS elev
    for i in range(len(X)):             # go through every row in the file
        P[i] = float(X[i][22:30])       # read the predicted value
        try:                            # read the measured value with some
            M[i] = float(X[i][30:-1])   #   error handling
        except ValueError:
            M[i] = 0.000

    return P,M                          # return the WS elevations
