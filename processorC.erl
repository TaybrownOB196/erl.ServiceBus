-module(processorC).
-author('ttuck101@gmail.com').
-export([start/1, connect/1]).

connect(NodeName) ->
	{bus, NodeName} ! {processorC, self()},
	send_msg(NodeName).

send_msg(NodeName) ->
	{bus, NodeName} ! {message, "Command"},
	receive
		{event, Message} ->
			io:format("~p~n", [Message]),
			send_msg(NodeName)
		after
			3000 ->
				send_msg(NodeName)
	end.

start(NodeName) -> 	
	spawn(processorC, connect, [NodeName]).

stop() ->
	receive
		after
			infinity ->
				ok;
	end.