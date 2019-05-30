%%%-------------------------------------------------------------------
%%% @author micha
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. maj 2019 19:12
%%%-------------------------------------------------------------------
-module(pollution_supervisor).
-author("micha").
-behaviour(supervisor).

%% API
-export([init/1, start_link/0]).

start_link() ->
  supervisor:start_link(
    {local, pollution_supervisor},
    pollution_supervisor, []).

init(_) ->
  {ok, {
    {one_for_one, 2, 5},
    [{pollution_gen_server,
      {pollution_gen_server, start_link, []},
      permanent, brutal_kill, worker, [pollution_gen_server, pollution]}
    ]}
  }.