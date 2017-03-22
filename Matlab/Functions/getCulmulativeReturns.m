function cReturnsSet = getCulmulativeReturns(set)

% We take in a package with returns and compute the culmulative returns of them

%DataMatrix = cell2mat(table2array(set(:,3:end)));

% We have to start at the place where we set the index to 1. Then work from
% there to the front.
set(:,end)=1;
for n = -((size(set,2)-2)/2):-2
    k = abs(2*n);
    set(:,k) = set(:,k+2) .* (1 + set(:,k));
end
cReturnsSet = set;

end