%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. maj 2018 12:19
%%%-------------------------------------------------------------------
-module(pollution_server_otp).
-behaviour(gen_server).
-author("timelock").

%% API
-export([start_link/1, init/1, handle_cast/2, handle_call/3]).
-export([start/0,crash/0,stop/0]).
-export([getState/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMinimumPollutionStation/1]).
-import(pollution,[createMonitor/0]).

start() ->
  start_link(pollution:createMonitor()).

start_link(Monitor) ->
  gen_server:start_link({local, pollution_server_otp}, pollution_server_otp, Monitor, []).

init(Monitor) ->
  {ok, Monitor}.

stop()->
  gen_server:stop(pollution_server_otp).
%% Some getter functions

getState() ->
  gen_server:call(pollution_server_otp, {getState}).

getOneValue(StationID, DateTime, Type) ->
  gen_server:call(pollution_server_otp, {getOneValue, {StationID, DateTime, Type}}).

getStationMean(StationID, Type) ->
  gen_server:call(pollution_server_otp, {getStationMean, {StationID, Type}}).

getDailyMean(Type, Date) ->
  gen_server:call(pollution_server_otp, {getDailyMean, {Type, Date}}).

getMinimumPollutionStation(Type) ->
  gen_server:call(pollution_server_otp, {getMinimumPollutionStation, {Type}}).

%%Some Setter functions

addStation(Name, {X, Y}) ->
  gen_server:cast(pollution_server_otp, {addStation, {Name, {X, Y}}}).

addValue(StationID, DateTime, Type, Value) ->
  gen_server:cast(pollution_server_otp, {addValue, {StationID, DateTime, Type, Value}}).

removeValue(StationID, DateTime, Type) ->
  gen_server:cast(pollution_server_otp, {removeValue, {StationID, DateTime, Type}}).

crash() ->
  gen_server:cast(pollution_server_otp, crash).


handle_cast({addStation, {Name, {X, Y}}}, CurrentVal)
  -> {noreply, pollution:addStation(Name, {X, Y}, CurrentVal)};

handle_cast({addValue, {StationID, DateTime, Type, Value}}, CurrentVal)
  -> {noreply, pollution:addValue(StationID, DateTime, Type, Value, CurrentVal)};

handle_cast({removeValue, {Name, DateTime, Type}}, CurrentVal)
  -> {noreply, pollution:removeValue(Name, DateTime, Type, CurrentVal)};

handle_cast(crash, CurrentVal)
  -> {noreply, pollution:crash()}.


handle_call({getState}, Pid, CurrentVal) ->
  {reply, CurrentVal, CurrentVal};

handle_call({getOneValue, {StationID, DateTime, Type}}, Pid, CurrentVal) ->
  {reply, pollution:getOneValue(StationID, DateTime, Type, CurrentVal), CurrentVal};

handle_call({getStationMean, {StationID, Type}}, Pid, CurrentVal) ->
  {reply, pollution:getStationMean(StationID, Type, CurrentVal), CurrentVal};

handle_call({getDailyMean, {Day, Type}}, Pid, CurrentVal) ->
  {reply, pollution:getDailyMean(Day, Type, CurrentVal), CurrentVal};

handle_call({getMinimumPollutionStation, {Type}}, Pid, CurrentVal) ->
  {reply, pollution:getMinimumPollutionStation(Type, CurrentVal), CurrentVal}.