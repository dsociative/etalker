%% Copyright
-module(talker).
-author("dsociative").

%% API
-export([talk/2, requests/3]).


requests(Gateway, ClientSocket, Pid) ->
  case gen_tcp:recv(ClientSocket, 0) of
    {ok, Msg} ->
      Gateway ! {in, Pid, jiffy:decode(Msg)},
      requests(Gateway, ClientSocket, Pid);
    {error, Reason} ->
      exit(Reason)
  end.


responses(Gateway, ClientSocket) ->
  receive
    {out, Msg} ->
      gen_tcp:send(ClientSocket, jiffy:encode({Msg})),
      responses(Gateway, ClientSocket);
    {'EXIT', _, _} ->
      Gateway ! {closed, self()},
      gen_tcp:close(ClientSocket)
  end.


talk(Gateway, ClientSocket) ->
  process_flag(trap_exit, true),
  spawn_link(?MODULE, requests, [Gateway, ClientSocket, self()]),
  responses(Gateway, ClientSocket).
