%% Copyright
-module(config).
-author("dsociative").

%% API
-export([read/0]).


read() ->
  {ok, Data} = file:read_file("config.json"),
  {Json} = jiffy:decode(Data),
  {
    proplists:get_value(<<"port">>, Json),
    proplists:get_value(<<"gateway_channel">>, Json),
    proplists:get_value(<<"performer_channel">>, Json)
  }.
