%==========================================================================
%                               Deep Pockets
%               4: From the basic sets, returns are computed.
%                               February 2017                       
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
%
%  
load('params');
%firstYear = params.firstYear;
%lastYear = params.lastYear;
disp('Using Price-Data to compute and save all Data per year:');

% Here, I add the path where the data is stored to the searchpath:
cd(params.DATA_SAVE_PATH{1})
addpath(genpath(params.DATA_SAVE_PATH{1}))

% ---------------------->!! INITIALIZATION !!<-----------------------------
%nanMonitor = [(firstYear:lastYear)', nan(lastYear-firstYear+1,2)];
% -------------------------->!! LOOP !!<-----------------------------------
for y = 1900:2100%firstYear:lastYear
    disp(y);
    if exist(strcat('Output/Year_',int2str(y),'.mat'), 'file') == 2
        load(strcat('Output/Year_',int2str(y),'.mat'));
        Returns = getReturns(cSet);
        CulmReturns = getCulmulativeReturns(Returns);
        MVMReturns = getMeanVariance(Returns);
        MVMCulmReturns = getMeanVariance(CulmReturns);
        %[ZScoreReturns, nanMonitor(y-firstYear+1,2)] = getZScore(Returns,MVMReturns);
        ZScoreReturns = getZScore(Returns,MVMReturns);
        %[ZScoreCulmReturns, nanMonitor(y-firstYear+1,3)] = getZScore(CulmReturns,MVMCulmReturns);
        ZScoreCulmReturns = getZScore(CulmReturns,MVMCulmReturns);
        save(strcat('Output/Year_',int2str(y),'Returns.mat'),'Returns','-v7.3');
        save(strcat('Output/Year_',int2str(y),'CulmReturns.mat'),'CulmReturns','-v7.3');
        save(strcat('Output/Year_',int2str(y),'MVReturns.mat'),'MVMReturns','-v7.3');
        save(strcat('Output/Year_',int2str(y),'MVCulmReturns.mat'),'MVMCulmReturns','-v7.3');
        save(strcat('Output/Year_',int2str(y),'ZScoreReturns.mat'),'ZScoreReturns','-v7.3');
        save(strcat('Output/Year_',int2str(y),'ZScoreCulmReturns.mat'),'ZScoreCulmReturns','-v7.3');
        clearvars -except y firstYear lastYear nanMonitor
    end
end
disp('In the following years, some z-scores had to be replaced with 0 due to too few observations:')
%nanMonitor = nanMonitor(nanMonitor(:,3)>0,:)