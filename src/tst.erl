%% Copyright
-module(tst).
-author("dsociative").

%% API
-export([tst/0, tst2/0, tst3/0]).


parse_first_command([Json|T]) ->
  {List} = Json,
  proplists:split(List, [<<"cids">>]).


tst() ->
  {ok, Data} = file:read_file("request.json"),
  io:format("~s~n", [Data]),
  Json = jiffy:decode(Data),
  io:format("~w~n", [Json]),
  {Cids, Command} = parse_first_command(Json),
  io:format("~p~p~n", [Command, Cids]),
  io:format("~s~n", [jiffy:encode({Command})]).


tst2() ->
  Pids = [gateway:pid_pack(Pid) || Pid <- [self(), self()]],
  io:format("~s~n", [jiffy:encode({[{<<"cids">>, Pids}]})]),
  U = [list_to_pid(binary_to_list(Pid)) || Pid <- Pids],
  io:format("~w~n", [U]).


tst3() ->
  Gateway = gateway_test,
  spawn_link(gateway, start, [Gateway, "ipc:///home/buildbot/jewels/testing/jewels_testing_gateway", "ipc:///home/buildbot/jewels/testing/jewels_testing_performer"]),
  accepter:listen(Gateway, 10556).
