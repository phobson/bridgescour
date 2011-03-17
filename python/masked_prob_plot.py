import numpy as np
import scipy.stats as st
import matplotlib.pyplot as pl

def probPlotNonDetects(data, mask):
    ppos = st.mstats.plotting_positions(data)
    qntl = st.distributions.norm.ppf(ppos)
    
    qntlMask = np.ma.MaskedArray(qntl, mask=mask)
    dataMask = np.ma.MaskedArray(data, mask=mask)
    
    fit = st.mstats.linregress(dataMask, qntlMask)
    mu = -fit[1]
    sigma = fit[0]
    x_ = np.linspace(np.min(data),np.max(data))
    y_ = sigma * x_ - mu
    
    maskedProbPlot = {"mskData" : dataMask,
                      "mskQntl" : qntlMask,
                      "bestFitX" : x_,
                      "bestFitY" : y_,
                      "mu" : mu,
                      "sigma" : sigma}
    return maskedProbPlot

N = 45
data = np.random.normal(loc=6.5, scale=1.5, size=N)

# come up with random indices of value to call detection limits
#   number of NDs (at least 12 as repeats may occur)
n_ND = np.random.random_integers(12, high=N/2.)

#   indices (between 0 and N):
i_ND = np.random.random_integers(0, high=N-1, size=n_ND)

# creat mask
mask = np.zeros((N,),dtype=bool)
for i in i_ND:
    mask[i] = True

# compute plotting positions on unmasked data
ppos = st.mstats.plotting_positions(data)#, alpha=1, beta=1)
qntl = st.distributions.norm.ppf(ppos)

# mask data
dataMask = np.ma.MaskedArray(data, mask=mask)
qntlMask = np.ma.MaskedArray(qntl, mask=mask)

# fit lines to raw data and selected+masked data
fit_raw = st.linregress(data, qntl)
fit_msk = st.mstats.linregress(dataMask, qntlMask)

# estimate values from the fits
x_ = np.linspace(np.min(data),np.max(data))
y_ = fit_raw[0] * x_ + fit_raw[1]
ym_ = fit_msk[0] * x_ + fit_msk[1]

# figure stuff:
#  plot quantile points
fig = pl.figure()
ax = fig.add_subplot(111)
ax.plot(data, qntl,
    linestyle='none',
    marker='.',
    markerfacecolor='g',
    markeredgecolor='g',
    markersize=3,
    alpha=1.00,
    label='With substituted DLs')
    
ax.plot(dataMask, qntlMask,
    linestyle='none',
    marker='o',
    markerfacecolor='none',
    markeredgecolor='b',
    markersize=5,
    alpha=1.00,
    label='With masked non-detects')
    

#  plot best-fit lines
ax.plot(x_, y_,
        linestyle='-',
        linewidth=2,
        color='g',
        marker='None',
        alpha=0.75,
        label='_nolegend_')
        
ax.plot(x_, ym_,
        linestyle='--',
        dashes=(20,10),
        linewidth=2,
        color='b',
        marker='None',
        alpha=0.75,
        label='_nolegend_')
        
ax.text(3.50, 1.75, r'$y = \sigma x - \mu$')
ax.text(3.50, 1.50, 
        r'$\sigma = %0.3f, \:\: \mu = %0.3f$' % (fit_raw[0], -1.0*fit_raw[1]),
        color='g')

ax.text(3.50, 1.25, 
        r'$\sigma = %0.3f, \:\: \mu = %0.3f$' % (fit_msk[0], -1.0*fit_msk[1]),
        color='b')
        
ax.set_ylim([np.floor(np.min(qntl)), np.ceil(np.max(qntl))])
ax.set_ylabel(r'Quantiles, $y$')
ax.set_xlabel(r'Data, $x$')
ax.legend(loc='upper left')
fig.savefig('masked_prob_plot.png')
