-module(service_auditor).
-author('ttuck101@gmail.com').
-export([start_analysis/2, stop/0]).

start_analysis(NodeName, Time) ->
	erase(),
	{bus, NodeName} ! {auditor, self()},
	{bus, NodeName} ! start_analysis,
	put("NodeName", NodeName),
	put("Time", Time),
	receive
		after 
			Time ->
				{bus, NodeName} ! stop_analysis,
				await_results()
	end.

await_results() ->
	receive 
		{result, Count} ->
			io:format("Bus processed ~p messages within ~p seconds!~n", [Count, get("Time")/1000]),
			Result = utility:string_format("Bus processed ~p messages within ~p seconds! Time:~p Date:~p ~n", [Count, get("Time")/1000, time(), date()]),
			{_, IO} = file:open("C://Erlang//ServiceBus//ServiceBus//results.txt", [append]),
			file:write(IO, Result),
			file:close(IO)
	end.

stop() ->
	exit(self(), no_reason).
