%% Copyright
-module(accepter).
-author("dsociative").

%% API
-export([listen/2]).


open_server_socket(Port) ->
  gen_tcp:listen(Port, [binary, {packet, 4}, {active, false}, {reuseaddr, true}]).


listen(Gateway, Port) ->
  case open_server_socket(Port) of
    {ok, ServerSocket} ->
      accept(Gateway, ServerSocket);
    {error, Reason} ->
      io:format("Listen start error: ~s~n", [Reason])
  end.


spawn_talk(Gateway, ClientSocket) ->
  spawn_link(talker, talk, [Gateway, ClientSocket]).


accept(Gateway, ServerSocket) ->
  case gen_tcp:accept(ServerSocket) of
    {ok, ClientSocket} ->
      Pid = spawn_talk(Gateway, ClientSocket),
      Gateway ! {accept, Pid};
    {error, Reason} ->
      io:format(user,"Error accept: ~w~n", [Reason])
  end,
  accept(Gateway, ServerSocket).