def bootstrapMedian(data, N=5000):
    '''Bootstraper to refine estimate of a percentile from data
    N = number of iterations for the bootstrapping
    M = number of data points
    output = MU.bootStrapper(data, 50, 10000)
    '''
    import numpy as np
    import matplotlib.mlab as mlab
    
    M = len(data)
    percentile = 50
    
    estimate = np.array([])
    for k in range(N):
        bsIndex = np.random.random_integers(0,M-1,M)
        bsData = data[bsIndex]
        tmp = mlab.prctile(bsData, percentile)
        estimate = np.hstack((estimate, tmp))
        

    CI = mlab.prctile(estimate, [2.5,97.5])
    med = np.mean(estimate)
    
    return med, CI, estimate

#---------------------------------------------
def linInterp(X,Y,x):
    '''        NOT YET TESTED
    Old MATLAB Code:
    % LINEARLY INTERPOLATE FROM A 2D DATASET
    %   This function linearly interpolates bewteen two values in a dataset
    %
    %   Inputs:
    %       x_val  = the value from which y_val will be interpolated
    %       x_data = x-values of data set
    %       y_data = y-values of data set
    %
    %   Outputs:
    %       y_val  = the linearly interpolated value
    %
    %   Other functions called:
    %       NONE
    %
    %   Example:
    %       >> SG = (2.95:-0.05:2.45)';
    %       >> a = (0.94:0.01:1.04)';
    %       >> a_ = linInterp(2.682, SG, a);
    %
    %   See also planeInterp.
    
    if x_val < min(x_data)
        Sl = (y_data(2) - y_data(1)) / (x_data(2) - x_data(1));
        y_val = y_data(1) - (x_data(1) - x_val)*Sl;

    elseif x_val > max(x_data)
        Sl = (y_data(end) - y_data(end-1)) / (x_data(end) - x_data(end-1));
        y_val = y_data(end) + (x_val - x_data(end))*Sl;

    else
        for n = 1:length(x_data)-1
            if x_val >= x_data(n) && x_val <= x_data(n+1)
                m = n;
            end
        end
    y_val = (y_data(m)-y_data(m + 1)) * (x_val-x_data(m)) / (x_data(m)-...
        x_data(m + 1))+y_data(m);

    end
    '''
    if x < min(X): # this checks
        S = (Y[1] - Y[0])/(X[1] - X[0])
        y = Y[0] - (X[0] - x)*S
        
    elif x > max(X): # this checks
        S = (Y[-1] - Y[-2])/(X[-1] - X[-2])
        y = Y[-1] + (x - X[-1])*S
        
    else: # needs to be checked
        for i in range(len(X)-1):
            if x >= X[i] and x <= X[i+1]:
                m = i
        y = (Y[m] - Y[m+1]) * (x - X[m]) / (X[m]-X[m+1]) + Y[m]
    return y
   
#---------------------------------------------   
def planeInterp(X,Y,Z,x,y):
    '''         NOT YET TESTED
    X, Y, and Z need to be arrays, not list!
    
    '''

    
    # determine x-indicies
    if x > max(X):
        nx = [len(X)-1, len(X)]
    
    elif x < min(X):
        nx = [0, 1]
        
    else:
        nx = [find(X<x)[-1], find(X>x)[0]]

    # determine y-indicies
    if y > max(Y):
        ny = [len(Y)-1, len(Y)]
    
    elif y < min(Y):
        ny = [0, 1]
        
    else:
        ny = [find(Y<y)[-1], find(Y>y)[0]]
       
    # use all those indices        
    Z_ = Z[ny[0]:ny[1]+1, nx[0]:nx[1]+1]
    X_ = X[nx[0]:nx[1]+1]
    Y_ = Y[ny[0]:ny[1]+1]
    
    zt = [linInterp(Y, Z_[:,0], y), linInterp(Y, Z_[:,1], y)]
    z = linInterp(X, zt, z)
    return z
    
#--------------------------------------------- 
def smoothData(x, d):
            
    from numpy import zeros, mean, mod
    X = zeros(len(x))               # initialize output
    for n in range(len(x)):            
        if n-d < 0:
            n = range(0, n+d+1)
        elif n+d >= len(x):
            n = range(n-d, len(x))
        else:
            n = range(n-d, n+d+1)
        
        X[n] = mean(x[n])
        
    return X

#---------------------------------------------
def savitsky_golay(data, kernel=11, order=4):
    """
        applies a Savitzky-Golay filter
        input parameters:
        - data => data as a 1D numpy array
        - kernel => a positiv integer > 2*order giving the kernel size
        - order => order of the polynomal
        returns smoothed data as a numpy array
            
        invoke like:
        smoothed = savitzky_golay(<rough>, [kernel = value], [order = value] )
    """
    import numpy as np
    try:
        kernel = abs(int(kernel))
        order = abs(int(order))
    except ValueError, msg:
        raise ValueError("kernel and order have to be of type int (floats will be converted).")
    if kernel % 2 != 1 or kernel < 1:
        raise TypeError("kernel size must be a positive odd number, was: %d" % kernel)
    if kernel < order + 2:
        raise TypeError("kernel is to small for the polynomals\nshould be > order + 2")

    # a second order polynomal has 3 coefficients
    order_range = range(order+1)
    half_window = (kernel -1) // 2
    b = np.mat([[k**i for i in order_range] for k in range(-half_window, half_window+1)])
    # since we don't want the derivative, else choose [1] or [2], respectively
    m = np.linalg.pinv(b).A[0]

    # temporary data, with padded first/last values (since we want the same length after smoothing)
    firstval=data[0]
    lastval=data[len(data)-1]
    data = np.concatenate((np.zeros(half_window)+firstval, data, np.zeros(half_window)+lastval))

    # use the np.convolve function because it's much much faster
    smooth_data = np.convolve( m, data, mode='valid')

    return smooth_data

#---------------------------------------------
def smooth(x, delta=11, type='hanning', order=4):
    '''smooth the data using a window with requested size.
    
    This method is based on the convolution of a scaled window with the signal.
    The signal is prepared by introducing reflected copies of the signal 
    (with the window size) in both ends so that transient parts are minimized
    in the begining and end part of the output signal.
    
    input:
        x: the input signal 
        window_len: the dimension of the smoothing window; 
                    should be an odd integer
        window: the type of window 
                'flat', 'hanning', 'hamming', 'bartlett',
                'blackman', or 'savitsky golay'
                (flat window will produce a moving average smoothing)
    output:
        the smoothed signal
        
    example:

    t=linspace(-2,2,0.1)
    x=sin(t)+randn(len(t))*0.1
    y=smooth(x)
    
    see also: 
    
    numpy.hanning, numpy.hamming, numpy.bartlett, numpy.blackman, numpy.convolve
    scipy.signal.lfilter
    '''
    import numpy as np
    
    if type == 'savitsky golay':
        smooth_data = savitsky_golay(x, kernel=delta, order=order)
        
    else:            
        if x.ndim != 1:
            raise ValueError, "smooth only accepts 1 dimension arrays."

        if x.size < delta:
            raise ValueError, "Input vector needs to be bigger than window size."


        if delta < 3:
            return x


        if not type in ['flat', 'hanning', 'hamming', 'bartlett', 'blackman']:
            raise ValueError, "Window is not 'flat', 'hanning', 'hamming', 'bartlett', or 'blackman'"


        s = np.r_[2*x[0]-x[delta:1:-1],x,2*x[-1]-x[-1:-delta:-1]]
        #print(len(s))
        if window == 'flat': #moving average
            w = np.ones(delta,'d')
        else:
            w=eval('np.%s(delta)' % type)

        y = np.convolve(w/w.sum(),s,mode='same')
        smooth_data = y[delta-1:-delta+1]
    
    return smooth_data

#--------------------------------------------- 
def resampleData(t1, x1, d):
    '''
    N = 50 #length of series
    x1 = np.random.randn(N,1)
    t1 = range(0,N)
    index = range(0,N+1,d)
    for n in range(1,len(index)-1):
        ii = index[n]
        print(ii)
        t2.append(t1[ii])
        x2.append(np.mean(x1[ii-5:ii]))
    t3 = np.hstack([t1[0], t2, t1[-1]])
    x3 = np.hstack[x1[0], x2, x1[-1]])'''
    from numpy import hstack, mean
    
    N = len(t1)
    index = range(0,N+1,d)
    t2 = [t1[0]]
    x2 = [x1[0]]
    for n in range(1,len(index)-1):
        k = index[n]
        t2.append(t1[k])
        x2.append(mean(x1[k-d:k]))
        
    t3 = hstack((t2, t1[-1]))
    x3 = hstack((x2, x1[-1]))
    
    return t3, x3
    
#---------------------------------------------
def findNonZeros(x):
    '''
    This function takes a 2-D array and finds all of the rows
    where the elements in every colums is non-zero.
    
    For example, this array:
    X_in = 0 1 2 3
           4 5 6 7
           8 9 0 1
           2 3 4 5
        
    would become:
    X_out = 4 5 6 7
            2 3 4 5
    with >>> X_out = findNonZeros(X_in)
    
    Input:
        x, ndarray:
            2-dimensional numpy array. Numeric data only.
        
    Output:
        x[N], ndarray:
            2-dimensional numpy array with only the rows
            that are complete comprised of non-zero data.
            
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/09/17              (_)/ (_)  |
    +-----------------------------------+
        
    '''
    from pylab import find
    from numpy import shape
    rows, cols = shape(x)
    N = []
    for n in range(rows):
        tmp = find(x[n]>0)
        if len(tmp) == cols:
            N.append(n)
    return x[N]
    
#---------------------------------------------
def wholeFloor(val, order):
    '''
    Round val DOWN to the nearest 10^order
    
    Example with some array X = [95, 102, 178, 152]:
    >>> x_min = min(X)
    >>> x_bottom = wholeFloor(x_min,2) # returns 0.0
    >>> x_bottom = wholeFloor(x_min,1) # returns 90.0
    >>> x_bottom = wholeFloor(x_min,0) # returns 95.0
    '''
    
    from numpy import floor
    v = float(val)
    n = float(order)
    N = floor(v/(10**n)) * 10**n
    return N
    
    
#---------------------------------------------
def wholeCeil(val, order):
    '''
    Round val UP to the nearest 10^order
    
    Example with some array X = [95, 102, 178, 152]:
    >>> x_max = max(X)
    >>> x_top = wholeCeil(x_max,3) # returns 1000.0
    >>> x_top = wholeCeil(x_max,2) # returns 200.0
    >>> x_top = wholeCeil(x_max,1) # returns 180.0
    >>> x_top = wholeCeil(x_max,0) # returns 178.0
    '''    
    from numpy import ceil
    v = float(val)
    n = float(order)
    N = ceil(v/(10**n)) * 10**n
    return N

#---------------------------------------------
def linFit(x,y):
    '''
    linFit - LEAST-SQUARES METHOD OF CURVE FITTING TO LINEAR DATA 
    This function performs a least-square curve fitting on x & y based on
    model E of order n.  Examples of E:
    Linear model, n = 1: E[:,1] = 1; E[:,2] = x;
    Quadratic model, n = 2: E[:,1] = 1; E[:,2] = x; E[:,3] = x**2;
    
    Input:
      x - independent variable (array)
      y - dependent variable (array)
      n - model order, n = 1 for linear model, n = 2 for quadratic...
    
    Output:
      x_hat - this is a (n+1)-by-1 vector of the output model parameters.
      x_hat[n] = n order term -- .i.e.:
      x_hat[0] = constant (0th order) term,
      x_hat[1] = linear (1st order) term, etc...
    
    Other functions called:
      NONE
    
    Example:
        >>> import LinearRegressions as LR
        >>> m,b = LR.linFin(x, y, 3)  # cubic model of data.
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/03/11              (_)/ (_)  |
    +-----------------------------------+
    '''
    import rpy2.robjects as robj
    
    # define the R environment and 
    # convert numpy arrays to lists
    R = robj.r
    xList = robj.FloatVector(list(x))
    yList = robj.FloatVector(list(y))
    
    # put x and y in to the R environment
    robj.globalEnv["x"] = xList
    robj.globalEnv["y"] = yList
    
    # execute the fit, assign output variables
    fit = R.lm("y ~ x")
    model = [fit[0][0], fit[0][1]]
    
    R_out = {"coeff" : fit[0],
             "res" : fit[1],
             "effects" : fit[2],
             "rank" : fit[3],
             "fitted.values" : fit[4],
             "assign" : fit[5],
             "qr" : fit[6],
             "df.residual" : fit[7],
             "xlevels" : fit[8], 
             "call" : fit[9],
             "terms" : fit[10],
             "model" : fit[11]
             }
    return model, R_out
    
#---------------------------------------------
def powerFit(x,y):
    '''
    powerFit - LEAST-SQUARES METHOD OF CURVE FITTING - POWER FUNCTIONS
    This function performs a least-square curve fitting on x & y based on
    power function in the form y = a * x^b
        
    Input:
      x - independent variable
      y - dependent variable
        
    Output:
      This function fits data in the form of y = a * x^b:
      a and b are output.
        
    Other functions called:
      NONE
        
    Example:
        >>> import LinearRegressions as LR
        >>> a, b = LR.powerFin(x, y);
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/03/11              (_)/ (_)  |
    +-----------------------------------+
    '''	
    # import all that stuff
    import numpy as np
 
    # take natural logs of the data
    X = np.log(x); 
    Y = np.log(y);
    
    # create model
    E = np.zeros([len(Y),2]);
    E[:,0] = 1;
    E[:,1] = X;
 
    # evaluate model
    X1 = np.dot(np.transpose(E),E)
    X2 = np.dot(np.transpose(E),Y)
    Xhat = np.dot(np.linalg.inv(X1),X2)
    a = np.exp(Xhat[0]);
    b = Xhat[1];
    return a,b
    
#---------------------------------------------
def expFit(x,y):
    '''
    expFit - LEAST-SQUARES METHOD OF CURVE FITTING TO EXPONENTIAL DATA
    This function performs a least-square curve fitting on x & y based on
    an exponential function in the form: y = a * exp(b*x)
    
    Input:
      x - independent variable
      y - dependent variable
    
    Output:
      This function fits data in the form of y = a * exp(b*x) :
      a and b are output.
    
    Other functions called:
      NONE
    
    Example:
        >>> import LinearRegressions as LR
        >>> a,b = LR.expFit(x, y); 
    
      See also LR.linFit, LR.powerFit
    +-----------------------------------+
    | Paul M. Hobson             __o    |
    | phobson@geosyntec.com    _`\<,_   | 
    | 2009/03/11              (_)/ (_)  |
    +-----------------------------------+
    '''
    # import all that stuff
    import numpy as np
    
    # take the natural log of the data
    Y = np.log(y)
    
    # create the model
    E = np.zeros([len(y), 2])
    E[:,0] = 1
    E[:,1] = x 
    
    # evaluate model
    X1 = np.dot(np.transpose(E),E)
    X2 = np.dot(np.transpose(E),y)
    Xhat = np.dot(np.linalg.inv(X1),X2)
    a = np.exp(Xhat[0])
    b = Xhat[1]
    return a,b
