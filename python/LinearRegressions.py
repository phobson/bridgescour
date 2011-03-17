'''
    Deprecated. Please update yr code to call NumUtils.py
   
+-----------------------------------+
| Paul M. Hobson             __o    |
| phobson@geosyntec.com    _`\<,_   | 
| 2010/05/04              (_)/ (_)  |
+-----------------------------------+
'''
import rpy2.robjects as robj

def linFit(x,y):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    
    import NumUtils as nu
    model, R_out = nu.linFit(x,y)
    return model, R_out
    

def powerFit(x,y):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    
    import NumUtils as nu
    a,b = nu.powerFit(x,y)
    return a,b
    
def expFit(x,y):
    '''
    Deprecated. Please update yr code to call this from NumUtils.py
    '''    
    print('Deprecated. Please update yr code to call this from NumUtils.py')
    
    import NumUtils as nu
    a,b = nu.expFit(x,y)
    return a,b