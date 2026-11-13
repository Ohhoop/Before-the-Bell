-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Data/Cast"

local b={}
BeforeTheBell.Bell.Build=b
b.LOWEST_FLAGS={armorCap=true,thornsPierceAt=true}

local c=BeforeTheBell.Bell.Items
local g=BeforeTheBell.Bell.Cast

local i={"atk","arm","spd","hp","thorns"}

local function j(side,id)
return{
side=side,id=id,hp=0,maxHp=0,atk=0,arm=0,spd=0,thorns=0,
poison=0,bleed=0,freeze=0,flags={},hooks={},extra={hp=0},
}
end

local function d(fighter,source,rank,stats,hooks,flags)
if stats~=nil then
for f=1,#i do
local a=i[f]
local e=stats[a]
if e~=nil then
if a=="hp"then
fighter.extra.hp=fighter.extra.hp+e
else
fighter[a]=fighter[a]+e
end
end
end
end
if hooks~=nil then
for e=1,#hooks do
local a=hooks[e]
fighter.hooks[#fighter.hooks+1]={on=a.on,fx=a.fx,once=a.once,every=a.every,again=a.again,source=source,rank=rank}
end
end
if flags~=nil then
for a,e in pairs(flags)do
local f=fighter.flags[a]
if type(e)=="number"and b.LOWEST_FLAGS[a]and f~=nil then
fighter.flags[a]=math.min(f,e)
elseif type(e)=="number"then
fighter.flags[a]=(f or 0)+e
elseif e then
fighter.flags[a]=true
end
end
end
end

function b.owned(run)
local a={}
if run.weapon then
a[run.weapon.id]=true
end
for e=1,#run.gear do
a[run.gear[e].id]=true
local f=c.byId[run.gear[e].id].stands
if f then
a[f]=true
end
end
for e=1,#run.bag do
a[run.bag[e]]=true
end
return a
end

function b.completeSets(run)
local h=b.owned(run)
local a={}
for k=1,#c.sets do
local e=c.sets[k]
local f=true
for l=1,#e.items do
if not h[e.items[l]]then
f=false
end
end
if f then
a[#a+1]=e
end
end
return a
end

function b.countInBag(run,id)
local a=0
for e=1,#run.bag do
if run.bag[e]==id then
a=a+1
end
end
return a
end

function b.hero(run)
local f=g.heroById[run.hero]
local a=j("hero",run.hero)
a.spd=f.spd
a.arm=f.arm
a.atk=f.atk
d(a,run.hero,1,nil,f.hooks,f.flags)
if run.training then
d(a,"TrainingDummy",1,{[run.training]=g.TRAINING_BONUS})
end
if run.weapon then
local e=c.byId[run.weapon.id]
d(a,e.id,1,c.effects(e,run.weapon.bonuses,1))
end
for e=1,#run.gear do
local h=c.byId[run.gear[e].id]
d(a,h.id,run.gear[e].rank,c.effects(h,nil,run.gear[e].rank))
end
for h=1,#run.blessings do
local e=g.blessingById[run.blessings[h]]
d(a,e.id,1,e.stats,e.hooks,e.flags)
if e.flags and e.flags.keepArmor then
a.keptArmor=run.keptArmor
end
if e.flags and e.flags.dawn then
d(a,e.id,1,run.dawnStats)
end
end
local e=b.completeSets(run)
for h=1,#e do
d(a,e[h].id,1,nil,e[h].hooks,e[h].flags)
end
if a.flags.setAttack then
a.atk=a.atk+a.flags.setAttack*#e
end
if a.flags.goldAtk then
a.atk=a.atk+a.flags.goldAtk*math.min(c.GOLD_ATK_MAX,math.floor(run.gold/c.GOLD_STEP))
end
if a.flags.atkPerEmpty then
a.atk=a.atk+a.flags.atkPerEmpty*(c.SLOTS-#run.gear)
end
if a.flags.armPerEmpty then
a.arm=a.arm+a.flags.armPerEmpty*(c.SLOTS-#run.gear)
end
if a.flags.setGuard then
a.arm=a.arm+a.flags.setGuard*#e
a.spd=a.spd+a.flags.setGuard*#e
end
if a.flags.armToAtk then
a.atk=a.atk+math.floor(a.arm*a.flags.armToAtk/100)
end
a.arm=math.max(0,a.arm)
a.spd=math.max(0,a.spd)
a.maxHp=math.max(1,run.maxHp+a.extra.hp)
a.hp=math.min(run.hp,a.maxHp)
a.feathers=b.countInBag(run,"PhoenixFeather")
return a
end

function b.foe(definition,kind,rules)
local a=j("foe",definition.id)
a.kind=kind
a.atk=definition.atk
a.arm=definition.arm
a.spd=math.max(0,definition.spd)
a.thorns=definition.thorns or 0
a.gold=definition.gold
d(a,definition.id,1,nil,definition.hooks,definition.flags)
local e=definition.hp
if kind=="night"then
e=math.floor(e*rules.nightHealth/100)
end
if kind=="boss"and rules.bossArmor>0 then
d(a,"TollOfIron",1,nil,{{on="turn",fx={arm=rules.bossArmor}}},nil)
end
a.maxHp=e
a.hp=e
if definition.phase2 then
a.phase2=b.foe(definition.phase2,kind,rules)
end
return a
end
