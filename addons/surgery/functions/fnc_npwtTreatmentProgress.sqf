#include "script_component.hpp"
/*
 * Author: MiszczuZPolski
 * Local call for clearing all wounds on a patient
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "LeftLeg"] call kat_surgery_fnc_npwtTreatmentLocal;
 *
 * Public: No
 */
params ["_args", "_elapsedTime", "_totalTime"];
_args params ["_medic", "_patient", "_bodyPart"];
_bodyPart = toLower _bodyPart;

private _openWounds = GET_OPEN_WOUNDS(_patient);
private _openWoundsOnPart = _openWounds get _bodyPart;

// Stop treatment if there are no wounds that can be bandaged remaining
if (_openWoundsOnPart isEqualTo []) exitWith {false};

if (_totalTime - _elapsedTime > ([_patient, _patient, _bodyPart] call FUNC(getNPWTTime)) - GVAR(npwtTime)) exitWith {true};

[QACEGVAR(medical_treatment,bandageLocal), [_patient, _bodyPart, "Dressing"], _patient] call CBA_fnc_targetEvent;

private _bandagedWounds = GET_BANDAGED_WOUNDS(_patient);
private _bandagedWoundsOnPart = _bandagedWounds get _bodyPart;

if (_bandagedWoundsOnPart isEqualTo []) exitWith {false};

// Remove the first stitchable wound from the bandaged wounds
private _treatedWound = _bandagedWoundsOnPart deleteAt (count _bandagedWoundsOnPart - 1);
_treatedWound params ["_treatedID", "_treatedAmountOf", "", "_treatedDamageOf"];

// Check if we need to add a new stitched wound or increase the amount of an existing one
private _stitchedWounds = GET_STITCHED_WOUNDS(_patient);
private _stitchedWoundsOnPart = _stitchedWounds getOrDefault [_bodyPart, [], true];

private _woundIndex = _stitchedWoundsOnPart findIf {
    _x params ["_classID"];
    _classID == _treatedID
};

if (_woundIndex == -1) then {
    _stitchedWoundsOnPart pushBack _treatedWound;
} else {
    private _wound = _stitchedWoundsOnPart select _woundIndex;
    _wound set [1, (_wound select 1) + _treatedAmountOf];
};

_patient setVariable [VAR_BANDAGED_WOUNDS, _bandagedWounds, true];
_patient setVariable [VAR_STITCHED_WOUNDS, _stitchedWounds, true];

private _partIndex = ALL_BODY_PARTS find _bodyPart;
private _bodyPartDamage = _patient getVariable [QACEGVAR(medical,bodyPartDamage), []];
_bodyPartDamage set [_partIndex, (_bodyPartDamage select _partIndex) - (_treatedDamageOf * _treatedAmountOf)];
_patient setVariable [QACEGVAR(medical,bodyPartDamage), _bodyPartDamage, true];

switch (_bodyPart) do {
    case "head": {[_patient, true, false, false, false] call ACEFUNC(medical_engine,updateBodyPartVisuals);};
    case "body": {[_patient, false, true, false, false] call ACEFUNC(medical_engine,updateBodyPartVisuals);};
    case "leftarm";
    case "rightarm": {[_patient, false, false, true, false] call ACEFUNC(medical_engine,updateBodyPartVisuals);};
    default {[_patient, false, false, false, true] call ACEFUNC(medical_engine,updateBodyPartVisuals);};
};

[_patient] call ACEFUNC(medical_engine,updateDamageEffects);
[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);
