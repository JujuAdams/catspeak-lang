//! Contains the primary user-facing API for consuming Pugspeak.

//# feather use syntax-errors

/// Packages all common Pugspeak features into a neat, configurable box.
function PugspeakEnvironment() constructor {
    self.keywords = undefined;
    self.interface = new PugspeakForeignInterface();

    /// Applies list of presets to this Pugspeak environment. These changes
    /// cannot be undone, so only choose presets you really need.
    ///
    /// @param {Enum.PugspeakPreset} preset
    ///   The preset type to apply.
    ///
    /// @param {Enum.PugspeakPreset} ...
    ///   Additional preset arguments.
    static applyPreset = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var presetFunc = __pugspeak_preset_get(argument[i]);
            presetFunc(interface);
        }
    };

    /// Creates a new [PugspeakLexer] from the supplied buffer, overriding
    /// the keyword database if one exists for this [PugspeakEngine].
    ///
    /// NOTE: The lexer does not take ownership of this buffer, but it may
    ///       mutate it so beware. Therefore you should make sure to delete
    ///       the buffer once parsing is complete.
    ///
    /// @param {Id.Buffer} buff
    ///   The ID of the GML buffer to use.
    ///
    /// @param {Real} [offset]
    ///   The offset in the buffer to start parsing from. Defaults to 0.
    ///
    /// @param {Real} [size]
    ///   The length of the buffer input. Any characters beyond this limit
    ///   will be treated as the end of the file. Defaults to `infinity`.
    ///
    /// @return {Struct.PugspeakLexer}
    static tokenise = function (buff, offset=undefined, size=undefined) {
        // PugspeakLexer() will do argument validation
        return new PugspeakLexer(buff, offset, size, keywords);
    };

    /// Parses a buffer containing a Pugspeak program into a bespoke format
    /// understood by Catpskeak. Overrides the keyword database if one exists
    /// for this [PugspeakEngine].
    ///
    /// NOTE: The parser does not take ownership of this buffer, but it may
    ///       mutate it so beware. Therefore you should make sure to delete
    ///       the buffer once parsing is complete.
    ///
    /// @param {Id.Buffer} buff
    ///   The ID of the GML buffer to use.
    ///
    /// @param {Real} [offset]
    ///   The offset in the buffer to start parsing from. Defaults to 0.
    ///
    /// @param {Real} [size]
    ///   The length of the buffer input. Any characters beyond this limit
    ///   will be treated as the end of the file. Defaults to `infinity`.
    ///
    /// @return {Struct.PugspeakLexer}
    static parse = function (buff, offset=undefined, size=undefined) {
        // tokenise() will do argument validation
        var lexer = tokenise(buff, offset, size);
        var builder = new PugspeakIRBuilder();
        var parser = new PugspeakParser(lexer, builder);
        var moreToParse;
        do {
            moreToParse = parser.update();
        } until (!moreToParse);
        return builder.get();
    };

    /// Similar to [parse], except a string is used instead of a buffer.
    ///
    /// @param {String} src
    ///   The string containing Pugspeak source code to parse.
    ///
    /// @return {Struct.PugspeakLexer}
    static parseString = function (src) {
        var buff = __pugspeak_create_buffer_from_string(src);
        return Pugspeak.parse(buff);
    };

    /// Similar to [parse], except it will pass the responsibility of
    /// parsing to this sessions async handler.
    ///
    /// NOTE: The async handler can be customised, and therefore any
    ///       third-party handlers are not guaranteed to finish within a
    ///       reasonable time.
    ///
    /// NOTE: The parser does not take ownership of this buffer, but it may
    ///       mutate it so beware. Therefore you should make sure to delete
    ///       the buffer once parsing is complete.
    ///
    /// @param {Id.Buffer} buff
    ///   The ID of the GML buffer to use.
    ///
    /// @param {Real} [offset]
    ///   The offset in the buffer to start parsing from. Defaults to 0.
    ///
    /// @param {Real} [size]
    ///   The length of the buffer input. Any characters beyond this limit
    ///   will be treated as the end of the file. Defaults to `infinity`.
    ///
    /// @return {Struct.Future}
    static parseAsync = function (buff, offset=undefined, size=undefined) {
        __pugspeak_error_unimplemented("async-parsing");
    };

    /// Compiles a syntax graph into a GML function. See the [parse] function
    /// for how to generate a syntax graph from a Pugspeak script.
    ///
    /// @param {Struct} asg
    ///   The syntax graph to convert into a GML function.
    ///
    /// @return {Function}
    static compileGML = function (asg) {
        // PugspeakGMLCompiler() will do argument validation
        var compiler = new PugspeakGMLCompiler(asg, interface);
        var result;
        do {
            result = compiler.update();
        } until (result != undefined);
        return result;
    };

    /// Used to change the string representation of a Pugspeak keyword.
    ///
    /// @param {String} currentName
    ///   The current string representation of the keyword to change.
    ///
    /// @param {String} newName
    ///   The new string representation of the keyword.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static renameKeyword = function () {
        keywords ??= __pugspeak_keywords_create();
        var keywords_ = keywords;
        for (var i = 0; i < argument_count; i += 2) {
            var currentName = argument[i];
            var newName = argument[i + 1];
            if (PUGSPEAK_DEBUG_MODE) {
                __pugspeak_check_arg("currentName", currentName, is_string);
                __pugspeak_check_arg("newName", newName, is_string);
            }
            __pugspeak_keywords_rename(keywords, currentName, newName);
        }
    };

    /// Used to add a new Pugspeak keyword alias.
    ///
    /// @param {String} name
    ///   The name of the keyword to add.
    ///
    /// @param {Enum.PugspeakToken} token
    ///   The token this keyword should represent.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static addKeyword = function () {
        keywords ??= __pugspeak_keywords_create();
        var keywords_ = keywords;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            var token = argument[i + 1];
            if (PUGSPEAK_DEBUG_MODE) {
                __pugspeak_check_arg("name", name, is_string);
            }
            keywords_[$ name] = token;
        }
    };

    /// Used to remove an existing Pugspeak keyword from this environment.
    ///
    /// @param {String} name
    ///   The name of the keyword to remove.
    ///
    /// @param {String} ...
    ///   Additional keywords to remove.
    static removeKeyword = function () {
        keywords ??= __pugspeak_keywords_create();
        var keywords_ = keywords;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            if (PUGSPEAK_DEBUG_MODE) {
                __pugspeak_check_arg("name", name, is_string);
            }
            if (variable_struct_exists(keywords_, name)) {
                variable_struct_remove(keywords_, name);
            }
        }
    };

    /// @ignore
    static __removeInterface = function () {
        for (var i = 0; i < argument_count; i += 1) {
            interface.addBanList([argument[i]]);
        }
    };
}

/// A usability function for converting special GML constants, such as
/// `global` into structs.
///
/// Will return `undefined` if there does not exist a valid conversion.
///
/// @param {Any} gmlSpecial
///   Any special value to convert into a struct.
///
/// @return {Struct}
function pugspeak_special_to_struct(gmlSpecial) {
    if (is_struct(gmlSpecial)) {
        return gmlSpecial;
    }
    if (gmlSpecial == global) {
        var getGlobal = method(global, function () { return self });
        return getGlobal();
    }
    if (__pugspeak_is_withable(gmlSpecial)) {
        with (gmlSpecial) {
            // magic to convert an id into its struct version
            return self;
        }
    }
    __pugspeak_error_silent(
        "could not convert special GML value '", gmlSpecial, "' ",
        "into a valid Pugspeak representation"
    );
    return undefined;
}

/// @ignore
function __pugspeak_init_engine() {
    // initialise the default Pugspeak env
    Pugspeak = new PugspeakEnvironment();
}