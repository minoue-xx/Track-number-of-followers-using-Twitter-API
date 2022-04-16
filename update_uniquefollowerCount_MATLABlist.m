% This script use Twitter connection object (Datafeed Toolbox) to extract
% the unique follower count of the account listed in a particular list.
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

%%
% https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-user_timeline
baseurl = 'https://api.twitter.com/1.1/followers/ids.json';

parameters.screen_name = d.Body.Data.users{1}.screen_name;
parameters.stringify_ids = 'true';
% parameters.screen_name = 'michio_MWJ';
% parameters.cursor =  next_cursor;
parameters.count = 5000; % 取得する数
% next_cursor = d.Body.Data.next_cursor_str;

ids = [];

for ii=1:length(d.Body.Data.users)
    parameters.cursor =  -1;
    parameters.screen_name = d.Body.Data.users{ii}.screen_name;
    while any(parameters.cursor ==  -1) || (~isfield(d2.Body.Data, 'next_cursor') || d2.Body.Data.next_cursor ~= 0)

        % Search for follower
        d2 = getdata(c,baseurl, parameters);
        if d2.StatusCode == "TooManyRequests"
            disp("TooManyRequests: wait for 20 minutes for the next request.")
            pause(60)
            disp("1 min passed...")
            pause(60)
            disp("2 min passed.....")
            pause(18*60) % wait for 20 minutes
            disp("20 mins passed!!")
            d2 = getdata(c,baseurl, parameters);
            disp(d2.StatusCode)
        end
        ids = [ids; d2.Body.Data.ids];
        parameters.cursor = d2.Body.Data.next_cursor_str;

    end
end

%%
disp("length(ids) = " + length(ids))
disp("length(unique(ids)) = " + length(unique(ids)))
