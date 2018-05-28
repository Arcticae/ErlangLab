%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. maj 2018 20:54
%%%-------------------------------------------------------------------
-module(pollution_server_otp_test).
-author("timelock").
-include_lib("eunit/include/eunit.hrl").
-import(pollution_server_otp,[start_link/1, init/1, handle_cast/2, handle_call/3]).
-import(pollution_server_otp,[start/0,crash/0]).
-import(pollution_server_otp,[getState/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMinimumPollutionStation/1]).
-import(pollution, [createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3,getMinimumPollutionStation/2]).


getOneValue_test() ->
  pollution_server_otp:start(),
  pollution_server_otp:addStation("Aleja", {50.2, 40.2}),
  pollution_server_otp:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24),
  pollution_server_otp:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 24),
  pollution_server_otp:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_server_otp:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM10", 142),
  pollution_server_otp:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM2,5", 2),
  [?assert( pollution_server_otp:getOneValue("Aleja", {{2018,04,16}, {21,36,14}}, "PM10") =:= 24),
    ?assert( pollution_server_otp:getOneValue("Plac Sikorskiego", {{2018,04,18}, {10,36,14}}, "PM2,5") =:= 2)
  ],
  pollution_server_otp:stop().

getStationMean_test() ->
  pollution_server_otp:start(),
  pollution_server_otp:addStation("Aleja", {50.2, 40.2}),
  pollution_server_otp:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24),
  pollution_server_otp:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 36),
  pollution_server_otp:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_server_otp:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM10", 142),
  pollution_server_otp:addValue({47.4, 52.1}, {{2018,04,18}, {10,36,14}}, "PM2,5", 2),
  [?assert( pollution_server_otp:getStationMean("Aleja", "PM10") == 30),
    ?assert( pollution_server_otp:getStationMean({47.4, 52.1}, "PM2,5") == 2)
  ],
  pollution_server_otp:stop().

getDailyMean_test() ->
  pollution_server_otp:start(),
  pollution_server_otp:addStation("Aleja", {50.2, 40.2}),
  pollution_server_otp:addValue({50.2,40.2}, {{2018,04,16}, {21,36,14}}, "PM10", 24),
  pollution_server_otp:addValue("Aleja", {{2018,04,16}, {21,37,14}}, "PM10", 36),
  pollution_server_otp:addStation("Plac Sikorskiego", {47.4, 52.1}),
  pollution_server_otp:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM10", 120),
  pollution_server_otp:addValue({47.4, 52.1}, {{2018,04,16}, {10,36,14}}, "PM2,5", 2),
  pollution_server_otp:addValue("Aleja", {{2018,04,16}, {14,36,14}}, "PM2,5", 23),
  [?assert( pollution_server_otp:getDailyMean("PM10", {2018,04,16}) == 60),
    ?assert( pollution_server_otp:getDailyMean("PM2,5", {2018,04,16}) == 12.5)
  ],
  pollution_server_otp:stop().

