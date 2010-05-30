function [X, Y, S, P, C] = lsq_stepwiseRegression(x,y)



cnt = 1;

[Xall, Yall, Sall] = lsq_multLinFit2(x,y);   % evaluate model with all parameters
SS_Eall = Sall(1);                          % standard error of model with all predictors

% initialize all the variables
X = {};         % model parameters
Y = {};         % model response estimations
S = [];         % stat matrices [SE, R2, R2_adj]
Cp = {};        % mallow's Cp
P = {};         % indices of predictors used in model


K = size(x,2);  % number of columns in x
n = size(x,1);  % number of data points (rows in x)
index = 1:size(x,2);
for k = K:-1:1              % loop through the width of x (1 predictor -> all predictors)

    %     ii = nchoosek(1:K,k);       % create matrix of all combinations of n predictors
    %     M = size(ii,1);             % number of combos to evaluate
    %
    %     for m = 1:M                     % loop through each comination of predictors
    %         index = ii(m,:);            % create index for the predictors for the mth combo

    % evaluate a multiple linear rergression with mth combo of
    % predictors
    %        x_mod = x(:,index);
    [Xtmp, Ytmp, Stmp] = lsq_multLinFit2(x,y);

    % Mallow's Cp
    Cptmp = Stmp(1)/SS_Eall/(n - K - 1) - (n - 2*k);

    % concatentate results into a cell
    X{k,1} = Xtmp;
    Y{k,1} = Ytmp;
    S = [S; (k) Stmp Cptmp];
    P{k,1} = index;

    C{k} = abs(sum(x,1).*Xtmp(2:end)');
    bad = find(C{k} == min(C{k}));

    if k ~= 1
        if bad == 1
            x = x(:,2:end);
            index = index(2:end);

        elseif bad == K
            x = x(:,1:end-1);
            index = index(1:end-1);

        else
            x = [x(:,1:bad-1) x(:,bad+1:end)];
            index = [index(1:bad-1) index(bad+1:end)];
        end
    end

    cnt = cnt+1;
end
