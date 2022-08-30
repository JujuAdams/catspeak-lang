//! Handles errors raised by the compiler and runtime environment.

//# feather use syntax-errors

/// Represents a line and column number in a Catspeak source file.
///
/// @param {Real} line
///   The line number this position is found on.
///
/// @param {Real} [column]
///   The column number this position is found on. This is the number of
///   characters since the previous new-line character; therefore, tabs are
///   considered a single column, not 2, 4, 8, etc. columns.
function CatspeakLocation(line, column) constructor {
    self.line = line;
    self.column = column;
    self.lexeme = undefined;

    /// Creates an exact copy of this source location and returns it.
    ///
    /// @return {Struct.CatspeakLocation}
    static clone = function () {
        return new CatspeakLocation(line, column);
    };

    /// Copies values from this location to a new `CatspeakLocation` without
    /// creating a new instance.
    ///
    /// @param {Struct.CatspeakLocation} source
    ///   The target location to sample from.
    static reflect = function (source) {
        line = source.line;
        column = source.column;
        lexeme = source.lexeme;
    };

    /// Renders this Catspeak location. If both a line number and column
    /// number exist, then the format will be `(line N, column M)`. Otherwise,
    /// if only a line number exists, the format will be `(line N)`.
    ///
    /// If this source location also includes a debug text, it is also included
    /// in the debug output between square brackets.
    ///
    /// @return {String}
    static toString = function () {
        var msg = "(line " + string(line);
        if (column != undefined) {
            msg += ", column " + string(column);
        }
        msg += ")";
        if (lexeme != undefined) {
            msg += " [" + string(lexeme) + "]";
        }
        return msg;
    };
}

/// Represents an error raised by the Catspeak runtime. Follows a similar
/// structure to the built-in error struct.
///
/// @param {Struct.CatspeakLocation} location
///   The location where this error occurred.
///
/// @param {String} [message]
///   The error message to display. Defaults to "No message".
function CatspeakError(location, message="No message") constructor {
    try {
        show_error(message, false);
    } catch (e) {
        self.message = e.message;
        self.longMessage = e.longMessage;
        self.script = e.script;
        self.stacktrace = e.stacktrace;
    }
    self.location = location.clone();

    /// Renders this Catspeak error with its location followed by the error
    /// message.
    ///
    /// @param {Bool} [verbose]
    ///   Whether to include the stack trace as part of the error output.
    ///
    /// @return {String}
    static toString = function (verbose=false) {
        var msg = "";
        msg += instanceof(self) + " " + string(location);
        msg += ": " + string(message);
        if (verbose) {
            msg += "\nStacktrace:";
            var count = array_length(stacktrace);
            for (var i = 0; i < count; i += 1) {
                msg += "\nat " + string(stacktrace[i]);
            }
        }
        return msg;
    };
}