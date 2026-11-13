-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local c={}
BeforeTheBell.Bell.Combat=c

c.MAX_TURNS=160
c.HERO_STREAK=3
c.FATIGUE_TURN=40
c.SPEED_BASE=2
c.RAGE_SHARE=3
c.HEAVY_BLEED=6
c.GAUGE_FULL=12

local n={"atk","arm","spd","thorns","heal","healArmor","healFull","damage","pierceDamage","poison","bleed","freeze","foeArm","foeSpd","steal"}

local h
local g
local i

local function o(f)
return{id=f.id,hp=f.hp,maxHp=f.maxHp,atk=f.atk,arm=f.arm,spd=f.spd,poison=f.poison,bleed=f.bleed,freeze=f.freeze,thorns=f.thorns,gauge=f.gauge}
end

local function b(state,kind,side,value,source)
state.events[#state.events+1]={
kind=kind,side=side,value=value,source=source,rank=state.rank,opens=state.opens,
hero=o(state.hero),foe=o(state.foe),
}
state.opens=nil
end

local function m(state,f)
if f==state.hero then
return state.foe
end
return state.hero
end

local function q(state,f)
local d=f.phase2
for e,a in ipairs({"id","hp","maxHp","atk","arm","spd","thorns","flags","hooks","gold","phase2"})do
f[a]=d[a]
end
f.poison,f.bleed,f.freeze=0,0,0
f.used={}
f.half=f.hp*2<=f.maxHp
f.below=false
f.broken=false
f.hadArmor=f.arm>0
f.startArm=f.arm
f.rearmed=false
b(state,"phase",f.side,f.hp,f.id)
g(state,f,"start")
end

local function r(state,f)
if f.phase2 then
q(state,f)
return
end
if f.side=="hero"and f.feathers>0 then
f.feathers=f.feathers-1
state.feathersUsed=state.feathersUsed+1
f.hp=math.ceil(f.maxHp/2)
b(state,"revive",f.side,f.hp,"PhoenixFeather")
return
end
state.over=true
state.won=f.side=="foe"
b(state,"fall",f.side,0,nil)
end

local function l(state,f)
if state.over then
return
end
if f.hp>0 and not f.half and f.hp*2<=f.maxHp then
f.half=true
g(state,f,"half")
end
if f.hp>0 and not f.below and f.hp*2<=f.maxHp then
f.below=true
g(state,f,"below")
end
if f.broken and f.arm>0 then
f.rearmed=true
end
if f.hadArmor and not f.broken and f.arm<=0 then
f.broken=true
g(state,f,"broken")
elseif f.rearmed and f.arm<=0 then
f.rearmed=false
g(state,f,"broken",true)
end
end

local function j(state,f,amount,source)
f.arm=f.arm+amount
f.hadArmor=true
b(state,"gain_arm",f.side,amount,source)
end

local function k(state,f,amount,source,quiet,overheal)
if amount<=0 or state.over then
return
end
local a=f.hp
f.hp=math.min(f.maxHp,f.hp+amount)
if f.side=="hero"then
state.healed=state.healed+f.hp-a
end
b(state,"heal",f.side,amount,source)
local d=a+amount-f.maxHp
if overheal and d>0 then
j(state,f,d,"LeechFang")
end
if f.flags.healPoison and not quiet then
i(state,f,m(state,f),"poison",f.flags.healPoison,"LeechAmulet")
end
end

h=function(state,target,amount,pierce,source,kind)
if amount<=0 or state.over then
return
end
if target.arm>0 then
target.hadArmor=true
end
local a=amount
if not pierce then
local e=math.min(target.arm,a)
local d=e
if target.flags.armorCap then
d=math.min(d,target.flags.armorCap)
end
target.arm=target.arm-d
a=a-e
end
target.hp=target.hp-a
b(state,kind or"damage",target.side,amount,source)
if target.hp<=0 then
r(state,target)
return
end
l(state,target)
end

i=function(state,source,target,status,amount,origin)
if amount<=0 or state.over then
return
end
if status=="poison"and target.flags.poisonImmune then
return
end
if status=="poison"and target.wardLeft>0 then
target.wardLeft=target.wardLeft-1
b(state,"ward",target.side,amount,"PlagueMask")
return
end
if status=="freeze"and target.flags.coldBlood then
j(state,target,target.flags.coldBlood*amount,"WinterCloak")
return
end
if status=="freeze"and source.flags.freezePlus then
amount=amount+source.flags.freezePlus
end
if status=="poison"and source.flags.poisonDouble then
amount=amount*2
end
target[status]=target[status]+amount
b(state,status,target.side,amount,origin)
if status=="bleed"and source.flags.bleedArmor then
source.arm=source.arm+source.flags.bleedArmor*amount
source.hadArmor=true
b(state,"gain_arm",source.side,source.flags.bleedArmor*amount,"BloodLocket")
end
if status=="freeze"and source.flags.freezeDamage then
h(state,target,source.flags.freezeDamage,false,"WinterCloak")
end
if status=="freeze"and source.flags.freezeHeal then
k(state,source,source.flags.freezeHeal,"RimeRing")
end
if status=="freeze"and source.flags.freezeArmor then
j(state,source,source.flags.freezeArmor,"RimeRing")
end
if status=="bleed"and source.flags.bleedHeal then
k(state,source,source.flags.bleedHeal,"BloodLocket")
end
if status=="poison"and source.flags.poisonHeal then
k(state,source,source.flags.poisonHeal,"LeechAmulet",true)
end
end

local function s(state,owner,target,amount,origin)
h(state,target,amount,false,origin,"blast")
if owner.flags.wildfire then
i(state,owner,target,"bleed",owner.flags.wildfire,"Wildfire")
end
end

local function t(state,owner,fx,origin)
local e=m(state,owner)
local f=#state.events+1
for p=1,#n do
local a=n[p]
local d=fx[a]
if d~=nil and not state.over then
if a=="atk"or a=="thorns"then
owner[a]=owner[a]+d
b(state,"gain_"..a,owner.side,d,origin)
elseif a=="spd"then
owner.spd=math.max(0,owner.spd+d)
b(state,"gain_spd",owner.side,d,origin)
elseif a=="arm"then
owner.arm=owner.arm+d
owner.hadArmor=true
b(state,"gain_arm",owner.side,d,origin)
elseif a=="heal"then
k(state,owner,d,origin,false,fx.overhealArmor)
elseif a=="healArmor"then
k(state,owner,math.floor(owner.startArm*d/100),origin)
elseif a=="healFull"then
k(state,owner,owner.maxHp-owner.hp,origin)
elseif a=="damage"then
s(state,owner,e,d,origin)
elseif a=="pierceDamage"then
h(state,e,d,true,origin,"toll")
elseif a=="poison"or a=="bleed"or a=="freeze"then
i(state,owner,e,a,d,origin)
elseif a=="foeArm"then
e.arm=math.max(0,e.arm+d)
b(state,"shred",e.side,-d,origin)
l(state,e)
elseif a=="foeSpd"then
e.spd=math.max(0,e.spd+d)
b(state,"slow",e.side,-d,origin)
elseif a=="steal"then
state.stolen=state.stolen+d
b(state,"steal",e.side,d,origin)
end
end
end
for a=f+1,#state.events do
if state.events[a].source==origin then
state.events[a].joined=true
end
end
end

g=function(state,f,trigger,againOnly)
for d=1,#f.hooks do
local a=f.hooks[d]
if a.on==trigger and not state.over and(not againOnly or a.again)then
local e=true
if a.once and f.used[d]then
e=false
end
if a.every and f.turns%a.every~=0 then
e=false
end
if e then
f.used[d]=true
state.rank=a.rank
t(state,f,a.fx,a.source)
state.rank=nil
end
end
end
end

local function u(f)
if f.flags.thornsBoost then
return math.floor(f.thorns*(100+f.flags.thornsBoost)/100)
end
return f.thorns
end

local function v(state,a)
local function f(amount,source)
local d=a.hp
a.hp=math.min(a.maxHp,a.hp+amount)
if a.side=="hero"then
state.healed=state.healed+a.hp-d
end
b(state,"heal",a.side,amount,source)
end
if a.flags.halfHitHeal and a.hp*2<=a.maxHp then
f(a.flags.halfHitHeal,"BloodPact")
end
for e=1,#a.hooks do
local d=a.hooks[e]
if d.on=="hit"and d.fx.heal and not(d.once and a.used[e])and not(d.every and a.turns%d.every~=0)then
a.used[e]=true
state.rank=d.rank
f(d.fx.heal,d.source)
state.rank=nil
end
end
end

local function w(state,a,d)
if a.blindLeft>0 then
a.blindLeft=a.blindLeft-1
b(state,"miss",a.side,0,"SmokeBomb")
return
end
a.hitsDealt=a.hitsDealt+1
local e=a.atk
if a.flags.twinStrike then
e=math.ceil(e/2)
end
local f=false
if a.firstHitsLeft>0 then
e=e+1
a.firstHitsLeft=a.firstHitsLeft-1
f=true
end
if a.flags.firstStrikeDouble and a.hitsDealt==1 then
e=e*2
end
if a.flags.thirdDouble and a.hitsDealt%3==0 then
e=e*2
end
if a.flags.rage and a.hp*c.RAGE_SHARE<=a.maxHp then
e=e*2
end
if a.bleed>0 and d.flags.bleedWeaken then
e=e-d.flags.bleedWeaken
end
if a.bleed>=c.HEAVY_BLEED and d.flags.bleedHeavyWeaken then
e=e-d.flags.bleedHeavyWeaken
end
local p,x=d.hp,d.arm
if d.blockLeft>0 then
d.blockLeft=d.blockLeft-1
b(state,"block",d.side,e,"IronHelm")
else
h(state,d,math.max(0,e),a.flags.pierce or(a.flags.firstPierce and a.hitsDealt==1),a.id,"hit")
end
if state.over then
if d.hp<=0 and a.hp>0 then
v(state,a)
end
return
end
if d.flags.hpLossRiposte and d.hp<p then
h(state,a,d.flags.hpLossRiposte,false,"GlassAmulet","damage")
end
if d.flags.armorHitAtk and d.arm<x then
d.atk=d.atk+d.flags.armorHitAtk
b(state,"gain_atk",d.side,d.flags.armorHitAtk,"HeavyTorc")
end
if f and a.oilBleedLeft>0 then
a.oilBleedLeft=a.oilBleedLeft-1
i(state,a,d,"bleed",a.flags.oilBleed,"OilFlask")
end
if a.flags.fifthPoison and a.hitsDealt%5==0 then
i(state,a,d,"poison",a.flags.fifthPoison,"VenomVial")
end
if a.flags.halfHitHeal and a.hp*2<=a.maxHp then
k(state,a,a.flags.halfHitHeal,"BloodPact")
end
if a.hitsDealt==1 then
if a.flags.firstHitBleed then
i(state,a,d,"bleed",a.flags.firstHitBleed,a.id)
end
end
if a.flags.freezeEvery and a.hitsDealt%a.flags.freezeEvery==0 then
i(state,a,d,"freeze",1,a.id)
end
g(state,a,"hit")
g(state,d,"hurt")
if d.thorns>0 then
local y=d.flags.thornsPierceAt~=nil and d.thorns>=d.flags.thornsPierceAt
h(state,a,u(d),y,"thorns","thorns")
if d.flags.thornsBleed then
i(state,d,a,"bleed",d.flags.thornsBleed,"BrambleCloak")
end
end
end

local function x(state,a,d)
local f=a.side=="hero"and state.heroChain
state.heroChain=false
if a.side=="hero"then
state.heroStreak=state.heroStreak+1
else
state.heroStreak=0
end
if state.lastSide==a.side and a.flags.chainAtk then
a.atk=a.atk+a.flags.chainAtk
b(state,"gain_atk",a.side,a.flags.chainAtk,"SwiftBoots")
end
state.lastSide=a.side
a.turns=a.turns+1
state.turn=state.turn+1
if state.turn>c.FATIGUE_TURN then
h(state,a,state.turn-c.FATIGUE_TURN,true,"TheBell","toll")
end
g(state,a,"turn")
if a.poison>0 and not state.over then
local e=a.poison
if a.flags.poisonHalf then
e=math.ceil(e/2)
end
h(state,a,e,true,"poison","tick_poison")
if d.flags.poisonArmor and not state.over then
j(state,d,d.flags.poisonArmor,"ViperRing")
end
if d.flags.poisonShred and not state.over then
a.arm=math.max(0,a.arm-d.flags.poisonShred)
b(state,"shred",a.side,d.flags.poisonShred,"PlagueLocket")
l(state,a)
end
if not d.flags.poisonStays then
a.poison=a.poison-1
end
end
if a.bleed>0 and not state.over then
h(state,a,a.bleed,false,"bleed","tick_bleed")
end
if a.flags.chalice and d.bleed>0 then
k(state,a,math.floor(d.bleed*a.flags.chalice/100),"BloodChalice")
end
if a.flags.halfTurnArmor and a.hp*2<=a.maxHp and not state.over then
j(state,a,a.flags.halfTurnArmor,"LastBanner")
end
if state.over then
return
end
if a.freeze>0 then
a.freeze=a.freeze-1
b(state,"skip",a.side,0,nil)
if d.flags.frozenArmor then
j(state,d,d.flags.frozenArmor,"FrostPendant")
end
return
end
if a.side=="foe"then
state.foeActions=state.foeActions+1
end
local e=1
if a.flags.twinStrike then
e=e+1
end
for p=1,e do
if not state.over then
w(state,a,d)
end
end
if a.side=="hero"then
if f then
state.heroSpeedDouble=true
end
if state.heroStreak>=c.HERO_STREAK then
state.heroStreakReached=true
end
state.heroChain=true
end
end

local function e(f)
return c.SPEED_BASE+f.spd
end

local function y(hero,foe)
local a=hero.gauge>=c.GAUGE_FULL
local d=foe.gauge>=c.GAUGE_FULL
if d and(not a or foe.gauge>hero.gauge)then
return foe
end
if a then
return hero
end
return nil
end

local function p(f)
f.turns=0
f.gauge=0
f.startArm=0
f.hitsDealt=0
f.used={}
f.half=f.hp*2<=f.maxHp
f.below=false
f.broken=false
f.hadArmor=f.arm>0
f.firstHitsLeft=f.flags.firstHits or 0
f.oilBleedLeft=f.flags.oilBleedHits or 0
f.rearmed=false
f.blockLeft=f.flags.blockFirst or 0
f.wardLeft=f.flags.poisonWard or 0
f.blindLeft=0
f.feathers=f.feathers or 0
end

local function z(f)
local a=0
for d=1,#f.hooks do
if f.hooks[d].on=="start"then
a=a+1
end
end
return a
end

function c.fight(hero,foe)
p(hero)
p(foe)
local a={
hero=hero,foe=foe,events={},over=false,won=false,turn=0,
stolen=0,feathersUsed=0,
healed=0,heroSpeedDouble=false,heroChain=false,heroStreak=0,heroStreakReached=false,foeActions=0,lastSide=nil,startEffects=z(hero),
}
hero.blindLeft=(foe.flags.blind or 0)+(foe.flags.firstMiss and 1 or 0)
foe.blindLeft=(hero.flags.blind or 0)+(hero.flags.firstMiss and 1 or 0)
for f,d in ipairs({hero,foe})do
if d.flags.startArmShare then
j(a,d,math.floor(d.maxHp*d.flags.startArmShare/100),"HeartCharm")
end
end
b(a,"begin","foe",0,nil)
g(a,hero,"start")
if hero.flags.echoStart then
g(a,hero,"start")
end
if hero.flags.echoAgain then
g(a,hero,"start")
end
g(a,foe,"start")
l(a,hero)
l(a,foe)
if hero.keptArmor and hero.keptArmor>0 then
j(a,hero,hero.keptArmor,"Steel")
end
hero.startArm=hero.arm
foe.startArm=foe.arm
while not a.over and a.turn<c.MAX_TURNS do
local d=y(hero,foe)
if d then
d.gauge=d.gauge-c.GAUGE_FULL
a.opens=d.side
x(a,d,m(a,d))
a.opens=nil
else
hero.gauge=hero.gauge+e(hero)
foe.gauge=foe.gauge+e(foe)
end
end
if not a.over then
a.over=true
a.won=false
b(a,"fall","hero",0,nil)
end
return a
end
