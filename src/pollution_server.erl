%%%-------------------------------------------------------------------
%%% @author micha
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. kwi 2019 19:41
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("micha").

%% API
-export([start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, crash/0, getMonitor/0]).

start() ->
  Pid = spawn_link(fun() -> init() end),
  register(monitor, Pid),
  Pid.

stop() ->
  monitor ! stop.

init() ->
  loop(pollution:createMonitor()).

loop(M) ->
  receive
    {request,Pid,{addStation,N,C}} ->
      NewM = pollution:addStation(M,N,C),
      Pid ! {reply,ok},
      loop(NewM);
    {request,Pid,{addValue,N,D,P,V}} ->
      NewM = pollution:addValue(M,N,D,P,V),
      Pid ! {reply,ok},
      loop(NewM);
    {request,Pid,{removeValue,N,D,P}} ->
      NewM = pollution:removeValue(M,N,D,P),
      Pid ! {reply,ok},
      loop(NewM);
    {request,Pid,{getOneValue,S,P,D}} ->
      Pid ! {reply, pollution:getOneValue(M,S,P,D)},
      loop(M);
    {request,Pid,{getStationMean,S,P}} ->
      Pid ! {reply,pollution:getStationMean(M,S,P)},
      loop(M);
    {request,Pid,{getDailyMean,P,D}} ->
      Pid ! {reply, pollution:getDailyMean(M,P,D)},
      loop(M);

    {request,Pid,{getMonitor}} ->
      Pid ! {reply, pollution:getMonitor(M)},
      loop(M);

    stop ->
      terminate();
    crash ->
      io:format("server crash~n"),
      1/0
  end.

call(Message) ->
  monitor ! {request, self(), Message},
  receive
    {reply, Reply} -> Reply
  end.

addStation(N,C) ->
  call({addStation,N,C}).

addValue(N,D,P,V) ->
  call({addValue,N,D,P,V}).

removeValue(N,D,P) ->
  call({removeValue,N,D,P}).

getOneValue(S,P,D) ->
  call({getOneValue,S,P,D}).

getStationMean(S,P) ->
  call({getStationMean,S,P}).

getDailyMean(P,D) ->
  call({getDailyMean,P,D}).

getMonitor() ->
  call({getMonitor}).

terminate() ->
  ok.

crash() ->
  monitor ! crash.