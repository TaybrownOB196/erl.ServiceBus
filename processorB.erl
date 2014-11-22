-module(processorB).
-author('ttuck101@gmail.com').
-export([start/1, connect/1]).

connect(NodeName) ->
	{bus, NodeName} ! {processorB, self()},
	send_msg(NodeName).

send_msg(NodeName) ->
	{bus, NodeName} ! {message, "Message"},
	receive
		{command, Message} ->
			io:format("~p~n", [Message]),
			send_msg(NodeName)
		after
			3000 ->
				send_msg(NodeName)
	end.

start(NodeName) -> 	
	spawn(processorB, connect, [NodeName]).

stop() ->
	receive
		after
			infinity ->
				ok;
	end.