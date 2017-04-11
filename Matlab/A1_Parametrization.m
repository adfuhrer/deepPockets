%==========================================================================
%                               Deep Pockets
%                            1: Parametrization
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
clc
%
%==========================================================================
% We set parameters for the process:
% ------------------------>!! PARAMETERS !!<-------------------------------
% GENERAL SETTINGS:
% -- In what folder is the data stored? Temporary data will be stored here
%       as well. It should be a local path.
%       In this folder, three subfolders will be created:
%           -    Temp: contains the data in the new 'packages' format, as
%                specified within this script (days, weeks, months)
%           -  Output: contains the data transformed to returns, culReturns,
%                z-scores of both and as raw data, grouped by years.
%           - homerun: contains the final datasets in the .mat format. They
%                will then be used in the network.
DATA_SAVE_PATH = '/Users/adrian/Deep Pockets/Matlab/Data';
% DATA_SAVE_PATH = % Set a second one that can be easily commented/uncomm.
% -- This is to control wether a .mat file of the set is stored in the
%       end (at any rate, the set will be available in the heap at the end)
STORE_DOT_MAT = true;
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

% I allow to specify a 'stretch' that is required, that is a number of
% consecutive month in the recent history for securities to be viable for
% testing the Network. The stretch is characterized by its length and the
% date it ends.
requiredLengthOfStretch = 12*10;
requiredMinimalEndDateOfStretch = 736697; %01.01.2017
testSetSize = 200;
nrRandomSets = 5;
chosenSet1=[7047;5354;119957;119956;16814;119955;112089;34608;119953;119948;119947;10469;8345;34378;119946;149;34379;87666;26363;119944;7401;11595;26364;114407;119942;119941;114408;34491;114411;7675;119940;119939;114409;119938;6180;11695;34492;114410;156;119981;119937;5042;4065;11871;5744;119932;26367;119931;119930;114412;119923;119785;13704;119927;11054;26368;119989;87546;6774;87549;87552;6723;7100;26371;119915;87561;119988;119204;34493;119912;11917;7071;119910;34494;26372;119834;7715;114413;119907;119906;114415;34610;119904;34380;119903;26374;7979;87933;34495;119900;115146;34612;119898;17294;119986;119756;6758;119924;11077;6132;114416;26378;13678;114406;8040;8042;114417;119840;26379;26380;114418;119909;119207;3374;10484;119893;34613;119819;10864;119985;8104;194;119888;119975;26383;17006;34381;26384;119886;119885;119884;12417;114419;34614;6167;119883;34615;87755;26386;200;119877;6647;119874;26389;26388;26396;119872;119838;119871;114421;3871;34496;119743;87834;119869;13821;12372;34616;11570;119740;87835;119867;119983;13720;119866;26393;119864;26398;16762;13915;26399;119860;119816;119858;114422;119856;5055;5054;119736;114424;8378;114423;26376;119855;87585;10993;11819;11894;26400;114425;34617;119628;114426;119853;119850;6971;114427;119849;34618;26401;119848];
chosenSet2=[1;2];

chosenSetsConstituents = [chosenSet1,chosenSet2];

cutoffYear = 2014;
nameSuffixOfSet = '_new';

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

paramsData = [DATA_SAVE_PATH, STORE_DOT_MAT, NR_DOWNLOADED_FILES, PACKS_PER_OUTPUT_TABLE, minTradingDays, noDailyObs, noWeeklyObs, noMonthlyObs, ...
    {futureUnit}, futureStep, noConsMonths, date, minPrice, maxGR, maxNonVariationDays, cutoffYear, criticalValue, ...
    nameSuffixOfSet, requiredLengthOfStretch, requiredMinimalEndDateOfStretch, testSetSize, nrRandomSets, chosenSetsConstituents];
paramsNames = {'DATA_SAVE_PATH' 'STORE_DOT_MAT' 'NR_DOWNLOADED_FILES' 'PACKS_PER_OUTPUT_TABLE' 'minTradingDays' 'noDailyObs' 'noWeeklyObs' ...
    'noMonthlyObs' 'futureUnit' 'futureStep' 'noConsMonths' 'date' 'minPrice' 'maxGR' 'maxNonVariationDays' ...
    'cutoffYear' 'criticalValue' 'nameSuffixOfSet' 'requiredLengthOfStretch' 'requiredMinimalEndDateOfStretch' 'testSetSize' 'nrRandomSets' 'chosenSetsConstituents'};
params = array2table(paramsData,'VariableNames',paramsNames);

% Since the function 'getVarNamesFromParams' uses the params as input, it
% is easiest to use it right here and create the varNames, and then save
% them as part of the params. Then, they are accesible at all times.
varNames = getVarNamesFromParams(params);
varNames = array2table({varNames},'VariableNames',{'VarNames'});
params = horzcat(params, varNames);
save('Matlab/params.mat','params');

% I can now try to call the different scripts from right here. This allows
% for a lot of freedom: I run this script and end up with a finished
% Dataset! 
% If not all steps are needed, feel free to comment out any script-calls.
tic
disp('Starting to repackage the raw date according to the parametrization...')
run('A2_Import.m')
toc
disp('Sorting packages by months and years to get relative performance measures...')
run('A3_CreateSets.m')
toc
disp('Computing relative performance measures...')
run('A4_ComputeReturns.m')
toc
disp('Writing the dataset to file...')
run('A5_CreateCSV.m')
toc