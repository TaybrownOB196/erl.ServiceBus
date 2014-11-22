-module(message_bus).
-export([start/0, receive_msg/1]).

receive_msg(Processor_List) ->
	receive
		{message, Message} ->
			io:format("~p Received~n", [Message]),
			route_msg(Message, Processor_List),
			receive_msg(Processor_List);
		{Node_Name, PId} ->
			io:format("~p Connected~n", [Node_Name]),
			New_Processor_List = add_processor(Node_Name, PId, Processor_List),
			receive_msg(New_Processor_List);
		{'EXIT', PId, Reason} ->
			io:format("~p~n", [Reason]),
			New_Processor_List = drop_processor(PId, Processor_List),
			receive_msg(New_Processor_List)
		after
			5000 ->
				io:format("Bus running~n", []),
				receive_msg(Processor_List)
	end.

route_msg(Message, Processor_List) ->
	case Message of
		"Event" ->
			%Send all events to processor C
			case lists:keysearch(processorC, 1, Processor_List) of
				false ->
					io:format("Failed to route ~p~n", [Message]),
					%print_Processor_List(Processor_List),
					ok;
				{value, {processorC, PId}} ->
					io:format("About to route ~p~n", [Message]),
					PId ! {event, "You have received an event"}
			end;
		"Message" ->
			%Send all messages to processor A
			case lists:keysearch(processorA, 1, Processor_List) of
				false ->
					io:format("Failed to route ~p~n", [Message]),
					%print_Processor_List(Processor_List),
					ok;
				{value, {processorA, PId}} ->
					io:format("About to route ~p~n", [Message]),
					PId ! {message, "You have received a message"}
			end;
		"Command" ->
			%Send all commands to processor B
			case lists:keysearch(processorB, 1, Processor_List) of
				false ->
					io:format("Failed to route ~p~n", [Message]),
					%print_Processor_List(Processor_List),
					ok;
				{value, {processorB, PId}} ->
					io:format("About to route ~p~n", [Message]),
					PId ! {command, "You have received a command"}
			end
	end.

add_processor(Node_Name, PId, Processor_List) ->
	case lists:keymember(Node_Name, 1, Processor_List) of
		true ->
			Processor_List;
		false ->
			[{Node_Name, PId} | Processor_List]
	end.

drop_processor(PId, Processor_List) ->
	lists:keydelete(PId, 2, Processor_List).

print_Processor_List([]) ->
	ok;
print_Processor_List([First|Rest]) ->
	io:format("~p~n", [First]),
	print_Processor_List(Rest).

start() ->
	register(bus, spawn(message_bus, receive_msg, [[]])).