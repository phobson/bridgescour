function [X, Y, S, P] = lsq_bestSubsetsRegression(x,y,K)












cnt = 1;



[Xall, Yall, Sall] = lsq_multLinFit2(x,y);   % evaluate model with all parameters
SS_Eall = Sall(1);                          % standard error of model with all predictors

% initialize all the variables
X = {};         % model parameters
Y = {};         % model response estimations
S = [];         % stat matrices [SE, R2, R2_adj]
Cp = {};        % mallow's Cp
P = {};         % indices of predictors used in model


Pr = size(x,2);  % number of predictors (columns in x)
n = size(x,1);  % number of data points (rows in x)

for k = 1:K                % loop through the width of x (1 predictor -> all predictors)

    ii = nchoosek(1:Pr,k);       % create matrix of all combinations of n predictors 
    M = size(ii,1);             % number of combos to evaluate
    
    for m = 1:M                     % loop through each comination of predictors
        index = ii(m,:);            % create index for the predictors for the mth combo
        
        % evaluate a multiple linear rergression with mth combo of
        % predictors
        x_mod = x(:,index);
        [Xtmp, Ytmp, Stmp] = lsq_multLinFit2(x_mod,y);
        
        % Mallow's Cp
        Cptmp = Stmp(1)/SS_Eall/(n - K - 1) - (n - 2*k);
        
        % concatentate results into a cell
        X{cnt,1} = Xtmp;
        Y{cnt,1} = Ytmp;
        S = [S; numel(index) Stmp Cptmp];
        P{cnt,1} = index;
        
        cnt = cnt+1;
    end
end

