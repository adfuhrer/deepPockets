function indicators = getValidityOfMonths(array, params)

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