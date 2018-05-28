%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. maj 2018 11:39
%%%-------------------------------------------------------------------
-module(pollution_supervisor).
-author("timelock").



%% API
-export([start/0,init/0]).


start()->
  spawn(?MODULE,init,[]).

init()->
  pollution_server:start(),
  process_flag(trap_exit,true),
    receive
    {'EXIT',Reason,Pid} -> init()
    end.



