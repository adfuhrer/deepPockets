function returnsSet = getReturns(set)

% We take in a package with prices and compute the returns of them

DataMatrix = cell2mat(table2array(set(:,2:end)));

% Except for the first two rows (month and year), there is always a pair of
% date and price. So I start 2 columns in and take very even row and
% replace it, except for the very last one, which I set to NaN or just get
% rid off...
for n = 1:((size(DataMatrix,2)-4)/2)
    k = 2+2*n;
    DataMatrix(:,k) = DataMatrix(:,k) ./ DataMatrix(:,k+2) - 1;
end
set(:,2:end) = array2table(num2cell(DataMatrix));
returnsSet = set;

end