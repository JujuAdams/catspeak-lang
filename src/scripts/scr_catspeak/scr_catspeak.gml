//! The primary user-facing interface for compiling and executing Catspeak
//! programs.

//# feather use syntax-errors

/// Creates a new Catspeak runtime process for this Catspeak function. This
/// function is also compatible with GML functions.
///
/// @param {Function|Struct.CatspeakFunction} scr
///   The GML or Catspeak function to execute.
///
/// @param {Array<Any>} [args]
///   The array of arguments to pass to the function call. Defaults to the
///   empty array.
///
/// @return {Struct.CatspeakVMProcess|Struct.CatspeakGMLProcess}
function catspeak_execute(scr, args) {
    static noArgs = [];
    var args_ = args ?? noArgs;
    var argo = 0;
    var argc = array_length(args);
    var process;
    if (instanceof(scr) == "CatspeakFunction") {
        var vm = new CatspeakVM();
        vm.pushCallFrame(self, scr, args, argo, argc);
        process = new CatspeakVMProcess();
        process.vm = vm;
    } else {
        process = new CatspeakGMLProcess();
        process.self_ = self;
        process.f = scr;
        process.argc = argc;
        process.argo = argo;
        process.args = args;
    }
    process.invoke();
    return process;
}

/// Creates a new Catspeak compiler process for a buffer containing Catspeak
/// code. The seek position of the buffer will not be set to the beginning of
/// the buffer, this is something you have to manage yourself:
/// ```
/// buffer_seek(buff, buffer_seek_start, 0); // reset seek
/// catspeak_compile_buffer(buff);           // then compile
/// ```
///
/// @param {ID.Buffer} buff
///   A reference to the buffer containing the source code to compile.
///
/// @param {Bool} [consume]
///   Whether the buffer should be deleted after the compiler process is
///   complete. Defaults to `false`.
///
/// @return {Struct.CatspeakCompilerProcess}
function catspeak_compile_buffer(buff, consume=false) {
    var lexer = new CatspeakLexer(buff);
    var compiler = new CatspeakCompiler(lexer);
    var process = new CatspeakCompilerProcess();
    process.compiler = compiler;
    process.consume = consume;
    process.invoke();
    return process;
}

/// Creates a new Catspeak compiler process for a string containing Catspeak
/// code. This will allocate a new buffer to store the string, if that isn't
/// ideal then you will have to create and write to your own buffer, then
/// pass it into the `catspeak_compile_buffer` function instead.
///
/// @param {Any} src
///   The value containing the source code to compile.
///
/// @return {Struct.CatspeakCompilerProcess}
function catspeak_compile_string(src) {
    var src_ = is_string(src) ? src : string(src);
    var buff = catspeak_create_buffer_from_string(src_);
    return catspeak_compile_buffer(buff, true);
}

/// A helper function for creating a buffer from a string.
///
/// @param {String} src
///   The source code to convert into a buffer.
///
/// @return {Id.Buffer}
function catspeak_create_buffer_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

/// Configures various global settings of the Catspeak compiler and runtime.
/// Below is a list of configuration values available to be customised:
///
///  - "frameAllocation" should be a number in the range [0, 1]. Determines
///    what percentage of a game frame should be reserved for processing
///    Catspeak programs. Catspeak will only spend this time when necessary,
///    and will not sit idly wasting time. A value of 1 will cause Catspeak
///    to spend the whole frame processing, and a value of 0 will cause
///    Catspeak to only process a single instruction per frame. The default
///    setting is 0.5 (50% of a frame). This leaves enough time for the other
///    components of your game to complete, whilst also letting Catspeak be
///    speedy.
///
///  - "exceptionHandler" should be a script or method ID. This will set the
///    catch-all exception handler when no handler exists for a specific
///    process. Set to `undefined` to remove the handler.
///
/// @param {Struct} configData
///   A struct which can contain any one of the fields mentioned above. Only
///   the fields which are passed will have their configuration changed, so
///   if you don't want a value to change, leave it blank.
function catspeak_config(configData) {
    catspeak_force_init();
    var processManager = global.__catspeakProcessManager;
    var frameAllocation = configData[$ "frameAllocation"];
    if (is_real(frameAllocation)) {
        processManager.frameAllocation = clamp(frameAllocation, 0, 1);
    }
    if (variable_struct_exists(configData, "exceptionHandler")) {
        var handler = configData[$ "exceptionHandler"];
        processManager.exceptionHandler = handler;
    }
}