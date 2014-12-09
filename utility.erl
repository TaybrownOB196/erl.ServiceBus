-module(utility).
-author('ttuck101@gmail.com').
-export([string_format/2, identify_xml_name/1]).

string_format(String, Addition) ->
	New = io_lib:format(String, Addition),
	lists:flatten(New).

identify_xml_name(FileName) ->
	{ParsedXML, _} = xmerl_scan:file(FileName),
	element(2, ParsedXML).
