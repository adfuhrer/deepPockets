function MVSet = getMeanVariance(set)

% We take any package with the common structure and compute mean and var
% per month.

% Split the set up in month.
% Then, for each month, create two lines with the excat same format as
% usual, but one is 'mean' and one is 'variance' of that month-year
% combination. In the end, we return a set containing (at most) 24 lines.

finalData = [];
for m=1:12
    monthIndex = find(set(:,1) == m);
    if not(isempty(monthIndex))
        meanMat = set(monthIndex(1,1),:);
        varMat = meanMat;
        for n = 2:((size(set,2)-2)/2)
            k = 2*n;
            meanMat(1,k) = mean(set(monthIndex,k));
            varMat(1,k) = var(set(monthIndex,k));
        end
        tempData = [{'mean';'variance'}, num2cell([meanMat;varMat])];
        finalData = [finalData; tempData];
    end
end
finalTable = array2table(finalData);
MVSet = finalTable;

end