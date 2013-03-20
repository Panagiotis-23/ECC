function [ parameters ] = ecc_params(levels, iterations, transform, dpInitMan, featBasedInit, varargin)
% This function creates a struct that contains all the necessary parameters
% to successfully run the ECC algorithm.
%
% Standard input elements
% -->LEVELS: Number of levels in a pyramid implementation
% -->ITERATIONS: Number of iterations of the algorithm
% -->TRANSFORM: The applied transform. Valid values are:
% 'euclidean','affine','homography' and 'translation'
% -->DPINITMAN: Manual parameter initialization flag
% -->FEATBASEDINIT: Featured based initialization flag
% 
% Variable input elements
% -->DPINIT: If DPINITMAN is not 0, this field contains the initial 
% parameters
% -->IMAGEPOINTS: If FEATBASEDINIT is not 0, this field contains the image
% points
% -->TEMPPOINTS: If FEATBASEDINIT is not 0, this field contains the
% template points
% -->INITMETHOD: If FEATBASEDINIT is not 0, this field contains the
% initialization method. Valid values are:
% 'LS' (Least Squares) and 'RANSAC'

%% Essential error checking for standard input elements
if (nargin<5)
    error('ecc_params: Wrong number of arguments given');
end

if ~(isscalar(levels))
    error('ecc_params: Input "levels" must be scalar');
end

if ~(isscalar(iterations))
    error('ecc_params: Input "iterations" must be scalar');
end

if ~(ischar(transform))
    error('ecc_params: Input "transform" must be a string');
end

if ~(isscalar(dpInitMan))
    error('ecc_params: Input "dpInitMan" must be scalar');
end

if ~(isscalar(featBasedInit))
    error('ecc_params: Input "featBasedInit" must be scalar');
end

% Check if transform is valid
transform=lower(transform);
if ~(strcmp(transform,'euclidean')||strcmp(transform,'affine')...
        ||strcmp(transform,'homography')||strmp(transform,'translation'))
    error('ecc_params: Input "transform" must be a valid transform string. Check help');
end


%% Parsing the variable-length part of the input
dpInitMan=logical(dpInitMan);
featBasedInit=logical(featBasedInit);

VarOffset=1;
if (dpInitMan)
    % Extracting input associated with "dpInitMan", dpInit
    dp=cell2mat(varargin(VarOffset));
    VarOffset=VarOffset+1;
    
    dpSz=size(dp);
    if (strcmp(transform,'translation'))
        if ((dpSz(1)~=2)||(dpSz(2)~=1))
            error('ecc_params: For "translation", the parameters matrix must be 2x1');
        end
        nop=2;
    elseif(strcmp(transform,'euclidean'))
        if ((dpSz(1)~=2)||(dpSz(2)~=3))
            error('ecc_params: For "euclidean", the parameters matrix must be 2x3');
        end
        nop=3;
    elseif(strcmp(transform,'affine'))
        if ((dpSz(1)~=2)||(dpSz(2)~=3))
            error('ecc_params: For "affine", the parameters matrix must be 2x3');
        end
        nop=6;
    elseif(strcmp(transform,'homography'))
        if ((dpSz(1)~=3)||(dpSz(2)~=3))
            error('ecc_params: For "homography", the parameters matrix must be 3x3');
        end
        nop=8;
        
        if (dp(3,3)~=1)
            fprintf(1,'ecc_params: In case of "homography" parameter p9 must be equal to 1, so it has been changed\n');
            dp(3,3)=1;
        end
    end
else
    % Default warp matrices
    if (strcmp(transform,'translation'))
        dp=zeros(2,1);
        nop=2;
    elseif(strcmp(transform,'euclidean'))
        dp=[1 0 0;0 1 0;0 0 0];
        nop=3;
    elseif(strcmp(transform,'affine'))
        dp=[1 0 0;0 1 0;0 0 0];
        nop=6;
    elseif(strcmp(transform,'homography'))
        dp=eye(3);
        nop=8;
    end
end

if (featBasedInit)
    % Extracting inputs associated with "featBasedInit", imagePoints,
    % tempPoints and initMethod
    iPts=cell2mat(varargin(VarOffset));
    tPts=cell2mat(varargin(VarOffset+1));
    initMethod=cell2mat(varargin(VarOffset+2));
    
    Isz=size(imagePts);
    Tsz=size(tempPts);
    
    % Checking Image and template points structures for valid sizes
    if (Isz(1)~=2)
        error('ecc_params: Image Points structure must be 2xM');
    end
    if (Tsz(2)~=2)
        error('ecc_params: Template Points structure must be 2xM');
    end
    
    % Image and template points structures must be of same size
    if (~isequal(Isz,Tsz))
        error('ecc_params: Image Points and Template Points structures must be of same size');
    end
    
    % Checking initialization method
    if (~ischar(initMethod))
        error('ecc_params: Input "initMethod" must be a string');
    end
    
    initMethod=upper(initMethod);
    if ~(strcmp(initMethod,'LS')||strcmp(initMethod,'RANSAC'))
        error('ecc_params: Input "initMethod" must be a valid string. Check help');
    end
    
    VarOffset=VarOffset+3;
else
    % Null-out unnecessary fields
    iPts=[];
    tPts=[];
    initMethod=[];
end
% End of parsing the variable-length part of the input

%% Export final parameters struct
parameters=struct('levels',levels,'iterations',iterations,'transform',...
    transform,'initWarp',dp,'NoP',nop,'imagePoints',iPts,'tempPoints',tPts,'initMethod',initMethod);

end

