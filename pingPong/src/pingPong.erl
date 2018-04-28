%%%-------------------------------------------------------------------
%%% @author timelock
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. kwi 2018 11:32
%%%-------------------------------------------------------------------
-module(pingPong).
-author("timelock").

%% API
-export([ping_loop/0,pong_loop/0,stop/0,start/0,go/1]).

start()->
  register(ping,spawn(?MODULE,ping_loop,[])),
  register(pong,spawn(?MODULE,pong_loop,[])).

stop() ->
  ping ! die, pong ! die.

go(N)->pong!N.

ping_loop() ->

    receive
      die -> ok;
      0 -> ok;
      N -> io:format("I have received a pong from mr. pong~n"),timer:sleep(100),pong ! N-1,ping_loop()
    end.

pong_loop()->
  receive
    die->ok;
    0->ok;
    N-> io:format("I have received a ping from mr ping~n"),timer:sleep(100), ping ! N , pong_loop()
    end.