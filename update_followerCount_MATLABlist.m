% This script use Twitter connection object (Datafeed Toolbox) to extract
% the follower count of the account listed in a particular list.
% Copyright (c) 2022 Michio Inoue.

% Replace with your own credentials.
% Using setenv/getenv so that it can be used in GitHub Actions for automate
% the process.
% setenv('CONSUMERKEY','xxxxxxxxxxxxxx');
% setenv('CONSUMERSECRET','xxxxxxxxxxxxxx');
% setenv('ACCESSTOKEN','xxxxxxxxxxxxxx');
% setenv('ACCESSTOKENSECRET','xxxxxxxxxxxxxx');

consumerkey = getenv("CONSUMERKEY");
consumersecret = getenv("CONSUMERSECRET");
accesstoken = getenv("ACCESSTOKEN");
accesstokensecret = getenv("ACCESSTOKENSECRET");

% Create Twitter connection object
c = twitter(consumerkey,consumersecret,accesstoken,accesstokensecret);
disp("Twitter connection object created.");

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

disp("Member list retrived.");
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

%% Append timestamp and save to csv
followers_counts = array2table(followers_count', 'VariableNames', id_str');
followers_counts.Properties.VariableDescriptions = screen_name';
tt = table2timetable(followers_counts,"RowTimes",datetime);

if ~exist('followercount_history.csv','file')
    writetimetable(tt,'followercount_history.csv');
else
    tt_old = readtable('followercount_history.csv',...
    'ReadVariableNames',true, 'VariableNamingRule', 'preserve');

    tt = outerjoin(tt_old, timetable2table(tt),'MergeKeys',true);
    writetable(tt,'followercount_history.csv');
end

disp("Data is saved to followercount_history.csv");


%% Retrieve Follower IDs
disp("Start getting follower IDs of each members.");
baseurl = 'https://api.twitter.com/1.1/followers/ids.json';
clear parameters;
parameters.stringify_ids = 'true';
parameters.count = 5000; % max

ids = [];
for ii=1:length(d.Body.Data.users)
    parameters.cursor =  -1;
    parameters.screen_name = d.Body.Data.users{ii}.screen_name;
    while any(parameters.cursor ==  -1) || (~isfield(d2.Body.Data, 'next_cursor') || d2.Body.Data.next_cursor ~= 0)

        % Retrieve followr ids
        d2 = getdata(c,baseurl, parameters);
        if d2.StatusCode == "TooManyRequests"
            disp("TooManyRequests: wait for 20 minutes for the next request.")

            % wait for 20 minutes
            for jj = 1:20
                pause(60)
                disp(jj + " mins...")
            end
            disp("20 mins passed!!")
            d2 = getdata(c,baseurl, parameters);
            disp(d2.StatusCode)
        end
        ids = [ids; d2.Body.Data.ids];
        parameters.cursor = d2.Body.Data.next_cursor_str;
        disp( ii + "/" + length(d.Body.Data.users) + " done...");
    end
end

disp("Finished getting IDs");
disp("length(ids) = " + length(ids));

uniqueIDs = unique(ids);
disp("length(unique(ids)) = " + length(uniqueIDs));

%% Append timestamp and save to csv
t = table(length(ids), length(uniqueIDs), 'VariableNames', ["total","unique"]);
tt = table2timetable(t,"RowTimes",datetime);

if ~exist('uniquefollowercount_history.csv','file')
    writetimetable(tt,'uniquefollowercount_history.csv');
else
    tt_old = readtable('uniquefollowercount_history.csv',...
    'ReadVariableNames',true, 'VariableNamingRule', 'preserve');

    tt = outerjoin(tt_old, timetable2table(tt),'MergeKeys',true);
    writetable(tt,'uniquefollowercount_history.csv');
end

%% Update figure
updatePlot
disp("New figure file denerated.")
