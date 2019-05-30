%%%-------------------------------------------------------------------
%%% @author micha
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. kwi 2019 10:38
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-behaviour(gen_server).
-author("micha").

%% API
-export([start/0, stop/0, init/1, handle_cast/2, handle_call/3, start_link/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, crash/0, handle_info/2, terminate/2, getMonitor/0]).

start_link() ->
  gen_server:start_link({local, pollution_gen_server}, pollution_gen_server, [], []).

start() ->
  gen_server:start({local, pollution_gen_server}, pollution_gen_server, [], []).

stop() ->
  gen_server:stop(pollution_gen_server).

init(_) ->
  {ok, pollution:createMonitor()}.

handle_cast({addStation, N, C}, M) ->
  {noreply, pollution:addStation(M, N, C)};

handle_cast({addValue, K, D, T, V}, M) ->
  {noreply, pollution:addValue(M, K, D, T, V)};

handle_cast({removeValue, K, D, T}, M) ->
  {noreply, pollution:removeValue(M, K, D, T)};

handle_cast(crash, _) ->
  1/0,
  {noreply, ok}.

handle_call({getOneValue, K, D, T}, _From, M) ->
  {reply, pollution:getOneValue(M, K, D, T), M};

handle_call({getStationMean, K, T}, _From, M) ->
  {reply, pollution:getStationMean(M, K, T), M};

handle_call({getDailyMean, D, T}, _From, M) ->
  {reply, pollution:getDailyMean(M, D, T), M};

handle_call({getMonitor}, _From, M) ->
  {reply, pollution:getMonitor(M), M}.


addStation(N, C) ->
  gen_server:cast(pollution_gen_server, {addStation, N, C}).

addValue(K, D, T, V) ->
  gen_server:cast(pollution_gen_server, {addValue, K, D, T, V}).

removeValue(K, D, T) ->
  gen_server:cast(pollution_gen_server, {removeValue, K, D, T}).

getOneValue(K, D, T) ->
  gen_server:call(pollution_gen_server, {getOneValue, K, D, T}).

getStationMean(K, T) ->
  gen_server:call(pollution_gen_server, {getStationMean, K, T}).

getDailyMean(D, T) ->
  gen_server:call(pollution_gen_server, {getDailyMean, D, T}).

getMonitor() ->
  gen_server:call(pollution_gen_server,{getMonitor}).

crash() ->
  gen_server:cast(pollution_gen_server, crash).

handle_info(_, LoopData) ->
  {noreply, LoopData}.

terminate(_Reason, _State) ->
  ok.