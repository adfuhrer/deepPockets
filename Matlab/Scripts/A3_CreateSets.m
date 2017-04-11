%==========================================================================
%                               Deep Pockets
%                      3: Merging and Expanding the Set.
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
FOLDER_NAME = strrep(mfilename('fullpath'),mfilename,'');
if ismac
    backslashes = strfind(FOLDER_NAME,'/');
elseif isunix
    backslashes = strfind(FOLDER_NAME,'/');
elseif ispc
    backslashes = strfind(FOLDER_NAME,'\');
else
    disp('Platform not supported')
end
FOLDER_NAME = FOLDER_NAME(1:backslashes(end-1));
cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
%==========================================================================
close all
clear
%
%==========================================================================
% It is a bit unfortunate, but the download-script had to include a
% batching-algorithm, since (probably) the RAM of my MacBook can't handle
% the yahoo-connection when the active memory passes 1GB. So I need this
% script to 'glue' the set back together and to get from simple price data
% to actually usefull returns, culmulative returns and z-scroes. For this
% purpose, it is necessary to cut the set back up, into peices for every
% year. Then, I can get the cross-section \mu and \sigma. I will use them
% to compute the z-score. 
%==========================================================================
% I load all the parameters and the Ticker list form the Matlab Searchpath.
load('params');
packages    = params.packages;

isExcel     = false;
firstYear   = 2100;  % Since I use the min-function, I just set it high.
lastYear    = 0;     % Since I use the max-function, I just set it low.

% Here, I add the path where the data is stored to the searchpath:
%   DON'T FORGET TO CHAGE BACK!! (This is why I save it in FOLDER_NAME)
FOLDER_NAME = pwd;
cd(params.DATA_SAVE_PATH{1})
addpath(genpath(params.DATA_SAVE_PATH{1}))

% ---------------------->!! INITIALIZATION !!<-----------------------------
mkdir('Output')

% We determine, which years we need to consider:
for p = 1:packages
    disp(num2str(p))
    load(strcat('Temp/Table_',int2str(p)));
    firstYear = min([packCollection(:,3); firstYear]);
    lastYear = max([packCollection(:,3);lastYear]);
    clear packCollection
end
% -------------------------->!! LOOP !!<-----------------------------------
% Then, for every year, we loop through all packages and extract the
% relevant data, collect it and save the set. Then delete everything and
% start over.
for y = firstYear:lastYear
    % For every year, a set is initialized to contain the data for said
    % year.
    cSet=[];
    
    for p = 1:packages
        disp([int2str(y),', Set: ',int2str(p)]) 
        % Every package is loaded and cut into pieces
        load(strcat('Temp/Table_',int2str(p)));
        ncols = size(packCollection,2)+1;
        
        % Then, the data for the year is collected...
        yearIndex = find(packCollection(:,3) == y);
        tempData = packCollection(yearIndex,:);
        % ...and continuously saved in the set.
        cSet = [cSet;tempData];
    end
    % Now we need to save the set for every year:
    save(strcat('Output/Year_',int2str(y),'.mat'),'cSet');
end

cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
params.firstYear = firstYear;
params.lastYear = lastYear;
save('params.mat','params');