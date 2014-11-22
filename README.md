erl.ServiceBus
==============

Message router in Erlang

To use:
  Navigate to where your erl.exe lives and execute "erl -sname {module_name}" 
  (Where module name is the name of the module for each file. The module_name for the message_bus is just "bus").
  
  First run the message_bus
    $ erl -sname bus
    bus@{machine_name}> message_bus:start().
    
  Then repeat the following three times for each processor
    $erl -sname processorA
    processorA@{machine_name}> processorA:start(bus@machine_name).
