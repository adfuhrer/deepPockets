function indicators = getValidityOfMonths(array, params)

% This function takes in a cell array of matrices, where each matrix
% represents a unique month-year combination of time series data and is a 
% [mx4]-matrix, where m is the number of trading days in that month and
% the first coulmn being the month, the second being the year, the third
% being the date (the first and second coumn map directly to that date) and
% the forth is the time-series data.
% It returns a boolean array for every month-year combination, indicating
% if that month-year combination meets certain criteria. The criteria
% tested are the following:
%   - if a given minimum number of trading days is available for that month
%   - if the time series value drops below a certain threshold
%   - if there is more than a certain number of days with no trades
ind = zeros(length(array),1);

for i=1:length(array)
    testSet = array{i,1}(:,4);
    testSetGR = testSet(2:end)./testSet(1:end-1)-1;
    testSetGRofZero = (testSetGR==0);
    % 1. Are there at least x trading-days in the months?
    if length(testSet)>=params.minTradingDays{1}
        % 2. Are there any prices below $x in the month?
        if min(testSet)>=params.minPrice{1}
            % 3. Are there growth-rates of more than +/- x00%?
            if max(abs(testSetGR))<=params.maxGR{1}
                % 4. Are there less than x trading-days without variation?
                if sum(testSetGRofZero)<=params.maxNonVariationDays{1}
                    ind(i,1)=1;
                end
            end
        end
    end
    
    
end

indicators = ind;

end