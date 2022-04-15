% Update the figure shown on README
% Copyright (c) 2022 Michio Inoue.

tt = readtable('followercount_history.csv',...
    'ReadVariableNames',true, 'VariableNamingRule', 'preserve');

totalFollowes = sum(tt{:,2:end},2);
plot(tt.Time, totalFollowes,'-o')
title('Total follower counts of a Twitter list');
ha = gca;
ha.YAxis.TickLabelFormat = "%d";
ha.YAxis.Exponent = 0;
exportgraphics(gcf,fullfile("fig","historyPlot.png"));