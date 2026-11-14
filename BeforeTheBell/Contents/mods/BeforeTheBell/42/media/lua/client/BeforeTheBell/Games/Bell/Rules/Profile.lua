-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Map"
require"BeforeTheBell/Games/Bell/Rules/Challenges"
require"SpiffBoy/Core/SaveData"

local a={}
BeforeTheBell.Bell.Profile=a

local y=BeforeTheBell.Bell.Build
local b=BeforeTheBell.Bell.Items
local e=BeforeTheBell.Bell.Cast
local f=BeforeTheBell.Bell.Run
local z=BeforeTheBell.Bell.Challenges
local h=BeforeTheBell.Bell.Map

a.MARK_MAX=3
a.RUNS_PER_SLOT=3
a.MAX_STAT=999
a.HERO_WINS={Templar=1,Berserker=2,Hexen=3}
a.HERO_BOSSES={Ranger=1,Alchemist=2}
a.FORGED="+"
a.RANK="*"
a.DUMMY_KILLS=50
a.LEVELS=10

local function c(value,low,high,default)
if type(value)~="number"or value~=value then
return default
end
value=math.floor(value)
if value<low or value>high then
return default
end
return value
end

function a.readOptions(save)
local d=save.options
if type(d)~="table"then
return{music=a.LEVELS,effects=a.LEVELS,fast=false}
end
return{
music=c(d.music,0,a.LEVELS,a.LEVELS),
effects=c(d.effects,0,a.LEVELS,a.LEVELS),
fast=d.fast==true,
}
end

function a.writeOptions(save,options)
save.options={music=options.music,effects=options.effects,fast=options.fast}
end

function a.trainingOf(value)
for d=1,#e.TRAINING do
if value==e.TRAINING[d]then
return value
end
end
return nil
end

function a.tentOf(value)
for d=1,#e.TENT do
if value==e.TENT[d]then
return value
end
end
return nil
end

function a.tentOpen(profile)
return profile.bosses[1]>0
end

function a.fastOpen(profile)
return profile.bosses[1]>0
end

function a.dummyOpen(profile)
return profile.kills>=a.DUMMY_KILLS
end

function a.foeBeaten(profile)
local d=a.dummyOpen(profile)
profile.kills=math.min(a.MAX_STAT,profile.kills+1)
return not d and a.dummyOpen(profile)
end

function a.read(save)
local d=save.profile
local g={
bossItems={},wins=0,tier=0,bosses={0,0,0},runs=0,marks={ban={},favor={}},challenges={},deaths=0,
kills=0,training=nil,tent=nil,merged={},masteries={},sets={},
}
if type(d)~="table"then
return g
end
g.kills=c(d.kills,0,a.MAX_STAT,0)
g.training=a.trainingOf(d.training)
if d.training==e.NONE then
g.training=e.NONE
end
g.tent=a.tentOf(d.tent)
if d.tent==e.NONE then
g.tent=e.NONE
end
g.deaths=c(d.deaths,0,z.MAX_DEATHS,0)
if type(d.challenges)=="table"then
for k=1,#b.list do
local i=d.challenges[k]
local j=b.byId[i]
if type(i)=="string"and j and j.pool==b.CHALLENGE then
g.challenges[i]=true
end
end
end
for m,i in ipairs({"merged","masteries"})do
if type(d[i])=="table"then
for l=1,#b.list do
local j=d[i][l]
local k=b.byId[j]
if type(j)=="string"and k and k.kind==b.GEAR then
g[i][j]=true
end
end
end
end
if type(d.sets)=="table"then
for j=1,#b.sets do
local i=d.sets[j]
if type(i)=="string"and b.setById[i]then
g.sets[i]=true
end
end
end
g.runs=c(d.runs,0,a.MAX_STAT,0)
if type(d.marks)=="table"then
for n,j in ipairs({"ban","favor"})do
local k=d.marks[j]
if type(k)=="table"then
for m=1,a.MARK_MAX do
local i=k[m]
if type(i)=="string"and b.byId[i]and not a.marked(g,i)then
local l=g.marks[j]
l[#l+1]=i
end
end
end
end
end
if type(d.bossItems)=="table"then
for j=1,#b.list do
local i=d.bossItems[j]
if type(i)=="string"and b.bossUnlocked[i]then
g.bossItems[i]=true
end
end
end
g.wins=c(d.wins,0,a.MAX_STAT,0)
g.tier=c(d.tier,0,#e.tiers-1,0)
if type(d.bosses)=="table"then
for i=1,#e.bosses do
g.bosses[i]=c(d.bosses[i],0,a.MAX_STAT,0)
end
end
return g
end

function a.write(save,profile)
local m,n={},{}
for d=1,#profile.marks.ban do
m[d]=profile.marks.ban[d]
end
for d=1,#profile.marks.favor do
n[d]=profile.marks.favor[d]
end
local g={}
for d=1,#b.list do
if profile.challenges[b.list[d].id]then
g[#g+1]=b.list[d].id
end
end
local i={}
for d=1,#b.sets do
if profile.sets[b.sets[d].id]then
i[#i+1]=b.sets[d].id
end
end
local j={}
for d=1,#b.list do
if profile.bossItems[b.list[d].id]then
j[#j+1]=b.list[d].id
end
end
local k,l={},{}
for o=1,#b.list do
local d=b.list[o].id
if profile.merged[d]then
k[#k+1]=d
end
if profile.masteries[d]then
l[#l+1]=d
end
end
save.profile={
bossItems=j,wins=profile.wins,tier=profile.tier,runs=profile.runs,merged=k,masteries=l,sets=i,
challenges=g,deaths=profile.deaths,kills=profile.kills,training=profile.training or"",tent=profile.tent or"",
bosses={profile.bosses[1],profile.bosses[2],profile.bosses[3]},
marks={ban=m,favor=n},
}
end

function a.noteRank(profile,piece)
if piece.rank>=2 then
profile.merged[piece.id]=true
end
if piece.rank==#b.RANK_SCALE then
profile.masteries[piece.id]=true
end
end

function a.noteSets(profile,run)
local d=y.completeSets(run)
for g=1,#d do
profile.sets[d[g].id]=true
end
end

function a.rankKnown(profile,id,rank)
if rank==#b.RANK_SCALE then
return profile.masteries[id]==true
end
return profile.merged[id]==true
end

function a.markText(profile)
return table.concat(profile.marks.ban,",").."|"..table.concat(profile.marks.favor,",")
end

function a.marked(profile,id)
for j,d in ipairs({"ban","favor"})do
local g=profile.marks[d]
for i=1,#g do
if g[i]==id then
return d
end
end
end
return nil
end

function a.markSlots(profile)
local d=math.min(2*a.MARK_MAX,math.max(0,math.floor(profile.runs/a.RUNS_PER_SLOT)-1))
return math.ceil(d/2),math.floor(d/2)
end

function a.runFinished(profile)
local d=a.chestOpen(profile)
profile.runs=math.min(a.MAX_STAT,profile.runs+1)
return not d and a.chestOpen(profile)
end

function a.chestOpen(profile)
return profile.runs>=a.RUNS_PER_SLOT
end

function a.canMark(profile,kind)
local g,i=a.markSlots(profile)
local d=g
if kind=="favor"then
d=i
end
return#profile.marks[kind]<d
end

function a.mark(profile,id,kind)
table.insert(profile.marks[kind],id)
end

function a.unmark(profile,id)
for j,i in ipairs({"ban","favor"})do
local d=profile.marks[i]
for g=#d,1,-1 do
if d[g]==id then
table.remove(d,g)
end
end
end
end

function a.heroOpen(profile,heroId)
local d=a.HERO_BOSSES[heroId]
if d then
return profile.bosses[d]>0
end
local g=a.HERO_WINS[heroId]
if g then
return profile.wins>=g
end
return true
end

local function o(profile)
local d={}
for g=1,#e.heroes do
d[e.heroes[g].id]=a.heroOpen(profile,e.heroes[g].id)
end
return d
end

local function p(before,profile)
local d={}
for i=1,#e.heroes do
local g=e.heroes[i].id
if not before[g]and a.heroOpen(profile,g)then
d[#d+1]=g
end
end
return d
end

function a.bossBeaten(profile,act,tier)
local i=o(profile)
profile.bosses[act]=math.min(a.MAX_STAT,profile.bosses[act]+1)
local g={}
local d=b.BOSS_UNLOCKS[act][tier+1]
if d and not profile.bossItems[d]then
profile.bossItems[d]=true
g[1]=d
end
return g,p(i,profile)
end

function a.runWon(profile,tier)
local g=o(profile)
profile.wins=math.min(a.MAX_STAT,profile.wins+1)
local d=nil
if tier>=profile.tier and profile.tier<#e.tiers-1 then
profile.tier=profile.tier+1
d=profile.tier
end
return p(g,profile),d
end

local function q(piece)
local d=piece.id
if piece.rank and piece.rank>1 then
d=d..a.RANK..piece.rank
end
if piece.bonuses then
for g=1,#piece.bonuses do
d=d..a.FORGED..piece.bonuses[g]
end
end
return d
end

local function r(text,kind)
if type(text)~="string"then
return nil
end
local d={}
for g in string.gmatch(text,"[^%+]+")do
d[#d+1]=g
end
if d[1]==nil then
return nil
end
local j,l=string.match(d[1],"^(%w+)%*(%d)$")
local g=1
if j==nil then
j=d[1]
else
g=tonumber(l)
end
local i=b.byId[j]
if i==nil or i.kind~=kind then
return nil
end
if kind~=b.WEAPON then
if g<1 or g>#b.RANK_SCALE then
return nil
end
return{id=i.id,rank=g}
end
if l~=nil then
return nil
end
if#d-1>f.FORGE_SLOTS then
return nil
end
local k={}
for n=2,#d do
local m=d[n]
if b.FORGE_BONUS[m]==nil then
return nil
end
k[#k+1]=m
end
return{id=i.id,bonuses=k}
end

local function s(run)
local g=""
if run.weapon then
g=q(run.weapon)
end
local i={}
for d=1,#run.gear do
i[d]=q(run.gear[d])
end
local j={}
for d=1,#run.bag do
j[d]=run.bag[d]
end
local k={}
for d=1,#run.blessings do
k[d]=run.blessings[d]
end
local l={}
for d=1,#run.unlocks do
l[d]=run.unlocks[d].kind..":"..(run.unlocks[d].id or"")
end
return{
hero=run.hero,tier=run.tier,mapSeed=run.mapSeed,daySeed=run.daySeed,nightHurt=run.nightHurt==true,lastFoe=run.lastFoe or"",act=run.act,day=run.day,hp=run.hp,maxHp=run.maxHp,
gold=run.gold,kills=run.kills,weapon=g,gear=i,bag=j,blessings=k,
forges=run.forges,healed=run.healed,thornsDealt=run.thornsDealt,lowWins=run.lowWins,blessedAct=run.blessedAct,keptArmor=run.keptArmor,dawnAtk=run.dawnStats.atk,dawnArm=run.dawnStats.arm,dawnSpd=run.dawnStats.spd,training=run.training or"",tent=run.tent or"",unlocks=l,
}
end

function a.writeRun(save,run)
save.run=s(run)
end

function a.clear(save)
save.profile=nil
save.run=nil
end

function a.clearRun(save)
save.run=nil
end

local function A(saved)
local d={}
if type(saved)~="table"then
return d
end
for j=1,#saved do
local g,i=tostring(saved[j]):match("^(%a+):(%w*)$")
if g=="item"and b.byId[i]then
d[#d+1]={kind=g,id=i}
elseif(g=="dummy"or g=="tent")and i==""then
d[#d+1]={kind=g}
end
end
return d
end

local function B(saved)
if type(saved)~="table"or type(saved.hero)~="string"or e.heroById[saved.hero]==nil then
return nil
end
local g=nil
if saved.weapon~=""then
g=r(saved.weapon,b.WEAPON)
if g==nil then
return nil
end
end
local j=c(saved.mapSeed,1,BeforeTheBell.Bell.Map.SEED_MAX,nil)
if j==nil then
return nil
end
local d=f.new(saved.hero,c(saved.tier,0,#e.tiers-1,0),j)
d.act=c(saved.act,1,f.ACTS,1)
d.day=c(saved.day,1,f.DAYS,1)
d.maxHp=c(saved.maxHp,1,a.MAX_STAT,d.maxHp)
d.hp=c(saved.hp,1,a.MAX_STAT,d.maxHp)
d.gold=c(saved.gold,0,a.MAX_STAT,0)
d.kills=c(saved.kills,0,a.MAX_STAT,0)
d.training=a.trainingOf(saved.training)
d.tent=a.tentOf(saved.tent)
d.forges=c(saved.forges,0,f.MAX_COUNT,0)
d.healed=c(saved.healed,0,f.MAX_COUNT,0)
d.thornsDealt=c(saved.thornsDealt,0,f.MAX_COUNT,0)
d.lowWins=c(saved.lowWins,0,f.MAX_COUNT,0)
d.blessedAct=c(saved.blessedAct,0,f.ACTS,0)
d.keptArmor=c(saved.keptArmor,0,f.MAX_COUNT,0)
d.dawnStats={atk=c(saved.dawnAtk,0,f.MAX_COUNT,0),arm=c(saved.dawnArm,0,f.MAX_COUNT,0),spd=c(saved.dawnSpd,0,f.MAX_COUNT,0)}
d.weapon=g
d.gear={}
if type(saved.gear)=="table"then
for k=1,b.SLOTS do
local i=r(saved.gear[k],b.GEAR)
if i then
d.gear[#d.gear+1]=i
end
end
end
d.bag={}
if type(saved.bag)=="table"then
for k=1,b.BAG do
local i=b.byId[saved.bag[k]]
if i and i.kind==b.CONSUMABLE then
d.bag[#d.bag+1]=i.id
end
end
end
d.blessings={}
if type(saved.blessings)=="table"then
for k=1,#e.blessings do
local i=saved.blessings[k]
if type(i)=="string"and e.blessingById[i]then
d.blessings[#d.blessings+1]=i
end
end
end
d.unlocks=A(saved.unlocks)
d.daySeed=c(saved.daySeed,1,h.SEED_MAX,nil)
d.nightHurt=saved.nightHurt==true
if type(saved.lastFoe)=="string"and e.isFoe(saved.lastFoe)then
d.lastFoe=saved.lastFoe
end
return d
end

function a.readRun(save)
return B(save.run)
end

a.OFFER_MARKS={{field="sold",mark="s"},{field="plenty",mark="p"},{field="revealed",mark="r"}}
a.PAID_GOLD="g"
a.PAID_HEALTH="h"

local function i(value)
return string.format("%d",value)
end

local function j(text)
local d={}
local g=SpiffBoy.SaveData.MAX_STRING
for k=1,string.len(text),g do
d[#d+1]=string.sub(text,k,k+g-1)
end
return d
end

local function k(list)
if type(list)~="table"then
return nil
end
local g={}
for d=1,#list do
if type(list[d])~="string"then
return nil
end
g[d]=list[d]
end
return table.concat(g)
end

local function t(text,most)
if text==nil then
return nil
end
local d={}
for g in string.gmatch(text,"[^,]+")do
if not string.match(g,"^%d+$")then
return nil
end
d[#d+1]=c(tonumber(g),1,most,nil)
if d[#d]==nil then
return nil
end
end
return d
end

local function C(place)
local d={}
if place.kind=="forge"then
for g,l in pairs(place.choices)do
d[#d+1]=g.."="..table.concat(l,".")
end
elseif place.kind=="shrine"then
for g=1,#place.offer do
local l=place.offer[g]
local m=a.PAID_HEALTH
if l.gold>0 then
m=a.PAID_GOLD
end
d[g]=l.blessing.id.."."..m
end
else
for l=1,#place.offer do
local m=place.offer[l]
local g=""
for n=1,#a.OFFER_MARKS do
if m[a.OFFER_MARKS[n].field]then
g=g..a.OFFER_MARKS[n].mark
end
end
d[l]=m.item.id.."."..g
end
end
return table.concat(d,",")
end

function a.writeRunOnLand(save,run,map)
local u=s(run)
local v,g={},{}
for l=1,#map.places do
local d=map.places[l]
v[d.number]=true
if(d.kind=="forge"and d.choices)or(d.kind~="forge"and d.offer)then
g[#g+1]=i(d.number)..":"..C(d)
end
end
local l={}
for d=1,map.placeTotal do
if not v[d]then
l[#l+1]=i(d)
end
end
local w,m={},{}
for x=1,#map.foes do
local d=map.foes[x]
w[d.number]=true
if d.wound>0 or d.caught then
local n="0"
if d.caught then
n="1"
end
m[#m+1]=i(d.number).."."..i(d.wound).."."..n
end
end
local d={}
for n=1,map.foeTotal do
if not w[n]then
d[#d+1]=i(n)
end
end
local n={}
for D,x in pairs(map.traps)do
n[#n+1]=i(x.x).."."..i(x.y)
end
u.land={
heroX=map.heroX,heroY=map.heroY,energy=map.energy,steps=map.steps,
night=map.phase==h.NIGHT,blessed=map.blessed==true,
used=j(table.concat(l,",")),beaten=j(table.concat(d,",")),hurt=j(table.concat(m,",")),
traps=j(table.concat(n,",")),offers=j(table.concat(g,"/")),
}
save.run=u
end

local function n(map,number)
for d=1,#map.places do
if map.places[d].number==number then
return map.places[d]
end
end
return nil
end

local function u(map,number)
for d=1,#map.foes do
if map.foes[d].number==number then
return map.foes[d]
end
end
return nil
end

local function x(map,text)
local d=t(text,map.placeTotal)
if d==nil then
return false
end
for l=1,#d do
local g=n(map,d[l])
if g==nil then
return false
end
h.removePlace(map,g)
end
return true
end

local function D(map,text)
local d=t(text,map.foeTotal)
if d==nil then
return false
end
for l=1,#d do
local g=u(map,d[l])
if g==nil then
return false
end
h.removeFoe(map,g)
end
return true
end

local function E(map,text)
if text==nil then
return false
end
for m in string.gmatch(text,"[^,]+")do
local l,d,v=string.match(m,"^(%d+)%.(%d+)%.([01])$")
if l==nil then
return false
end
local g=u(map,c(tonumber(l),1,map.foeTotal,nil))
d=c(tonumber(d),0,f.MAX_COUNT,nil)
if g==nil or d==nil then
return false
end
g.wound=d
g.caught=v=="1"
end
return true
end

local function F(map,text)
if text==nil then
return false
end
for l in string.gmatch(text,"[^,]+")do
local d,g=string.match(l,"^(%d+)%.(%d+)$")
if d==nil then
return false
end
d=c(tonumber(d),1,h.COLS,nil)
g=c(tonumber(g),1,h.ROWS,nil)
if d==nil or g==nil or not h.walkable(map,d,g)or not h.placeTrap(map,d,g)then
return false
end
end
return true
end

local function G(payload)
local g={}
for w in string.gmatch(payload,"[^,]+")do
local l,H=string.match(w,"^(%w+)=([%a%.]+)$")
local m=b.byId[l]
if m==nil or m.kind~=b.WEAPON or g[l]then
return nil
end
local d={}
for v in string.gmatch(H,"[^%.]+")do
if b.FORGE_BONUS[v]==nil or#d>=f.FORGE_CHOICES then
return nil
end
d[#d+1]=v
end
g[l]=d
end
return g
end

local function H(kind,run,id,marks)
if kind=="shrine"then
local d=e.blessingById[id]
if d==nil then
return nil
end
if marks==a.PAID_GOLD then
return{blessing=d,gold=e.BLESSING_GOLD,health=0}
end
if marks==a.PAID_HEALTH then
return{blessing=d,gold=0,health=e.BLESSING_HEALTH}
end
return nil
end
local g=b.byId[id]
if g==nil or marks==nil then
return nil
end
local d={item=g,price=0}
if kind~="merchant"then
if marks~=""then
return nil
end
return d
end
d.price=f.price(run,g)
for m=1,string.len(marks)do
local w=string.sub(marks,m,m)
local l=nil
for v=1,#a.OFFER_MARKS do
if a.OFFER_MARKS[v].mark==w then
l=a.OFFER_MARKS[v].field
end
end
if l==nil then
return nil
end
d[l]=true
end
return d
end

local function I(map,run,text)
if text==nil then
return false
end
local w={chest=f.CHEST_CHOICES,merchant=f.MERCHANT_ITEMS+f.MERCHANT_EXTRA+2,shrine=f.SHRINE_CHOICES}
for J in string.gmatch(text,"[^/]+")do
local l,m=string.match(J,"^(%d+):(.*)$")
if l==nil then
return false
end
local d=n(map,c(tonumber(l),1,map.placeTotal,nil))
if d==nil or d.offer or d.choices then
return false
end
if d.kind=="forge"then
d.choices=G(m)
if d.choices==nil then
return false
end
else
local g={}
for K in string.gmatch(m,"[^,]+")do
local L,M=string.match(K,"^(%w+)%.(%a*)$")
local v=H(d.kind,run,L,M)
if v==nil or#g>=w[d.kind]then
return false
end
g[#g+1]=v
end
d.offer=g
end
end
return true
end

function a.holdsLand(save)
return type(save.run)=="table"and type(save.run.land)=="table"
end

function a.readLand(save,run)
local g=save.run.land
if run.daySeed==nil then
return nil
end
local d=h.generate(SpiffBoyRandom.new(run.daySeed),run.mapSeed,run.act,run.day,f.rules(run),g.blessed==true,f.firstChest(run))
local l=c(g.heroX,1,h.COLS,nil)
local m=c(g.heroY,1,h.ROWS,nil)
local v=c(g.energy,0,h.MAX_ENERGY,nil)
local w=c(g.steps,0,f.MAX_COUNT,nil)
if l==nil or m==nil or v==nil or w==nil or not h.walkable(d,l,m)then
return nil
end
d.heroX,d.heroY,d.energy,d.steps=l,m,v,w
if g.night==true then
d.phase=h.NIGHT
end
if not(x(d,k(g.used))and D(d,k(g.beaten))and E(d,k(g.hurt))and F(d,k(g.traps)))then
return nil
end
h.clearAround(d,d.heroX,d.heroY,h.RESUME_GAP)
if run.blessedAct==run.act and not d.blessed then
h.shrinesToChests(d)
end
if not I(d,run,k(g.offers))then
return nil
end
return d
end
