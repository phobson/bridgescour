'''POTENTIOMETER.PY
Collection of function to process, use, and plot potentiometer data.
Planeed functions/routines:
    -getExtrusionData
    -getErosionData
    -extrusionLength
    -erosionRate
'''

from __future__ import division
from MiscUtils import connectToDB

def getPotData(loc_id, tube_num, sn, table):
    import numpy as np
    cmd = """
    SELECT rn, disp
    FROM %s
    WHERE loc_id   = %d
      AND tube_num = %d
      AND sn       = %d
    """ % (table, loc_id, tube_num, sn)
    cnn, cur = connectToDB(cmd)
    t = np.array([])
    d = np.array([])

    for c in cur:
        t = np.hstack([t, c[0]])
        d = np.hstack([d, c[0]])

    cur.close()
    cnn.close()
    return t, d

def getExtrusionData(loc_id, tube_num, sn):
    t, d = getPotData(loc_id, tube_num, sn, 'extrusion')
    cmd = """
    SELECT sf,
           dur,
           in1, in2,
           msw,
           note,
           wc_sn
    FROM extrusion_info
    WHERE loc_id   = %d
      AND tube_num = %d
      AND sn       = %d
    """ % (loc_id, tube_num, sn)
    cnn, cur = connectToDB(cmd)
    test = cur.fetchone()

    info = {'sf' : test[0],
            'dur' : test[1],
            'index' : (test[2], test[3]),
            'mss' : test[4],
            'note' : test[5],
            'wc_sn' : test[6]}

    cur.close()
    cnn.close()
    return t, d, info

def getErosionData(loc_id, tube_num, sn):
    t,d = getPotData(loc_id, tube_num, sn, 'erosion')
    cmd = """
    SELECT EI.sf,
           EI.tau,
           EI.dur,
            C.descr,
           EI.note,
           EI.wc_sn,
           EI.ext_sn
    FROM erosion_info EI
    INNER JOIN codes C on C.code = EI.erosion_type
    WHERE EI.loc_id   = %d
      AND EI.tube_num = %d
      AND EI.sn       = %d
    """ % (loc_id, tube_num, sn)
    cnn, cur = connectToDB(cmd)
    test = cur.fetchone()

    info = {'sf' : test[0],
                'tau' : test[1],
                'dur' : test[2],
                'type' : test[3],
                'note' : test[4],
                'wc_sn' : test[5],
                'ext_sn' : test[6]}

    cur.close()
    cnn.close()
    return t, d, info


def extrusionLength(loc_id, tube_num, sn):
    t, d, info = getExtrusionData(loc_id, tube_num, sn)
    N = info['index']
    h1 = d[:N[0]].mean()
    h2 = d[N[1]:].mean()
    h = h2 - h1
    return h


def __test_getAllData(table):
    #Tables = ['erosion', 'erosion_info', 'extrusion', 'extrusion_info']
    cmd = """
    SELECT DISTINCT loc_id, tube_num, sn
    FROM %s""" % table
    cnn, cur = connectToDB(cmd)
    loc_id = []
    tube_num = []
    sn = []
    for c in cur:
        loc_id.append(c[0])
        tube_num.append(c[1])
        sn.append(c[2])

    return loc_id, tube_num, sn

def __test_getPotData():
    Tables = ['erosion', 'erosion_info', 'extrusion', 'extrusion_info']
    for table in Tables:
        loc_id, tube_num, sam_num = __test_getAllData(table)
        for lid, tnum, snum in zip(loc_id, tube_num, sam_num):
            t,d = getPotData(lid, tnum, snum, 'extrusion')

def __test_getExtrusionData():
    Tables = ['extrusion', 'extrusion_info']
    for table in Tables:
        loc_id, tube_num, sam_num = __test_getAllData(table)
        for lid, tnum, snum in zip(loc_id, tube_num, sam_num):
            t, d, info = getExtrusionData(lid, tnum, snum)

def __test_getErosionData():
    Tables = ['erosion', 'erosion_info']
    for table in Tables:
        loc_id, tube_num, sam_num = __test_getAllData(table)
        for lid, tnum, snum in zip(loc_id, tube_num, sam_num):
            t, d, info = getErosionData(lid, tnum, snum)


def __test_extrusionLength():
    h = []
    Tables = ['extrusion', 'extrusion_info']
    for table in Tables:
        loc_id, tube_num, sam_num = __test_getAllData(table)
        for lid, tnum, snum in zip(loc_id, tube_num, sam_num):
            h.append(extrusionLength(lid, tnum, snum))
    return h

def __test_potentiometer():
    #__test_getAllData()
    __test_getPotData()
    __test_getExtrusionData()
    __test_getErosionData()
    h = __test_extrusionLength()
    return h



if 1:
    h=__test_potentiometer()


