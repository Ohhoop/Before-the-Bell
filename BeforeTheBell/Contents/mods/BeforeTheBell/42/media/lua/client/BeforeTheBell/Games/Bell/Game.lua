-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Core/GameBase"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Map"
require"BeforeTheBell/Games/Bell/Rules/Challenges"
require"BeforeTheBell/Games/Bell/Screens/Camp"
require"BeforeTheBell/Games/Bell/Screens/World"
require"BeforeTheBell/Games/Bell/Screens/Battle"
require"BeforeTheBell/Games/Bell/Screens/Offer"
require"BeforeTheBell/Games/Bell/Screens/Bag"
require"BeforeTheBell/Games/Bell/Screens/Settings"
require"BeforeTheBell/Games/Bell/Screens/Pause"
require"BeforeTheBell/Games/Bell/Screens/Notice"
require"BeforeTheBell/Games/Bell/Screens/Chest"
require"BeforeTheBell/Games/Bell/Screens/Tent"
require"BeforeTheBell/Games/Bell/Screens/Dummy"

BeforeTheBellBellGame=SpiffBoyGameBase:derive("BeforeTheBellBellGame")

local a=BeforeTheBell.Bell
local g=a.Music
local k=a.Look
local b=a.Profile
local c=a.Run
local h=a.Map
local j=a.Challenges
local e=k.text
local r={up=false,down=false,left=false,right=false,a=false,b=false,start=false}

local function s(quiet)
return quiet.source:axes()
end

local l={pressed=r,axes=s}

function BeforeTheBellBellGame:init()
self.sheets=k.load(self.context)
self.profile=b.read(self.save)
self.options=b.readOptions(self.save)
self:applyMix()
self.tune=nil
self.saved=b.readRun(self.save)
self.ticks=0
self:open(a.Camp)
end

function BeforeTheBellBellGame:open(screenModule,args)
self.screenModule=screenModule
self.view={}
screenModule.enter(self,args or{})
end

function BeforeTheBellBellGame:playMusic(name)
if self.options.music==0 then
self.tune=nil
self.sequencer:stop()
return
end
if self.tune~=name then
self.tune=name
self.sequencer:play(name)
end
end

function BeforeTheBellBellGame:stopMusic()
self.tune=nil
self.sequencer:stop()
end

function BeforeTheBellBellGame:applyMix()
self.sequencer:setMix(self.options.music/b.LEVELS,self.options.effects/b.LEVELS)
end

function BeforeTheBellBellGame:setLevel(kind,level,name)
self.options[kind]=level
self:applyMix()
if kind=="music"then
self:playMusic(name)
end
end

function BeforeTheBellBellGame:effect(name)
self.sequencer:effect(name)
end

function BeforeTheBellBellGame:tick(inputs,tick)
self.ticks=self.ticks+1
local f=inputs[1]
local d=self.screenModule
d.tick(self,f)
if self.options.fast and b.fastOpen(self.profile)and self.screenModule==d and(d==a.World or d==a.Battle)then
l.held=f.held
l.source=f
d.tick(self,l)
end
end

function BeforeTheBellBellGame:draw(screen)
screen:clear(k.ink(4))
self.screenModule.draw(self,screen)
end

function BeforeTheBellBellGame:startRun(heroId,tier)
local d=nil
if b.dummyOpen(self.profile)and self.profile.training~=a.Cast.NONE then
d=self.profile.training
end
local f=nil
if b.tentOpen(self.profile)and self.profile.tent~=a.Cast.NONE then
f=self.profile.tent
end
self.run=c.new(heroId,tier,h.newSeed(self.random),d,f)
self.saved=nil
self:openDawn()
end

function BeforeTheBellBellGame:continueRun()
if b.holdsLand(self.save)then
local d=b.readLand(self.save,self.saved)
if d==nil then
error("Before the Bell: the land saved with the run does not fit the land of its seed")
end
self.run=self.saved
self.map=d
self.saved=nil
self:open(a.World)
return
end
self.run=self.saved
self.saved=nil
self:openDawn()
end

function BeforeTheBellBellGame:openDawn()
local f=self.run
local d={e("DawnLine")}
if self.dawnGain and self.dawnGain.hp>0 then
d[#d+1]=e("DawnHeal_"..self.dawnGain.source,self.dawnGain.hp)
self:effect(g.HEAL)
end
if self.dawnGain and self.dawnGain.gold>0 then
d[#d+1]=e("DawnGold",self.dawnGain.gold)
self:effect(g.COIN)
end
if self.dawnGain and self.dawnGain.stat then
d[#d+1]=e("DawnStat_"..self.dawnGain.stat)
self:effect(g.BLESS)
end
self.dawnGain=nil
self:open(a.Notice,{
kind="text",
title=e("Dawn",f.day),
lines=d,
picture="dawn",
onConfirm="confirmDawn",
})
end

function BeforeTheBellBellGame:confirmDawn()
self.run.daySeed=h.newSeed(self.random)
b.writeRun(self.save,self.run)
b.write(self.save,self.profile)
self:persist()
self:startDay()
end

function BeforeTheBellBellGame:startDay()
self.map=h.generate(SpiffBoyRandom.new(self.run.daySeed),self.run.mapSeed,self.run.act,self.run.day,c.rules(self.run),self.run.blessedAct==self.run.act,c.firstChest(self.run))
self:effect(g.DAWN)
self:open(a.World)
end

function BeforeTheBellBellGame:startFight(definition,kind,mapFoe,place)
self.run.lastFoe=definition.id
local d=0
if mapFoe then
d=mapFoe.wound
end
local f=c.fight(self.run,definition,kind,d)
c.rollGold(f,self.random)
self:open(a.Battle,{result=f,definition=definition,kind=kind,mapFoe=mapFoe,place=place})
end

local function i(items,heroes)
local d={}
for f=1,#items do
d[#d+1]={kind="item",id=items[f]}
end
for f=1,#heroes do
d[#d+1]={kind="hero",id=heroes[f]}
end
return d
end

function BeforeTheBellBellGame:announce(entries,after)
if#entries==0 then
self[after](self)
return
end
self:effect(g.WIN)
self:open(a.Notice,{
kind="list",
title=e("Unlocked"),
entries=entries,
onConfirm=after,
})
end

function BeforeTheBellBellGame:backToLand()
c.keepUnlocks(self.run,i(j.onLand(self.profile,self.run),{}))
self:open(a.World)
end

function BeforeTheBellBellGame:afterFight(args)
local d=args.result
c.settle(self.run,d)
local f=i(j.afterFight(self.profile,self.run,d,self.map.phase==h.NIGHT),{})
if d.won and b.foeBeaten(self.profile)then
f[#f+1]={kind="dummy"}
end
c.keepUnlocks(self.run,f)
self:afterAnnounce(args)
end

function BeforeTheBellBellGame:afterAnnounce(args)
local f=args.result
if not f.won then
self:endRun(false)
return
end
if args.kind=="roamer"then
h.removeFoe(self.map,args.mapFoe)
if args.place then
self:effect(g.SELECT)
self:open(a.Offer,{place=args.place})
return
end
self:open(a.World)
return
end
local d={}
if args.kind=="boss"then
local m=b.tentOpen(self.profile)
d=i(b.bossBeaten(self.profile,self.run.act,self.run.tier))
if not m and b.tentOpen(self.profile)then
d[#d+1]={kind="tent"}
end
end
c.keepUnlocks(self.run,d)
local m,n,o,p=c.rest(self.run,self.random)
self.dawnGain={hp=m,gold=n,source=o,stat=p}
if c.advance(self.run)then
self:endRun(true)
return
end
self:openDawn()
end

function BeforeTheBellBellGame:endRun(won)
local t,u=b.markSlots(self.profile)
local v=b.runFinished(self.profile)
local w,x=b.markSlots(self.profile)
local f=self.run
local d={}
c.keepUnlocks(f,i(j.runEnded(self.profile,f,won),{}))
for m=1,#f.unlocks do
d[#d+1]=f.unlocks[m]
end
if v then
d[#d+1]={kind="chest"}
end
if w>t then
d[#d+1]={kind="mark",id="ban"}
end
if x>u then
d[#d+1]={kind="mark",id="favor"}
end
local o=e("Fallen")
local p=f.lastFoe
if won then
o=e("Victory")
p=nil
local y,m=b.runWon(self.profile,f.tier)
local q=i({},y)
for n=1,#q do
d[#d+1]=q[n]
end
if m then
d[#d+1]={kind="tier",id=a.Cast.tiers[m+1].id}
for z=1,#a.Items.list do
local n=a.Items.list[z]
if n.pool==a.Items.TIER and n.wonTier==m-1 then
d[#d+1]={kind="item",id=n.id}
end
end
end
self:effect(g.WIN)
end
local m={won=won,hero=f.hero,act=f.act,day=f.day,kills=f.kills,gold=f.gold,killer=p}
self.run=nil
self.map=nil
self:open(a.Notice,{
kind="summary",
title=o,
summary=m,
onConfirm="announceRunEnd",
confirmWith=d,
})
end

function BeforeTheBellBellGame:announceRunEnd(entries)
self:announce(entries,"closeRun")
end

function BeforeTheBellBellGame:closeRun()
b.clearRun(self.save)
b.write(self.save,self.profile)
self:persist()
self:open(a.Camp)
end

function BeforeTheBellBellGame:nightfall()
c.keepUnlocks(self.run,i(j.onNightfall(self.profile,self.map),{}))
self:openNight()
end

function BeforeTheBellBellGame:openNight()
self:effect(g.NIGHT)
self:open(a.Notice,{
kind="text",
title=e("Night"),
lines={e("NightLine",h.NIGHT_STEPS)},
picture="night",
onConfirm="beginNight",
})
end

function BeforeTheBellBellGame:beginNight()
h.startNight(self.map)
self.run.nightHurt=false
self:open(a.World)
end

function BeforeTheBellBellGame:nightEnds()
local f,m=c.nightFoe(self.run)
local d=e("Hunted")
if m=="boss"then
d=e("BellTolls")
end
self:effect(g.NIGHT)
self:open(a.Notice,{
kind="foe",
title=d,
foe=f.id,
act=self.run.act,
day=self.run.day,
onConfirm="fightNightFoe",
})
end

function BeforeTheBellBellGame:fightNightFoe()
local d,f=c.nightFoe(self.run)
self:startFight(d,f,nil)
end

function BeforeTheBellBellGame:phaseEnds()
if self.map.phase==h.DAY then
self:nightfall()
else
self:nightEnds()
end
end

function BeforeTheBellBellGame:resetProgress()
b.clear(self.save)
self.profile=b.read(self.save)
self.saved=nil
self:persist()
end

function BeforeTheBellBellGame:saveAndQuit()
b.writeRunOnLand(self.save,self.run,self.map)
b.write(self.save,self.profile)
self:persist()
self.saved=b.readRun(self.save)
self.run=nil
self.map=nil
self:open(a.Camp)
end
