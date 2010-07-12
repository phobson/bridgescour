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

def rheoWaterContent(rheoInfo):
    #rheoInfo = getRheoInfo(loc_id, tube_num, sn)
    Msw = rheoInfo['mcsw'] - rheoInfo['mc']
    Ms = rheoInfo['mps'] - rheoInfo['mp']
    Mw = Msw - Ms
    wc = Mw/Ms
    return wc

def yieldStress(rheoData, rheoInfo):
    import numpy as np
    import matplotlib.pyplot as pl
    import NumUtils as nu
    g, t, gd = (rheoData['gamma'], rheoData['tau'], rheoData['gammadot'])
    LI = rheoInfo['lowerN']
    UI = rheoInfo['upperN']

    # lower yield stress
    gL1 = g[LI[0,0]:LI[0,1]]
    tL1 = t[LI[0,0]:LI[0,1]]

    gL2 = g[LI[1,0]:LI[1,1]]
    tL1 = g[LI[1,0]:LI[1,1]]

    aL1, bL1 = nu.powerFit(tL1, gL1)
    aL2, bL2 = nu.powerFit(tL2, gL2)

    # upper yield stress
    gdU1 = gd[UI[0,0]:UI[0,1]]
    tU1 = t[UI[0,0]:UI[0,1]]

    gdU2 = gd[UI[1,0]:UI[1,1]]
    tU2 = t[UI[1,0]:UI[1,1]]

    mU1, rU1 = nu.linFit(gdU1, tU1)
    m1, b1 = (mU1[0], mU1[1])
    mU2, rU2 = nu.linFit(gdU2, tU2)
    m2, b2 = (mU2[0], mU2[1])

    tau_y = {'lower' : np.exp(np.log(aL2/aL1)/(bL1/bL2)),
             'upper' : (b2-b1)/(m1-m2)}

    ys = {'lowerYS' : np.exp(np.log(aL2/aL1)/(bL1/bL2)),
          'upperYS' : (b2-b1)/(m1-m2),
          'gamma_y' : aL1 * tau_y['lower']**bL1,
          'gammadot_y' : m1*tau_y['upper'] + b1,
          'lowerfit' : np.array([[aL1, bL1],[aL2, bL2]]),
          'upperfit' : np.array([[m1, b1],[m2.b2]])}

    return ys

def plotRheoData(rheoData, rheoInfo):
    import numpy as np
    import matplotlib.pyplot as pl
    #rheoData = getRheoData(loc_id, tube_num, sn)
    #rheoInfo = getRheoInfo(loc_id, tube_num, sn)
    ys = yieldStress(rheoData, rheoInfo)
    g, t, gd = (rheoData['gamma'], rheoData['tau'], rheoData['gammadot'])
    LI = rheoInfo['lowerN']
    UI = rheoInfo['upperN']

    a1, c1 = (ys['lowerfit'][0,0], ys['lowerfit'][0,1])
    a2, c2 = (ys['lowerfit'][1,0], ys['lowerfit'][1,1])
    t_ = np.logspace(-2,2)
    g1_ = a1 * t_**c1
    g2_ = a2 * t_**c2

    fig = pl.figure(figsize=[5,6])
    ax1 = fig.add_axes([0.12, 0.59, 0.85, 0.38])
    ax2 = fig.add_axes([0.12, 0.10, 0.85, 0.38])

    ax1.plot(t, g, 'k.',zorder=0, alpha=0.85, label='Rheometer Data')
    ax1.plot(t[LI[0,0]:LI[0,1]], g[LI[0,0]:LI[0,1]],
             'o', mec='b', mfc='none', label='_nolegend')
    ax1.plot(t[LI[1,0]:LI[1,1]], g[LI[1,0]:LI[1,1]],
             'o', mec='g', mfc='none', label='_nolegend')
    ax1.plot(t_, g1_, 'k-', lw=0.5, zorder=5, alpha=0.85, label='Power Fits')
    ax1.plot(t_, g2_, 'k-', lw=0.5, zorder=5, alpha=0.85, label='_nolegend')
    ax1.plot(ys['lower'], ys['gamma_y'], 'r*', label='yield stress')

    ax2.plot(gd, t, 'k.', zorder=0, alpha=0.85)
    ax2.plot(gd[UI[0,0]:UI[0,1]], t[UI[0,0]:UI[0,1]], 'o', mec='b', mfc='none')
    ax2.plot(gd[UI[1,0]:UI[1,1]], t[UI[1,0]:UI[1,1]], 'o', mec='g', mfc='none')

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

def  __test_getRheoData(rheoInfo):
    rheoData = getRheoData(11,1,1)
    print(rheoData['gamma'].shape)
    print(rheoData['tau'].shape)
    print(rheoData['gammadot'].shape)

def __test_rheoWaterContent(rheoInfo):
    for ri in rheoInfo:
        wc = rheoWaterContent(ri)
        print(wc)

def __test_plotRheoData(rheoData, rheoInfo):
    for rd, ri in zip(rheoData, rheoInfo):
        plotRheoData(rd, ri)


def __test_rheometer():
    ri1 = getRheoInfo(11,1,1)
    ri2 = getRheoInfo(11,1,2)
    ri3 = getRheoInfo(11,1,3)
    ri4 = getRheoInfo(11,2,1)
    ri5 = getRheoInfo(11,2,2)
    ri6 = getRheoInfo(11,2,3)
    rheoInfo = [ri1, ri2, ri3, ri4, ri5, ri6]

    rd1 = getRheoData(11,1,1)
    rd2 = getRheoData(11,1,2)
    rd3 = getRheoData(11,1,3)
    rd4 = getRheoData(11,2,1)
    rd5 = getRheoData(11,2,2)
    rd6 = getRheoData(11,2,3)
    rheoData = [rd1, rd2, rd3, rd4, rd5, rd6]

    __test_rheoWaterContent(rheoInfo)
    __test_plotRheoData(rheoData, rheoInfo)


if 1:
    __test_rheometer()
