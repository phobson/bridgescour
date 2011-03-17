import scipy.stats as st
import numpy as np
import matplotlib.pyplot as pl
import rpy2.robjects as ro
R = ro.r

def getQQdata(x):
    '''probplot using R'''
    xR = ro.FloatVector(x)
    ro.globalEnv['x'] = xR
    qq = R("qqnorm(x, datax=TRUE, plot.it=FALSE)") 
    q = np.array(qq[1])    
    return q
    
def lm_R(x,y):
    '''linear model using R'''
    ro.globalEnv['x'] = ro.FloatVector(x)
    ro.globalEnv['y'] = ro.FloatVector(y)
    model = R("lm(y~x)")
    b = model[0][0]
    m = model[0][1]
    
    xhat = np.linspace(min(x), max(x))
    yhat = m * xhat + b
    return m, b, [xhat, yhat]
    
def lm_S(x,y):
    '''linear model using scipy.stats'''
    m,b, j1,j2,j3 = st.linregress(x,y)
    xhat = np.linspace(min(x), max(x))
    yhat = m * xhat + b
    return m, b, [xhat, yhat]

# fake data mu=5.5, sigma=2, n=35
x = np.random.normal(5.5,2,35)

# R qqplot
qR = getQQdata(x)
mR_R, bR_R, estR_R = lm_R(x,qR)
mR_S, bR_S, estR_S = lm_S(x,qR)

# scipy.stats.probplot
qS, fitS = st.probplot(x)
mS_R, bS_R, estS_R = lm_R(qS[1], qS[0])
mS_S, bS_S, estS_S = lm_S(qS[1], qS[0])

R_out = """
R's Probability:    Scipy's Probability:
quantiles           quantiles
---------------     ---------------
min\tmax            min\tmax
%0.3f\t%0.3f        %0.3f\t%0.3f

slopes (scale)      slopes (scale)
---------------     ---------------
R\tScipy            R\tScipy
%0.3f\t%0.3f        %0.3f\t%0.3f

intercepts (loc)    intercepts (loc)
---------------     ---------------
R\tScipy            R\tScipy
%0.3f\t%0.3f        %0.3f\t%0.3f
""" % (min(qR), max(qR), min(qS[0]), max(qS[0]),
       mR_R, mR_S, mS_R, mS_S, 
       bR_R, bR_S, bS_R, bS_S)
       
print(R_out)


xhat = np.linspace(min(x),max(x))
yhatR = xhat*mR_R + bR_R
yhatS = xhat*mS_S + bS_S

fig = pl.figure()
ax1 = fig.add_subplot(1,2,1)
ax2 = fig.add_subplot(1,2,2)

ax1.plot(x,qR, 'ko', ms=4, markerfacecolor='none',
         label='Sample Data',zorder=10,markeredgewidth=1.25)
ax1.plot(xhat,yhatR, 'b-', lw=2, 
         label='Best-Fit', zorder=5,alpha=0.75)
ax1.set_xlabel('Sample Data')
ax1.set_ylabel('Quantiles')
ax1.legend(loc='upper left')
ax1.set_title('Rpy2-Python Plot')
ax1.annotate(r'$y = %0.4f\:x + %0.4f$' % (mR_R, bR_R), 
             xy=(xhat[17], yhatR[17]), xycoords='data', 
             xytext=(3,-2.5), textcoords='data', 
             arrowprops=dict(arrowstyle='->'))

ax2.plot(qS[1],qS[0], 'ko', ms=4, markerfacecolor='none', 
         label='Sample Data', zorder=10, markeredgewidth=1.25)
ax2.plot(xhat,yhatS, 'b-', lw=2, 
         label='Best-Fit', zorder=5, alpha=0.75)
ax2.set_xlabel('Sample Data')
ax2.set_ylabel('Quantiles')
ax2.legend(loc='upper left')
ax2.set_title('Scipy Plot')
ax2.annotate(r'$y = %0.4f\:x + %0.4f$' % (mS_S, bS_S), 
             xy=(xhat[17], yhatS[17]), xycoords='data', 
             xytext=(3,-2.5), textcoords='data', 
             arrowprops=dict(arrowstyle='->'))

fig.subplots_adjust(left=0.10,right=0.95,
                    bottom=0.10,top=0.90,
                    wspace=0.30)
fig.savefig('prob_plot_test.pdf')
pl.close(fig) 