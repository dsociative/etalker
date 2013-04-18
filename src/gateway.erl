%% Copyright
-module(gateway).
-author("dsociative").

%% API
-export([start/3, pid_pack/1, gateway_listen/1]).
-define(DISCONNECT_MSG, {[{<<"command">>, <<"user.disconnect">>}]}).


zmq_socket(Type) ->
  {ok, Context} = erlzmq:context(),
  {ok, Socket} = erlzmq:socket(Context, Type),
  Socket.


performer_socket(Channel) ->
  Socket = zmq_socket(push),
  ok = erlzmq:connect(Socket, Channel),
  Socket.


gateway_socket(Channel) ->
  Socket = zmq_socket(pull),
  ok = erlzmq:bind(Socket, Channel),
  Socket.


unpack_pid(Pid) ->
  io:format("Pids ~p~n", [Pid]),
  list_to_pid(binary_to_list(Pid)).



split_request(Request) ->
  {[[{_, Pids}]], Msg} = proplists:split(Request, [<<"cids">>]),
  {Pids, Msg}.


process_requests([]) ->
  0;
process_requests([{Request}|T]) ->
  {Pids, Msg} = split_request(Request),
  [unpack_pid(Pid) ! {out, Msg} || Pid <- Pids],
  process_requests(T).


gateway_listen(GatewaySocket) ->
  {ok, Requests} = erlzmq:recv(GatewaySocket),
  io:format("Req gateway ~p~n", [Requests]),
  process_requests(jiffy:decode(Requests)),
  gateway_listen(GatewaySocket).


start(Gateway, GatewayChannel, PerformerChannel) ->
  register(Gateway, self()),
  spawn_link(?MODULE, gateway_listen, [gateway_socket(GatewayChannel)]),
  loop(Gateway, performer_socket(PerformerChannel)).


pid_pack(Pid) ->
  list_to_binary(pid_to_list(Pid)).


pack_msg(Pid, {Msg}) ->
  jiffy:encode({Msg ++ [{<<"cid">>, pid_pack(Pid)}]}).


send(Socket, Pid, Msg) ->
  erlzmq:send(Socket, pack_msg(Pid, Msg)).


loop(Gateway, PerformerSocket) ->
  receive
    {in, Pid, Msg} ->
      io:format("~p~n", [Msg]),
      send(PerformerSocket, Pid, Msg);
    {closed, Pid} ->
      send(PerformerSocket, Pid, ?DISCONNECT_MSG)
  end,
  loop(Gateway, PerformerSocket).
