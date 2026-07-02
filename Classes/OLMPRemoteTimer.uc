// One instance per remote player. Routes timer callbacks back to the controller
// so SetTimer/ClearTimer calls for different players never collide.
class OLMPRemoteTimer extends Actor;

var OLMPController ControllerOwner;
var int PlayerID;

function PlayIdleAnim()
{
    if (ControllerOwner != None)
        ControllerOwner.PlayCamcorderIdleAnimFor(PlayerID);
}

function HideCamcorderProp()
{
    if (ControllerOwner != None)
        ControllerOwner.HideCamcorderPropFor(PlayerID);
}

function FinishInactiveReload()
{
    if (ControllerOwner != None)
        ControllerOwner.FinishInactiveReloadFor(PlayerID);
}

function PlayCrouchIdle()
{
    if (ControllerOwner != None)
        ControllerOwner.PlayCrouchIdleFor(PlayerID);
}

DefaultProperties
{
    bHidden=true
    bNoDelete=false
    RemoteRole=ROLE_None
}
