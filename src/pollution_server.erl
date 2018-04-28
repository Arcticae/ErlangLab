%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. kwi 2018 18:26
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("timelock").

%% API
-export([startServer/0, addStation/2, serverLoop/1, getStatus/0]).

startServer() ->
  register(pollutionServer, spawn(pollution_server, serverLoop, [pollution:createMonitor()])).


serverLoop(CurrentState) ->
  receive
    {addStation, Pid, {Name, {X, Y}}} ->
      Result = pollution:addStation(Name, {X, Y}, CurrentState),
      Pid ! {result, Result},
      serverLoop(Result);

    {getStatus, Pid, _} ->
      Pid ! {result, CurrentState},
      serverLoop(CurrentState)
  end.


%%client functions

request(RequestName, Args) ->
  pollutionServer ! {RequestName, self(), Args},
  receive
    {result, Result} -> Result
  end
.

getStatus() ->
  request(getStatus, {}).

addStation(Name, {X, Y}) ->
  request(addStation, {Name, {X, Y}}).
