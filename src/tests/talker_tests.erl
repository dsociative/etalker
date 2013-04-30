%% Copyright
-module(talker_tests).
-author("dsociative").

-include_lib("eunit/include/eunit.hrl").

%% %% API
%% -export([]).
%%
%% -define(PORT, 10556).
%% -define(TIMEOUT, 5).
%% -define(TEST_GATEWAY, testgateway).
%% -define(setup(F), {setup, fun start/0, fun stop/1, F}).
%%
%%
%% connect() ->
%%   gen_tcp:connect("localhost", ?PORT, [binary, {packet, 4}, {active, false}], ?TIMEOUT).
%%
%%
%% talker_listen() ->
%%   accepter:listen(?PORT).
%%
%%
%% start() ->
%%   Gateway = testgateway,
%%   register(Gateway, self()),
%%   spawn(accepter, listen, [Gateway, ?PORT]).
%%
%%
%% flush() ->
%%   receive
%%     Any ->
%%       flush()
%%   after
%%   0 ->
%%     true
%%   end.
%%
%%
%% stop(Pid) ->
%%   unregister(?TEST_GATEWAY),
%%   exit(Pid, ok),
%%   flush().
%%
%%
%% try_connect() ->
%%   {Status, _} = connect(),
%%   ?assertEqual(ok, Status).
%%
%%
%% send(Msg) ->
%%   {Status, Socket} = connect(),
%%   ?assertEqual(ok, Status),
%%   gen_tcp:send(Socket, Msg).
%%
%% response() ->
%%   receive
%%     {in, Msg} ->
%%       Msg
%%   after 10 ->
%%     "No Messages"
%%   end.
%%
%%
%% try_send_message() ->
%%   Msg = jiffy:encode({[{<<"Msg">>, <<"привет talker !">>}]}),
%%   Status = send(Msg),
%%   ?assertEqual(ok, Status),
%%   ?assertEqual(jiffy:decode(Msg), response()).
%%
%%
%% spawned_pid() ->
%%   receive
%%     {accept, Pid} ->
%%       Pid
%%   end.
%%
%%
%% try_get_message() ->
%%   Msg = <<"привет talker !">>,
%%   {ok, Socket} = connect(),
%%   SpawnedPid = spawned_pid(),
%%   SpawnedPid ! SpawnedPid ! {out, Msg},
%%   ?assertEqual({ok, Msg}, gen_tcp:recv(Socket, 0, 10)),
%%   ?assertEqual({ok, Msg}, gen_tcp:recv(Socket, 0, 10)).
%%
%%
%% disconnected_msgs() ->
%%   receive
%%     {closed, Pid} ->
%%       Pid
%%   end.
%%
%%
%% try_get_disconnected() ->
%%   {ok, Socket} = connect(),
%%   SpawnedPid = spawned_pid(),
%%   gen_tcp:close(Socket),
%%   ?assertEqual(SpawnedPid, disconnected_msgs()).
%%
%%
%% send_message_test() ->
%%   Pid = start(),
%%   try_send_message(),
%%   stop(Pid).
%%
%%
%% get_message_test() ->
%%   Pid = start(),
%%   try_get_message(),
%%   stop(Pid).
%%
%%
%% get_disconnected_test() ->
%%   Pid = start(),
%%   try_get_disconnected(),
%%   stop(Pid).
