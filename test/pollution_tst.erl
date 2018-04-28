%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. kwi 2018 02:12
%%%-------------------------------------------------------------------
-module(pollution_tst).
-author("timelock").

%% API
-import(pollution, [createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3,getMinimumPollutionStation/2]).

-include_lib("eunit/include/eunit.hrl").

createMonitor_test() ->
  ?assertEqual({monitor, []}, createMonitor()).

addStation_test() ->
  M1 = createMonitor(),
  M2 = addStation("Station1", {1,1}, M1),
  ?assertEqual({monitor, [{station, "Station1", {1,1}, []}]}, M2).

addValue_test() ->
  M1 = createMonitor(),
  M2 = addStation("Station1", {1,1}, M1),
  M3 = addValue("Station1", {{2018,4,13},{23,56,58}}, "PM10", 50, M2),
  ?assertEqual({monitor, [{station, "Station1", {1,1}, [{measurement, "PM10", 50, {{2018,4,13},{23,56,58}}}]}]}, M3).

removeValue_test() ->
  M1 = createMonitor(),
  M2 = addStation("Station1", {1,1}, M1),
  M3 = addValue("Station1", {{2018,4,13},{23,56,58}}, "PM10", 50, M2),
  M4 = removeValue("Station1", {{2018,4,13},{23,56,58}}, "PM10", M3),
  ?assertEqual({monitor, [{station, "Station1", {1,1}, []}]}, M4).

getOneValue_test() ->
  M1 = createMonitor(),
  M2 = addStation("Station1", {1,1}, M1),
  M3 = addValue("Station1", {{2018,4,13},{23,56,58}}, "PM10", 50, M2),
  Value = getOneValue("Station1",{{2018,4,13},{23,56,58}}, "PM10", M3),
  ?assertEqual(50, Value).

getStationMean_test() ->
  M1 = createMonitor(),
  M2 = addStation("Station1", {1,1}, M1),
  M3 = addValue("Station1", {{2018,4,13},{23,56,58}}, "PM10", 50, M2),
  M4 = addValue("Station1", {{2018,4,13},{22,56,58}}, "PM10", 100, M3),
  MeanValue = getStationMean("Station1" , "PM10", M4),
    ?assertEqual(75.0, MeanValue).

getDailyMean_test() ->
  M1 = createMonitor(),
  M2 = addStation("Station1", {1,1}, M1),
  M3 = addValue("Station1", {{2018,4,13},{23,56,58}}, "PM10", 50, M2),
  M4 = addValue("Station1", {{2018,4,13},{22,56,58}}, "PM10", 100, M3),
  M5 = addStation("Station2", {2,2}, M4),
  M6 = addValue("Station2", {{2018,4,13},{22,56,58}}, "PM10", 300, M5),
  MeanValue = getDailyMean({2018,4,13},"PM10", M6),
  ?assertEqual(150.0, MeanValue).

getMinimumPollutionStation_test() ->
  Mon1= createMonitor(),
  Mon2= addStation("Station1",{10,10},Mon1),
  Mon3= addStation("Station2",{20,20},Mon2),
  Mon4= addStation("Station3",{30,30},Mon3),
  Mon5= addValue("Station1",{{2018,4,24},{24,44,34}},"PM2.5",1,Mon4),
  Mon6= addValue("Station2",{{2018,4,24},{23,43,44}},"PM2.5",2,Mon5),
  Mon7= addValue("Station3",{{2018,4,24},{23,46,64}},"PM2.5",3,Mon6),
  Station= getMinimumPollutionStation("PM2.5",Mon7),
  ?assertEqual({station,"Station1",
    {10,10},
    [{measurement,"PM2.5",1,{{2018,4,24},{24,44,34}}}]},Station).