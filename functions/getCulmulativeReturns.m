function cReturnsSet = getCulmulativeReturns(set)

% We take in a package with returns and compute the culmulative returns of them

DataMatrix = cell2mat(table2array(set(:,2:end)));

% We have to start at the place where we set the index to 1. Then work from
% there to the front.
DataMatrix(:,end-2)=1;
for n = -((size(DataMatrix,2)-4)/2):-2
    k = abs(2*n);
    DataMatrix(:,k) = DataMatrix(:,k+2) .* (1 + DataMatrix(:,k));
end
set(:,2:end) = array2table(num2cell(DataMatrix));
cReturnsSet = set;

end