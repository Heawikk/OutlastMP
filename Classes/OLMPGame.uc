class OLMPGame extends OLGame;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return Default.class;
}

DefaultProperties
{
    PlayerControllerClass = class'Multiplayer.OLMPController'
    DefaultPawnClass      = class'Multiplayer.OLMPHero'
    HUDType               = class'Multiplayer.OLMPHUD'
}