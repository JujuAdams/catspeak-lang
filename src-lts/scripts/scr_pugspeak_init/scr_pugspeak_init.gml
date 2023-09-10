//! Initialises core components of the Pugspeak compiler. This includes
//! any uninitialised global variables.

//      _             _                                                       
//     |  `.       .'  |                   _                             _    
//     |    \_..._/    |                  | |                           | |   
//    /    _       _    \     |\_/|  __ _ | |_  ___  _ __    ___   __ _ | | __
// `-|    / \     / \    |-'  / __| / _` || __|/ __|| '_ \  / _ \ / _` || |/ /
// --|    | |     | |    |-- | (__ | (_| || |_ \__ \| |_) ||  __/| (_| ||   < 
//  .'\   \_/ _._ \_/   /`.   \___| \__,_| \__||___/| .__/  \___| \__,_||_|\_\
//     `~..______    .~'                       _____| |   by: katsaii         
//               `.  |                        / ._____/ logo: mashmerlow      
//                 `.|                        \_)                             

//# feather use syntax-errors

/// The compiler version, should be updated before each release.
#macro PUGSPEAK_VERSION "3.0.0"

/// Whether sanity checks and unsafe developer features are enabled at runtime.
/// You can override this using a configuration macro:
///
/// ```gml
/// #macro Release:PUGSPEAK_DEBUG_MODE false
/// ```
///
/// NOTE: Disabling this will give a significant performance boost, but may
///       result in undefined behaviour or cryptic error messages if an error
///       occurs. If you are getting errors in your game, and you suspect
///       Pugspeak may be the cause, make sure to re-enable debug mode if you
///       have it disabled.
#macro PUGSPEAK_DEBUG_MODE (GM_build_type == "run")

#macro Pugspeak  (__PugspeakGMLGlobal().__environment)

/// Makes sure that all Pugspeak global variables are initialised.
/// Returns `true` if this is the first time this function was called, and
/// `false` otherwise.
///
/// NOTE: This only needs to be called if you are trying to use Pugspeak from
///       within a script, or through `gml_pragma`. Otherwise you can just
///       forget this function exists.
///
/// @return {Bool}
function pugspeak_force_init() {
    static initialised = false;
    static _global = __PugspeakGMLGlobal();
    if (initialised) {
        return false;
    }
    initialised = true;
    /// @ignore
    _global.__pugspeakConfig = { };
    // call initialisers
    __pugspeak_init_alloc();
    __pugspeak_init_operators();
    __pugspeak_init_presets();
    __pugspeak_init_lexer();
    __pugspeak_init_codegen();
    __pugspeak_init_engine();
    // display the initialisation message
    var motd = "you are now using Pugspeak v" + PUGSPEAK_VERSION +
            " by @katsaii";
    show_debug_message(motd);
    return true;
}

pugspeak_force_init();