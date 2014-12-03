-module(processorD).
-author('ttuck101@gmail.com').
-export([start/1, connect/1, stop/0]).

connect(NodeName) ->
	init(),
	{bus, NodeName} ! {processorD, self()},
	send_msg(NodeName).

send_msg(NodeName) ->
	receive
		{message, Message} ->
			io:format("~p~n", [Message]),
			send_msg(NodeName);
		{event, Message} ->
			io:format("~p~n", [Message]),
			send_msg(NodeName);
		{command, Message} ->
			io:format("~p~n", [Message]),
			send_msg(NodeName)
		after
			5000 ->
				send_msg(NodeName)
	end.

init() ->
	process_flag(priority, low).

start(NodeName) -> 	
	spawn(processorD, connect, [NodeName]).

stop() ->
	exit(self(), normal).