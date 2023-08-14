Catspeak.renameKeyword("self", "global");

var _asg = Catspeak.parseString(@'
a = 1
global.b = 2
');

func = Catspeak.compileGML(_asg);

selfStruct = {};
globalsStruct = {};

func.setSelf(selfStruct);
func.setGlobals(globalsStruct);

func();
show_debug_message("selfStruct = " + string(selfStruct));
show_debug_message("globalsStruct = " + string(globalsStruct));