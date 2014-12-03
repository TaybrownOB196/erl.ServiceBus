-module(message_bus).
-author('ttuck101@gmail.com').
-export([start/0, receive_msg/2, stop/0]).

receive_msg(Processor_List, Count) ->
	init(),
	receive
		start_analysis ->
			io:format("Analysis Started~n",[]),
			receive_msg(Processor_List, 0);
		stop_analysis ->
			io:format("Analysis Ended~n", []),
			send_to_audit(Processor_List, Count),
			receive_msg(Processor_List, 0);
		{message, Message} ->
			route_msg(Message, Processor_List),
			case Message of
				"Event" ->
					receive_msg(Processor_List, Count + 2);
				"Message" ->
					receive_msg(Processor_List, Count + 2);
				"Command" ->
					receive_msg(Processor_List, Count + 3)
			end;
		{Node_Name, PId} ->
			link(PId),
			io:format("~p Connected~n", [Node_Name]),
			New_Processor_List = add_processor(Node_Name, PId, Processor_List),
			receive_msg(New_Processor_List, Count);
		{'EXIT', PId, Reason} ->
			io:format("PId ~p disconnected with reason: ~p~n", [PId, Reason]),
			New_Processor_List = drop_processor(PId, Processor_List),
			io:format("Connected Processors:~n", []),
			print_Processor_List(New_Processor_List),
			receive_msg(New_Processor_List, Count)
		after
			5000 ->
				%io:format("Bus running~n", []),
				receive_msg(Processor_List, 0)
	end.

route_msg(Message, Processor_List) ->
	case Message of
		"Event" ->
			send_to_processor(processorC, Message, Processor_List),
			send_to_processor(processorD, Message, Processor_List);
		"Message" ->
			send_to_processor(processorA, Message, Processor_List),
			send_to_processor(processorD, Message, Processor_List);
		"Command" ->
			send_to_processor(processorB, Message, Processor_List),
			send_to_processor(processorC, Message, Processor_List),
			send_to_processor(processorD, Message, Processor_List)
	end.

send_to_audit(Processor_List, Count) ->
	case lists:keysearch(auditor, 1, Processor_List) of
		false ->
			ok;
		{value, {auditor, PId}} ->
			io:format("Sending Results~n", []),
			PId ! {result, Count},
			receive_msg(Processor_List, 0)
	end.

send_to_processor(Processor, Message, Processor_List) ->
	case Processor of
		processorA ->
			case lists:keysearch(processorA, 1, Processor_List) of
				false ->
					ok;
				{value, {processorA, PId}} ->
					PId ! {message, Message}
			end;

		processorB ->
			case lists:keysearch(processorB, 1, Processor_List) of
				false ->
					ok;
				{value, {processorB, PId}} ->
					PId ! {command, Message}
			end;

		processorC ->
			case lists:keysearch(processorC, 1, Processor_List) of
				false ->
					ok;
				{value, {processorC, PId}} ->
					if
						Message == "Event" ->
							PId ! {event, Message};
						Message == "Command" ->
							PId ! {command, Message}
					end
					
			end;
		processorD ->
			case lists:keysearch(processorD, 1, Processor_List) of
				false ->
					ok;
				{value, {processorD, PId}} ->
					if
						Message == "Message" ->
							PId ! {message, Message};
						Message == "Event" ->
							PId ! {event, Message};
						Message == "Command" ->
							PId ! {command, Message}
					end
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

init() ->
	process_flag(trap_exit, true),
	process_flag(priority, normal).

start() ->
	register(bus, spawn(message_bus, receive_msg, [[], 0])).

stop() ->
	exit(self(), normal).