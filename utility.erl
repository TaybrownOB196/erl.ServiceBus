-module(utility).
-author('ttuck101@gmail.com').
-export([string_format/2]).

string_format(String, Addition) ->
	New = io_lib:format(String, Addition),
	lists:flatten(New).