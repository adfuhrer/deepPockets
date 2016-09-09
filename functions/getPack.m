function tablePack = getPack(cellArray,tick,params)
% This function takes 13 monthly packs that meet certain criteria and
% creates one pack of obs that can be used by the neural network

% For often used Params, I assign simpler names:
consMonths = params.noConsMonths{1};
minTradingDays = params.minTradingDays{1};
noDailyObs = params.noDailyObs{1};
noWeeklyObs = params.noWeeklyObs{1};
noMonthlyObs = params.noMonthlyObs{1};
futureUnit = 'd';%params.futureUnit{1};
futureStep = 1; %params.futureStep{1};
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
pack = cell(1,packageLength);

posC = 1; % position Counter
moC = 1;  % months Counter
% We need to make sure that there are no big jumps between months:
interMonthsGR=NaN(consMonths-1,1);
for i=1:(consMonths-1)
    interMonthsGR(i,1) = cellArray{i}(end,4)./cellArray{i+1}(1,4)-1;
end
if max(abs(interMonthsGR))<=params.maxGR{1}
    % We can now start to construct the set.
    % The first five are set: They are always tick, month, year,
    % date_Future and Future:
    varNames{1,posC} = 'tick';
        pack{1,posC} = tick{1};
    posC = posC + 1;
    varNames{1,posC} = 'month';
        pack{1,posC} = cellArray{1 + futureMonths}(1,1);
    posC = posC + 1;
    varNames{1,posC} = 'year';
        pack{1,posC} = cellArray{1 + futureMonths}(1,2);
    posC = posC + 1;
    varNames{1,posC} = 'date_Future';
        pack{1,posC} = cellArray{1}(futureDayOfMonth,3);
    posC = posC + 1;
    varNames{1,posC} = 'Future';
        pack{1,posC} = cellArray{1}(futureDayOfMonth,4);
    posC = posC + 1;
    moC = moC + futureMonths;
    % We collect the noDailyObs last trading days in the month (or the next month):
    for p = 0:ceil(noDailyObs/minTradingDays)-1
        for d = 1:min(minTradingDays,noDailyObs-p*minTradingDays)
            varNames{1,posC} = strcat('date_Day',int2str(d+p*minTradingDays));
                pack{1,posC} = cellArray{moC}(d,3);
            posC = posC + 1;
            varNames{1,posC} = strcat('Day',     int2str(d+p*minTradingDays));
                pack{1,posC} = cellArray{moC}(d,4);
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
                pack{1,posC} = cellArray{moC}(1+5*(w-1),3);
            posC = posC + 1;
            varNames{1,posC} = strcat('Week',     int2str(w+q*4));
                pack{1,posC} = cellArray{moC}(1+5*(w-1),4);
            posC = posC + 1;
        end
        moC = moC + 1;
    end
    % For months we collect the value of the last trading day:
    for m=1:noMonthlyObs
        varNames{1,posC} = strcat('date_Month',int2str(m));
            pack{1,posC} = cellArray{moC}(1,3);
        posC = posC + 1;
        varNames{1,posC} = strcat('Month',     int2str(m));
            pack{1,posC} = cellArray{moC}(1,4);
        posC = posC + 1;
        moC = moC + 1;
    end
    tablePack = array2table(pack,'VariableNames',varNames);
else
    tablePack = [];
end

end
