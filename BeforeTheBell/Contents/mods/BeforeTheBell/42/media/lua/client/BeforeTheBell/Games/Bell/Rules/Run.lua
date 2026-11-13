-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Combat"

local c={}
BeforeTheBell.Bell.Run=c

local e=BeforeTheBell.Bell.Items
local d=BeforeTheBell.Bell.Cast
local f=BeforeTheBell.Bell.Build
local m=BeforeTheBell.Bell.Combat

c.DAYS=3
c.ACTS=3
c.CHEST_CHOICES=3
c.MERCHANT_ITEMS=3
c.MERCHANT_EXTRA=3
c.WINS_PER_STALL=2
c.SHRINE_CHOICES=2
c.FORGE_PRICE=10
c.FORGE_SLOTS=2
c.ACT_PRICE_STEP=2
c.WEAPON_CHANCE=0.25
c.FAVOR_WEIGHT=3
c.HELD_WEIGHT=1
c.DROP_SHARE=100
c.MAX_COUNT=999
c.REST_MIN=5
c.REST_MAX=10
c.GOLD_SPREAD=25
c.FORAGE_MIN=4
c.FORAGE_MAX=8

function c.new(heroId,tier,mapSeed,training,tent)
local a=d.heroById[heroId]
local b={
hero=heroId,tier=tier,mapSeed=mapSeed,act=1,day=1,hp=a.hp,maxHp=a.hp,gold=0,
weapon=nil,gear={},bag={},blessings={},kills=0,
forges=0,healed=0,thornsDealt=0,lowWins=0,blessedAct=0,keptArmor=0,dawnStats={atk=0,arm=0,spd=0},nightHurt=false,training=training,tent=tent,unlocks={},
}
if not d.tierRules(tier).bareHands then
b.weapon={id=a.weapon,bonuses={}}
end
for g=1,#a.gear do
b.gear[#b.gear+1]={id=a.gear[g],rank=1}
end
if a.bag then
for g=1,#a.bag do
b.bag[#b.bag+1]=a.bag[g]
end
end
return b
end

function c.blessed(run,id)
for a=1,#run.blessings do
if run.blessings[a]==id then
return true
end
end
return false
end

function c.keepUnlocks(run,entries)
for a=1,#entries do
run.unlocks[#run.unlocks+1]=entries[a]
end
end

function c.freshItems(run)
local a={}
for b=1,#run.unlocks do
if run.unlocks[b].kind=="item"then
a[run.unlocks[b].id]=true
end
end
return a
end

function c.rules(run)
return d.tierRules(run.tier)
end

function c.maxHealth(run)
return f.hero(run).maxHp
end

function c.nightFoe(run)
if run.day>=c.DAYS then
return d.bosses[run.act],"boss"
end
return d.nights[run.act][run.day],"night"
end

function c.fight(run,definition,kind,wound)
local g=f.hero(run)
local a=f.foe(definition,kind,c.rules(run))
a.hp=math.max(1,a.hp-wound)
local b=m.fight(g,a)
b.gold=a.gold
b.kind=kind
b.definition=definition
return b
end

function c.rollGold(result,random)
local a=result.gold
if a<=0 then
return
end
local b=math.max(1,math.floor(a*c.GOLD_SPREAD/100))
result.gold=math.max(0,random:int(a-b,a+b))
end

function c.spend(run,id,count)
for b=1,count do
for a=#run.bag,1,-1 do
if run.bag[a]==id then
table.remove(run.bag,a)
break
end
end
end
end

function c.settle(run,result)
local a=f.hero(run).flags
local b=a.goldWon
if a.keepArmor then
run.keptArmor=math.min(c.MAX_COUNT,math.max(0,result.hero.arm))
end
run.hp=math.max(0,result.hero.hp)
run.gold=math.max(0,run.gold-result.stolen)
run.healed=math.min(c.MAX_COUNT,run.healed+result.healed)
c.spend(run,"PhoenixFeather",result.feathersUsed)
if result.won then
run.gold=run.gold+result.gold
if b then
run.gold=run.gold+b
end
run.kills=run.kills+1
end
end

function c.rest(run,random)
local g=c.maxHealth(run)
local h,i=run.hp,run.gold
local b=nil
local a=nil
if f.hero(run).flags.dawn then
a=d.TRAINING[random:int(1,#d.TRAINING)]
run.dawnStats[a]=math.min(c.MAX_COUNT,run.dawnStats[a]+1)
end
if run.tent=="rest"then
run.hp=math.min(g,run.hp+math.ceil(g*random:int(c.REST_MIN,c.REST_MAX)/100))
b="rest"
elseif run.tent=="forage"then
run.gold=math.min(c.MAX_COUNT,run.gold+random:int(c.FORAGE_MIN,c.FORAGE_MAX))
b="forage"
end
return run.hp-h,run.gold-i,b,a
end

function c.advance(run)
if run.day<c.DAYS then
run.day=run.day+1
return false
end
if run.act>=c.ACTS then
return true
end
run.act=run.act+1
run.day=1
return false
end

function c.weaponId(run)
if run.weapon then
return run.weapon.id
end
return nil
end

function c.holds(run,id)
if run.weapon and run.weapon.id==id then
return true
end
for a=1,#run.gear do
if run.gear[a].id==id then
return true
end
end
return false
end

function c.markOf(marks,id)
for g,a in ipairs({"ban","favor"})do
for b=1,#marks[a]do
if marks[a][b]==id then
return a
end
end
end
return nil
end

local function j(list,marks,random,held,drops)
local h,g={},0
for b=1,#list do
local i=c.markOf(marks,list[b].id)
local a=e.RARITY[list[b].rarity]*(drops[list[b].id]or c.DROP_SHARE)
if i=="ban"then
a=0
elseif i=="favor"then
a=a*c.FAVOR_WEIGHT
end
if held[list[b].id]then
a=a*c.HELD_WEIGHT
end
h[b]=a
g=g+a
end
if g==0 then
return nil
end
local a=random:int(1,g)
for b=1,#list do
a=a-h[b]
if a<=0 then
return list[b]
end
end
end

local function h(random,profile,taken,skipId,held,drops,fresh)
local i=e.GEAR
if random:chance(c.WEAPON_CHANCE)then
i=e.WEAPON
end
local a=e.pool(i,profile,fresh)
local b={}
for g=1,#a do
if not taken[a[g].id]and a[g].id~=skipId then
b[#b+1]=a[g]
end
end
return j(b,profile.marks,random,held,drops)
end

local function k(run)
local a={}
for b=1,#run.gear do
if run.gear[b].rank<#e.RANK_SCALE then
a[run.gear[b].id]=true
end
end
return a
end

function c.chestOffer(run,random,profile)
local l=k(run)
local i={}
local a={}
local b=0
while#a<c.CHEST_CHOICES and b<20 do
b=b+1
local g=h(random,profile,i,c.weaponId(run),l,d.heroById[run.hero].drops,c.freshItems(run))
if g then
i[g.id]=true
a[#a+1]={item=g,price=0}
end
end
return a
end

function c.price(run,item)
local a=e.price(item)+c.ACT_PRICE_STEP*(run.act-1)
return math.floor(a*c.rules(run).prices/100)
end

function c.merchantSize(wins)
return c.MERCHANT_ITEMS+math.min(c.MERCHANT_EXTRA,math.floor(wins/c.WINS_PER_STALL))
end

function c.merchantOffer(run,random,profile)
local l=k(run)
local b={}
local a={}
local i=0
local n=c.merchantSize(profile.wins)
while#a<n and i<30 do
i=i+1
local g=h(random,profile,b,c.weaponId(run),l,d.heroById[run.hero].drops,c.freshItems(run))
if g then
b[g.id]=true
a[#a+1]={item=g,price=c.price(run,g)}
end
end
if c.blessed(run,"Plenty")then
local g=h(random,profile,b,c.weaponId(run),l,d.heroById[run.hero].drops,c.freshItems(run))
if g then
b[g.id]=true
a[#a+1]={item=g,price=c.price(run,g),plenty=true}
end
end
local g=j(e.pool(e.CONSUMABLE,profile,c.freshItems(run)),profile.marks,random,{},d.heroById[run.hero].drops)
if g then
a[#a+1]={item=g,price=c.price(run,g)}
end
return a
end

function c.shrineOffer(run,random)
local g={}
for a=1,#run.blessings do
g[run.blessings[a]]=true
end
local b={}
for a=1,#d.blessings do
if not g[d.blessings[a].id]then
b[#b+1]=d.blessings[a]
end
end
local a={}
while#a<c.SHRINE_CHOICES and#b>0 do
local l=random:int(1,#b)
local i=table.remove(b,l)
if random:chance(0.5)then
a[#a+1]={blessing=i,gold=d.BLESSING_GOLD,health=0}
else
a[#a+1]={blessing=i,gold=0,health=d.BLESSING_HEALTH}
end
end
return a
end

function c.forgeOffer(run)
if run.weapon==nil then
return{}
end
return{{item=e.byId[run.weapon.id],price=c.FORGE_PRICE}}
end

function c.forgeFull(run)
return#run.weapon.bonuses>=c.FORGE_SLOTS
end

c.FORGE_CHOICES=3

function c.forgeChoices(random)
local b={"atk","arm","spd","hp","thorns"}
local a={}
while#a<c.FORGE_CHOICES and#b>0 do
a[#a+1]=table.remove(b,random:int(1,#b))
end
return a
end

function c.forge(run,entry,bonus,slot)
if run.gold<entry.price then
return false
end
run.gold=run.gold-entry.price
run.forges=math.min(c.MAX_COUNT,run.forges+1)
local a=run.weapon.bonuses
if c.forgeFull(run)then
a[slot]=bonus
else
a[#a+1]=bonus
end
return true
end

function c.bless(run,entry)
if run.gold<entry.gold then
return false
end
if entry.health>0 and run.maxHp-entry.health<1 then
return false
end
run.gold=run.gold-entry.gold
run.maxHp=run.maxHp-entry.health
run.hp=math.min(run.hp,c.maxHealth(run))
run.blessings[#run.blessings+1]=entry.blessing.id
run.blessedAct=run.act
if run.hp<1 then
run.hp=1
end
return true
end

function c.take(run,item)
if item.kind==e.WEAPON then
run.weapon={id=item.id,bonuses={}}
return"taken"
end
if item.kind==e.CONSUMABLE then
if#run.bag>=e.BAG then
return"bagfull"
end
run.bag[#run.bag+1]=item.id
return"taken"
end
if#run.gear>=e.SLOTS then
return"full"
end
run.gear[#run.gear+1]={id=item.id,rank=1}
return"taken"
end

function c.replace(run,slot,item)
run.gear[slot]={id=item.id,rank=1}
run.hp=math.min(run.hp,c.maxHealth(run))
end

function c.canMerge(run,from,into)
local a,b=run.gear[from],run.gear[into]
return from~=into and a~=nil and b~=nil and a.id==b.id and a.rank==b.rank and a.rank<#e.RANK_SCALE
end

function c.merge(run,from,into)
run.gear[into].rank=run.gear[into].rank+1
table.remove(run.gear,from)
run.hp=math.min(run.hp,c.maxHealth(run))
if from<into then
return into-1
end
return into
end

function c.canMergeIncoming(run,slot,item)
local a=run.gear[slot]
return a~=nil and a.id==item.id and a.rank==1
end

function c.mergeTarget(run,item)
for a=1,#run.gear do
if c.canMergeIncoming(run,a,item)then
return a
end
end
return nil
end

function c.mergeIncoming(run,slot)
run.gear[slot].rank=run.gear[slot].rank+1
end

function c.swap(run,a,b)
run.gear[a],run.gear[b]=run.gear[b],run.gear[a]
end

function c.moveLast(run,slot)
local a=table.remove(run.gear,slot)
run.gear[#run.gear+1]=a
end

function c.drop(run,slot)
table.remove(run.gear,slot)
run.hp=math.min(run.hp,c.maxHealth(run))
end

function c.drinkPotion(run)
for a=1,#run.bag do
if run.bag[a]=="HealingPotion"then
table.remove(run.bag,a)
local b=run.hp
run.hp=c.maxHealth(run)
run.healed=math.min(c.MAX_COUNT,run.healed+run.hp-b)
return true
end
end
return false
end
