-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Screens/Settings"
require"BeforeTheBell/Games/Bell/Screens/Chest"

local a={}
BeforeTheBell.Bell.Camp=a

local b=BeforeTheBell.Bell.Look
local d=BeforeTheBell.Bell.Music
local g=BeforeTheBell.Bell.Cast
local f=BeforeTheBell.Bell.Profile
local j=BeforeTheBell.Bell.Settings
local c=b.text

a.SLOTS={{30,70},{56,62},{108,62},{134,70},{44,84},{120,84}}
a.FIRE_X=84
a.FIRE_SPOT={83,56}
a.WALK_TICKS=24
a.STEP_TICKS=4
a.FIDGET_EVERY=180
a.FIDGET_TICKS=40
a.FIDGET_STEP=10
a.CHEST=7
a.DUMMY=8
a.TENT=9
a.TENT_X=2
a.TENT_Y=40
a.DUMMY_X=162
a.DUMMY_Y=58
a.ROW=b.step(10)
a.PANEL_ROW=b.step(10)
a.YES=1
a.NO=2
a.CHEST_X=8
a.CHEST_Y=72
a.FIRE_Y=73
a.FIRE_TICKS=8
a.BOB_TICKS=20
a.PANEL_Y=100
a.MENU_Y=22
a.SKY_SHIFT=40
a.PAN_STEP=2
a.MENU_STEP=13
a.BELL_FRAMES=8
a.BELL_W=15
a.BELL_H=12
a.RING_TICKS=48
a.RING_SWING=6
a.FADE_TICKS=10
a.FADE_STEPS=4
a.BELL_GAP=1
a.SETTING_GAP=8
a.TIER_ARROW_GAP=3
a.TIER_ARROW_Y=3
a.MARK_SLOT=9
a.MARK_EDGE=4
a.MARK_LABEL_GAP=4
a.MARK_TEXT_DY=0

local function u(game)
local e={}
if game.saved then
e[#e+1]="continue"
end
e[#e+1]="new"
e[#e+1]="options"
return e
end

local function v(game)
if f.fastOpen(game.profile)then
return{"music","effects","fast","reset"}
end
return{"music","effects","reset"}
end

local function k(view)
if view.phase=="question"then
return view.question.back
end
return view.phase
end

function a.enter(game,args)
local e=game.view
game:playMusic(d.CAMP)
e.hero=1
e.tier=game.profile.tier
e.menu=1
e.option=1
e.phase="menu"
e.shift=a.SKY_SHIFT
e.spot=nil
e.walk=0
if args.party then
e.hero=args.party.hero
e.tier=args.party.tier
e.phase="prepare"
e.shift=0
e.walk=a.WALK_TICKS
end
if args.chest then
e.spot=a.CHEST
end
if args.tent then
e.spot=a.TENT
end
if args.dummy then
e.spot=a.DUMMY
end
e.ring=nil
e.fade=nil
e.question=nil
end

local function p(game)
local e={}
if f.chestOpen(game.profile)then
e[#e+1]=a.CHEST
end
if f.tentOpen(game.profile)then
e[#e+1]=a.TENT
end
if f.dummyOpen(game.profile)then
e[#e+1]=a.DUMMY
end
e[#e+1]=game.view.hero
return e
end

local function n(index,step,size)
return(index-1+step+size)%size+1
end

local function w(game,input,index,size)
if input.pressed.up then
game:effect(d.MOVE)
return n(index,-1,size)
end
if input.pressed.down then
game:effect(d.MOVE)
return n(index,1,size)
end
return index
end

local function E(game,input)
local e=game.view
local i=u(game)
e.menu=w(game,input,e.menu,#i)
if not(input.pressed.a or input.pressed.start)then
return
end
local h=i[e.menu]
if h=="continue"or h=="new"then
game:effect(d.RING)
e.ring={ticks=0,entry=h}
return
end
game:effect(d.SELECT)
e.phase="options"
e.option=1
e.optionsAtOpen=j.snapshot(game)
end

local function F(game)
local e=game.view
if e.fade then
e.fade=e.fade+1
if e.fade>=a.FADE_TICKS*a.FADE_STEPS then
game:continueRun()
end
return
end
e.ring.ticks=e.ring.ticks+1
if e.ring.ticks<a.RING_TICKS then
return
end
if e.ring.entry=="new"then
e.ring=nil
e.phase="pick"
else
e.fade=0
end
end

local function q(game,lines,onYes,back)
local e=game.view
e.question={lines=lines,choice=a.NO,onYes=onYes,back=back}
e.phase="question"
end

local function G(game)
local e=game.view
game:resetProgress()
game:effect(d.SELECT)
e.menu=1
e.tier=game.profile.tier
end

local function H(game)
q(game,{c("ResetLine"),c("ResetAsk")},"resetProgress","options")
end

local function I(game,input)
local e=game.view
local h=v(game)
e.option=w(game,input,e.option,#h)
local i=h[e.option]
if input.pressed.b or input.pressed.start then
j.saveIfChanged(game,e.optionsAtOpen)
game:effect(d.BACK)
e.phase="menu"
elseif i=="reset"then
if input.pressed.a then
game:effect(d.SELECT)
H(game)
end
else
j.tick(game,input,i,d.CAMP)
end
end



local function z(game)
local e=game.view
game:effect(d.SELECT)
game:startRun(g.heroes[e.hero].id,e.tier)
end

local function A(game)
if game.saved then
q(game,{c("Abandon")},"setOut",game.view.phase)
return
end
z(game)
end

local J={resetProgress=G,setOut=z,askAbandon=A}

local function K(game)
local e=game.profile
local h={}
if f.dummyOpen(e)and e.training==nil then
h[#h+1]=c("DummyIdle")
end
if f.tentOpen(e)and e.tent==nil then
h[#h+1]=c("TentIdle")
end
local i,l=f.markSlots(e)
if i>0 and(#e.marks.ban<i or#e.marks.favor<l)then
h[#h+1]=c("ChestFree")
end
return h
end

local function B(game)
local e=K(game)
if#e==0 then
A(game)
return
end
e[#e+1]=c("SetOutAnyway")
q(game,e,"askAbandon",game.view.phase)
end

local function L(game,input)
local e=game.view
local h=input.pressed
if h.left or h.right then
local i=1
if h.left then
i=-1
end
e.hero=n(e.hero,i,#g.heroes)
game:effect(d.MOVE)
elseif h.up and e.tier<game.profile.tier then
e.tier=e.tier+1
game:effect(d.MOVE)
elseif h.down and e.tier>0 then
e.tier=e.tier-1
game:effect(d.MOVE)
end
if h.b then
e.phase="menu"
game:effect(d.BACK)
return
end
if h.a or h.start then
local i=g.heroes[e.hero]
if not f.heroOpen(game.profile,i.id)then
game:effect(d.BUMP)
elseif#p(game)>1 then
e.phase="prepare"
e.spot=p(game)[1]
game:effect(d.SELECT)
else
game:effect(d.MOVE)
B(game)
end
end
end

local function M(game,input)
local e=game.view
local h=input.pressed
if h.left or h.right then
local l=1
if h.left then
l=-1
end
local i=p(game)
local m=1
for o=1,#i do
if i[o]==e.spot then
m=o
end
end
e.spot=i[n(m,l,#i)]
game:effect(d.MOVE)
end
if h.b then
e.phase="pick"
e.spot=nil
game:effect(d.BACK)
return
end
if not(h.a or h.start)then
return
end
local i={hero=e.hero,tier=e.tier}
if e.spot==a.DUMMY then
game:effect(d.SELECT)
game:open(BeforeTheBell.Bell.Dummy,{party=i})
elseif e.spot==a.TENT then
game:effect(d.SELECT)
game:open(BeforeTheBell.Bell.Tent,{party=i})
elseif e.spot==a.CHEST then
game:effect(d.SELECT)
game:open(BeforeTheBell.Bell.Chest,{party=i})
else
game:effect(d.MOVE)
B(game)
end
end

local function N(game,input)
local h=game.view
local e=h.question
local i=input.pressed
if i.left or i.right then
e.choice=a.YES+a.NO-e.choice
game:effect(d.MOVE)
elseif i.a and e.choice==a.YES then
h.question=nil
h.phase=e.back
J[e.onYes](game)
elseif i.a or i.b then
h.question=nil
h.phase=e.back
game:effect(d.BACK)
end
end

function a.tick(game,input)
local e=game.view
local h=0
local l=k(e)
if l=="menu"or l=="options"then
h=a.SKY_SHIFT
end
if e.shift<h then
e.shift=math.min(h,e.shift+a.PAN_STEP)
elseif e.shift>h then
e.shift=math.max(h,e.shift-a.PAN_STEP)
end
if l=="prepare"then
e.walk=math.min(a.WALK_TICKS,e.walk+1)
else
e.walk=math.max(0,e.walk-1)
end
local i=e.phase
if e.ring then
F(game)
return
end
if i=="menu"then
E(game,input)
elseif i=="options"then
I(game,input)
elseif i=="pick"then
if e.shift==0 then
L(game,input)
end
elseif i=="prepare"then
M(game,input)
else
N(game,input)
end
end

local function O(game,screen,dim)
local e=game.view
for i=1,#g.heroes do
local h=a.SLOTS[i]
local m=h[2]+e.shift
if not f.heroOpen(game.profile,g.heroes[i].id)then
b.layers(screen,game.sheets.heroes,(i-1+2*b.HERO_COUNT)*b.HERO,b.HERO,b.HERO,h[1],m,{1},dim)
elseif i==e.hero and(k(e)=="pick"or k(e)=="prepare")then
local o=e.walk/a.WALK_TICKS
local s=math.floor(h[1]+(a.FIRE_SPOT[1]-h[1])*o+0.5)
local t=math.floor(h[2]+(a.FIRE_SPOT[2]-h[2])*o+0.5)+e.shift
local l=math.floor(game.ticks/a.BOB_TICKS)%2
if e.walk>0 and e.walk<a.WALK_TICKS then
l=math.floor(game.ticks/a.STEP_TICKS)%2
elseif e.walk==a.WALK_TICKS then
local r=game.ticks%a.FIDGET_EVERY
l=0
if r<a.FIDGET_TICKS then
l=math.floor(r/a.FIDGET_STEP)%2
end
end
b.walker(screen,game.sheets,i,s,t-l,dim)
else
b.layers(screen,game.sheets.heroes,(i-1+b.HERO_COUNT)*b.HERO,b.HERO,b.HERO,h[1],m,b.ALL_SHADES,dim)
end
end
end

local function r(game,screen,name,line)
local h=math.floor(screen.width/2)
local e=a.PANEL_Y-b.lift(screen,a.PANEL_Y-1,2,a.PANEL_ROW)
b.panel(screen,e,screen.height-e)
screen:textCentre("< "..name.." >",h,e-1,b.ink(4))
b.richCentre(screen,game.sheets,line,h,e-1+a.PANEL_ROW,3)
end

local function C(screen,mark,used,x,y,size)
if not used then
screen:rect(x,y,size,size,b.ink(2))
screen:rect(x+1,y+1,size-2,size-2,b.ink(3))
return
end
screen:rect(x,y,size,size,b.ink(1))
screen:rect(x+1,y+1,size-2,size-2,b.ink(4))
local h=size-4
if mark=="ban"then
for e=0,h-1 do
screen:rect(x+2+e,y+2+e,1,1,b.ink(1))
screen:rect(x+1+h-e,y+2+e,1,1,b.ink(1))
end
else
local i=x+math.floor(size/2)
for e=0,2 do
screen:rect(i-e,y+3+e,2*e+1,1,b.ink(1))
end
end
end

local function P(game,screen)
r(game,screen,c("CampChest"),"")
local h=game.profile
local m,o=f.markSlots(h)
local Q=BeforeTheBell.Bell.Chest
local e=a.MARK_SLOT
local s=e+Q.SLOT_GAP
local t=a.PANEL_Y-b.lift(screen,a.PANEL_Y-1,2,a.PANEL_ROW)-1+screen:lineHeight()
local i=t+math.floor((screen.height-t-e)/2)
local x=i+math.floor((e-screen:lineHeight())/2)+a.MARK_TEXT_DY
if m>0 then
local y=c("CampMark_ban")
screen:text(y,a.MARK_EDGE,x,b.ink(3))
local l=a.MARK_EDGE+screen:textWidth(y)+a.MARK_LABEL_GAP
for D=1,m do
C(screen,"ban",D<=#h.marks.ban,l,i,e)
l=l+s
end
end
if o>0 then
local y=c("CampMark_favor")
local D=screen.width-a.MARK_EDGE
screen:textRight(y,D,x,b.ink(3))
local l=D-screen:textWidth(y)-a.MARK_LABEL_GAP-e
for R=1,o do
C(screen,"favor",R<=#h.marks.favor,l,i,e)
l=l-s
end
end
end

local function Q(game,screen)
local e=c("TrainingNone")
if game.profile.training==g.NONE then
e=c("TrainingOff")
elseif game.profile.training then
e=c("Training_"..game.profile.training)
end
r(game,screen,c("TrainingDummy"),e)
end

local function R(game,screen)
local e=c("Tent_none")
local h=BeforeTheBell.Bell.Run
if game.profile.tent==g.NONE then
e=c("Tent_off")
elseif game.profile.tent=="rest"then
e=c("Tent_rest",h.REST_MIN,h.REST_MAX)
elseif game.profile.tent=="forage"then
e=c("Tent_forage",h.FORAGE_MIN,h.FORAGE_MAX)
end
r(game,screen,c("Tent"),e)
end

local function x(game,screen)
local h=game.view.question
local i=math.floor(screen.width/2)
local m=#h.lines+1
local e=screen.height-m*a.ROW-2
e=e-b.lift(screen,e-1,m,a.ROW)
b.panel(screen,e,screen.height-e)
for l=1,#h.lines do
local o=3
if l==#h.lines then
o=4
end
screen:textCentre(h.lines[l],i,e-1+(l-1)*a.ROW,b.ink(o))
end
local l=e-1+#h.lines*a.ROW
local o,s=2,2
if h.choice==a.YES then
o=4
else
s=4
end
local t=math.floor(screen.width/4)
screen:textCentre(c("Yes"),i-t,l,b.ink(o))
screen:textCentre(c("No"),i+t,l,b.ink(s))
end

local function S(game,screen)
local h=game.view
local l=math.floor(screen.width/2)
if h.spot==a.CHEST then
P(game,screen)
return
end
if h.spot==a.DUMMY then
Q(game,screen)
return
end
if h.spot==a.TENT then
R(game,screen)
return
end
local e=g.heroes[h.hero]
local i=a.PANEL_Y-b.lift(screen,a.PANEL_Y-1,2,a.PANEL_ROW)
b.panel(screen,i,screen.height-i)
local m=c("Hero_"..e.id)
if not f.heroOpen(game.profile,e.id)then
m=c("Unknown")
end
screen:textCentre("< "..m.." >",l,i-1,b.ink(4))
local o=c("Passive_"..e.id)
if not f.heroOpen(game.profile,e.id)then
o=c("Opens_"..e.id)
end
b.richCentre(screen,game.sheets,o,l,i-1+a.PANEL_ROW,3)
end

local function T(game,entry)
if entry=="continue"then return c("Continue")end
if entry=="new"then return c("NewRun")end
if entry=="options"then return c("Options")end
return c("ResetProgress")
end

local function U(entry)
return entry=="music"or entry=="effects"or entry=="fast"
end

local function V(game,screen)
local h=game.view
local s,m=u(game),h.menu
if k(h)=="options"then
s,m=v(game),h.option
end
local y=math.floor(screen.width/2)
for i=1,#s do
local l=s[i]
local o=a.MENU_Y+(i-1)*a.MENU_STEP
local t=3
if i==m then
t=4
end
local e
if U(l)then
local D=j.label(l)
e=y-math.floor(j.rowWidth(screen,game,l,a.SETTING_GAP)/2)
screen:text(D,e,o,b.ink(t))
j.drawValue(game,screen,l,e+screen:textWidth(D)+a.SETTING_GAP,o,i==m)
else
local D=T(game,l)
e=y-math.floor(screen:textWidth(D)/2)
screen:text(D,e,o,b.ink(t))
end
if i==m then
local D=0
if h.ring then
D=math.floor(h.ring.ticks/a.RING_SWING)%a.BELL_FRAMES
end
screen:layers(game.sheets.bell,D*a.BELL_W,a.BELL_W,a.BELL_H,e-a.BELL_W-a.BELL_GAP,o+1,b.ICON_SHADES)
end
end
end

function a.draw(game,screen)
local e=game.view
local i=game.sheets
local l=math.floor(screen.width/2)
local m=e.shift
local h=0
if e.fade then
h=math.floor(e.fade/a.FADE_TICKS)+1
if h>=a.FADE_STEPS then
screen:rect(0,0,screen.width,screen.height,b.ink(1))
return
end
end
b.layers(screen,i.camp,0,screen.width,screen.height+a.SKY_SHIFT,0,m-a.SKY_SHIFT,b.ALL_SHADES,h)
if f.tentOpen(game.profile)then
local o=0
if e.phase=="prepare"and e.spot==a.TENT then
o=math.floor(game.ticks/a.BOB_TICKS)%2
end
b.layers(screen,i.tent,0,b.TENT_W,b.TENT_H,a.TENT_X,a.TENT_Y+m-o,b.ALL_SHADES,h)
end
local y=math.floor(game.ticks/a.FIRE_TICKS)%4
b.layers(screen,i.fire,y*b.FIRE_W,b.FIRE_W,b.FIRE_H,a.FIRE_X,a.FIRE_Y+m,b.ALL_SHADES,h)
O(game,screen,h)
if f.chestOpen(game.profile)then
local o=0
if e.phase=="prepare"and e.spot==a.CHEST then
o=math.floor(game.ticks/a.BOB_TICKS)%2
end
b.tile(screen,i,"chest",a.CHEST_X,a.CHEST_Y+m-o,h)
end
if f.dummyOpen(game.profile)then
local o=0
if e.phase=="prepare"and e.spot==a.DUMMY then
o=math.floor(game.ticks/a.BOB_TICKS)%2
end
b.layers(screen,i.dummy,0,b.DUMMY_W,b.DUMMY_H,a.DUMMY_X,a.DUMMY_Y+m-o,b.ALL_SHADES,h)
end
if e.fade then
return
end
local o=k(e)
if o=="menu"or o=="options"then
screen:textCentre(c("Title"),l,0,b.ink(4))
V(game,screen)
if e.phase=="question"then
x(game,screen)
end
return
end
if game.profile.tier>0 then
local s=c("Tier_"..g.tiers[e.tier+1].id)
local t=screen:textWidth(s)/2
screen:textCentre(s,l,0,b.ink(4))
if o=="pick"then
b.markLit(screen,i,"up",math.floor(l-t)-a.TIER_ARROW_GAP-b.ICON,a.TIER_ARROW_Y)
b.markLit(screen,i,"down",math.ceil(l+t)+a.TIER_ARROW_GAP,a.TIER_ARROW_Y)
end
else
screen:textCentre(c("Title"),l,0,b.ink(4))
end
if e.phase=="question"then
x(game,screen)
return
end
if e.shift==0 then
S(game,screen)
end
end
