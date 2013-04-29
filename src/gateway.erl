%% Copyright
-module(gateway).
-author("dsociative").

%% API
-export([start/2, pid_pack/1, gateway_listen/1, main/0]).
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
  list_to_pid(binary_to_list(Pid)).



split_request(Request) ->
  {[[{_, Pids}]], Msg} = proplists:split(Request, [<<"cids">>]),
  {Pids, Msg}.


unpack_and_send(BPid, Msg) ->
  Pid = unpack_pid(BPid),
  case is_pid(Pid) of
    true ->
      Pid ! {out, Msg};
    false ->
      io:format("Bad Pid ~w~n", [Pid])
  end.


process_requests([]) ->
  0;
process_requests([{Request}|T]) ->
  {Pids, Msg} = split_request(Request),
  [unpack_and_send(Pid, Msg) || Pid <- Pids],
  process_requests(T).


gateway_listen(GatewaySocket) ->
  {ok, Requests} = erlzmq:recv(GatewaySocket),
  process_requests(jiffy:decode(Requests)),
  gateway_listen(GatewaySocket).


start(GatewayChannel, PerformerChannel) ->
  spawn_link(?MODULE, gateway_listen, [gateway_socket(GatewayChannel)]),
  loop(performer_socket(PerformerChannel)).


pid_pack(Pid) ->
  list_to_binary(pid_to_list(Pid)).


pack_msg(Pid, {Msg}) ->
  jiffy:encode({Msg ++ [{<<"cid">>, pid_pack(Pid)}]}).


send(Socket, Pid, Msg) ->
  erlzmq:send(Socket, pack_msg(Pid, Msg)).


loop(PerformerSocket) ->
  receive
    {in, Pid, Msg} ->
      send(PerformerSocket, Pid, Msg);
    {closed, Pid} ->
      send(PerformerSocket, Pid, ?DISCONNECT_MSG)
  end,
  loop(PerformerSocket).


main() ->
  {Port, GatewayChannel, PerformerChannel} = config:read(),
  Pid = spawn_link(gateway, start, [GatewayChannel, PerformerChannel]),
  accepter:listen(Pid, Port).
