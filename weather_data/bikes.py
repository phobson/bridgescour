import matplotlib.pyplot as pl
import numpy as np

def resample(t1, x1, d):
    N = len(t1)
    index = range(0,N,d)
    t2 = []
    x2 = []
    for n in index[1:-1]:
        t2.append(t1[n])
        x2.append(np.mean(x1[n-d:n]))
        
    t3 = np.hstack([t1[0], t2, t1[-1]])
    x3 = np.hstack([x1[0], x2, x1[-1]])
    
    return t3, x3
    

def readElevData(fIN, delim=","):
    # load data from file
    x2,y2 = np.loadtxt(fIN, delimiter=',', 
                     skiprows=1, unpack=True, 
                     usecols=[0,1])
                     
    #x2, y2 = resample(x,y,15)    
    
    # calculate and smooth the gradient along x-axis
    g = np.zeros(len(x2))
    for n in range(1,len(x2)):
        g[n] = (y2[n] - y2[n-1])/(x2[n]-x2[n-1])*100
    g = smoothData(g,15,1)

    return x2, y2, g
    

def setFigStuff(x,y,g,lc,ax):
    # add and formate axis labels
    ax.set_xlabel('Distance Ridden (km)', fontsize=10)
    ax.set_ylabel('Elevation (m above MSL)', fontsize=10)

    # set axes limits
    glimits = (wholeFloor(g,0), wholeCeil(g,0))
    ylimits = (wholeFloor(y,2), wholeCeil(y,2))
    xlimits = (0, x[-1] + 0.5)
    
    ax.set_ylim(*ylimits)
    ax.set_xlim(*xlimits)
    ax.yaxis.grid(True, linestyle='-', which='major', 
                  color='0.0', alpha=0.25, lw=0.5)
    ax.xaxis.grid(True, linestyle='-', which='major', 
                  color='0.0', alpha=0.25, lw=0.5)

    # create and format the colorbar
    cbar = pl.colorbar(lc, ticks=range(*glimits))    
    cbar.ax.set_ylabel(r'Gradient ($\%$)', fontsize=10)

def elevColorMap(fIN, delim=',', gres=0.25, fs=4, fOUT='elev.pdf'):
    r'''PLOT ELEVATION PROFILE AND GRADIENT FROM ELEVATION DATA
    
    INPUT
        fIN : str (req'd)
            This is the file name of the data. First column should be
            x-data. Second column should be y-data. Subsequent columns
            are ignored.
            
        delim : str (opt)
            This is the delimiter string of the file. Defaults to commas.
            Use '\t' for tab-delimited files.
            
        gres : float (opt)
            This is the resolution of the gradient's colormap.
            Defaults to 0.5%
            
        fOUT : str (opt)
            This is the file image of the image output by this utility.
            Defaults to 'elev.png'. pl.savefig command can infer file
            format from most common image extensions (e.g., .pdf, .gif...)
            
    OUTPUT
        NONE

    EXAMPLE
        >>> os.chdir('users/paul/python/misc')
        >>> from bikes import *
        >>> elevColorMap('users/paul/desktop/elev.txt', delim='\t', gres=1)

    '''
    import matplotlib.cm as cm
    import matplotlib.mlab as mlab
    import matplotlib.colors as colors
    from matplotlib.patches import Ellipse
        
    # load data from file
    x, y, g = readElevData(fIN, delim=delim)
   
    # whacky stuff with setting up the gradient matrix
    Y = y * 10.
    C = int(len(x))
    R = int(np.ceil(max(Y)))

    # populate gradient matrix
    yin = np.arange(R)
    p = np.zeros([R,C]) - 999
    for n in range(C):
        p[0:Y[n],n] = g[n]
      
    # mask that array
    pm = np.ma.masked_array(p, p == -999)

    # determine range of gradients present in data
    g1 = int(np.floor(min(g)))
    g2 = int(np.ceil(max(g)))
    
    gr = max((np.abs(g1), np.abs(g2)))

    # set up the colormap's range and 
    # resolution (set to 0.5%)
    V = np.arange(-gr,gr+1, gres) 
    
    # setup the figure
    fig = pl.figure(1, figsize=(fs*1.62,fs))
    ax = fig.add_axes([0.110, 0.125, 0.875, 0.850])
    
    # plot the gradient colormap
    x = x/1000.
    G1 = ax.contourf(x, yin/10, pm, V,
                     antialiased=False, 
                     cmap=cm.RdBu_r,
                     norm=pl.Normalize((-gr,gr)))
    G2 = ax.contour(x, yin/10, pm, V,
                    antialiased=False, 
                    cmap=cm.RdBu_r,
                    norm=pl.Normalize((-gr,gr)))
    
    n1, = np.where(g==g.min())[0]
    n2, = np.where(g==g.max())[0]
    
    # plot the elevation profile
    elv = ax.plot(x, y, 'k-', lw=2.0, label='Elevation')
    
    # create and format the colorbar
    cbar = pl.colorbar(G1, ticks=range(-gr,gr+1))    
    cbar.ax.set_ylabel(r'Gradient ($\%$)', fontsize=10)
    
    #setFigStuff(x,y,g,ax)

    # add and formate axis labels
    ax.set_xlabel('Distance Ridden (km)', fontsize=10)
    ax.set_ylabel('Elevation (m above MSL)', fontsize=10)

    # set axes limits
    ylimits = (wholeFloor(y,2), wholeCeil(y,2))
    xlimits = (0, x[-1] + 0.5)
    
    ax.set_ylim(*ylimits)
    ax.set_xlim(*xlimits)
    ax.yaxis.grid(True, linestyle='-', which='major', 
                  color='0.0', alpha=0.25, lw=0.5)
    ax.xaxis.grid(True, linestyle='-', which='major', 
                  color='0.0', alpha=0.25, lw=0.5)
    
    el = Ellipse((2, -1), 0.5, 0.5)
    ap1 = dict(arrowstyle="simple", fc="0.6", ec="none",
               patchB=el, connectionstyle="arc3,rad=-0.3")
    ap2 = dict(arrowstyle="simple", fc="0.6", ec="none",
               patchB=el, connectionstyle="arc3,rad=0.3")
    ax.annotate(r'$%0.1f \%%$' % (g[n1],), (x[n1], y[n1]), 
               xytext=(15,40), textcoords='offset points',
               size=10, arrowprops=ap1)
    ax.annotate(r'$%0.1f \%%$' % (g[n2],), (x[n2], y[n2]), 
               xytext=(-40,60), textcoords='offset points',
               size=10,arrowprops=ap2)           
    
    fig.savefig(fOUT, dpi=200)
    pl.close(fig)
    
def elevColorLine(fIN, delim=",", gres=0.25, fOUT='elev.pdf'):
    import matplotlib.collections as mc
    import matplotlib.cm as cm

    x,y,g = readElevData(fIN, delim=delim)
    x *= 0.001


    # Create a set of line segments so that we can color them individually
    # This creates the points as a N x 1 x 2 array so that we can stack points
    # together easily to get the segments. The segments array for line collection
    # needs to be numlines x points per line x 2 (x and y)
    points = np.array([x, y]).T.reshape(-1, 1, 2)
    segments = np.concatenate([points[:-1], points[1:]], axis=1)

    # Create the line collection object, setting the colormapping parameters.
    # Have to set the actual values used for colormapping separately.
    lc =mc.LineCollection(segments, cmap=cm.copper_r,
        norm=pl.Normalize())
    lc.set_array(g)
    lc.set_linewidth(3)

    fig = pl.figure(1, figsize=(3*1.62,3))
    ax = fig.add_axes([0.110, 0.125, 0.875, 0.850])
    ax.plot(x,y, 'k-', lw=0.5, alpha=0)
    ax.add_collection(lc)
    setFigStuff(x,y,g,lc,ax)
    fig.savefig(fOUT, dpi=300)

def wholeFloor(x, order):
    '''
    Round val DOWN to the nearest 10^order
    
    Example with some array X = [95, 102, 178, 152]:
    >>> x_min = min(X)
    >>> x_bottom = wholeFloor(x_min,2) # returns 0.0
    >>> x_bottom = wholeFloor(x_min,1) # returns 90.0
    >>> x_bottom = wholeFloor(x_min,0) # returns 95.0
    '''
    v = min(x)
    n = float(order)
    N = np.floor(v/(10**n)) * 10**n
    return N
    
    

def wholeCeil(x, order):
    '''
    Round val UP to the nearest 10^order
    
    Example with some array X = [95, 102, 178, 152]:
    >>> x_max = max(X)
    >>> x_top = wholeCeil(x_max,3) # returns 1000.0
    >>> x_top = wholeCeil(x_max,2) # returns 200.0
    >>> x_top = wholeCeil(x_max,1) # returns 180.0
    >>> x_top = wholeCeil(x_max,0) # returns 178.0
    '''    
    v = max(x)
    n = float(order)
    N = np.ceil(v/(10**n)) * 10**n
    return N
        
def smoothData(x, d, type):                 
    '''
    SMOOTHS NOISEY DATA, NOTHING SCIENTIFIC ABOUT THIS
    '''
    X = np.zeros(len(x))               # initialize output
    if type == 1:                   # for a rolling average sceme
        for n in range(len(x)):            
            if n-d < 0:
                n = range(0, n+d+1)
            elif n+d >= len(x):
                n = range(n-d, len(x))
            else:
                n = range(n-d, n+d+1)
            
            X[n] = np.mean(x[n])
            
    elif type == 2:                 # resample at lower frequency
        # NOT FINISHED
        N = len(x) - np.mod(len(x),d)
        X = np.zeros(N)
        for n in range(0,N,d):
            m = n + d
            X[n] = np.mean(x[n:m])
            
    else:
        print 'invalid averaging type'
        X = x
        
    return X
