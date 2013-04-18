%% Copyright
-module(gateway_test).
-author("dsociative").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

-define(TEST_GATEWAY, test_gateway).
-define(PERFORMER_CHANNEL, "ipc://test_performer").
-define(GATEWAY_CHANNEL, "ipc://test_gateway").


start() ->
  spawn(gateway, start, [?TEST_GATEWAY, ?GATEWAY_CHANNEL, ?PERFORMER_CHANNEL]).


zmq_socket(Type) ->
  {ok, Context} = erlzmq:context(),
  {ok, Sock} = erlzmq:socket(Context, Type),
  Sock.


listener() ->
  Sock = zmq_socket(pull),
  ok = erlzmq:bind(Sock, ?PERFORMER_CHANNEL),
  Sock.


recv_more(Socket)->
  {ok, Status} = erlzmq:getsockopt(Socket, rcvmore),
  Status.


recv(Socket) ->
  case erlzmq:recv(Socket) of
    {ok, Msg} ->
      Msg;
    _ ->
      error
  end.


recv_multipart(Socket) ->
  [recv(Socket)] ++ recv_multipart(Socket, recv_more(Socket)).
recv_multipart(Socket, 1) ->
  recv_multipart(Socket);
recv_multipart(_, 0) ->
  [].


pack_msg(Msg) ->
  jiffy:encode({[{<<"Msg">>, Msg}, {<<"cid">>, gateway:pid_pack(self())}]}).


%% response_test() ->
%%   Msg = <<"Сообщение !">>,
%%   Pid = start(),
%%   ListenerSocket = listener(),
%%   Pid ! {in, self(), {[{<<"Msg">>, Msg}]}},
%%   ?assertEqual(pack_msg(Msg), recv(ListenerSocket)).


%% disconnect_test() ->
%%   Msg = {[{<<"command">>, <<"user.disconnect">>},
%%           {<<"cid">>, gateway:pid_pack(self())}]},
%%   Pid = start(),
%%   ListenerSocket = listener(),
%%   Pid ! {closed, self()},
%%   ?assertEqual(jiffy:encode(Msg), recv(ListenerSocket)).


get_msgs() ->
  receive
    {out, Msg} ->
      Msg
  end.


%% request_test() ->
%%   Msg = <<"Сообщение !">>,
%%   start(),
%%   ?TEST_GATEWAY ! {out, [self()], Msg},
%%   ?assertEqual(Msg, get_msgs()).


pack_all_pids(Pids) ->
  [gateway:pid_pack(Pid) || Pid <- Pids].


send(Msg) ->
  Socket = zmq_socket(push),
  erlzmq:connect(Socket, ?GATEWAY_CHANNEL),
  erlzmq:send(Socket, Msg).


request_by_zmq_test() ->
  Msg = <<"Сообщение !">>,
  start(),
  Pid = gateway:pid_pack(self()),
  Json = [{[{<<"cids">>, [Pid, Pid]}, {<<"Msg">>, Msg}]}, {[{<<"cids">>, [Pid]}, {<<"Msg">>, Msg}]}],
  send(jiffy:encode(Json)),
  ExpectedMsg = [{<<"Msg">>, Msg}],
  ?assertEqual(ExpectedMsg, get_msgs()),
  ?assertEqual(ExpectedMsg, get_msgs()),
  ?assertEqual(ExpectedMsg, get_msgs()).
