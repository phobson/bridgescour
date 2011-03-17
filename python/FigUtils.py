def censoredProbPlot(data, mask):
    import scipy.stats as st
    import numpy as np
    
    ppos = st.mstats.plotting_positions(data)
    qntl = st.distributions.norm.ppf(ppos)
    
    qntlMask = np.ma.MaskedArray(qntl, mask=mask)
    dataMask = np.ma.MaskedArray(data, mask=mask)
    
    fit = st.mstats.linregress(dataMask, qntlMask)
    mu = -fit[1]
    sigma = fit[0]
    d_ = np.linspace(np.min(data),np.max(data))
    q_ = sigma * d_ - mu
    
    maskedProbPlot = {"mskData" : dataMask,
                      "mskQntl" : qntlMask,
                      "unmskData" : data,
                      "unmskQntl" : qntl,
                      "bestFitD" : d_,
                      "bestFitQ" : q_,
                      "mu" : mu,
                      "sigma" : sigma}
    return maskedProbPlot


#---------------------------------------------
def connect_bbox(bbox1, bbox2,
                 loc1a, loc2a, loc1b, loc2b,
                 prop_lines, prop_patches=None):

    from mpl_toolkits.axes_grid.inset_locator import BboxPatch, BboxConnector,\
     BboxConnectorPatch
     
    import mpl_toolkits.axes_grid.inset_locator as IL
    
    if prop_patches is None:
        prop_patches = prop_lines.copy()
        prop_patches["alpha"] = prop_patches.get("alpha", 1)*0.2
        prop_patches["ec"] = 'none'

    c1 = IL.BboxConnector(bbox1, bbox2, loc1=loc1a, loc2=loc2a, **prop_lines)
    c1.set_clip_on(False)
    c2 = IL.BboxConnector(bbox1, bbox2, loc1=loc1b, loc2=loc2b, **prop_lines)
    c2.set_clip_on(False)

    bbox_patch1 = IL.BboxPatch(bbox1, **prop_patches)
    bbox_patch2 = IL.BboxPatch(bbox2, **prop_patches)

    p = BboxConnectorPatch(bbox1, bbox2,
                           #loc1a=3, loc2a=2, loc1b=4, loc2b=1,
                           loc1a=loc1a, loc2a=loc2a, loc1b=loc1b, loc2b=loc2b,
                           **prop_patches)
    p.set_clip_on(False)

    return c1, c2, bbox_patch1, bbox_patch2, p


#---------------------------------------------
def zoom_effect(ax1, ax2, xmin, xmax, **kwargs):
    import matplotlib.transforms as mt
    '''
    ax1 : the main axes
    ax1 : the zoomed axes
    (xmin,xmax) : the limits of the colored area in both plot axes.

    connect ax1 & ax2. The x-range of (xmin, xmax) in both axes will
    be marked.  The keywords parameters will be used ti create
    patches.
    '''

    trans1 = mt.blended_transform_factory(ax1.transData, ax1.transAxes)
    trans2 = mt.blended_transform_factory(ax2.transData, ax2.transAxes)

    bbox = mt.Bbox.from_extents(xmin, 0, xmax, 1)

    mybbox1 = mt.TransformedBbox(bbox, trans1)
    mybbox2 = mt.TransformedBbox(bbox, trans2)

    prop_patches=kwargs.copy()
    prop_patches["ec"]="none"
    prop_patches["alpha"]=0.2

    c1, c2, bbox_patch1, bbox_patch2, p = \
        connect_bbox(mybbox1, mybbox2,
                     loc1a=3, loc2a=2, loc1b=4, loc2b=1,
                     prop_lines=kwargs, prop_patches=prop_patches)

    ax1.add_patch(bbox_patch1)
    ax2.add_patch(bbox_patch2)
    ax2.add_patch(c1)
    ax2.add_patch(c2)
    ax2.add_patch(p)

    return c1, c2, bbox_patch1, bbox_patch2, p
    

#---------------------------------------------
def zoom_effect_2(ax1, ax2, **kwargs):
    from matplotlib.transforms import Bbox, TransformedBbox, \
     blended_transform_factory

    from mpl_toolkits.axes_grid.inset_locator import BboxPatch, BboxConnector,\
     BboxConnectorPatch
    '''
    ax1 : the main axes
    ax1 : the zoomed axes

    Similar to zoom_effect01.  The xmin & xmax will be taken from the
    ax1.viewLim.
    '''

    tt = ax1.transScale + (ax1.transLimits + ax2.transAxes)
    trans = blended_transform_factory(ax2.transData, tt)

    mybbox1 = ax1.bbox
    mybbox2 = TransformedBbox(ax1.viewLim, trans)

    prop_patches=kwargs.copy()
    prop_patches["ec"]="none"
    prop_patches["alpha"]=0.2

    c1, c2, bbox_patch1, bbox_patch2, p = \
        connect_bbox(mybbox1, mybbox2,
                     loc1a=3, loc2a=2, loc1b=4, loc2b=1,
                     prop_lines=kwargs, prop_patches=prop_patches)

    ax1.add_patch(bbox_patch1)
    ax2.add_patch(bbox_patch2)
    ax2.add_patch(c1)
    ax2.add_patch(c2)
    ax2.add_patch(p)


    return c1, c2, bbox_patch1, bbox_patch2, p
