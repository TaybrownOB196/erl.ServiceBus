-module(processorA).
-author('ttuck101@gmail.com').
-export([start/1, connect/1, stop/0]).

%group_leader() ->
%	Sets the group leader of process Pid to be the process Leader

connect(NodeName) ->
	init(),
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

init() ->
	process_flag(priority, low).

start(NodeName) -> 	
	spawn(processorA, connect, [NodeName]).

stop() ->
	exit(self(), normal).