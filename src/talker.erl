%% Copyright
-module(talker).
-author("dsociative").

%% API
-export([talk/2, requests/3]).


requests(Pid, Gateway, ClientSocket) ->
  case gen_tcp:recv(ClientSocket, 0) of
    {ok, Msg} ->
      Gateway ! {in, Pid, jiffy:decode(Msg)},
      requests(Pid, Gateway, ClientSocket);
    {error, Reason} ->
      exit(Reason)
  end.


responses(Gateway, ClientSocket) ->
  receive
    {out, Msg} ->
      io:format("Response ~p~n", [Msg]),
      gen_tcp:send(ClientSocket, jiffy:encode(Msg)),
      responses(Gateway, ClientSocket);
    {'EXIT', _, _} ->
      Gateway ! {closed, self()}
  end.


talk(Gateway, ClientSocket) ->
  process_flag(trap_exit, true),
  spawn_link(?MODULE, requests, [self(), Gateway, ClientSocket]),
  responses(Gateway, ClientSocket).

