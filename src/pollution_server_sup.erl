%%%-------------------------------------------------------------------
%%% @author micha
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. kwi 2019 09:53
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("micha").

%% API
-export([start/0]).

start() ->
  register(sup,spawn(fun() -> loop() end)).

loop() ->
  process_flag(trap_exit,true),
  pollution_server:start(),
  receive
    {'EXIT', _Pid,Reason} -> io:format("crash detected~w~n",[Reason]),
      loop()
  end.