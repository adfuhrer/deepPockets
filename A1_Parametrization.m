%==========================================================================
%                               Deep Pockets
%                            1: Parametrization
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
cd('/Users/adrian/Dropbox/MatlabForDeep')
addpath(genpath('/Users/adrian/Dropbox/MatlabForDeep'))
%==========================================================================
close all
clear
clc
%
%==========================================================================
% We set parameters for the process:
% ------------------------>!! PARAMETERS !!<-------------------------------
% I create first a list of Tickers. I can import them from Excel.
[~,ticks,~] = xlsread('Tickers.xlsx');
% How many years of history should (at most) be downloaded?
history = 100;
% How many tickers per excel-file (output)?
packageSize = 200; 
% What is the minimum trading days we require to be in a month?
%       This should be closely linked to the 'noDailyObs' value below.
minTradingDays = 19;
% How many trading days do we include in the monthly package?
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
% How many weekly observations do we include in the monthly package?
%       A month is assumed to have exactly 4 weekly observations.
noWeeklyObs = 8;
% How many monthly observations do we include in the monthly package?
%       A monthly Obs is ALWAYS the last trading day in the month. So any
%       left over days or weeks prohibit this month from being a monthly
%       Obs.
noMonthlyObs = 9;
% What point in the future do we take as a reference?
%       futureUnit is one of 'd', 'w', 'm'. It is the unit, either daily,
%       weekly or monthly of the point of reference.
%       futureStep is the number of Units the point lies in the future.
futureUnit = 'm';
futureStep = 1;
% From the Parameters, I can obtain the number of consecutive months
% needed:
unassignedDays = rem(noDailyObs,minTradingDays);
noConsMonths = (noDailyObs-unassignedDays)/minTradingDays ...
    + ceil(unassignedDays/20 + noWeeklyObs/4) + ... Devide by 20 because weeks are always 4 at 5 days per month
    + noMonthlyObs ...
    + (futureUnit == 'm')*futureStep ...
    + ceil((futureUnit == 'w')*futureStep/4) ...
    + ceil((futureUnit == 'd')*futureStep/minTradingDays);
% The first date we try to download data for:
date= addtodate(today, -history, 'year');
% How many packages we will need to create:
packages = ceil(length(ticks)/packageSize);
% What is the price-threshold, at which the data is ignored? In USD.
minPrice = 2;
% What are the maximally allowed price-swings within months? In 100%.
maxGR = 2;
% How many traiding-days with no movement are allowed within a month?
maxNonVariationDays = 4;
% I collect all the parameters to be able to hand them to functions so they
% can use them. I even export them to .csv for later use.
paramsData = [history, packageSize, minTradingDays, noDailyObs, noWeeklyObs, noMonthlyObs, ...
    {futureUnit}, futureStep, noConsMonths, date, packages, minPrice, maxGR, maxNonVariationDays];
paramsNames = {'history' 'packageSize' 'minTradingDays' 'noDailyObs' 'noWeeklyObs' ...
    'noMonthlyObs' 'futureUnit' 'futureStep' 'noConsMonths' 'date' 'packages' 'minPrice' 'maxGR' 'maxNonVariationDays'};
params = array2table(paramsData,'VariableNames',paramsNames);
save('params.mat','params');


