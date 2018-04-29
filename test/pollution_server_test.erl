%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. kwi 2018 11:54
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("timelock").

%% API
-import(pollution_server, [startServer/0, addStation/2, serverLoop/1, getStatus/0, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2,getMinimumPollutionStation/1]).
-include_lib("eunit/include/eunit.hrl").

startServer_test() ->
  ?assertEqual(true, startServer()).

addStation_test() ->
  ?assertEqual({monitor, [{station, "Stacja 1", {2, 4}, []}]}, addStation("Stacja 1", {2, 4})).

addValue_test() ->
  ?assertEqual({monitor, [{station, "Stacja 1", {2, 4}, [{measurement, "PM10", 2, {{2018, 4, 13}, {23, 56, 58}}}]}]},
    addValue("Stacja 1", {{2018, 4, 13}, {23, 56, 58}}, "PM10", 2)).


getOneValue_test() ->
  ?assertEqual(2,
    getOneValue("Stacja 1", {{2018, 4, 13}, {23, 56, 58}}, "PM10")).

getStationMean_test() ->
  addValue("Stacja 1", {{2018, 4, 13}, {22, 56, 58}}, "PM10", 4),
  ?assertEqual(3.0, getStationMean("Stacja 1", "PM10")
  ).

getDailyMean_test() ->
  ?assertEqual(3.0,
    getDailyMean({2018, 4, 13}, "PM10")).

removeValue_test() ->
  ?assertEqual({monitor, [{station, "Stacja 1", {2, 4}, [{measurement, "PM10", 4, {{2018, 4, 13}, {22, 56, 58}}}]}]},
    removeValue("Stacja 1", {{2018, 4, 13}, {23, 56, 58}}, "PM10")).

getMinimumPollutionStation_test() ->
  addStation("Stacja 2",{3,4}),
  addValue("Stacja 2",{{2017,4,13},{24,53,34}},"PM10",1),
  ?assertEqual(
    {station,"Stacja 2",{3,4},[{measurement,"PM10",1,{{2017,4,13},{24,53,34}}}]},
    getMinimumPollutionStation("PM10")).