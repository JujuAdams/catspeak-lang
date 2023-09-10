//! Contains compatibility library for help with converting from Pugspeak 2 to
//! Pugspeak 3.

//# feather use syntax-errors

/// @ignore
/// @param {Any} name
/// @param {Any} [alternative]
function __pugspeak_deprecated(name, alternative=undefined) {
    if (alternative == undefined) {
        __pugspeak_error_silent("'", name, "' isn't supported anymore");
    } else {
        __pugspeak_error_silent(
            "'", name, "' isn't supported anymore",
            ", use '", alternative, "' instead"
        );
    }
}

// PUGSPEAK 2 //

/// Configures various global settings of the Pugspeak compiler and runtime.
/// See the list in [scr_pugspeak_config] for configuration values and their
/// usages.
///
/// @deprecated
///
/// @return {Struct}
function pugspeak_config() {
    static _global = __PugspeakGMLGlobal();
    pugspeak_force_init();
    var config = _global.__pugspeakConfig;
    if (argument_count > 0 && is_struct(argument[0])) {
        // for compatibility
        var newConfig = argument[0];
        var keys = variable_struct_get_names(newConfig);
        for (var i = array_length(keys) - 1; i > 0; i -= 1) {
            var key = keys[i];
            if (variable_struct_exists(config, key)) {
                config[$ key] = newConfig[$ key];
            }
        }
    }
    return config;
}

/// Permanently adds a new Pugspeak function to the default standard library.
///
/// @deprecated
///
/// @param {String} name
///   The name of the function to add.
///
/// @param {Function} f
///   The function to add, will be converted into a method if a script ID
///   is used.
///
/// @param {Any} ...
///   The remaining key-value pairs to add, in the same pattern as the two
///   previous arguments.
function pugspeak_add_function() {
    __pugspeak_deprecated("pugspeak_add_function", "Pugspeak.addFunction");
    pugspeak_force_init();
    for (var i = 0; i < argument_count; i += 2) {
        Pugspeak.addFunction(argument[i + 0], argument[i + 1]);
    }
}

/// Permanently adds a new Pugspeak constant to the default standard library.
/// If you want to add a function, use the [pugspeak_add_function] function
/// instead because it makes sure your value will be callable from within
/// Pugspeak.
///
/// @param {String} name
///   The name of the constant to add.
///
/// @param {Any} value
///   The value to add.
///
/// @param {Any} ...
///   The remaining key-value pairs to add, in the same pattern as the two
///   previous arguments.
function pugspeak_add_constant() {
    __pugspeak_deprecated("pugspeak_add_function", "Pugspeak.addConstant");
    pugspeak_force_init();
    for (var i = 0; i < argument_count; i += 2) {
        Pugspeak.addConstant(argument[i + 0], argument[i + 1]);
    }
}

/// Creates a new Pugspeak runtime process for this Pugspeak function. This
/// function is also compatible with GML functions.
///
/// @deprecated
///
/// @param {Function|Struct.PugspeakFunction} scr
///   The GML or Pugspeak function to execute.
///
/// @param {Array<Any>} [args]
///   The array of arguments to pass to the function call. Defaults to the
///   empty array.
///
/// @return {Struct.PugspeakProcess}
function pugspeak_execute(scr, args) {
    __pugspeak_deprecated("pugspeak_execute");
    static noArgs = [];
    var args_ = args ?? noArgs;
    var argo = 0;
    var argc = array_length(args_);
    try {
        var result;
        with (method_get_self(scr) ?? self) {
            result = script_execute_ext(method_get_index(scr),
                    args_, argo, argc);
        }
        return future_ok(result);
    } catch (e) {
        return future_error(e);
    }
}

/// The old name of [pugspeak_into_gml_function] from the compatibility
/// runtime for Pugspeak.
///
/// @deprecated
///
/// @deprecated
///  Use [pugspeak_into_gml_function] instead.
///
/// @param {Struct.PugspeakFunction} scr
///   The Pugspeak function to execute.
///
/// @return {Function}
function pugspeak_session_extern(scr) {
    __pugspeak_deprecated("pugspeak_session_extern");
    return pugspeak_into_gml_function(scr);
}

/// Converts a Pugspeak function into a GML function which is executed
/// immediately.
///
/// @deprecated
///
/// @param {Function} scr
///   The Pugspeak function to execute.
///
/// @return {Function}
function pugspeak_into_gml_function(scr) {
    __pugspeak_deprecated("pugspeak_into_gml_function");
    return scr;
}

/// Creates a new Pugspeak compiler process for a buffer containing Pugspeak
/// code.
///
/// @deprecated
///
/// @param {ID.Buffer} buff
///   A reference to the buffer containing the source code to compile.
///
/// @param {Bool} [consume]
///   Whether the buffer should be deleted after the compiler process is
///   complete. Defaults to `false`.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0, the
///   start of the buffer.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit will
///   be treated as the end of the file. Defaults to `infinity`.
///
/// @return {Struct.PugspeakProcess}
function pugspeak_compile_buffer(buff, consume=false, offset=0, size=undefined) {
    __pugspeak_deprecated("pugspeak_compile_buffer", "Pugspeak.parse");
    var ret;
    try {
        var f = Pugspeak.compileGML(Pugspeak.parse(buff, offset, size));
        ret = future_ok(f);
    } catch (e) {
        ret = future_error(e);
    } finally {
        if (consume) {
            buffer_delete(buff);
        }
    }
    return ret;
}

/// Creates a new Pugspeak compiler process for a string containing Pugspeak
/// code. This will allocate a new buffer to store the string, if that isn't
/// ideal then you will have to create and write to your own buffer, then
/// pass it into the [pugspeak_compile_buffer] function instead.
///
/// @deprecated
///
/// @param {Any} src
///   The value containing the source code to compile.
///
/// @return {Struct.PugspeakProcess}
function pugspeak_compile_string(src) {
    __pugspeak_deprecated("pugspeak_compile_buffer", "Pugspeak.parseString");
    try {
        var f = Pugspeak.compileGML(Pugspeak.parseString(src));
        return future_ok(f);
    } catch (e) {
        return future_error(e);
    }
}

/// A helper function for creating a buffer from a string.
///
/// @deprecated
///
/// @param {String} src
///   The source code to convert into a buffer.
///
/// @return {Id.Buffer}
function pugspeak_create_buffer_from_string(src) {
    __pugspeak_deprecated("pugspeak_create_buffer_from_string");
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

// FUTURE //

/// The different progress states of a [Future].
enum FutureState {
    UNRESOLVED,
    ACCEPTED,
    REJECTED,
}

/// Constructs a new future, allowing for deferred execution of code depending
/// on whether it was accepted or rejected.
function Future() constructor {
    self.state = FutureState.UNRESOLVED;
    self.result = undefined;
    self.thenFuncs = [];
    self.catchFuncs = [];
    self.finallyFuncs = [];
    self.__futureFlag__ = true;

    /// Accepts this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static accept = function(value) {
        __resolve(FutureState.ACCEPTED, value);
        var thenCount = array_length(thenFuncs);
        for (var i = 0; i < thenCount; i += 2) {
            // call then callbacks
            var callback = thenFuncs[i + 0];
            var nextFuture = thenFuncs[i + 1];
            var result = callback(value);
            if (is_future(result)) {
                // if the result returned from the callback is another future,
                // delay the next future until the result future has been
                // resolved
                result.andFinally(method(nextFuture, function(future) {
                    if (future.state == FutureState.ACCEPTED) {
                        accept(future.result);
                    } else {
                        reject(future.result);
                    }
                }));
            } else {
                nextFuture.accept(result);
            }
        }
        var catchCount = array_length(catchFuncs);
        for (var i = 0; i < catchCount; i += 2) {
            // accept catch futures
            var nextFuture = catchFuncs[i + 1];
            nextFuture.accept(value);
        }
        var finallyCount = array_length(finallyFuncs);
        for (var i = 0; i < finallyCount; i += 2) {
            // accept finally futures and call their callbacks
            var callback = finallyFuncs[i + 0];
            var nextFuture = finallyFuncs[i + 1];
            callback(self);
            nextFuture.accept(value);
        }
    };

    /// Rejects this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static reject = function(value) {
        __resolve(FutureState.REJECTED, value);
        var thenCount = array_length(thenFuncs);
        for (var i = 0; i < thenCount; i += 2) {
            // reject then futures
            var nextFuture = thenFuncs[i + 1];
            nextFuture.reject(value);
        }
        var catchCount = array_length(catchFuncs);
        for (var i = 0; i < catchCount; i += 2) {
            // call catch callbacks
            var callback = catchFuncs[i + 0];
            var nextFuture = catchFuncs[i + 1];
            var result = callback(value);
            if (is_future(result)) {
                // if the result returned from the callback is another future,
                // delay the next future until the result future has been
                // resolved
                result.andFinally(method(nextFuture, function(future) {
                    if (future.state == FutureState.ACCEPTED) {
                        accept(future.result);
                    } else {
                        reject(future.result);
                    }
                }));
            } else {
                nextFuture.accept(result);
            }
        }
        var finallyCount = array_length(finallyFuncs);
        for (var i = 0; i < finallyCount; i += 2) {
            // reject finally futures and call their callbacks
            var callback = finallyFuncs[i + 0];
            var nextFuture = finallyFuncs[i + 1];
            callback(self);
            nextFuture.reject(value);
        }
    };

    /// Returns whether this future has been resolved. A resolved future
    /// may be the result of being accepted OR rejected.
    ///
    /// @return {Bool}
    static resolved = function() {
        return state != FutureState.UNRESOLVED;
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andThen = function(callback) {
        var future;
        if (state == FutureState.UNRESOLVED) {
            future = new Future();
            array_push(thenFuncs, callback, future);
        } else if (state == FutureState.ACCEPTED) {
            future = future_ok(callback(result));
        }
        return future;
    };

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andCatch = function(callback) {
        var future;
        if (state == FutureState.UNRESOLVED) {
            future = new Future();
            array_push(catchFuncs, callback, future);
        } else if (state == FutureState.REJECTED) {
            future = future_ok(callback(result));
        }
        return future;
    };

    /// Sets the callback function to invoke if this promise is resolved.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andFinally = function(callback) {
        var future;
        if (state == FutureState.UNRESOLVED) {
            future = new Future();
            array_push(finallyFuncs, callback, future);
        } else {
            future = future_ok(callback(self));
        }
        return future;
    };

    /// @ignore
    static __resolve = function(newState, value) {
        if (state != FutureState.UNRESOLVED) {
            show_error(
                    "future has already been resolved with a value of " +
                    "'" + string(result) + "'", false);
            return;
        }
        result = value;
        state = newState;
    };
}

/// Creates a new [Future] which is accepted only when all other futures in an
/// array are accepted. If any future in the array is rejected, then the
/// resulting future is rejected with its value. If all futures are accepted,
/// then the resulting future is accepted with an array of their values.
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_all(futures) {
    var count = array_length(futures);
    var newFuture = new Future();
    if (count == 0) {
        newFuture.accept([]);
    } else {
        var joinData = {
            future : newFuture,
            count : count,
            results : array_create(count, undefined),
        };
        for (var i = 0; i < count; i += 1) {
            var future = futures[i];
            future.andThen(method({
                pos : i,
                joinData : joinData,
            }, function(result) {
                var future = joinData.future;
                if (future.resolved()) {
                    return;
                }
                var results = joinData.results;
                results[@ pos] = result;
                joinData.count -= 1;
                if (joinData.count <= 0) {
                    future.accept(results);
                }
            }));
            future.andCatch(method(joinData, function(result) {
                if (future.resolved()) {
                    return;
                }
                future.reject(result);
            }));
        }
    }
    return newFuture;
}

/// Creates a new [Future] which is accepted if any of the futures in an
/// array are accepted. If all futures in the array are rejected, then the
/// resulting future is rejected with an array of their values.
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_any(futures) {
    var count = array_length(futures);
    var newFuture = new Future();
    if (count == 0) {
        newFuture.reject([]);
    } else {
        var joinData = {
            future : newFuture,
            count : count,
            results : array_create(count, undefined),
        };
        for (var i = 0; i < count; i += 1) {
            var future = futures[i];
            future.andThen(method(joinData, function(result) {
                if (future.resolved()) {
                    return;
                }
                future.accept(result);
            }));
            future.andCatch(method({
                pos : i,
                joinData : joinData,
            }, function(result) {
                var future = joinData.future;
                if (future.resolved()) {
                    return;
                }
                var results = joinData.results;
                results[@ pos] = result;
                joinData.count -= 1;
                if (joinData.count <= 0) {
                    future.reject(results);
                }
            }));
        }
    }
    return newFuture;
}

/// Creates a new [Future] which is accepted when all of the futures in an
/// array are either accepted or rejected.
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_settled(futures) {
    var count = array_length(futures);
    var newFuture = new Future();
    if (count == 0) {
        newFuture.accept([]);
    } else {
        var joinData = {
            future : newFuture,
            count : count,
            results : array_create(count, undefined),
        };
        for (var i = 0; i < count; i += 1) {
            var future = futures[i];
            future.andFinally(method({
                pos : i,
                joinData : joinData,
            }, function(thisFuture) {
                var future = joinData.future;
                if (future.resolved()) {
                    return;
                }
                var results = joinData.results;
                results[@ pos] = thisFuture;
                joinData.count -= 1;
                if (joinData.count <= 0) {
                    future.accept(results);
                }
            }));
        }
    }
    return newFuture;
}

/// Creates a new [Future] which is immediately accepted with a value.
/// If the value itself it an instance of [Future], then it is returned
/// instead.
///
/// @param {Any} value
///   The value to create a future from.
///
/// @return {Struct.Future}
function future_ok(value) {
    if (is_future(value)) {
        return value;
    }
    var future = new Future();
    future.accept(value);
    return future;
}

/// Creates a new [Future] which is immediately rejected with a value.
/// If the value itself it an instance of [Future], then it is returned
/// instead.
///
/// @param {Any} value
///   The value to create a future from.
///
/// @return {Struct.Future}
function future_error(value) {
    if (is_future(value)) {
        return value;
    }
    var future = new Future();
    future.reject(value);
    return future;
}

/// Returns whether this value represents a future instance.
///
/// @param {Any} value
///   The value to check.
///
/// @return {Bool}
function is_future(value) {
    gml_pragma("forceinline");
    return is_struct(value) && variable_struct_exists(value, "__futureFlag__");
}