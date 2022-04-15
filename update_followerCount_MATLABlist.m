% This script use Twitter connection object (Datafeed Toolbox) to extract
% the follower count of the account listed in a particular list.
% Copyright (c) 2022 Michio Inoue.

% Replace with your own credentials.
% Using setenv/getenv so that it can be used in GitHub Actions for automate
% the process.
setenv('CONSUMERKEY','xxxxxxxxxxxxxx');
setenv('CONSUMERSECRET','xxxxxxxxxxxxxx');
setenv('ACCESSTOKEN','xxxxxxxxxxxxxx');
setenv('ACCESSTOKENSECRET','xxxxxxxxxxxxxx');

consumerkey = getenv("CONSUMERKEY");
consumersecret = getenv("CONSUMERSECRET");
accesstoken = getenv("ACCESSTOKEN");
accesstokensecret = getenv("ACCESSTOKENSECRET");

% Create Twitter connection object
c = twitter(consumerkey,consumersecret,accesstoken,accesstokensecret);

%%
% List: MATLAB の中の人達（JP）
% https://twitter.com/i/lists/1483201415342596096
parameters.list_id = '1483201415342596096';

% Twitter API v2: List members
% https://developer.twitter.com/en/docs/twitter-api/lists/list-members/introduction
baseurl = 'https://api.twitter.com/1.1/lists/members.json';
% specify the number of items for the HTTP request:
parameters.count = 200;

% Retrieve Twitter data
d = getdata(c,baseurl,parameters);

% Example: output is the vector of structures
% d.Body.Data.users{1}
%  id: 1.4982e+18
%  id_str: '1498237705867579395'
%  name: 'Satoru Abe'
%  screen_name: 'SatoruAbe_MW'

% Followers_count for each account can be found here:
% d.Body.Data.users{1}.followers_count

%% Restructure the output
ssize = length(d.Body.Data.users);
    
id_str = strings(ssize,1);
screen_name = strings(ssize,1);
followers_count = zeros(ssize,1);
friends_count = zeros(ssize,1);
for ii = 1:ssize
    id_str(ii) = d.Body.Data.users{ii,1}.id_str;
    screen_name(ii) = d.Body.Data.users{ii,1}.screen_name;
    followers_count(ii) = d.Body.Data.users{ii,1}.followers_count;
    friends_count(ii) = d.Body.Data.users{ii,1}.friends_count;
end
% put the data to a table
data = table(id_str,screen_name,followers_count,friends_count);

%% Append timestamp
followers_counts = array2table(followers_count', 'VariableNames', id_str');
followers_counts.Properties.VariableDescriptions = screen_name';
tt = table2timetable(followers_counts,"RowTimes",datetime);

if ~exist('followercount_history.csv','file')
    writetimetable(tt,'followercount_history.csv');
else
    tt_old = readtable('followerscount_history.csv',...
    'ReadVariableNames',true, 'VariableNamingRule', 'preserve');

    tt = outerjoin(tt_old, timetable2table(tt),'MergeKeys',true);
    writetimetable(tt,'followercount_history.csv');
end