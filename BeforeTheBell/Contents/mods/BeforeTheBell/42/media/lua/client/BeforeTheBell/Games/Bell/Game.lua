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
local d=a.Run
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
local c=self.screenModule
c.tick(self,f)
if self.options.fast and b.fastOpen(self.profile)and self.screenModule==c and(c==a.World or c==a.Battle)then
l.held=f.held
l.source=f
c.tick(self,l)
end
end

function BeforeTheBellBellGame:draw(screen)
screen:clear(k.ink(4))
self.screenModule.draw(self,screen)
end

function BeforeTheBellBellGame:startRun(heroId,tier)
local c=nil
if b.dummyOpen(self.profile)and self.profile.training~=a.Cast.NONE then
c=self.profile.training
end
local f=nil
if b.tentOpen(self.profile)and self.profile.tent~=a.Cast.NONE then
f=self.profile.tent
end
self.run=d.new(heroId,tier,h.newSeed(self.random),c,f)
self.saved=nil
self:openDawn()
end

function BeforeTheBellBellGame:continueRun()
self.run=self.saved
self.saved=nil
self:openDawn()
end

function BeforeTheBellBellGame:openDawn()
local f=self.run
local c={e("DawnLine")}
if self.dawnGain and self.dawnGain.hp>0 then
c[#c+1]=e("DawnHeal_"..self.dawnGain.source,self.dawnGain.hp)
self:effect(g.HEAL)
end
if self.dawnGain and self.dawnGain.gold>0 then
c[#c+1]=e("DawnGold",self.dawnGain.gold)
self:effect(g.COIN)
end
if self.dawnGain and self.dawnGain.stat then
c[#c+1]=e("DawnStat_"..self.dawnGain.stat)
self:effect(g.BLESS)
end
self.dawnGain=nil
self:open(a.Notice,{
kind="text",
title=e("Dawn",f.day),
lines=c,
picture="dawn",
onConfirm="confirmDawn",
})
end

function BeforeTheBellBellGame:confirmDawn()
local c={run=self.save.run,profile=self.save.profile}
b.writeRun(self.save,self.run)
b.write(self.save,self.profile)
if not b.same(c,{run=self.save.run,profile=self.save.profile})then
self:persist()
end
self:startDay()
end

function BeforeTheBellBellGame:startDay()
local c=self.run.tier==0 and self.run.act==1 and self.run.day==1
self.map=h.generate(self.random,self.run.mapSeed,self.run.act,self.run.day,d.rules(self.run),self.run.blessedAct==self.run.act,c)
self:effect(g.DAWN)
self:open(a.World)
end

function BeforeTheBellBellGame:startFight(definition,kind,mapFoe,place)
self.run.lastFoe=definition.id
local c=0
if mapFoe then
c=mapFoe.wound
end
local f=d.fight(self.run,definition,kind,c)
d.rollGold(f,self.random)
self:open(a.Battle,{result=f,definition=definition,kind=kind,mapFoe=mapFoe,place=place})
end

local function i(items,heroes)
local c={}
for f=1,#items do
c[#c+1]={kind="item",id=items[f]}
end
for f=1,#heroes do
c[#c+1]={kind="hero",id=heroes[f]}
end
return c
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
d.keepUnlocks(self.run,i(j.onLand(self.profile,self.run),{}))
self:open(a.World)
end

function BeforeTheBellBellGame:afterFight(args)
local c=args.result
d.settle(self.run,c)
local f=i(j.afterFight(self.profile,self.run,c,self.map.phase==h.NIGHT),{})
if c.won and b.foeBeaten(self.profile)then
f[#f+1]={kind="dummy"}
end
d.keepUnlocks(self.run,f)
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
local c={}
if args.kind=="boss"then
local m=b.tentOpen(self.profile)
c=i(b.bossBeaten(self.profile,self.run.act,self.run.tier))
if not m and b.tentOpen(self.profile)then
c[#c+1]={kind="tent"}
end
end
d.keepUnlocks(self.run,c)
local m,n,o,p=d.rest(self.run,self.random)
self.dawnGain={hp=m,gold=n,source=o,stat=p}
if d.advance(self.run)then
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
local c={}
d.keepUnlocks(f,i(j.runEnded(self.profile,f,won),{}))
for m=1,#f.unlocks do
c[#c+1]=f.unlocks[m]
end
if v then
c[#c+1]={kind="chest"}
end
if w>t then
c[#c+1]={kind="mark",id="ban"}
end
if x>u then
c[#c+1]={kind="mark",id="favor"}
end
local o=e("Fallen")
local p=f.lastFoe
if won then
o=e("Victory")
p=nil
local y,m=b.runWon(self.profile,f.tier)
local q=i({},y)
for n=1,#q do
c[#c+1]=q[n]
end
if m then
c[#c+1]={kind="tier",id=a.Cast.tiers[m+1].id}
for z=1,#a.Items.list do
local n=a.Items.list[z]
if n.pool==a.Items.TIER and n.wonTier==m-1 then
c[#c+1]={kind="item",id=n.id}
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
confirmWith=c,
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
d.keepUnlocks(self.run,i(j.onNightfall(self.profile,self.map),{}))
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
local f,m=d.nightFoe(self.run)
local c=e("Hunted")
if m=="boss"then
c=e("BellTolls")
end
self:effect(g.NIGHT)
self:open(a.Notice,{
kind="foe",
title=c,
foe=f.id,
act=self.run.act,
day=self.run.day,
onConfirm="fightNightFoe",
})
end

function BeforeTheBellBellGame:fightNightFoe()
local c,f=d.nightFoe(self.run)
self:startFight(c,f,nil)
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
self.saved=b.readRun(self.save)
self.run=nil
self.map=nil
self:open(a.Camp)
end
