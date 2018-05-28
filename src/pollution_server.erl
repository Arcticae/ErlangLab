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
-export([start/0,crashServer/0 ,addStation/2, serverLoop/1, getStatus/0, addValue/4, removeValue/3,getOneValue/3,getStationMean/2,getDailyMean/2,getMinimumPollutionStation/1]).


start() ->
  io:format("Hello im back~n"),
  register(pollutionServer, spawn_link(pollution_server, serverLoop, [pollution:createMonitor()])).


serverLoop(CurrentState) ->
  receive
    {getStatus, Pid, _} ->
      Pid ! {result, CurrentState},
      serverLoop(CurrentState);


    {addStation, Pid, {Name, {X, Y}}} ->
      Result = pollution:addStation(Name, {X, Y}, CurrentState),
      Pid ! {result, Result},
      serverLoop(Result);


    {addValue, Pid, {StationID, DateTime, Type, Value}} ->
      Result = pollution:addValue(StationID, DateTime, Type, Value, CurrentState),
      Pid ! {result, Result},
      serverLoop(Result);

    {removeValue, Pid, {StationID, DateTime, Type}} ->
      Result = pollution:removeValue(StationID, DateTime, Type, CurrentState),
      Pid ! {result, Result},
      serverLoop(Result);

    {getOneValue,Pid, {StationID, DateTime, Type}} ->
      Result = pollution:getOneValue(StationID,DateTime,Type,CurrentState),
      Pid! {result,Result},
      serverLoop(CurrentState);

    {getStationMean,Pid,{StationID,Type}} ->
      Result=pollution:getStationMean(StationID,Type,CurrentState),
      Pid ! {result,Result},
      serverLoop(CurrentState);

    {getDailyMean, Pid, {Day,Type}} ->
      Result=pollution:getDailyMean(Day,Type,CurrentState),
      Pid ! {result,Result},
      serverLoop(CurrentState);

    {getMinimumPollutionStation,Pid,{Type}}->
      Result = pollution:getMinimumPollutionStation(Type,CurrentState),
      Pid ! {result,Result},
      serverLoop(CurrentState);

    {crashSrv,_sth,_sth1} -> 1/0

  end.


%%client functions

request(RequestName, Args) ->
  pollutionServer ! {RequestName, self(), Args},
  receive
    {result, Result} -> Result
  after 1000 -> "Lol no monitor xD"

  end
.

getStatus() ->
  request(getStatus, {}).


addStation(Name, {X, Y}) ->
  request(addStation, {Name, {X, Y}}).

crashServer()->
  request(crashSrv,[]).

addValue(StationID, DateTime, Type, Value) ->
  request(addValue, {StationID, DateTime, Type, Value}).

removeValue(StationID, DateTime, Type) ->
  request(removeValue, {StationID, DateTime, Type}).

getOneValue(StationID,DateTime,Type)->
  request(getOneValue,{StationID,DateTime,Type}).

getStationMean(StationID,Type) ->
  request(getStationMean,{StationID,Type}).

getDailyMean(Day,Type) ->
  request(getDailyMean,{Day,Type}).

getMinimumPollutionStation(Type)->
  request(getMinimumPollutionStation,{Type}).