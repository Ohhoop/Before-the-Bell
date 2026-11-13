-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local a={}
BeforeTheBell.Bell.Items=a

a.WEAPON="weapon"
a.GEAR="gear"
a.CONSUMABLE="consumable"
a.START="start"
a.UNLOCK="unlock"
a.CHALLENGE="challenge"
a.TIER="tier"
a.SLOTS=6
a.BAG=3
a.PRICE={start=8,unlock=12,challenge=12,tier=12,consumable=6}
a.GOLD_STEP=15
a.GOLD_ATK_MAX=8

a.list={
{id="WoodenSword",kind="weapon",pool="start",rarity="common",stats={atk=1}},
{id="HandAxe",kind="weapon",pool="start",rarity="common",stats={atk=2,spd=-1}},
{id="Dagger",kind="weapon",pool="start",rarity="common",stats={atk=1,spd=2},hooks={{on="hit",fx={bleed=1}}}},
{id="Mace",kind="weapon",pool="start",rarity="common",stats={atk=2},hooks={{on="hit",fx={foeArm=-1}}}},
{id="ShortBow",kind="weapon",pool="start",rarity="common",stats={atk=1,spd=1},hooks={{on="start",fx={bleed=1}}}},
{id="Spear",kind="weapon",pool="unlock",rarity="uncommon",stats={atk=1},hooks={{on="start",fx={damage=3}}}},
{id="VenomFang",kind="weapon",pool="unlock",rarity="common",stats={atk=1},hooks={{on="hit",fx={poison=1}}}},
{id="FrostStaff",kind="weapon",pool="challenge",rarity="common",stats={atk=1},hooks={{on="start",fx={freeze=1}}}},
{id="ThornWhip",kind="weapon",pool="challenge",rarity="uncommon",stats={atk=1,thorns=2}},
{id="Greatsword",kind="weapon",pool="unlock",rarity="uncommon",stats={atk=4,spd=-2}},
{id="Warhammer",kind="weapon",pool="unlock",rarity="uncommon",stats={},flags={armToAtk=50}},
{id="Flail",kind="weapon",pool="unlock",rarity="uncommon",stats={atk=2},hooks={{on="hit",fx={foeArm=-2}}}},
{id="BoneAxe",kind="weapon",pool="unlock",rarity="uncommon",stats={atk=3,spd=-1},hooks={{on="hit",fx={bleed=1}}}},
{id="Rapier",kind="weapon",pool="challenge",rarity="rare",stats={atk=1,spd=2}},
{id="Halberd",kind="weapon",pool="challenge",rarity="rare",stats={atk=3},hooks={{on="start",fx={damage=2}}}},
{id="TwinDaggers",kind="weapon",pool="challenge",rarity="rare",stats={atk=1,spd=1},flags={twinStrike=true}},

{id="LeatherCap",kind="gear",pool="start",rarity="common",stats={arm=2},mastery={hooks={{on="broken",once=true,fx={arm=5}}}}},
{id="IronHelm",kind="gear",pool="start",rarity="common",stats={arm=4,spd=-1},mastery={flags={blockFirst=1}}},
{id="SwiftBoots",kind="gear",pool="start",rarity="common",stats={spd=2},mastery={flags={chainAtk=1}}},
{id="HeartCharm",kind="gear",pool="start",rarity="common",stats={hp=4},mastery={flags={startArmShare=25}}},
{id="Whetstone",kind="gear",pool="start",rarity="common",stats={atk=1},mastery={flags={thirdDouble=true}}},
{id="TowerShield",kind="gear",pool="unlock",rarity="uncommon",stats={arm=6,spd=-2},mastery={flags={armorCap=4}}},
{id="SmokeBomb",kind="gear",pool="start",rarity="common",hooks={{on="start",fx={foeSpd=-2}}},mastery={flags={blind=2}}},
{id="Caltrops",kind="gear",pool="start",rarity="common",hooks={{on="start",fx={bleed=2}}},mastery={flags={bleedWeaken=1}}},
{id="WarHorn",kind="gear",pool="challenge",rarity="rare",flags={atkPerEmpty=1},mastery={flags={armPerEmpty=1}}},
{id="OilFlask",kind="gear",pool="unlock",rarity="uncommon",flags={firstHits=3},mastery={flags={oilBleed=1},oiledBleed=true}},
{id="LeechFang",kind="gear",pool="start",rarity="common",hooks={{on="hit",fx={heal=1}}},mastery={replace=true,hooks={{on="hit",fx={heal=3,overhealArmor=true}}}}},
{id="VenomVial",kind="gear",pool="unlock",rarity="uncommon",hooks={{on="hit",fx={poison=1}}},mastery={flags={fifthPoison=3}}},
{id="RustyChain",kind="gear",pool="start",rarity="common",hooks={{on="hurt",fx={bleed=1}}},mastery={hooks={{on="hurt",fx={foeArm=-1}}}}},
{id="SpikedPauldron",kind="gear",pool="start",rarity="common",hooks={{on="hurt",fx={damage=1}}},mastery={replace=true,hooks={{on="hurt",fx={pierceDamage=3}}}}},
{id="LastBanner",kind="gear",pool="start",rarity="common",hooks={{on="below",fx={arm=3}}},mastery={flags={halfTurnArmor=2}}},
{id="HealingHerb",kind="gear",pool="start",rarity="common",hooks={{on="below",fx={heal=5}}},mastery={replace=true,hooks={{on="below",fx={healFull=1}}}}},
{id="BrokenPlate",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="broken",fx={atk=2}}},mastery={hooks={{on="broken",fx={spd=2}}}}},
{id="EmberRing",kind="gear",pool="unlock",rarity="uncommon",hooks={{on="broken",fx={damage=4}}},mastery={hooks={{on="broken",fx={bleed=2}}}}},
{id="FrostCharm",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="hurt",once=true,fx={freeze=1}}},mastery={hooks={{on="half",fx={freeze=1}}}}},
{id="BrambleCloak",kind="gear",pool="start",rarity="common",stats={thorns=3},mastery={flags={thornsBleed=1}}},
{id="PlagueMask",kind="gear",pool="challenge",rarity="uncommon",flags={poisonHalf=true},mastery={flags={poisonWard=1}}},
{id="BloodChalice",kind="gear",pool="challenge",rarity="uncommon",flags={chalice=34},mastery={flags={bleedHeavyWeaken=1}}},
{id="Chainmail",kind="gear",pool="unlock",rarity="uncommon",stats={arm=3},mastery={hooks={{on="hurt",fx={arm=1}}}}},
{id="IronGauntlets",kind="gear",pool="unlock",rarity="uncommon",stats={atk=1,arm=1},mastery={hooks={{on="hit",fx={foeArm=-1}}}}},
{id="HuntersCloak",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="start",fx={spd=1,foeSpd=-1}}},mastery={hooks={{on="start",fx={bleed=2}}}}},
{id="ViperRing",kind="gear",pool="start",rarity="common",jewel=true,hooks={{on="start",fx={poison=2}}},mastery={flags={poisonArmor=1}}},
{id="BattleDrum",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="start",fx={atk=1}}},mastery={hooks={{on="turn",every=3,fx={atk=1}}}}},
{id="ThornBracer",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="hurt",fx={thorns=1}}},mastery={flags={thornsPierceAt=6}}},
{id="BloodPact",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="below",fx={heal=3,atk=1}}},mastery={flags={halfHitHeal=1}}},
{id="FrostRune",kind="gear",pool="challenge",rarity="uncommon",hooks={{on="broken",fx={freeze=1}}},mastery={hooks={{on="broken",fx={freeze=1}}}}},
{id="SmithsHammer",kind="gear",pool="challenge",rarity="rare",hooks={{on="broken",fx={arm=3}}},mastery={again=true}},

{id="VenomRing",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={poisonDouble=true},mastery={hooks={{on="start",fx={poison=3}}}}},
{id="FrostPendant",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={freezePlus=1},mastery={flags={frozenArmor=2}}},
{id="BriarRing",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={thornsBoost=50},mastery={hooks={{on="start",fx={thorns=3}}}}},
{id="SignetOfBlades",kind="gear",pool="challenge",rarity="rare",jewel=true,stands="Dagger",mastery={flags={firstHitBleed=3}}},
{id="IronBand",kind="gear",pool="challenge",rarity="rare",jewel=true,stands="TowerShield",mastery={hooks={{on="start",fx={arm=5}}}}},
{id="PlagueLocket",kind="gear",pool="challenge",rarity="uncommon",jewel=true,stands="PlagueMask",mastery={flags={poisonShred=1}}},
{id="BloodLocket",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={bleedArmor=1},mastery={flags={bleedHeal=1}}},
{id="LeechAmulet",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={healPoison=1},mastery={flags={poisonHeal=1}}},
{id="RimeRing",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={freezeHeal=3},mastery={flags={freezeArmor=3}}},
{id="CrownOfEchoes",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={echoStart=true},mastery={flags={echoAgain=true}}},
{id="CollectorsRing",kind="gear",pool="challenge",rarity="rare",jewel=true,flags={setAttack=1},mastery={flags={setGuard=1}}},
{id="CursedBand",kind="gear",pool="challenge",rarity="rare",jewel=true,stats={atk=4,hp=-4},mastery={hooks={{on="below",fx={atk=4}}}}},
{id="GlassAmulet",kind="gear",pool="challenge",rarity="rare",jewel=true,stats={atk=4,arm=-4},mastery={flags={hpLossRiposte=2}}},
{id="HeavyTorc",kind="gear",pool="challenge",rarity="rare",jewel=true,stats={arm=6,spd=-3},mastery={flags={armorHitAtk=1}}},
{id="OwlFeather",kind="gear",pool="tier",wonTier=1,rarity="rare",stats={spd=0.75},flags={firstMiss=true},mastery={flags={firstPierce=true}}},
{id="MisersRing",kind="gear",pool="tier",wonTier=2,rarity="rare",jewel=true,flags={goldWon=1.5},mastery={flags={goldAtk=1}}},
{id="WinterCloak",kind="gear",pool="tier",wonTier=3,rarity="rare",stats={arm=1},flags={freezeDamage=1.5},mastery={flags={coldBlood=2}}},

{id="PhoenixFeather",kind="consumable",pool="challenge",rarity="rare"},
{id="HealingPotion",kind="consumable",pool="start",rarity="common"},
{id="FireBomb",kind="gear",pool="start",rarity="common",hooks={{on="start",fx={damage=3}}},mastery={hooks={{on="below",fx={damage=6}}}}},
{id="BearTrap",kind="consumable",pool="challenge",rarity="uncommon",price=2},
}

a.BOSS_UNLOCKS={
{"VenomFang","Spear","OilFlask","VenomVial"},
{"TowerShield","Chainmail","Warhammer","IronGauntlets"},
{"Greatsword","Flail","BoneAxe","EmberRing"},
}

a.sets={
{id="PlagueDoctor",items={"VenomFang","VenomVial","PlagueMask"},flags={poisonImmune=true},hooks={{on="hit",fx={poison=1}}}},
{id="Frostbite",items={"FrostStaff","FrostCharm","FrostRune"},hooks={{on="start",fx={freeze=1}}}},
{id="Juggernaut",items={"Warhammer","TowerShield"},hooks={{on="hit",fx={arm=1}}}},
{id="Wildfire",items={"EmberRing","FireBomb","OilFlask"},flags={wildfire=2}},
{id="Ironclad",items={"Chainmail","IronGauntlets","SmithsHammer"},hooks={{on="turn",fx={arm=1}},{on="hit",fx={arm=1}}}},
{id="WarBand",items={"BattleDrum","Halberd","WarHorn"},hooks={{on="turn",fx={atk=1}}}},
{id="Butcher",items={"BoneAxe","BloodPact","BloodChalice"},flags={firstHitBleed=3}},
{id="BrambleKnight",items={"ThornWhip","ThornBracer","Flail"},hooks={{on="hurt",fx={bleed=1}}}},
}

a.byId={}
for b=1,#a.list do
a.byId[a.list[b].id]=a.list[b]
end

a.setById={}
for b=1,#a.sets do
a.setById[a.sets[b].id]=a.sets[b]
end

a.bossUnlocked={}
for b=1,#a.BOSS_UNLOCKS do
for c=1,#a.BOSS_UNLOCKS[b]do
a.bossUnlocked[a.BOSS_UNLOCKS[b][c]]=true
end
end

function a.available(item,profile)
if item.pool==a.START then
return true
end
if item.pool==a.CHALLENGE then
return profile.challenges[item.id]==true
end
if item.pool==a.TIER then
return profile.tier>item.wonTier
end
return profile.bossItems[item.id]==true
end

function a.pool(kind,profile,fresh)
local c={}
for d=1,#a.list do
local b=a.list[d]
if b.kind==kind and a.available(b,profile)and not fresh[b.id]then
c[#c+1]=b
end
end
return c
end

function a.price(item)
if item.price then
return item.price
end
if item.kind==a.CONSUMABLE then
return a.PRICE.consumable
end
return a.PRICE[item.pool]
end

a.RARITY={common=6,uncommon=3,rare=1}
a.RARITY_SCALE={common=1,uncommon=1.5,rare=2}

a.FORGE_BONUS={atk=1,arm=2,spd=1,hp=3,thorns=1}
a.RANK_SCALE={1,1.5,2}

local function l(value,rankScale,rarityScale)
if value<0 then
return-math.ceil(-value*rankScale)
end
return math.ceil(value*rankScale*rarityScale)
end

local function i(values,rankScale,rarityScale)
local b={}
for d,c in pairs(values)do
if type(c)=="number"then
b[d]=l(c,rankScale,rarityScale)
else
b[d]=c
end
end
return b
end

a.NUMBER_ORDER={"atk","arm","spd","hp","thorns","damage","heal","bleed","poison","freeze","foeArm","foeSpd","armToAtk","atkPerEmpty","firstHits","chalice","thornsBoost","freezePlus","bleedArmor","healPoison","freezeHeal","setAttack","goldWon","freezeDamage"}

local function j(list,values,rankScale,rarityScale)
for c=1,#a.NUMBER_ORDER do
local b=values[a.NUMBER_ORDER[c]]
if type(b)=="number"then
list[#list+1]=math.abs(l(b,rankScale,rarityScale))
end
end
end

function a.numbers(item,rank)
local c=a.RANK_SCALE[rank]
local d=a.RARITY_SCALE[item.rarity]
local b={}
if item.stats then
j(b,item.stats,c,d)
end
if item.hooks then
for e=1,#item.hooks do
j(b,item.hooks[e].fx,c,d)
end
end
if item.flags then
j(b,item.flags,c,d)
end
return b
end

function a.effects(item,bonuses,rank)
local e=a.RANK_SCALE[rank]
local f=a.RARITY_SCALE[item.rarity]
local b=nil
if rank==#a.RANK_SCALE then
b=item.mastery
end
if(bonuses==nil or#bonuses==0)and e==1 and f==1 and b==nil then
return item.stats,item.hooks,item.flags
end
local g={}
if item.stats then
g=i(item.stats,e,f)
end
if bonuses then
for d=1,#bonuses do
local c=bonuses[d]
g[c]=(g[c]or 0)+a.FORGE_BONUS[c]
end
end
local d,c={},{}
if item.hooks and not(b and b.replace)then
for k=1,#item.hooks do
local h={}
for m,n in pairs(item.hooks[k])do
h[m]=n
end
h.fx=i(item.hooks[k].fx,e,f)
if b and b.again then
h.again=true
end
d[#d+1]=h
end
end
if item.flags then
c=i(item.flags,e,f)
end
if b and b.oiledBleed then
c.oilBleedHits=c.firstHits
end
if b then
if b.hooks then
for h=1,#b.hooks do
d[#d+1]=b.hooks[h]
end
end
if b.flags then
for h,k in pairs(b.flags)do
if type(k)=="number"then
c[h]=(c[h]or 0)+k
else
c[h]=k
end
end
end
end
return g,d,c
end
