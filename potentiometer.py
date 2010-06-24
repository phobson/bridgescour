'''POTENTIOMETER.PY
Collection of function to process, use, and plot potentiometer data.
Planeed functions/routines:
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
           wcs_sn
    FROM luextrusion
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
            'wcs_sn' : test[6]}

    cur.close()
    cnn.close()
    return t, d, info

def getErosionData(loc_id, tube_num, sn):
    t,d = getPotData(loc_id, tube_num, sn, 'erosion')
    cmd = """
    SELECT LUE.sf,
           LUE.tau,
           LUE.dur,
             C.descr,
           LUE.note,
           LUE.wcs_sn,
           LUE.ext_sn
    FROM luerosion LUE
    INNER JOIN codes C on C.code = LUE.erosion_type
    WHERE LUE.loc_id   = %d
      AND LUE.tube_num = %d
      AND LUE.sn       = %d
    """ % (loc_id, tube_num, sn)
    cnn, cur = connectToDB(cmd)
    test = cur.fetchone()

    info = {'sf' : test[0],
                'tau' : test[1],
                'dur' : test[2],
                'type' : test[3],
                'note' : test[4],
                'wcs_sn' : test[5],
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


def __test_getPotData():
    loc_id = 11
    tube_num = 1
    sn = 1
    t1, d1 = getPotData(loc_id, tube_num, sn, 'extrusion')
    t2, d2 = getPotData(loc_id, tube_num, sn, 'erosion')

def __test_getExtrusionData():
    loc_id = 11
    tube_num = 1
    sn = 1
    t, d, info = getExtrusionData(loc_id, tube_num, sn)

def __test_getErosionData():
    loc_id = 11
    tube_num = 1
    sn = 1
    t, d, info = getErosionData(loc_id, tube_num, sn)

def __test_extrusionLength():
    loc_id = 11
    tube_num = 1
    sn = 1
    h = extrusionLength(loc_id, tube_num, sn)
    print(h)

def __test_potentiometer():
    __test_getPotData()
    __test_getExtrusionData()
    __test_getErosionData()
    __test_extrusionLength()



if 1:
    __test_potentiometer()


