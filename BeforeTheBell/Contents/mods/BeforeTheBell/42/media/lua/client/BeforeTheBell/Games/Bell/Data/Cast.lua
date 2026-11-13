-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local a={}
BeforeTheBell.Bell.Cast=a

a.heroes={
{id="Squire",hp=17,atk=2,arm=1,spd=2,drops={},hooks={{on="start",fx={arm=1}}},weapon="WoodenSword",gear={}},
{id="Ranger",hp=14,atk=1,arm=1,spd=2,drops={},flags={firstStrikeDouble=true},weapon="ShortBow",gear={}},
{id="Alchemist",hp=15,atk=1,arm=0,spd=3,drops={},flags={poisonStays=true},weapon="VenomFang",gear={},bag={"HealingPotion"}},
{id="Templar",hp=6,atk=1,arm=5,spd=1,drops={},hooks={{on="broken",fx={healArmor=100}}},weapon="Mace",gear={"LeatherCap"}},
{id="Berserker",hp=19,atk=1,arm=1,spd=3,drops={},flags={rage=true},weapon="HandAxe",gear={}},
{id="Hexen",hp=14,atk=1,arm=0,spd=2,drops={},flags={freezeEvery=4},weapon="FrostStaff",gear={"BrambleCloak"}},
}

a.roamers={
{
{id="RatSwarm",hp=7,atk=2,arm=0,spd=5,gold=2},
{id="Bandit",hp=10,atk=3,arm=1,spd=3,gold=2,hooks={{on="hit",fx={steal=1}}}},
{id="BogSlime",hp=13,atk=2,arm=0,spd=1,gold=2,hooks={{on="hit",fx={poison=1}}}},
},
{
{id="SkeletonGuard",hp=30,atk=7,arm=6,spd=2,gold=3},
{id="WolfPack",hp=30,atk=6,arm=0,spd=5,gold=3,flags={firstHitBleed=2}},
{id="HedgeWitch",hp=27,atk=6,arm=2,spd=3,gold=4,hooks={{on="start",fx={freeze=1}}}},
},
{
{id="PlagueKnight",hp=63,atk=8,arm=6,spd=2,gold=5,hooks={{on="hit",fx={poison=1}}}},
{id="Gargoyle",hp=77,atk=8,arm=4,spd=0,gold=5,thorns=2},
{id="BellCultist",hp=56,atk=7,arm=2,spd=3,gold=5,hooks={{on="turn",fx={atk=1}}}},
},
}

a.nights={
{
{id="GraveHound",hp=16,atk=3,arm=0,spd=5,gold=4,flags={firstHitBleed=2}},
{id="WillOWisp",hp=18,atk=3,arm=0,spd=6,gold=4,hooks={{on="turn",every=3,fx={pierceDamage=3}}}},
},
{
{id="Wraith",hp=54,atk=8,arm=0,spd=4,gold=6,flags={pierce=true}},
{id="BarrowLord",hp=60,atk=7,arm=6,spd=1,gold=6,hooks={{on="turn",fx={arm=2}}}},
},
{
{id="Banshee",hp=91,atk=8,arm=4,spd=2,gold=8,hooks={{on="hit",fx={atk=1}}}},
{id="GraveSexton",hp=95,atk=8,arm=4,spd=2,gold=8,hooks={{on="hit",fx={bleed=1}},{on="half",fx={heal=6}}}},
},
}

a.bosses={
{id="BogTroll",hp=52,atk=4,arm=2,spd=1,gold=10,hooks={{on="turn",fx={heal=2}}}},
{id="IronWarden",hp=132,atk=9,arm=14,spd=1,gold=15,hooks={{on="turn",every=3,fx={arm=6}}}},
{id="TheToller",hp=60,atk=10,arm=8,spd=2,gold=0,hooks={{on="turn",every=3,fx={pierceDamage=6}}},phase2={id="TheTollerWinged",hp=80,atk=10,arm=4,spd=4,gold=0,hooks={{on="turn",every=3,fx={pierceDamage=6}}},phase2={id="TheBellItself",hp=110,atk=10,arm=0,spd=2,gold=0,hooks={{on="turn",every=2,fx={pierceDamage=6}}}}}},
}

a.blessings={
{id="Steel",flags={keepArmor=true}},
{id="Wind",stats={spd=1}},
{id="Blood",hooks={{on="hit",fx={heal=1}}}},
{id="Thorns",stats={thorns=4}},
{id="Shadows",flags={shadows=true}},
{id="Dawn",flags={dawn=true}},
{id="Plenty",flags={plenty=true}},
}
a.BLESSING_GOLD=12
a.BLESSING_HEALTH=3
a.TRAINING={"atk","arm","spd"}
a.TENT={"rest","forage"}
a.NONE="none"
a.TRAINING_BONUS=1

a.tiers={
{id="SquiresOath"},
{id="LongNight",nightHealth=140},
{id="LeanPurse",prices=150,bareHands=true},
{id="DeepWinter",winter=true},
{id="RestlessDead",restless=true},
{id="TollOfIron",bossArmor=2},
}

a.heroById={}
for b=1,#a.heroes do
a.heroById[a.heroes[b].id]=a.heroes[b]
end

function a.heroIndex(heroId)
for b=1,#a.heroes do
if a.heroes[b].id==heroId then
return b
end
end
end

a.blessingById={}
for b=1,#a.blessings do
a.blessingById[a.blessings[b].id]=a.blessings[b]
end

function a.tierRules(tier)
local c={nightHealth=100,prices=100,bareHands=false,winter=false,restless=false,bossArmor=0}
for d=1,math.min(tier+1,#a.tiers)do
local b=a.tiers[d]
if b.nightHealth then c.nightHealth=b.nightHealth end
if b.prices then c.prices=b.prices end
if b.bareHands then c.bareHands=true end
if b.winter then c.winter=true end
if b.restless then c.restless=true end
if b.bossArmor then c.bossArmor=b.bossArmor end
end
return c
end

local b={}
for c=1,#a.roamers do
for d=1,#a.roamers[c]do
b[a.roamers[c][d].id]=true
end
end
for c=1,#a.nights do
for d=1,#a.nights[c]do
b[a.nights[c][d].id]=true
end
end
for d=1,#a.bosses do
b[a.bosses[d].id]=true
local c=a.bosses[d].phase2
while c do
b[c.id]=true
c=c.phase2
end
end

function a.isFoe(id)
return b[id]==true
end
