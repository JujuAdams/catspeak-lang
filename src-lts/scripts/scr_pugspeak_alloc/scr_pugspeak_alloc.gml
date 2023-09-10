//! The Pugspeak env creates a lot of garbage sometimes, this module is
//! responsible for the allocation and collection of that garbage.

//# feather use syntax-errors

/// Forces the Pugspeak env to collect any discarded resources.
function pugspeak_collect() {
    static _global = __PugspeakGlobal();
    if (PUGSPEAK_DEBUG_MODE) {
        __pugspeak_check_init();
    }
    var pool = _global.__pugspeakAllocPool;
    var poolSize = array_length(pool);
    for (var i = 0; i < poolSize; i += 1) {
        var weakRef = pool[i];
        if (weak_ref_alive(weakRef)) {
            continue;
        }
        weakRef.adapter.destroy(weakRef.ds);
        array_delete(pool, i, 1);
    }
}

/// "adapter" here is a struct with two fields: "create" and "destroy" which
/// indicates how to construct and destruct the resource once the owner gets
/// collected.
///
/// "owner" is a struct whose lifetime determines whether the resource needs
/// to be collected as well. Once "owner" gets collected by the garbage
/// collector, any resources it owns will eventually get collected as well.
///
/// @ignore
///
/// @param {Struct} owner
/// @param {Struct} adapter
/// @return {Any}
function __pugspeak_alloc(owner, adapter) {
    static _global = __PugspeakGlobal();
    var pool = _global.__pugspeakAllocPool;
    var poolMax = array_length(pool) - 1;
    if (poolMax >= 0) {
        repeat (3) { // the number of retries until a new resource is created
            var i = irandom(poolMax);
            var weakRef = pool[i];
            if (weak_ref_alive(weakRef)) {
                continue;
            }
            weakRef.adapter.destroy(weakRef.ds);
            var newWeakRef = weak_ref_create(owner);
            var resource = adapter.create();
            newWeakRef.adapter = adapter;
            newWeakRef.ds = resource;
            pool[@ i] = newWeakRef;
            return resource;
        }
    }
    var weakRef = weak_ref_create(owner);
    var resource = adapter.create();
    weakRef.adapter = adapter;
    weakRef.ds = resource;
    array_push(pool, weakRef);
    return resource;
}

/// @ignore
///
/// @param {Struct} owner
function __pugspeak_alloc_ds_map(owner) {
    static _global = __PugspeakGlobal();
    return __pugspeak_alloc(owner, _global.__pugspeakAllocDSMapAdapter);
}

/// @ignore
///
/// @param {Struct} owner
function __pugspeak_alloc_ds_list(owner) {
    static _global = __PugspeakGlobal();
    return __pugspeak_alloc(owner, _global.__pugspeakAllocDSListAdapter);
}

/// @ignore
///
/// @param {Struct} owner
function __pugspeak_alloc_ds_stack(owner) {
    static _global = __PugspeakGlobal();
    return __pugspeak_alloc(owner, _global.__pugspeakAllocDSStackAdapter);
}

/// @ignore
///
/// @param {Struct} owner
function __pugspeak_alloc_ds_priority(owner) {
    static _global = __PugspeakGlobal();
    return __pugspeak_alloc(owner, _global.__pugspeakAllocDSPriorityAdapter);
}

/// @ignore
function __pugspeak_init_alloc() {
    static _global = __PugspeakGlobal();
    /// @ignore
    _global.__pugspeakAllocPool = [];
    /// @ignore
    _global.__pugspeakAllocDSMapAdapter = {
        create : ds_map_create,
        destroy : ds_map_destroy,
    };
    /// @ignore
    _global.__pugspeakAllocDSListAdapter = {
        create : ds_list_create,
        destroy : ds_list_destroy,
    };
    /// @ignore
    _global.__pugspeakAllocDSStackAdapter = {
        create : ds_stack_create,
        destroy : ds_stack_destroy,
    };
    /// @ignore
    _global.__pugspeakAllocDSPriorityAdapter = {
        create : ds_priority_create,
        destroy : ds_priority_destroy,
    };
}