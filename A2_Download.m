%==========================================================================
%                               Deep Pockets
%                      2: Downloading a huge Dataset.
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================

%==========================================================================
close all
clear
clc
%
%==========================================================================
% I load all the parameters and the Ticker list form the Matlab Searchpath.
load('params');
[~,ticks,~] = xlsread('Tickers.xlsx');
% I 'unpack' some params for readability:
packageSize     = params.packageSize{1};
date            = params.date{1};
noConsMonths    = params.noConsMonths{1};
packages        = params.packages{1};
% Now I loop through all of the tickers and download data:
%   I initializes empty sets to collect the data:
% ---------------------->!! INITIALIZATION !!<-----------------------------
% initializing running variable(s):
connect = yahoo;
packCollection = [];
h = waitbar(0,'Please wait...');
% -------------------------->!! LOOP !!<-----------------------------------
for p=0:(packages-1)
    for i=(p*packageSize+1):min((p+1)*packageSize,length(ticks))
        waitbar(i / length(ticks),h,sprintf('%2.0f',i))
        try
            d = fetch(connect,ticks{i,1},'Close',date,today);
        catch
            d= [0 0];
        end
        tick = strcat('EQ_',strrep(strrep(strrep(strrep(ticks(i,1),'.','_'),'-','_'),'@','_'),':','_'));
        d = getMonths(d);
        monthIndicator = getValidityOfMonths(d,params);
        usableMonths = getConsecutiveMonths(monthIndicator,params);
        if size(usableMonths,1)>0
            % So, I have a set of all the months that we observe, and I know
            % which periods I can use for my analysis. Every row of
            % 'usableMonths' provides at least one usable 'package'.
            for j=1:size(usableMonths,1)
                for k=1:(usableMonths(j,2)-usableMonths(j,1)-noConsMonths+1) % I get the number of packages as the length of the run minus noConsMonths-1.
                    packTabel = getPack(d(usableMonths(j,1)+k-1:usableMonths(j,1)+k-1+noConsMonths-1,1),tick,params);
                    packCollection = vertcat(packCollection,packTabel);
                end
            end
        end
    end
display('Writing to file.')
% I could export to .csv, if for some reason we would want it to be usable
% outside matlab. Default is saving in matlab format.
%writetable(packCollection,strcat('Temp/Table_',int2str(p),'.csv'));
mkdir('Temp')
save(strcat('Temp/Table_',int2str(p),'.mat'),'packCollection');
packCollection = [];
end
close(h)