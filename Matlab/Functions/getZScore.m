function [ZScoreSet, nanRep] = getZScore(DataSet, MVSet)

% We take any package with the common structure and compute mean and var
% per month.

DataMatrix = DataSet;
MVMatrix = cell2mat(table2array(MVSet(:,2:end)));

% We find the Indices for all the lines with the same month-year
% combination for both the dataSet and the mean-variance Set. Then we just
% compute the Z-Score and directly replace it, but only at the places where
% the indices indicate. Like that we step by step replace every datapoint,
% such that we end up with a whole new set of Z-Scores.

for m=1:12
    monthIndex = find(DataMatrix(:,1) == m);
    monthIndexMV = find(MVMatrix(:,1) == m);
    if not(isempty(monthIndex))
        for n = 2:((size(DataMatrix,2)-2)/2)
            k = 2*n;
            DataMatrix(monthIndex,k) = (DataMatrix(monthIndex,k) - MVMatrix(monthIndexMV(1,1),k)) ./ sqrt(MVMatrix(monthIndexMV(2,1),k));
        end

    end
end
nanRep = sum(sum(isnan(DataMatrix(:,1:end-1))));
DataMatrix(isnan(DataMatrix))=0;
ZScoreSet = DataMatrix;

end