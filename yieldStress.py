#~ things to demo
#~ add transparency to power fits, yield point, water content
#~ make yield point a red star ('r*')
#~ change grid line style to ':'
#~ make minor grid invisible
#~ change to ax = fig.add_axes((0.12,0.15,0.83,0.8))
#~ add figtext
def getTubeID(cnn, name, num=1):
    cur = cnn.cursor(cursorclass=db.cursors.DictCursor)
    cmd = "SELECT id FROM tubes WHERE name = '%s' AND num = %s" % (name, num)
    cur.execute(cmd)
    d = cur.fetchall()
    id = int(d[0]['id'])
    return id

def selectAll(cnn, table, col, val):
    cur = cnn.cursor(cursorclass=db.cursors.DictCursor)
    cmd = "SELECT * FROM %s WHERE %s=%s" % (table, col, val)
    cur.execute(cmd)
    data = cur.fetchall()
    return data


# sample names to run through
def yieldStress(cnn, name):
    import sys
    sys.path.append(r'c:\stuff\utils\py')     # let python look for my modules
    import matplotlib.pyplot as pl
    import MySQLdb as db
    import LinearRegressions as lr
    #from datetime import datetime
    from MiscUtils import leadingZeros
    from numpy import log, exp, logspace

    # initialize empty arrays for output
    TY = []
    GY = []
    W = []
    table_guts = []
    figure_names = []
    figure_captions = [] # Plot showing the rheometer test data and yield stress of the fines from [river] in [county] County, GA

    # get sample IDs and rheometer test info
    id = getTubeID(cnn, name)
    yield_info = selectAll(cnn, 'luysd', 'id', id)
    tube_data = selectAll(cnn, 'tubes', 'id', id)

    # go through each rheometer test of this sample
    for x in yield_info:

        # pull out the sample number and get that test's data
        sn = x['sn']
        
        pathfile = r'c:\stuff\gdag2009\beamer\yield_stress_' + name + '_' + str(int(sn)) + '.pdf'
        path, fname = os.path.split(pathfile)

        yield_data = selectAll(cnn, 'ysd', 'sn', sn)
        figure_names.append('{' + fname[:-4] + '}')

        # Sample info
        riv = tube_data[0]['river']
        cty = tube_data[0]['county']
        top = tube_data[0]['top']
        bot = tube_data[0]['bottom']
        sLocation = '%s in %s County' % (riv, cty)
        sDepth = 'Sample Depth: %s ft to %s ft BGS' % (top, bot)

        # Determine Water Content of the Soil
        Mc = x['Mc']        # mass of the rheometer cup (g)
        Mcsw = x['Mcsw']    # mass of the cup+soil+water (g)
        Mp = x['Mp']        # mass of the evaporating pan (g)
        Mps = x['Mps']      # mass of the pan+soil (g)

        Ms = Mps - Mp               # mass of the soil (g)
        Mw = Mcsw - Mc - Ms         # mass of the water (g)
        w = round(Mw/Ms,2)          # water content of the slurry (dec. frac.)

        # intiliaze data arrays
        gam = []
        tau = []
        for r in yield_data:
            gam.append(r['gam']) # strain
            tau.append(r['tau']) # shear stress (Pa)

        # use info about the data to select point for
        # linear fitting to determing the yield stress
        gam1 = gam[x['L11']:x['L12']]
        gam2 = gam[x['U11']:x['U12']]

        tau1 = tau[x['L11']:x['L12']]
        tau2 = tau[x['U11']:x['U12']]

        # do the regressions
        X1 = lr.powerFit(tau1, gam1)
        X2 = lr.powerFit(tau2, gam2)

        # create lines for plotting
        tau_ = logspace(-2,2)
        gam1_ = X1[0] * (tau_**X1[1])
        gam2_ = X2[0] * (tau_**X2[1])

        # model coefficients
        # lower line: y = ax^b
        a = X1[0]
        b = X1[1]

        # upper line: y = cx^d
        c = X2[0]
        d = X2[1]

        # find intersection of models to determine
        # stress and strain at yield
        ty = exp(log(c/a)/(b-d))
        gy = a * ty**b

        # append those yield values to a final list
        TY.append(ty)
        GY.append(gy)
        W.append(w)

        # Create a legend labels based a on the yield stress
        tyLabel = r'Yield Stress' ####
        #tyLabel = r'Yield Stress, $\tau_{y} =  %s$ Pa at $w = %s$' %  (round(ty,2), w) ####

        table_tex = r"%s & %s & %s & %s & %s & %s \\" % (sn, cty, riv, round(ty,2), round(gy,2), w)
        cap = '{Plot showing the rheometer test data and yield stress of the fines from %s ft to %s ft BGS from %s in %s County, GA in a slurry with a water content of %s.}' % (top, bot, riv, cty, w)
        table_guts.append(table_tex + '\n')
        figure_captions.append(cap)
        

        fig = pl.figure(figsize=(5,3))
        #ax = fig.add_axes((0.12,0.15,0.85,0.8))
        ax = fig.add_axes((0.15,0.15,0.8,0.8))
        D = ax.loglog(tau, gam, 'k.', ms=4, lw=2, label='Rheometer Data', zorder=5)
        R1 = ax.loglog(tau_, gam1_, 'k-', lw=1.25, label='Power Fits', zorder=5, alpha=1) ####
        R2 = ax.loglog(tau_, gam2_, 'k-', lw=1.25, label='_nolegend_', zorder=5, alpha=1) ####
        YS = ax.plot(ty, gy, 'go', ms=10, mew=1, label=tyLabel, zorder=10, alpha=1.0) ####
        #pl.figtext(0.13,0.67, sLocation, fontsize=8)
        #pl.figtext(0.13,0.63, sDepth, fontsize=8)
        ax.set_ylabel(r'Strain, $\gamma$')
        ax.set_xlabel(r'Stress, $\tau$ (Pa)')

        GLS = '-' # grid line style ####
        #GLS = ':' # grid line style ####
        ax.yaxis.grid(True, which='major', linestyle=GLS,
                        color='0.5', lw=0.5, zorder=0, alpha=1)
        ax.yaxis.grid(True, linestyle=GLS, which='minor',
                        color='0.75', lw=0.5, zorder=0, alpha=1)
        ax.xaxis.grid(True, which='major', linestyle=GLS,
                        color='0.5', lw=0.5, zorder=0, alpha=1)
        ax.xaxis.grid(True, linestyle=GLS, which='minor',
                        color='0.75', lw=0.5, zorder=0, alpha=1)
        ax.set_xlim([0.01,100])
        ax.set_ylim([0.0001,100000])
        ax.legend(loc='upper left')
        pl.savefig(pathfile, dpi=300)
        print 'Figure %s saved, wooo!' % (file,)
        pl.close(fig)
        print table_guts
        print figure_names
        print figure_captions

    return TY, GY, W, table_guts, figure_names, figure_captions


import MySQLdb as db
import sys
import os
import matplotlib.pyplot as pl
sys.path.append(r'c:\utils\py')     # let python look for my modules
f = open('c:\stuff\gdag2009\python\puppies.dat', 'r')
pd = f.read().split(',')

# CODE TO USE ALL OF THE FUNCTION DEFINED ABOVE
# connect to the MySQL database
cnn = db.connect(host='localhost',
                 user='paul',
                 passwd=pd[0],
                 db='erosion')


#constructFigure(cnn)
sample_names = ['1A', '1B']#, '2A', '2B', '3A', '3B']


#colors = ['ko', 'gs', 'b^', 'mp', 'rd', 'c*']
colors = ['ko', 'go', 'bo', 'mo', 'ro', 'co']


# create new figure
fig1 = pl.figure(figsize=(8,4))

# create yield stress axis
ax1 = fig1.add_axes((0.075,0.12,0.4,0.83))
ax1.hold = True

# create yield strain axis
ax2 = fig1.add_axes((0.575,0.12,0.4,0.83))
ax2.hold = True
n = 0

# LaTeX output
#tables
os.system(r'del c:\stuff\gdag2009\beamer\table.tex')
os.system(r'del c:\stuff\gdag2009\beamer\figures.tex')
fTable = open(r'c:\stuff\gdag2009\beamer\table.tex', 'w')
fFigures = open(r'c:\stuff\gdag2009\beamer\figures.tex', 'w')

table_start = r"\begin{tabular}{c c c c c c}" + '\n' + \
                r"\toprule" + '\n' + \
                r"Sample Number & County & River & Water Content $\left(\dfrac{M_w}{M_s}\right)$ & " + '\n' + \
                r"Yield Stress ($\tau_y$) & Yield Strain ($\gamma_y$) \\" + '\n' + \
                r"\toprule" + '\n'
table_stop = r"\bottomrule" + '\n' + r"\end{tabular}"
figure_start = r"\begin{figure}" + '\n' + r"\centering"  + '\n'

fTable.write(table_start)

for name in sample_names:
    leg_label = 'Sample %s' % (name,)
    t,g,w, tg,fn,fc = yieldStress(cnn, name)
    ax1.plot(w, t, colors[n], ms=8, mec='k', mfc='none', label='_nolegend_', zorder=10)
    ax1.plot(w, t, colors[n], ms=8, mec='none', label=leg_label, zorder=10, alpha=0.5)
    ax2.semilogy(w, g, colors[n], ms=8, mec='k', mfc='none',label='_nolegend_', zorder=10)
    ax2.semilogy(w, g, colors[n], ms=8, mec='none', label=leg_label, zorder=10, alpha=0.5)
    n += 1
#    fFigures.write(r'\subsection{}')
    for n in range(len(tg)):
        fTable.write(r'\midrule' + '\n')
        fTable.write(tg[n])
        
        fFigures.write(figure_start)
        fFigures.write(r'\includegraphics')
        fFigures.write(fn[n] + '\n')
        fFigures.write(r'\caption')
        fFigures.write(fc[n] + '\n')
        fFigures.write(r'\label')
        fFigures.write(fn[n] + '\n')
        fFigures.write(r'\end{figure}' + '\n\n\n')
    fFigures.write(r'\clearpage')

ax1.set_xlabel(r'Water Content, $w=\frac{M_w}{M_s}$')
ax1.set_ylabel(r'Yield Stress, $\tau_y$ (Pa)')
ax1.set_xlim = ([0,5])
ax1.set_ylim = ([0,3.5])
ax1.legend(loc='upper right')


ax2.set_xlabel(r'Water Content, $w=\frac{M_w}{M_s}$')
ax2.set_ylabel(r'Yield Strain, $\gamma_y$')
ax1.set_xlim = ([0,5])
ax1.set_ylim = ([0.01,0.3])
ax2.legend(loc='lower right')

pl.savefig(r'c:\stuff\gdag2009\beamer\subplot.pdf', dpi=300)
pl.close('all')

fTable.write(table_stop)
fTable.close()
fFigures.close()


os.chdir(r'c:\stuff\gdag2009\beamer')
os.system(r'pdflatex pmhGDAG_python')
os.system(r'pdflatex report')
os.system(r'pdflatex report')
os.chdir(r'c:\stuff\gdag2009\python')



