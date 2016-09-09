function d = getMonths(array)

% This function takes a [nx2]-matrix of time-series data, with the dates in
% the Matlab Date Format in column 1 and the time-series data in column 2.
% It retuns a cell array of matrices with each matrix containing the
% time-series data for one unique year - month combination. All of the data
% is returned, packaged into monthly packs, with the packs being
% [mx4]-matrices, where m is the number of trading days in that month and
% the first coulmn being the month, the second being the year, the third
% being the date (the first and second coumn map directly to that date) and
% the forth is the time-series data.

years = year(array(:,1));
months = month(array(:,1));
contDate = years + (months-1)/12;

[~,~,uniqueIndex] = unique(contDate);

toSplit = [months years array(:,1) array(:,2)];

d = mat2cell(toSplit,flip(accumarray(uniqueIndex(:),1)),4);

end