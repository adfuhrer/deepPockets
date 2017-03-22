function consMonth = getConsecutiveMonths(vector, params)

% We need a binary vector and return a matrix nx2, where the first column
% indicates the start of a consecutive run of trues and the second coulmn
% indicated the end. We only return runs that have a minimum number of months
% (specified in params).
minConsMonths = params.noConsMonths{1};

a = diff([0; vector; 0]);
b = [find(a>0) find(a<0)];
c = [b(b(:,2)-b(:,1)>=minConsMonths,1) b(b(:,2)-b(:,1)>=minConsMonths,2)-1];

consMonth = c;

end