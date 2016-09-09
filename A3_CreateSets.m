%==========================================================================
%                               Deep Pockets
%                      3: Merging and Expanding the Set.
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================

%==========================================================================
close all
clear
clc
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

% 4. Try to store all this info somewhere. It sucks to run the script over
%    and over. Try to creat an .mat - file that has Ticks and months on x
%    and y, and stores a pack on every intersection. Maybe make prices,
%    returns, creturns and zscores as a z dimension. Very tractable like
%    that.

% 5. Start with some basic analysis:

    %5.1. Establish a 'normal' momentum strategy. This is a benchmark.
    
    %5.2. Run some basic OLS to figure out if you can 'enhance' the
    %     momentum like that.

%==========================================================================
% I load all the parameters and the Ticker list form the Matlab Searchpath.
load('params');
[~,ticks,~] = xlsread('Tickers.xlsx');
packages        = params.packages{1};

isExcel = false;
firstYear = 2100;
lastYear = 0;


mkdir(globals.globals.outPutDirectory);
% Now I loop through all of the tickers and download data:
readVarNames = true; % This is to only read the strings in the first file. For all consecutive Files, it is assumed the same.
for p=0:(packages-1)
    disp(num2str(p))
    
    if not(isExcel)
        load(strcat('Temp/Table_',int2str(p)));
        data = cell2mat(table2array(packCollection(:,2:end)));
        ncols = size(data,2)+1;
        if readVarNames
            varNames = packCollection.Properties.VariableNames;
            readVarNames = false;
        end
        tickArray = {table2array(packCollection(:,1))};
        clear packCollection
    else
        fileName = strcat('Table_',int2str(p),'.csv');
        % Read Numerical Data:
        data = csvread(fileName,1,1);
        ncols = size(data,2)+1;
        % Prepare for textscan:
        fid = fopen(fileName);
        textformat = repmat('%s',1,ncols);
        % Read header row:
        if readVarNames
            varNames = textscan(fid,textformat,1, 'delimiter',',');
            varNames = [varNames{1,:}];
            readVarNames = false;
        end
        % Read Ticks
        tickArray = textscan(fid,'%s%*[^\n]', 'delimiter',',','HeaderLines', 1);
        fclose(fid);
    end
    % Get all the years that are present:
    yearsUsed = unique(data(:,2));
    for q=1:size(yearsUsed,1)
        yearIndex = find(data(:,2) == yearsUsed(q,1));
        setName = ['Y',int2str(yearsUsed(q,1)),'.Data'];
        tempData = [tickArray{1,1}(yearIndex,:), num2cell(data(yearIndex,:))];
        tempTable = array2table(tempData,'VariableNames',varNames);
        % If it is the first time that data for the current year is found,
        % i need to initialize the set. Otherwise I can just vertcat to the
        % old.
        if exist(['Y',int2str(yearsUsed(q,1))],'var')==0
            eval([setName,'=[];']);
        elseif isfield(eval(['Y',int2str(yearsUsed(q,1))]),'Data')==0
            eval([setName,'=[];']);
        end
        
        eval([setName,'=vertcat(',setName,',tempTable);']);
    end
    firstYear = min([firstYear;yearsUsed]);
    lastYear = max([lastYear;yearsUsed]);
    clear tempTable tempData data
end
disp('Saving Price-Data per year:');
for y = firstYear:lastYear
    disp(y);
    if exist(['Y',int2str(y)],'var')
        save(strcat(globals.outPutDirectory,'/Year_',int2str(y),'.mat'),['Y',int2str(y)],'-v7.3');
    end
end

clearvars -except firstYear lastYear
disp('Using Price-Data to compute and save all Data per year:');
for y = firstYear:lastYear
    disp(y);
    if exist(strcat(globals.outPutDirectory,'/Year_',int2str(y),'.mat'), 'file') == 2
        load(strcat(globals.outPutDirectory,'/Year_',int2str(y),'.mat'));
    end
    if exist(['Y',int2str(y)],'var')
        eval(['Y',int2str(y),'.Returns = getReturns(Y',int2str(y),'.Data);']);
        eval(['Y',int2str(y),'.CulmReturns = getCulmulativeReturns(Y',int2str(y),'.Returns);']);
        eval(['Y',int2str(y),'.MVReturns = getMeanVariance(Y',int2str(y),'.Returns);']);
        eval(['Y',int2str(y),'.MVCulmReturns = getMeanVariance(Y',int2str(y),'.CulmReturns);']);
        eval(['Y',int2str(y),'.ZScoreReturns = getZScore(Y',int2str(y),'.Returns, Y',int2str(y),'.MVReturns);']);
        eval(['Y',int2str(y),'.ZScoreCulmReturns = getZScore(Y',int2str(y),'.CulmReturns, Y',int2str(y),'.MVCulmReturns);']);
        save(strcat(globals.outPutDirectory,'/Year_',int2str(y),'.mat'),['Y',int2str(y)],'-v7.3');
        clearvars -except y firstYear lastYear
    end
end