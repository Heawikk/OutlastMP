class OLMPHero extends OLHero;

event Tick(float DeltaTime)
{
    bCameraCracked = false;
    super.Tick(DeltaTime);
    bCameraCracked = false;
}

DefaultProperties
{
}
