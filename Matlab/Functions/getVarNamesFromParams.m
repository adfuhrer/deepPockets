function varNames = getVarNamesFromParams(params)
% This function takes *consMonths* monthly packs that meet certain 
% criteria and creates one pack of obs that can be used by 
% the neural network

    % For often used Params, I assign simpler names:
    consMonths = params.noConsMonths{1};
    minTradingDays = params.minTradingDays{1};
    noDailyObs = params.noDailyObs{1};
    noWeeklyObs = params.noWeeklyObs{1};
    noMonthlyObs = params.noMonthlyObs{1};
    futureUnit = params.futureUnit{1};
    futureStep = params.futureStep{1};
    % This one is new:
    packageLength = 3 + 2 * (1 + noDailyObs + noWeeklyObs + noMonthlyObs);
    % This one as well:
    futureMonths = (futureUnit == 'm')*futureStep ...
        + ceil((futureUnit == 'w')*futureStep/4) ...
        + ceil((futureUnit == 'd')*futureStep/minTradingDays);
    futureDayOfMonth = 1 + ... If we have a monthly unit, we always take the last day of the month.
        + (futureUnit == 'w')*not(rem(futureStep,4)==0)*((4-rem(futureStep,4))*5) ... Depending on 0,1,2,3 weeks left, we start 1, 16, 11, 6 days after end.
        + (futureUnit == 'd')*not(rem(futureStep,minTradingDays)==0)*(minTradingDays - rem(futureStep,minTradingDays));

    varNames = cell(1,packageLength);

    posC = 1; % position Counter
    moC = 1;  % months Counter

    % We can now start to construct the set.
    % The first five are set: They are always UniqueIdKey, month, year,
    % date_Future and Future:
    varNames{1,posC} = 'UniqueIdKey';
    posC = posC + 1;
    varNames{1,posC} = 'month';
    posC = posC + 1;
    varNames{1,posC} = 'year';
    posC = posC + 1;
    varNames{1,posC} = 'date_Future';
    posC = posC + 1;
    varNames{1,posC} = 'Future';
    posC = posC + 1;
    moC = moC + futureMonths;
    % We collect the noDailyObs last trading days in the month (or the next month):
    for p = 0:ceil(noDailyObs/minTradingDays)-1
        for d = 1:min(minTradingDays,noDailyObs-p*minTradingDays)
            varNames{1,posC} = strcat('date_Day',int2str(d+p*minTradingDays));
            posC = posC + 1;
            varNames{1,posC} = strcat('Day',     int2str(d+p*minTradingDays));
            posC = posC + 1;
        end
        moC = moC + 1;
    end
    unassignedDays = rem(noDailyObs,minTradingDays);
    skipWeeks = ceil(unassignedDays / 5);
    % From the 3rd and 4th months we take the last one, the 6th to last,
    % the 11th to last and the 16th to last:
    for q = 0:ceil((noWeeklyObs + skipWeeks)/4)-1
        for w=max(1,(q==0)*(skipWeeks+1)):min(4,noWeeklyObs-q*4 + skipWeeks)
            varNames{1,posC} = strcat('date_Week',int2str(w+q*4));
            posC = posC + 1;
            varNames{1,posC} = strcat('Week',     int2str(w+q*4));
            posC = posC + 1;
        end
        moC = moC + 1;
    end
    % For months we collect the value of the last trading day:
    for m=1:noMonthlyObs
        varNames{1,posC} = strcat('date_Month',int2str(m));
        posC = posC + 1;
        varNames{1,posC} = strcat('Month',     int2str(m));
        posC = posC + 1;
        moC = moC + 1;
    end
end
