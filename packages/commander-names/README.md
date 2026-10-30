# Commander Names

SuiNS-backed name registry. An `Instance` locks a SuiNS name (or subname) and
serves leaf records under it on request: any address registers `<label>.<name>`
resolving to itself, renames it, removes it and may make it its default name in
the SuiNS reverse registry. The target address of the leaf in SuiNS is the
source of truth for ownership, so the instance keeps no state besides the name.

The creator deposits the name, and is the only one who can withdraw it (for a
renewal, say) and delete the emptied instance.

Depends on `@suins/core`, `@suins/subnames` and `@suins/denylist` from the Move
Registry; `@suins/core` resolves on testnet only.
