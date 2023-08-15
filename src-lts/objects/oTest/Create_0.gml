Catspeak.renameKeyword("self", "global", "fun", "fn");

var _asg = Catspeak.parseString(@'

let Position = fn(value) {
    c = value
}

a = 1
global.b = 2

@Position = {left: 0, y: 20, x: 70, bottom: 100}


click = fn {

}
');

func = Catspeak.compileGML(_asg);

selfStruct = {};
globalsStruct = {};

func.setSelf(selfStruct);
func.setGlobals(globalsStruct);

func();
show_debug_message("selfStruct = " + string(selfStruct));
show_debug_message("globalsStruct = " + string(globalsStruct));