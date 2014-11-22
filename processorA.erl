-module(processorA).
-author('ttuck101@gmail.com').
-export([start/1, connect/1]).

connect(NodeName) ->
	{bus, NodeName} ! {processorA, self()},
	send_msg(NodeName).

send_msg(NodeName) ->
	{bus, NodeName} ! {message, "Event"},
	receive
		{message, Message} ->
			io:format("~p~n", [Message]),
			send_msg(NodeName)
		after
			5000 ->
				send_msg(NodeName)
	end.

start(NodeName) -> 	
	spawn(processorA, connect, [NodeName]).

stop() ->
	receive
		after
			infinity ->
				ok;
	end.