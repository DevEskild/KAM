#include "script_component.hpp"
/*
 * Author: Blue
 * Updates internal bleeding rate.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call kat_circulation_fnc_updateInternalBleeding
 *
 * Public: No
 */

params ["_unit"];

private _internalBleeding = 0;

if (_unit getVariable [QEGVAR(breathing,hemopneumothorax), false]) then {
    _internalBleeding = _internalBleeding + EGVAR(breathing,HPTXBleedAmount);
};

_unit setVariable [VAR_INTERNAL_BLEEDING, _internalBleeding, true];