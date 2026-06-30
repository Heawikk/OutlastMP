class OLTogetherLink extends TcpLink
    config(Multiplayer);

var OLTogetherController ControllerOwner;
var bool bIsConnected;
var bool bIsResolving;

var config string ServerHost;
var config int    ServerPort;

event PostBeginPlay()
{
    super.PostBeginPlay();

    if (ServerHost == "")
        ServerHost = "127.0.0.1";
    if (ServerPort <= 0)
        ServerPort = 7777;

    `log("OutlastMM: Connecting to" @ ServerHost $ ":" $ string(ServerPort));

    LinkMode     = MODE_Line;
    ReceiveMode  = RMODE_Event;
    bIsResolving = true;

    Resolve(ServerHost);
}

event Resolved(IpAddr Addr)
{
    bIsResolving = false;
    Addr.Port    = ServerPort;
    BindPort();
    Open(Addr);
}

event ResolveFailed()
{
    bIsResolving = false;
    bIsConnected = false;
    `log("OutlastMM: DNS resolve failed for" @ ServerHost);
}

event Opened()
{
    bIsConnected = true;
    `log("OutlastMM: Connected to" @ ServerHost $ ":" $ string(ServerPort));
}

event Closed()
{
    bIsConnected = false;
    `log("OutlastMM: Disconnected.");
}

event ReceivedLine(string Line)
{
    if (ControllerOwner != None)
        ControllerOwner.OnReceiveData(Line);
}

DefaultProperties
{
    ServerHost   = "127.0.0.1"
    ServerPort   = 7777
    bIsConnected = false
    bIsResolving = false
}
