-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local a={}
BeforeTheBell.Bell.Strikes=a

a.BARE="smash"

a.WEAPONS={
WoodenSword="slash",Greatsword="slash",HandAxe="slash",BoneAxe="slash",Dagger="slash",VenomFang="slash",TwinDaggers="slash",
Spear="thrust",Rapier="thrust",Halberd="thrust",
Mace="smash",Warhammer="smash",Flail="smash",
ShortBow="arrow",
ThornWhip="lash",
FrostStaff="frost",
}

a.FOES={
RatSwarm="bite",Bandit="slash",BogSlime="smash",
SkeletonGuard="slash",WolfPack="bite",HedgeWitch="hex",
PlagueKnight="slash",Gargoyle="claw",BellCultist="hex",
GraveHound="bite",WillOWisp="hex",Wraith="claw",BarrowLord="slash",Banshee="wave",GraveSexton="smash",
BogTroll="smash",IronWarden="smash",
TheToller="smash",TheTollerWinged="claw",TheBellItself="wave",
}

a.SOURCES={Spear="thrust",Halberd="thrust",FireBomb="bomb"}

a.KINDS={toll="wave",blast="blast"}

a.TWIN={slash="slashBack"}

function a.of(event,weaponId,foeId,second)
if event.kind=="hit"then
local b
if event.side=="foe"then
b=a.BARE
if weaponId then
b=a.WEAPONS[weaponId]
end
else
b=a.FOES[foeId]
end
if second and a.TWIN[b]then
return a.TWIN[b]
end
return b
end
if a.SOURCES[event.source]then
return a.SOURCES[event.source]
end
return a.KINDS[event.kind]
end
