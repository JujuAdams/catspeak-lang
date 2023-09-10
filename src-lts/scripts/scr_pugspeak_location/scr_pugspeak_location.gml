//! Responsible for the creation of diagnostic information used by failing
//! Pugspeak programs.

//# feather use syntax-errors

/// 0b00000000000011111111111111111111
///
/// @ignore
#macro __PUGSPEAK_LOCATION_ROW_MASK 0x000FFFFF

/// 0b11111111111100000000000000000000
///
/// @ignore
#macro __PUGSPEAK_LOCATION_COLUMN_MASK 0xFFF00000

/// Encodes the line and column numbers of a source location into a 32-bit
/// integer. The first 20 least-significant bits are reserved for the row
/// number, with the remaining 12 bits used for the (less important)
/// column number.
///
/// Mask layout:
/// | 00000000000011111111111111111111 |
/// | <--column--><-------line-------> |
///
/// @param {Real} row
///   The row number of the source location.
///
/// @param {Real} column
///   The column number of the source location. This is the number of
///   Unicode codepoints since the previous new-line character. As a result,
///   tabs are considered a single column, not 2, 4, 8, etc. columns.
///   characters since the previous new-line character; therefore, tabs are
///   considered a single column, not 2, 4, 8, etc. columns.
///
/// @return {Real}
function pugspeak_location_create(row, column) {
    gml_pragma("forceinline");
    if (PUGSPEAK_DEBUG_MODE) {
        __pugspeak_check_arg_size_bits("row", row, 20);
        __pugspeak_check_arg_size_bits("column", column, 12);
    }
    var bitsRow = row & __PUGSPEAK_LOCATION_ROW_MASK;
    var bitsCol = (column << 20) & __PUGSPEAK_LOCATION_COLUMN_MASK;
    return bitsRow | bitsCol;
}

/// Gets the column row of a Pugspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the
/// supplied Pugspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the source location of a Pugspeak source
///   file.
///
/// @returns {Real}
function pugspeak_location_get_row(location) {
    gml_pragma("forceinline");
    if (PUGSPEAK_DEBUG_MODE) {
        __pugspeak_check_arg_size_bits("location", location, 32);
    }
    return location & __PUGSPEAK_LOCATION_ROW_MASK;
}

/// Gets the column component of a Pugspeak source location. This is stored
/// as a 12-bit unsigned integer within the most significant bits of the
/// supplied Pugspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the source location of a Pugspeak source
///   file.
///
/// @returns {Real}
function pugspeak_location_get_column(location) {
    gml_pragma("forceinline");
    if (PUGSPEAK_DEBUG_MODE) {
        __pugspeak_check_arg_size_bits("location", location, 32);
    }
    return (location & __PUGSPEAK_LOCATION_COLUMN_MASK) >> 20;
}

/// @ignore
///
/// @param {Real} pos
function __pugspeak_location_show(location) {
    var msg = "in a file";
    if (location != undefined) {
        msg += " at (line " + 
                __pugspeak_string(pugspeak_location_get_row(location)) +
                ", column " +
                __pugspeak_string(pugspeak_location_get_column(location)) +
                ")";
    }
    return msg;
}

/// @ignore
///
/// @param {Real} pos
function __pugspeak_location_show_ext(location) {
    var msg = __pugspeak_location_show(location);
    if (argument_count > 1) {
        msg += " -- ";
        for (var i = 1; i < argument_count; i += 1) {
            msg += __pugspeak_string(argument[i]);
        }
    }
    return msg;
}