%==========================================================================
%                               Deep Pockets
%                    2: Importing Data form Datastream Set
%                              February 2017                       
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
DATA_SAVE_PATH          = params.DATA_SAVE_PATH{1};
requiredLengthOfStretch = params.requiredLengthOfStretch{1};
requiredMinimalEndDateOfStretch = params.requiredMinimalEndDateOfStretch{1};
testSetSize             = params.testSetSize{1};
nrRandomSets            = params.nrRandomSets{1};
chosenSetsConstituents  = params.chosenSetsConstituents{1};
% Here, I add the path where the data is stored to the searchpath:
%   DON'T FORGET TO CHAGE BACK!! (This is why I save it in FOLDER_NAME)
FOLDER_NAME = pwd;
cd(DATA_SAVE_PATH)
addpath(genpath(DATA_SAVE_PATH))
% ---------------------->!! INITIALIZATION !!<-----------------------------
% initializing running variable(s):
p = 1;
lineCount = 1;
securitiesToSets = NaN(5000,2);
securitiesToSetsCol = [];
mkdir('Temp')

% -------------------------->!! LOOP !!<-----------------------------------
for f=1:numberOfDownloadedFiles
    disp(['Looking at List ' num2str(f) ' of ' num2str(numberOfDownloadedFiles) '.'])
    currentMat=load([int2str(f),'_M']);
    currentMat = currentMat.Data;
    securitiesToSets = NaN(5000,2);
        
    dates = currentMat(2:end,1);
    for i=2:(size(currentMat,2)) %because the first one is dates
 
        UniqueIdKey = currentMat(1,i);
        equityReturns = currentMat(2:end,i);
        securitiesToSets(i-1,1) = UniqueIdKey;
        % I filter out all NaN:
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
            [usableMonths, stretch] = getConsecutiveMonths(monthIndicator,params);
            % After this, 'stretch' will contain two elements: [lengthOfStretch, lastUsableDate]
            if not(isnan(stretch(1,2)))
                stretch(1,2) = d{stretch(1,2),1}(end,3);
            end
            % If the stretch is at least 20 years and ends in January of
            % 2017, we indicate that it is a good security for analysis.
            if (stretch(1,1) >= requiredLengthOfStretch) && (stretch(1,2) >= requiredMinimalEndDateOfStretch)
                goodStretch = 1;
            else
                goodStretch = 0;
            end
            securitiesToSets(i-1,2) = goodStretch;
        end
        if size(usableMonths,1)>0
            % So, I have a set of all the months that we observe, and I know
            % which periods I can use for my analysis. Every row of
            % 'usableMonths' provides at least one usable 'package'.
            for j=1:size(usableMonths,1)
                for k=1:(usableMonths(j,2)-usableMonths(j,1)-noConsMonths+2) % I get the number of packages as the length of the run minus noConsMonths-1.
                    packMatrix = getPack(d(usableMonths(j,1)+k-1:usableMonths(j,1)+k-1+noConsMonths-1,1),UniqueIdKey,params);
                    if lineCount == 1 
                        packCollection = nan(packsPerOutputTable,size(packMatrix,2));
                    end
                    if size(packMatrix,1)>0
                        packCollection(lineCount,:) = packMatrix(1,:);
                    end
                    if lineCount==packsPerOutputTable
                        disp(['Writing to file. (Table: ' num2str(p) ')'])
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
    securitiesToSetsCol = [securitiesToSetsCol; securitiesToSets];
end
disp(['Writing to file. (Table: ' num2str(p) ', last)'])
% I could export to .csv, if for some reason we would want it to be usable
% outside matlab. Default is saving in matlab format.
%writetable(packCollection,strcat('Temp/Table_',int2str(p),'.csv'));
mkdir('Temp')
save(strcat('Temp/Table_',int2str(p),'.mat'),'packCollection');

securitiesToSets = securitiesToSetsCol;
% Cut off unused obs in the end:
securitiesToSets(isnan(securitiesToSets(:,1)),:)=[];
% Securities that do not have any month that we can use are still in this
% list, but they indicate NaN for goodStretch. So, we add a column that
% indicates wether a sec is at all used or not:
usedInSet = ~isnan(securitiesToSets(:,2));
goodStretch = securitiesToSets(:,2);
goodStretch(isnan(goodStretch(:,1)),:)=0; % If the sec's not in set, no goodstretch

randomSets = zeros(length(securitiesToSets),1);
setWithGoodStretch = securitiesToSets(goodStretch==1,1);
% Out of these, I can now randomly choose stocks. Remember to take them out
% of the set afterwards, so that they cannot be in two sets at the same
% time!
randomSetsConstituents = NaN(testSetSize,nrRandomSets);
for x=1:nrRandomSets
    if size(setWithGoodStretch,1)>testSetSize
        indx = randperm(size(setWithGoodStretch,1),testSetSize);
        randomSetsConstituents(:,x) = setWithGoodStretch(indx);
        setWithGoodStretch(indx)=[]; % clear them out such that no sec is double.
    end
end
randomSetsConstituents(:,isnan(randomSetsConstituents(1,:))) = [];% Just in case there were not enough secs for the random set.
disp(['Was able to create ', int2str(size(randomSetsConstituents,2)),' random sets (out of ',int2str(nrRandomSets) ,').'])

for k=1:size(randomSetsConstituents,2)
    randomSets(ismember(securitiesToSets(:,1),randomSetsConstituents(:,k)))=k;
end

chosenSets = zeros(length(securitiesToSets),1);
for k=1:size(chosenSetsConstituents,2)
    chosenSets(ismember(securitiesToSets(:,1),chosenSetsConstituents(:,k)))=k;
end

trainingSet = zeros(length(securitiesToSets),1);
trainingSet(randomSets==0 & chosenSets==0)=1;

secToSets = [securitiesToSets(:,1), usedInSet, goodStretch, randomSets, chosenSets, trainingSet];
save(strcat('Temp/SecToSets.mat'),'secToSets');

cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
params.packages = p;
save('params.mat','params');