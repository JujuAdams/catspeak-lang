#macro PUGSPEAK_SETTER_NAME  "Set"
#macro PUGSPEAK_GETTER_NAME  "Get"
#macro PUGSPEAK_SETTER       Set
#macro PUGSPEAK_GETTER       Get

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