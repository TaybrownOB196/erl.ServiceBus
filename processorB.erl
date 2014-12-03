-module(processorB).
-author('ttuck101@gmail.com').
-export([start/1, connect/1, stop/0]).

connect(NodeName) ->
	init(),
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

init() ->
	process_flag(priority, low).

start(NodeName) -> 	
	spawn(processorB, connect, [NodeName]).

stop() ->
	exit(self(), normal).