-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Run"

local a={}
BeforeTheBell.Bell.Challenges=a

local i=BeforeTheBell.Bell.Items
local j=BeforeTheBell.Bell.Build
local f=BeforeTheBell.Bell.Run

a.START_EFFECTS=4
a.SETS=3
a.LOW_HEALTH=3
a.ARMOR=20
a.POISON=10
a.FREEZES=3
a.BLEED=8
a.HEALED=30
a.FORGES=5
a.DEATHS=5
a.EMPTY_SLOTS=4
a.DAGGER_SPEED=6
a.MAX_DEATHS=999
a.RUN_THORNS=15
a.ON_HERO_POISON=5
a.LOW_WINS=3
a.LOW_SHARE=4
a.FREEZE_TURNS=2
a.FREEZES_FIGHT=2
a.HERO_FROZEN=2
a.HERO_THORNS=6
a.FOE_POISON=6
a.ON_HERO_BLEED=5
a.ARMOR_BREAKS=3
a.LONG_FIGHT=25

local function b(profile,id,opened)
if not profile.challenges[id]then
profile.challenges[id]=true
opened[#opened+1]=id
end
end

local function k(result)
local c={
armor=0,speed=-math.huge,bleed=0,poison=0,freezes=0,hurt=false,thornsKill=false,frozenKill=false,
heroThorns=0,heroFrozen=0,foePoison=0,foeFrozen=0,thorns=0,armorBreaks=0,
}
local e=nil
for g=1,#result.events do
local d=result.events[g]
c.armor=math.max(c.armor,d.hero.arm)
c.speed=math.max(c.speed,d.hero.spd)
c.bleed=math.max(c.bleed,d.foe.bleed)
c.heroThorns=math.max(c.heroThorns,d.hero.thorns)
c.heroFrozen=math.max(c.heroFrozen,d.hero.freeze)
c.foePoison=math.max(c.foePoison,d.foe.poison)
c.foeFrozen=math.max(c.foeFrozen,d.foe.freeze)
if d.kind=="thorns"and d.side=="foe"then
c.thorns=c.thorns+d.value
end
if e~=nil and e.hero.arm>0 and d.hero.arm==0 then
c.armorBreaks=c.armorBreaks+1
end
if d.kind=="poison"and d.side=="foe"then
c.poison=c.poison+d.value
elseif d.kind=="freeze"and d.side=="foe"then
c.freezes=c.freezes+1
elseif d.kind=="fall"and d.side=="foe"then
c.thornsKill=e~=nil and e.kind=="thorns"and e.side=="foe"
c.frozenKill=d.foe.freeze>0
end
if e~=nil and d.hero.hp<e.hero.hp then
c.hurt=true
end
e=d
end
return c
end

local function g(profile,run,opened)
if#j.completeSets(run)>=a.SETS then
b(profile,"CollectorsRing",opened)
end
if run.forges>=a.FORGES then
b(profile,"SmithsHammer",opened)
end
if run.healed>=a.HEALED then
b(profile,"LeechAmulet",opened)
end
end

function a.afterFight(profile,run,result,atNight)
local c={}
local d=k(result)
if atNight and d.hurt then
run.nightHurt=true
end
if d.armor>=a.ARMOR then
b(profile,"HeavyTorc",c)
end
if d.poison>=a.POISON then
b(profile,"VenomRing",c)
end
if d.freezes>=a.FREEZES then
b(profile,"FrostPendant",c)
end
if d.bleed>=a.BLEED then
b(profile,"BloodLocket",c)
end
if result.heroStreakReached then
b(profile,"Rapier",c)
end
run.thornsDealt=math.min(f.MAX_COUNT,run.thornsDealt+d.thorns)
if run.thornsDealt>=a.RUN_THORNS then
b(profile,"ThornWhip",c)
end
if d.foeFrozen>=a.FREEZE_TURNS then
b(profile,"FrostStaff",c)
end
if d.freezes>=a.FREEZES_FIGHT then
b(profile,"FrostRune",c)
end
if d.heroThorns>=a.HERO_THORNS then
b(profile,"ThornBracer",c)
end
if d.foePoison>=a.FOE_POISON then
b(profile,"PlagueLocket",c)
end
if d.armorBreaks>=a.ARMOR_BREAKS then
b(profile,"BrokenPlate",c)
end
if result.won then
local e=result.kind=="boss"
local h=result.events[#result.events]
if h.hero.poison>=a.ON_HERO_POISON then
b(profile,"PlagueMask",c)
end
if h.hero.bleed>=a.ON_HERO_BLEED then
b(profile,"BloodChalice",c)
end
if d.heroFrozen>=a.HERO_FROZEN then
b(profile,"FrostCharm",c)
end
if result.turn>a.LONG_FIGHT then
b(profile,"BattleDrum",c)
end
if result.foeActions==0 then
b(profile,"BearTrap",c)
end
if result.hero.hp*a.LOW_SHARE<=result.hero.maxHp then
run.lowWins=math.min(f.MAX_COUNT,run.lowWins+1)
if run.lowWins>=a.LOW_WINS then
b(profile,"BloodPact",c)
end
end
if result.startEffects>=a.START_EFFECTS then
b(profile,"CrownOfEchoes",c)
end
if result.hero.hp<a.LOW_HEALTH then
b(profile,"CursedBand",c)
end
if d.thornsKill then
b(profile,"BriarRing",c)
end
if e and d.armor==0 then
b(profile,"GlassAmulet",c)
end
if e and d.frozenKill then
b(profile,"RimeRing",c)
end
if e and i.SLOTS-#run.gear>=a.EMPTY_SLOTS then
b(profile,"WarHorn",c)
end
if e and run.act==1 and f.weaponId(run)=="Dagger"and#run.gear==0 then
b(profile,"SignetOfBlades",c)
end
if e and f.weaponId(run)=="Dagger"and d.speed>=a.DAGGER_SPEED then
b(profile,"TwinDaggers",c)
end
if result.kind~="roamer"and not run.nightHurt then
b(profile,"IronBand",c)
end
end
g(profile,run,c)
return c
end

function a.onLand(profile,run)
local c={}
g(profile,run,c)
return c
end

function a.onNightfall(profile,map)
local c={}
if#map.foes==0 then
b(profile,"HuntersCloak",c)
end
return c
end

function a.runEnded(profile,run,won)
local c={}
if won and f.rules(run).winter then
b(profile,"Halberd",c)
end
if not won then
profile.deaths=math.min(a.MAX_DEATHS,profile.deaths+1)
if profile.deaths>=a.DEATHS then
b(profile,"PhoenixFeather",c)
end
end
return c
end
