%==========================================================================
%                               Deep Pockets
%                    2: Importing Data form Datastream Set
%                              February 2017                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
FOLDER_NAME = pwd;
cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
%==========================================================================
close all
clear
%
%==========================================================================
% This is an adaption of a script used to download data with a direct
% connection to an external source (Bloomberg, Datastream, Yahoo, Google).
% The adaptio~n was needed because of a paywall for most of the good data,
% and the poor quality of data on free services. What is used now is a
% collection of sets downloaded externally, via a Datastream terminal and
% saved in a uniform excel file format. 
% STRUCTURE OF FILES:
% The data is generated with a 'Datastream Request Table', using
% Time-Series-List downloads. These are Lists of 1000 ISINs each that were
% created manually and are then fed into the 'Request Table'. The output is
% an [nx1001] table with dates in the first colomn, the company name in
% the first and the ISIN in the second rows. Startdate was manually set to
% date of download minus 67 years, which is the 21.02.1950 in our case.
% Every file contains three sheets of data, which were manually split up
% into seperate files. These files follow an integer naming convention.
% They have been imported into matlab on a seperate Windows machine, and
% are now available as stored Matlab Table Types in .mat Foramt.
% !!!IMPORTANT!!! : 
% Dates do not really matter. The script should be able to deal with any 
% start date. Just make sure that there are two header rows (Name and ISIN) 
% and that dates are in the first column.
%   --- Two header rows: Names and ISINs
%   --- Dates in first Column
%   --- NaN-String: "N/A"
%   --- Errors in Datastream download: 
%                              Name is "#ERROR" and no data after
%                              Row 4 (all others have "N/A" till the end).
% Since the script is adapted, params and other parts might still contain
% info that was used to manually download from external source.
%==========================================================================
% I load all the parameters form the Matlab Searchpath.
load('params');
% I 'unpack' some params for readability:
noConsMonths            = params.noConsMonths{1};
numberOfDownloadedFiles = params.NR_DOWNLOADED_FILES{1};
packsPerOutputTable     = params.PACKS_PER_OUTPUT_TABLE{1};
%   I initialize empty sets to collect the data:
% ---------------------->!! INITIALIZATION !!<-----------------------------
% initializing running variable(s):
p = 1;
lineCount = 1;
mkdir('Temp')
% -------------------------->!! LOOP !!<-----------------------------------
for f=1:numberOfDownloadedFiles
    display(['Looking at List ' num2str(f) ' of ' num2str(numberOfDownloadedFiles) '.'])
%    tic
    currentMat=load([int2str(f),'_M']);
%    toc
    currentMat = currentMat.Data;
    dates = currentMat(2:end,1);
    for i=1:(size(currentMat,2)-1)
        c=i+1; %because the first one is dates
 
        UniqueIdKey = currentMat(1,c);
        equityReturns = currentMat(2:end,c);

        % I filter out all 'N/A' by looking for non numeric fomrat:
        Index = find(~isnan(equityReturns));
        equityReturns=equityReturns(Index);
        datesUseable = dates(Index);
        % And create a set of only these returns:
        d = [datesUseable, equityReturns]; % This is great, this is a Matrix! Very efficient!

        d = getMonths(d);
        monthIndicator = getValidityOfMonths(d,params);
        if size(d,1)==0
            usableMonths = [];
        else
            usableMonths = getConsecutiveMonths(monthIndicator,params);
        end
        if size(usableMonths,1)>0
            % So, I have a set of all the months that we observe, and I know
            % which periods I can use for my analysis. Every row of
            % 'usableMonths' provides at least one usable 'package'.
            for j=1:size(usableMonths,1)
                for k=1:(usableMonths(j,2)-usableMonths(j,1)-noConsMonths+1) % I get the number of packages as the length of the run minus noConsMonths-1.
                    packMatrix = getPack(d(usableMonths(j,1)+k-1:usableMonths(j,1)+k-1+noConsMonths-1,1),UniqueIdKey,params);
                    if lineCount == 1 
                        packCollection = nan(packsPerOutputTable,size(packMatrix,2));
                    end
                    if size(packMatrix,1)>0
                        packCollection(lineCount,:) = packMatrix(1,:);
                    end
                    if lineCount==packsPerOutputTable
                        display(['Writing to file. (Table: ' num2str(p) ')'])
                        % I could export to .csv, if for some reason we would want it to be usable
                        % outside matlab. Default is saving in matlab format.
                        %writetable(packCollection,strcat('Temp/Table_',int2str(p),'.csv'));
                        save(strcat('Temp/Table_',int2str(p),'.mat'),'packCollection');
                        packCollection = [];
                        p = p+1;
                        lineCount = 0;
                    end
                    lineCount = lineCount + 1;
                end
            end
        end
    end
end
display(['Writing to file. (Table: ' num2str(p) ', last)'])
params.packages = p;
save('params.mat','params');
% I could export to .csv, if for some reason we would want it to be usable
% outside matlab. Default is saving in matlab format.
%writetable(packCollection,strcat('Temp/Table_',int2str(p),'.csv'));
mkdir('Temp')
save(strcat('Temp/Table_',int2str(p),'.mat'),'packCollection');