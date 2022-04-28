% Update the figure shown on README
% Copyright (c) 2022 Michio Inoue.

tt = readtable('uniquefollowercount_history.csv',...
    'ReadVariableNames',true, 'VariableNamingRule', 'preserve');

% If the datetime string was not correctly parsed (due to locale setting)
if iscell(tt.Time)
    tt.Time = datetime(tt.Time,'Locale','en_US');
end

plot(tt.Time, tt.total,'-o')
hold on
plot(tt.Time, tt.unique,'-o')
hold off
title('Total follower counts of a Twitter list');
legend(["Total","Unique"])
ha = gca;
ha.YAxis.TickLabelFormat = "%d";
ha.YAxis.Exponent = 0;
exportgraphics(gcf,fullfile("fig","historyPlot.png"));
