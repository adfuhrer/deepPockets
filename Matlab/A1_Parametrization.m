%==========================================================================
%                               Deep Pockets
%                            1: Parametrization
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
FOLDER_NAME = pwd;
cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
%==========================================================================
close all
clear
clc
%
%==========================================================================
% We set parameters for the process:
% ------------------------>!! PARAMETERS !!<-------------------------------
%--------------------------------------------------------------------------
% SPECIFYING FEATURES:
% -- How many individual sheets were downloaded form Datastream?
NR_DOWNLOADED_FILES = 154;
% -- When repackaging the time series, how many packages should be fit into
%    one Output Table?
PACKS_PER_OUTPUT_TABLE = 5000;
%       This is a trade-off: RAM-congestion vs. fewer files to create.

% -- What is the minimum trading days we require to be in a month?
%       This should be closely linked to the 'noDailyObs' value below.
minTradingDays = 19;
% -- How many trading days do we include in the monthly package?
%       Trading days are taken from the last day in the month towards the
%       first day of the month. So if the last trading day in February is
%       the 28th (Friday), then we take the 28th, 27th, 26th ... until we
%       have found 19 trading days. We thus loose some at the beginning.
%       --> Link this closely to the 'minTradingDays': Ideally, it is an
%       integer multiple of 'minTradingDays', so that we look at one or two
%       month on a daily basis. If this is not the case, all the days after
%       'minTradingDays' are taken from a new month (23: 19 in the first
%       month, 4 in the second (although there might be more than 19 in the
%       first month..)
noDailyObs = 19;
% -- How many weekly observations do we include in the monthly package?
%       A month is assumed to have exactly 4 weekly observations.
noWeeklyObs = 8;
% -- How many monthly observations do we include in the monthly package?
%       A monthly Obs is ALWAYS the last trading day in the month. So any
%       left over days or weeks prohibit this month from being a monthly
%       Obs.
noMonthlyObs = 9;
% -- What point in the future do we take as a reference?
%       futureUnit is one of 'd', 'w', 'm'. It is the unit, either daily,
%       weekly or monthly of the point of reference.
%       futureStep is the number of Units the point lies in the future.
futureUnit = 'm';
futureStep = 1;
% -- What is the price-threshold, at which the data is ignored? In USD.
minPrice = 2;
% -- What are the maximally allowed price-swings within months? In 100%.
maxGR = 2;
% -- How many traiding-days with no movement are allowed within a month?
maxNonVariationDays = 5;
%--------------------------------------------------------------------------
% SPECIFYING THE TEST SET:
% -- In this case, we just use a time-cutoff: Everything before
%    'cutoffYear' goes into the training, everything after into the test 
%    set.
cutoffYear = 2014;
nameSuffixOfSet = '_newWithFutureValue';

%--------------------------------------------------------------------------
% SPECIFYING CLASSIFICATION:
% -- What is the critical-value cutoff for the specification in to TopFlop?
TailSize = 0.1; % Each Tail has this size (i.e. 0.1: 10% in the upper and 10% in the lower tail.
criticalValue = norminv(1-TailSize,0,1);

%==========================================================================


% I collect all the parameters to be able to hand them to functions so they
% can use them. I even export them to .csv for later use.

% From the Parameters, I can obtain the number of consecutive months
% needed:
unassignedDays = rem(noDailyObs,minTradingDays);
noConsMonths = (noDailyObs-unassignedDays)/minTradingDays ...
    + ceil(unassignedDays/20 + noWeeklyObs/4) + ... Devide by 20 because weeks are always 4 at 5 days per month
    + noMonthlyObs ...
    + (futureUnit == 'm')*futureStep ...
    + ceil((futureUnit == 'w')*futureStep/4) ...
    + ceil((futureUnit == 'd')*futureStep/minTradingDays);

paramsData = [NR_DOWNLOADED_FILES, PACKS_PER_OUTPUT_TABLE, minTradingDays, noDailyObs, noWeeklyObs, noMonthlyObs, ...
    {futureUnit}, futureStep, noConsMonths, date, minPrice, maxGR, maxNonVariationDays, cutoffYear, criticalValue, ...
    nameSuffixOfSet];
paramsNames = {'NR_DOWNLOADED_FILES' 'PACKS_PER_OUTPUT_TABLE' 'minTradingDays' 'noDailyObs' 'noWeeklyObs' ...
    'noMonthlyObs' 'futureUnit' 'futureStep' 'noConsMonths' 'date' 'minPrice' 'maxGR' 'maxNonVariationDays' ...
    'cutoffYear' 'criticalValue' 'nameSuffixOfSet'};
params = array2table(paramsData,'VariableNames',paramsNames);

% Since the function 'getVarNamesFromParams' uses the params as input, it
% is easiest to use it right here and create the varNames, and then save
% them as part of the params. Then, they are accesible at all times.
varNames = getVarNamesFromParams(params);
varNames = array2table({varNames},'VariableNames',{'VarNames'});
params = horzcat(params, varNames);
save('params.mat','params');

% I can now try to call the different scripts from right here. This allows
% for a lot of freedom: I run this script and end up with a finished
% Dataset! 
tic
%disp('Starting to repackage the raw date according to the parametrization...')
%run('A2_Import.m')
%toc
%disp('Sorting packages by months and years to get relative performance measures...')
%run('A3_CreateSets.m')
%toc
%disp('Computing relative performance measures...')
%run('A4_ComputeReturns.m')
%toc
disp('Writing the dataset to file...')
run('A5_CreateCSV.m')
toc