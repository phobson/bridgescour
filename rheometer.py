'''Utilities to get and process data from a rheometer'''

from __future__ import division
from MiscUtils import connectToDB

def getRheoData(loc_id, tube_num, sn):
    import numpy as np
    cmd = """
    SELECT gam, tau, gmd
    FROM yieldstress
    WHERE loc_id = %d
      AND tube_num = %d
      AND sn = %d""" % (loc_id, tube_num, sn)
    cnn, cur = connectToDB(cmd)
    gamma = np.array([])
    tau = np.array([])
    gammadot = np.array([])
    for c in cur:
        gamma = np.hstack([gamma, c[0]])
        tau = np.hstack([tau, c[1]])
        gammadot = np.hstack([gammadot, c[2]])

    rheoData = {'gamma'   : gamma,
                'tau'     : tau,
                'gammadot' : gammadot
                }

    cur.close()
    cnn.close()
    return rheoData

def getRheoInfo(loc_id, tube_num, sn):
    import numpy as np
    cmd = """
    SELECT *
    FROM yieldstress_info
    WHERE loc_id = %d
      AND tube_num = %d
      AND sn = %d""" % (loc_id, tube_num, sn)
    cnn, cur = connectToDB(cmd)
    c  = cur.fetchone()
    rheoInfo = {'tauMin' : c[3],
                'tauMax' : c[4],
                'dur'    : c[5],
                'mc'     : c[6],
                'mcsw'   : c[7],
                'mp'     : c[8],
                'mps'    : c[9],
                'lowerN' : np.array([c[10:12], c[12:14]]),
                'upperN' : np.array([c[14:16], c[16:18]]),
                'axLimU' : np.array([c[18:20], c[20:22]]),
                'y'      : np.array([c[22:24], c[24:]])
                }


    cur.close()
    cnn.close()
    return rheoInfo

def plotRheoData(loc_id, tube_num, sn):
    import numpy as np
    import matplotlib.pyplot as pl
    rheoData = getRheoData(loc_id, tube_num, sn)
    rheoInfo = getRheoInfo(loc_id, tube_num, sn)

    g, t, gd = (rheoData['gamma'], rheoData['tau'], rheoData['gammadot'])
    LI = rheoInfo['lowerN']
    UI = rheoInfo['upperN']

    fig = pl.figure(figsize=[5,6])
    ax1 = fig.add_axes([0.12, 0.59, 0.85, 0.38])
    ax2 = fig.add_axes([0.12, 0.10, 0.85, 0.38])

    ax1.plot(t, g, 'k.')
    ax1.plot(t[LI[0,0]:LI[0,1]], g[LI[0,0]:LI[0,1]], 'bo')
    ax1.plot(t[LI[1,0]:LI[1,1]], g[LI[1,0]:LI[1,1]], 'go')

    ax2.plot(gd, t, 'k.')
    ax2.plot(gd[UI[0,0]:UI[0,1]], t[UI[0,0]:UI[0,1]], 'bo')
    ax2.plot(gd[UI[1,0]:UI[1,1]], t[UI[1,0]:UI[1,1]], 'go')

    ax1.set_xlabel(r'Shear Stress, $\tau$ (Pa)')
    ax1.set_ylabel(r'Strain, $\gamma$')
    ax1.set_xscale('log')
    ax1.set_yscale('log')
    ax1.xaxis.grid(True, which='major', ls='-', lw=0.50, alpha=0.25)
    ax1.xaxis.grid(True, which='minor', ls='-', lw=0.25, alpha=0.25)
    ax1.yaxis.grid(True, which='major', ls='-', lw=0.50, alpha=0.25)
    ax1.yaxis.grid(True, which='minor', ls='-', lw=0.25, alpha=0.25)

    ax2.set_xlabel(r'Strain Rate, $\dot{\gamma}$ ($\mathrm{s}^{-1}$) ')
    ax2.set_ylabel(r'Shear Stress, $\tau$ (Pa)')
    ax2.xaxis.grid(True,  which='major', ls='-', lw=0.50, alpha=0.25)
    ax2.xaxis.grid(False, which='minor', ls='-', lw=0.25, alpha=0.25)
    ax2.yaxis.grid(True,  which='major', ls='-', lw=0.50, alpha=0.25)
    ax2.yaxis.grid(False, which='minor', ls='-', lw=0.25, alpha=0.25)

    fig.savefig('Rheo_%d-%d-%d.pdf' % (loc_id, tube_num, sn))
    pl.close(fig)

def __test_getRheoData():
    rheoData = getRheoData(11,1,1)
    print(rheoData['gamma'].shape)
    print(rheoData['tau'].shape)
    print(rheoData['gammadot'].shape)

def __test_getRheoInfo():
    rheoInfo = getRheoInfo(11,1,1)
    print(rheoInfo)

def __test_plotRheoData():
    plotRheoData(11,1,1)
    plotRheoData(11,1,2)
    plotRheoData(11,1,3)
    plotRheoData(11,2,1)
    plotRheoData(11,2,2)
    plotRheoData(11,2,3)


def __test_rheometer():
    __test_getRheoData()
    __test_getRheoInfo()
    __test_plotRheoData()


if 1:
    __test_rheometer()
