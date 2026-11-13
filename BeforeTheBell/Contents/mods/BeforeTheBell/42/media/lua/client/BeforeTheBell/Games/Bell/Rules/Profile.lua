-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Map"
require"BeforeTheBell/Games/Bell/Rules/Challenges"

local c={}
BeforeTheBell.Bell.Profile=c

local q=BeforeTheBell.Bell.Build
local d=BeforeTheBell.Bell.Items
local f=BeforeTheBell.Bell.Cast
local g=BeforeTheBell.Bell.Run
local r=BeforeTheBell.Bell.Challenges

c.MARK_MAX=3
c.RUNS_PER_SLOT=3
c.MAX_STAT=999
c.HERO_WINS={Templar=1,Berserker=2,Hexen=3}
c.HERO_BOSSES={Ranger=1,Alchemist=2}
c.FORGED="+"
c.RANK="*"
c.DUMMY_KILLS=50
c.LEVELS=10

local function e(value,low,high,default)
if type(value)~="number"or value~=value then
return default
end
value=math.floor(value)
if value<low or value>high then
return default
end
return value
end

function c.readOptions(save)
local a=save.options
if type(a)~="table"then
return{music=c.LEVELS,effects=c.LEVELS,fast=false}
end
return{
music=e(a.music,0,c.LEVELS,c.LEVELS),
effects=e(a.effects,0,c.LEVELS,c.LEVELS),
fast=a.fast==true,
}
end

function c.writeOptions(save,options)
save.options={music=options.music,effects=options.effects,fast=options.fast}
end

function c.trainingOf(value)
for a=1,#f.TRAINING do
if value==f.TRAINING[a]then
return value
end
end
return nil
end

function c.tentOf(value)
for a=1,#f.TENT do
if value==f.TENT[a]then
return value
end
end
return nil
end

function c.tentOpen(profile)
return profile.bosses[1]>0
end

function c.fastOpen(profile)
return profile.bosses[1]>0
end

function c.dummyOpen(profile)
return profile.kills>=c.DUMMY_KILLS
end

function c.foeBeaten(profile)
local a=c.dummyOpen(profile)
profile.kills=math.min(c.MAX_STAT,profile.kills+1)
return not a and c.dummyOpen(profile)
end

function c.read(save)
local a=save.profile
local b={
bossItems={},wins=0,tier=0,bosses={0,0,0},runs=0,marks={ban={},favor={}},challenges={},deaths=0,
kills=0,training=nil,tent=nil,merged={},masteries={},sets={},
}
if type(a)~="table"then
return b
end
b.kills=e(a.kills,0,c.MAX_STAT,0)
b.training=c.trainingOf(a.training)
if a.training==f.NONE then
b.training=f.NONE
end
b.tent=c.tentOf(a.tent)
if a.tent==f.NONE then
b.tent=f.NONE
end
b.deaths=e(a.deaths,0,r.MAX_DEATHS,0)
if type(a.challenges)=="table"then
for j=1,#d.list do
local h=a.challenges[j]
local i=d.byId[h]
if type(h)=="string"and i and i.pool==d.CHALLENGE then
b.challenges[h]=true
end
end
end
for l,h in ipairs({"merged","masteries"})do
if type(a[h])=="table"then
for k=1,#d.list do
local i=a[h][k]
local j=d.byId[i]
if type(i)=="string"and j and j.kind==d.GEAR then
b[h][i]=true
end
end
end
end
if type(a.sets)=="table"then
for i=1,#d.sets do
local h=a.sets[i]
if type(h)=="string"and d.setById[h]then
b.sets[h]=true
end
end
end
b.runs=e(a.runs,0,c.MAX_STAT,0)
if type(a.marks)=="table"then
for m,i in ipairs({"ban","favor"})do
local j=a.marks[i]
if type(j)=="table"then
for l=1,c.MARK_MAX do
local h=j[l]
if type(h)=="string"and d.byId[h]and not c.marked(b,h)then
local k=b.marks[i]
k[#k+1]=h
end
end
end
end
end
if type(a.bossItems)=="table"then
for i=1,#d.list do
local h=a.bossItems[i]
if type(h)=="string"and d.bossUnlocked[h]then
b.bossItems[h]=true
end
end
end
b.wins=e(a.wins,0,c.MAX_STAT,0)
b.tier=e(a.tier,0,#f.tiers-1,0)
if type(a.bosses)=="table"then
for h=1,#f.bosses do
b.bosses[h]=e(a.bosses[h],0,c.MAX_STAT,0)
end
end
return b
end

function c.write(save,profile)
local l,m={},{}
for a=1,#profile.marks.ban do
l[a]=profile.marks.ban[a]
end
for a=1,#profile.marks.favor do
m[a]=profile.marks.favor[a]
end
local b={}
for a=1,#d.list do
if profile.challenges[d.list[a].id]then
b[#b+1]=d.list[a].id
end
end
local h={}
for a=1,#d.sets do
if profile.sets[d.sets[a].id]then
h[#h+1]=d.sets[a].id
end
end
local i={}
for a=1,#d.list do
if profile.bossItems[d.list[a].id]then
i[#i+1]=d.list[a].id
end
end
local j,k={},{}
for n=1,#d.list do
local a=d.list[n].id
if profile.merged[a]then
j[#j+1]=a
end
if profile.masteries[a]then
k[#k+1]=a
end
end
save.profile={
bossItems=i,wins=profile.wins,tier=profile.tier,runs=profile.runs,merged=j,masteries=k,sets=h,
challenges=b,deaths=profile.deaths,kills=profile.kills,training=profile.training or"",tent=profile.tent or"",
bosses={profile.bosses[1],profile.bosses[2],profile.bosses[3]},
marks={ban=l,favor=m},
}
end

function c.noteRank(profile,piece)
if piece.rank>=2 then
profile.merged[piece.id]=true
end
if piece.rank==#d.RANK_SCALE then
profile.masteries[piece.id]=true
end
end

function c.noteSets(profile,run)
local a=q.completeSets(run)
for b=1,#a do
profile.sets[a[b].id]=true
end
end

function c.rankKnown(profile,id,rank)
if rank==#d.RANK_SCALE then
return profile.masteries[id]==true
end
return profile.merged[id]==true
end

function c.markText(profile)
return table.concat(profile.marks.ban,",").."|"..table.concat(profile.marks.favor,",")
end

function c.marked(profile,id)
for i,a in ipairs({"ban","favor"})do
local b=profile.marks[a]
for h=1,#b do
if b[h]==id then
return a
end
end
end
return nil
end

function c.markSlots(profile)
local a=math.min(2*c.MARK_MAX,math.max(0,math.floor(profile.runs/c.RUNS_PER_SLOT)-1))
return math.ceil(a/2),math.floor(a/2)
end

function c.runFinished(profile)
local a=c.chestOpen(profile)
profile.runs=math.min(c.MAX_STAT,profile.runs+1)
return not a and c.chestOpen(profile)
end

function c.chestOpen(profile)
return profile.runs>=c.RUNS_PER_SLOT
end

function c.canMark(profile,kind)
local b,h=c.markSlots(profile)
local a=b
if kind=="favor"then
a=h
end
return#profile.marks[kind]<a
end

function c.mark(profile,id,kind)
table.insert(profile.marks[kind],id)
end

function c.unmark(profile,id)
for i,h in ipairs({"ban","favor"})do
local a=profile.marks[h]
for b=#a,1,-1 do
if a[b]==id then
table.remove(a,b)
end
end
end
end

function c.heroOpen(profile,heroId)
local a=c.HERO_BOSSES[heroId]
if a then
return profile.bosses[a]>0
end
local b=c.HERO_WINS[heroId]
if b then
return profile.wins>=b
end
return true
end

local function k(profile)
local a={}
for b=1,#f.heroes do
a[f.heroes[b].id]=c.heroOpen(profile,f.heroes[b].id)
end
return a
end

local function l(before,profile)
local a={}
for h=1,#f.heroes do
local b=f.heroes[h].id
if not before[b]and c.heroOpen(profile,b)then
a[#a+1]=b
end
end
return a
end

function c.bossBeaten(profile,act,tier)
local h=k(profile)
profile.bosses[act]=math.min(c.MAX_STAT,profile.bosses[act]+1)
local b={}
local a=d.BOSS_UNLOCKS[act][tier+1]
if a and not profile.bossItems[a]then
profile.bossItems[a]=true
b[1]=a
end
return b,l(h,profile)
end

function c.runWon(profile,tier)
local b=k(profile)
profile.wins=math.min(c.MAX_STAT,profile.wins+1)
local a=nil
if tier>=profile.tier and profile.tier<#f.tiers-1 then
profile.tier=profile.tier+1
a=profile.tier
end
return l(b,profile),a
end

local function m(piece)
local a=piece.id
if piece.rank and piece.rank>1 then
a=a..c.RANK..piece.rank
end
if piece.bonuses then
for b=1,#piece.bonuses do
a=a..c.FORGED..piece.bonuses[b]
end
end
return a
end

local function n(text,kind)
if type(text)~="string"then
return nil
end
local a={}
for b in string.gmatch(text,"[^%+]+")do
a[#a+1]=b
end
if a[1]==nil then
return nil
end
local i,o=string.match(a[1],"^(%w+)%*(%d)$")
local b=1
if i==nil then
i=a[1]
else
b=tonumber(o)
end
local h=d.byId[i]
if h==nil or h.kind~=kind then
return nil
end
if kind~=d.WEAPON then
if b<1 or b>#d.RANK_SCALE then
return nil
end
return{id=h.id,rank=b}
end
if o~=nil then
return nil
end
if#a-1>g.FORGE_SLOTS then
return nil
end
local j={}
for s=2,#a do
local p=a[s]
if d.FORGE_BONUS[p]==nil then
return nil
end
j[#j+1]=p
end
return{id=h.id,bonuses=j}
end

function c.writeRun(save,run)
local b=""
if run.weapon then
b=m(run.weapon)
end
local h={}
for a=1,#run.gear do
h[a]=m(run.gear[a])
end
local i={}
for a=1,#run.bag do
i[a]=run.bag[a]
end
local j={}
for a=1,#run.blessings do
j[a]=run.blessings[a]
end
local o={}
for a=1,#run.unlocks do
o[a]=run.unlocks[a].kind..":"..(run.unlocks[a].id or"")
end
save.run={
hero=run.hero,tier=run.tier,mapSeed=run.mapSeed,act=run.act,day=run.day,hp=run.hp,maxHp=run.maxHp,
gold=run.gold,kills=run.kills,weapon=b,gear=h,bag=i,blessings=j,
forges=run.forges,healed=run.healed,thornsDealt=run.thornsDealt,lowWins=run.lowWins,blessedAct=run.blessedAct,keptArmor=run.keptArmor,dawnAtk=run.dawnStats.atk,dawnArm=run.dawnStats.arm,dawnSpd=run.dawnStats.spd,training=run.training or"",tent=run.tent or"",unlocks=o,
}
end

function c.clear(save)
save.profile=nil
save.run=nil
end

function c.clearRun(save)
save.run=nil
end

local function o(saved)
local a={}
if type(saved)~="table"then
return a
end
for i=1,#saved do
local b,h=tostring(saved[i]):match("^(%a+):(%w*)$")
if b=="item"and d.byId[h]then
a[#a+1]={kind=b,id=h}
elseif(b=="dummy"or b=="tent")and h==""then
a[#a+1]={kind=b}
end
end
return a
end

function c.readRun(save)
local a=save.run
if type(a)~="table"or type(a.hero)~="string"or f.heroById[a.hero]==nil then
return nil
end
local h=nil
if a.weapon~=""then
h=n(a.weapon,d.WEAPON)
if h==nil then
return nil
end
end
local j=e(a.mapSeed,1,BeforeTheBell.Bell.Map.SEED_MAX,nil)
if j==nil then
return nil
end
local b=g.new(a.hero,e(a.tier,0,#f.tiers-1,0),j)
b.act=e(a.act,1,g.ACTS,1)
b.day=e(a.day,1,g.DAYS,1)
b.maxHp=e(a.maxHp,1,c.MAX_STAT,b.maxHp)
b.hp=e(a.hp,1,c.MAX_STAT,b.maxHp)
b.gold=e(a.gold,0,c.MAX_STAT,0)
b.kills=e(a.kills,0,c.MAX_STAT,0)
b.training=c.trainingOf(a.training)
b.tent=c.tentOf(a.tent)
b.forges=e(a.forges,0,g.MAX_COUNT,0)
b.healed=e(a.healed,0,g.MAX_COUNT,0)
b.thornsDealt=e(a.thornsDealt,0,g.MAX_COUNT,0)
b.lowWins=e(a.lowWins,0,g.MAX_COUNT,0)
b.blessedAct=e(a.blessedAct,0,g.ACTS,0)
b.keptArmor=e(a.keptArmor,0,g.MAX_COUNT,0)
b.dawnStats={atk=e(a.dawnAtk,0,g.MAX_COUNT,0),arm=e(a.dawnArm,0,g.MAX_COUNT,0),spd=e(a.dawnSpd,0,g.MAX_COUNT,0)}
b.weapon=h
b.gear={}
if type(a.gear)=="table"then
for p=1,d.SLOTS do
local i=n(a.gear[p],d.GEAR)
if i then
b.gear[#b.gear+1]=i
end
end
end
b.bag={}
if type(a.bag)=="table"then
for p=1,d.BAG do
local i=d.byId[a.bag[p]]
if i and i.kind==d.CONSUMABLE then
b.bag[#b.bag+1]=i.id
end
end
end
b.blessings={}
if type(a.blessings)=="table"then
for p=1,#f.blessings do
local i=a.blessings[p]
if type(i)=="string"and f.blessingById[i]then
b.blessings[#b.blessings+1]=i
end
end
end
b.unlocks=o(a.unlocks)
return b
end

function c.same(a,b)
if type(a)~="table"or type(b)~="table"then
return a==b
end
for h,i in pairs(a)do
if not c.same(i,b[h])then
return false
end
end
for h,i in pairs(b)do
if a[h]==nil then
return false
end
end
return true
end
