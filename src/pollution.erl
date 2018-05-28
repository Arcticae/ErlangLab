%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. kwi 2018 20:44
%%%-------------------------------------------------------------------
-module(pollution).
-author("timelock").

%% API
-export([createMonitor/0,crash/0,addStation/3,addValue/5,removeValue/4,getOneValue/4,getStationMean/3,getDailyMean/3,getMinimumPollutionStation/2]).

-record(monitor,{stations=[]}).
-record(station,{name,location,measurements=[]}).
-record(measurement,{type,value,datetime}).

createMonitor() -> #monitor{}.


addStation(Name, Location, Monitor) ->
  case lists:any(fun(#station{name = TMPname, location = TMPlocation}) -> (Name =:= TMPname) or (Location =:= TMPlocation) end, Monitor#monitor.stations) of
    true -> throw({error, "Name or location are taken."});
    false -> addStationToMonitor(#station{name = Name, location = Location}, Monitor)
  end.


addStationToMonitor(Station, Monitor) -> #monitor{stations = [Station | Monitor#monitor.stations]}.


addValue(StationID,DateTime,Type,Value,Monitor) ->
  Station=findStation(StationID,Monitor#monitor.stations),

  case Station of
    {error, Msg } -> throw({error,"Described Station not found: " ++ Msg});

    #station{measurements=Measurements} ->

      case sameMeasurements(DateTime,Type,Measurements) of
        []->
          StationsNew=Monitor#monitor.stations -- [ Station ],
          StationNew=Station#station{measurements=[#measurement{type = Type, datetime = DateTime, value = Value} | Measurements ]},
          MonitorNew=Monitor#monitor{stations = [ StationNew | StationsNew ]},
          MonitorNew;
          _->throw({error,"There is at least one same measurement already."})

      end
  end.


sameMeasurements(DateTime,Type,Measurements) -> lists:filter(fun(#measurement{type=TMPtype,datetime=TMPdatetime}) -> (DateTime=:=TMPdatetime) and (Type=:=TMPtype) end,Measurements).


removeValue(StationID,DateTime,Type,Monitor) ->
  Station=findStation(StationID,Monitor#monitor.stations),
  case Station of
    {error, Msg } -> throw({error,"Described Station not found: " ++ Msg});

    #station{measurements=Measurements} ->

      case sameMeasurements(DateTime,Type,Measurements) of
        []->
          throw({error,"There are no measurements specified like you did"});

        A->
          StationsNew=Monitor#monitor.stations -- [ Station ],
          StationNew=Station#station{measurements=Measurements -- A},
          MonitorNew=Monitor#monitor{stations = [ StationNew | StationsNew ]},
          MonitorNew
      end
  end.

getOneValue(StationID,DateTime,Type,Monitor) ->
  Station=findStation(StationID,Monitor#monitor.stations),
  case Station of
    {error, Msg } -> throw({error,"Described Station not found: " ++ Msg});

    #station{measurements=Measurements} ->

      case sameMeasurements(DateTime,Type,Measurements) of
        []->
          throw({error,"There are no measurements specified like you did"});

        [A]->
          A#measurement.value
      end
  end.


getStationMean(StationID,Type,Monitor) ->
  Station=findStation(StationID,Monitor#monitor.stations),
  case Station of
    {error, Msg } -> throw({error,"Described Station not found: " ++ Msg});

    #station{measurements=Measurements} ->
      case sameTypeMeasurements(Type,Measurements) of
        []->
          throw({error,"There are no measurements specified like you did"});
        A ->
          {Sum,Length}=lists:foldl(fun(X,{Acc,Len})-> {X#measurement.value+Acc,Len+1} end,{0,0},A),
          Sum/Length
      end
  end.


sameTypeMeasurements(Type,Measurements)->lists:filter(fun(#measurement{type=TMPtype}) -> (TMPtype=:=Type) end,Measurements).

getDailyMean(Day,Type,Monitor)->
  {Sum,Length}=
    lists:foldl(fun(X,{Acc,Len}) -> {X#measurement.value+Acc,Len+1} end,{0,0},
      lists:filter(fun(Measurement)-> (Measurement#measurement.type=:=Type) and (element(1,Measurement#measurement.datetime) =:= Day) end,
        lists:foldl(fun(Station,List) -> Station#station.measurements ++ List end, [] ,Monitor#monitor.stations))),
  case {Sum,Length} of
    {0,0} -> throw({error,"Cannot calculate daily mean, because of lack of specified measurements."});
    {_,_} -> Sum/Length
  end.

getMinimumPollutionStation(Type,Monitor) ->
  Minimums=lists:filter(fun({Thing,_})-> case Thing of error->false; _->true end end,
              lists:foldl(fun(Station,List) ->  [getMinimumForStation(Type,Station)] ++ List end, [] ,Monitor#monitor.stations)),
  case Minimums of
    []->throw({error,"No minimum of specified type in this monitor"});
    [{Station,_}]->Station;
    [H|_]->element(1,lists:foldl(fun(Elem,Acc) -> case element(2,Elem) < element(2,Acc) of true -> Elem; false -> Acc end end,H,Minimums))
  end.

getMinimumForStation(Type,Station)->
  Measurements=lists:filter(fun(Measurement) -> (Measurement#measurement.type =:= Type) end,Station#station.measurements),
  case Measurements of
    []-> {error,"No data of the wanted type"};
    [A]->{Station,A};
    [H|_]->{Station,
      lists:foldl(
                  fun(Measurement,Acc) ->
                  case Measurement#measurement.value < Acc#measurement.value of
                    true-> Measurement;
                    false-> Acc
                  end
                  end, H ,Measurements)}
  end.



findStation(StationID,Stations) ->
  case StationID of
    {X,Y} ->
    case lists:filter(fun(Station) -> Station#station.location == {X,Y} end,Stations) of
      [] -> {error,"Coordinates wrong."};
      [A]->A
    end;
    Name->
     case lists:filter(fun(Station) -> Station#station.name == Name end,Stations) of
      [] -> {error,"Name wrong"};
      [A]->A
     end
  end.

crash()->1/0.