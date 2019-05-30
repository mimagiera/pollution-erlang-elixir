%%%-------------------------------------------------------------------
%%% @author micha
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. kwi 2019 17:43
%%%-------------------------------------------------------------------
-module(pollution).
-author("micha").

%% API
-export([createMonitor/0, addStation/3, addValue/5, getOneValue/4, getStationMean/3, getDailyMean/3, removeValue/4, addStation/4, getMonitor/1]).
-record(measurement,{date,parameter,value}).
-record(station,{name, coordinates,listOfMeasurements=[]}).

createMonitor() -> [].

getMonitor(Monitor) ->
  Monitor.

addStation(Monitor,Name,Coordinates)->
  Monitor++[#station{name = Name,coordinates = Coordinates}].

addStation(Monitor,Name,Coordinates,List)->
  Monitor++[#station{name = Name,coordinates = Coordinates,listOfMeasurements = List}].

addValue(Monitor,Name,Date,Parameter,Value) ->
  case (Name) of
    {_,_} -> A =lists:filter(fun(N) -> element(3, N) == Name end,Monitor);
    _ -> A =lists:filter(fun(N) -> element(2, N) == Name end,Monitor)
  end,
  % A =lists:filter(fun(N) -> element(2, N) == Name end,Monitor),
  case(length(A)) of
    1 ->
      [H|_] = A,
      NewListOfStations=lists:delete(H,Monitor),
      NewListOfMeasurements = (element(4,H)++
      [#measurement{date = Date,parameter = Parameter,value = Value}]),
      NewStation = H#station{listOfMeasurements = NewListOfMeasurements},
      NewListOfStations++[NewStation];
    _ -> []
  end.

removeValue(Monitor,Name,Date,Parameter) ->
  case (Name) of
    {_,_} -> A =lists:filter(fun(N) -> element(3, N) == Name end,Monitor);
    _ -> A =lists:filter(fun(N) -> element(2, N) == Name end,Monitor)
  end,
  case(length(A)) of
    1 ->
      [H|_] = A,
      NewListOfStations=lists:delete(H,Monitor),
      ListOfMeasurements = element(4,H),
      io:format("printing: ~p~n", [ListOfMeasurements]),
      B = lists:filter(fun(N) -> ((element(2,N) == Date) and ((element(3,N)) == Parameter))end,ListOfMeasurements),
      case(length(B)) of
        1 ->
          [NewHead|_] = B,
          NewList = lists:delete(NewHead,ListOfMeasurements),
          NewStation = H#station{listOfMeasurements = NewList},

          NewListOfStations++[NewStation];

        _ -> []
      end;
    _ -> []
  end.


getOneValue(Monitor,StationName,ParameterName,Date) ->
  case (StationName) of
    {_,_} -> A =lists:filter(fun(N) -> element(3, N) == StationName end,Monitor);
    _ -> A =lists:filter(fun(N) -> element(2, N) == StationName end,Monitor)
  end,
  case(length(A)) of
    1 ->
      [H|_] = A,
      case(element(4,H)) of
        [] -> [];
        _ ->
          B = lists:filter(fun(N) -> ((element(2,N) == Date) and ((element(3,N)) == ParameterName))end,element(4,H)),
          case(length(B)) of
            1 -> [HNew|_] =B,
              element(4,HNew);
            _ -> []
          end
      end;
    _ -> []
  end.

getStationMean(Monitor,StationName,ParameterName) ->
  case (StationName) of
    {_,_} -> A =lists:filter(fun(N) -> element(3, N) == StationName end,Monitor);
    _ -> A =lists:filter(fun(N) -> element(2, N) == StationName end,Monitor)
  end,
  case(length(A)) of
    1 ->
      [H|_] = A,
      Measurements = element(4,H),
      B = lists:filter(fun(N) -> element(3,N) == ParameterName end, Measurements),
      Sum = lists:foldr(fun(N,Element) -> element(4,N)+Element end,0,B),
      Sum/length(B);
    _ -> []
  end.

getDailyMean(Monitor,ParameterName,Day) ->
  A = lists:map(fun(N) -> element(4,N) end,Monitor),
  B = lists:foldr(fun(N,Element) ->
    lists:filter(fun(X) -> (element(3,X) == ParameterName) and (element(1,element(2,X))==Day) end,N) ++Element end, [],A),
  Sum = lists:foldr(fun(N,Element) -> element(4,N)+Element end,0,B),
  case B of
    [] -> [];
    _ ->  Sum/length(B)
  end.
