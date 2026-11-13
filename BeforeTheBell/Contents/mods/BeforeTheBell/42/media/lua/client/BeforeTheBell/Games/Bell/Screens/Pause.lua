-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Screens/Settings"
require"BeforeTheBell/Games/Bell/Screens/World"

local a={}
BeforeTheBell.Bell.Pause=a

local c=BeforeTheBell.Bell
local b=c.Look
local d=c.Music
local f=c.Settings
local g=b.text

a.MENU={"resume","bag","compendium","options","save"}
a.MENU_KEYS={resume="Resume",bag="MenuBag",compendium="Compendium",options="Options",save="SaveQuit"}
a.COMPENDIUM={
{mark="life",name="Stat_hp",desc="CompDesc_hp"},
{mark="physical",name="Stat_atk",desc="CompDesc_atk"},
{mark="armor",name="Stat_arm",desc="CompDesc_arm"},
{mark="speed",name="Stat_spd",desc="CompDesc_spd"},
{mark="thorns",name="Stat_thorns",desc="CompDesc_thorns"},
{mark="poison",name="Stat_poison",desc="CompDesc_poison"},
{mark="bleed",name="Stat_bleed",desc="CompDesc_bleed"},
{mark="freeze",name="Stat_freeze",desc="CompDesc_freeze"},
{icon="coin",name="Comp_gold",desc="CompDesc_gold"},
{icon="sun",name="Comp_day",desc="CompDesc_day"},
{icon="moon",name="Comp_night",desc="CompDesc_night"},
{icon="steps",name="Comp_steps",desc="CompDesc_steps"},
}
a.COMP_TOP=16
a.COMP_LEFT=4
a.COMP_TEXT_X=16
a.COMP_ROW=b.step(10)
a.COMP_GAP=4
a.COMP_ARROW_X=170
a.OPTIONS={"music","effects","fast","back"}
a.OPTIONS_LOCKED={"music","effects","back"}
a.DIM=1
a.BOX_X=20
a.BOX_Y=16
a.BOX_W=140
a.BOX_H=94
a.ROWS_DY=15
a.ROW=b.step(13)
a.BELL_DX=8
a.TEXT_DX=20
a.VALUE_DX=8
a.SLIDER_RIGHT=8
a.PLATE_PAD=8
a.PLATE_H=13
a.PLATE_DY=-6

function a.enter(game,args)
game.view.page="menu"
game.view.selected=1
game.view.option=1
game.view.atOpen=f.snapshot(game)
end

local function l(game,screenModule)
f.saveIfChanged(game,game.view.atOpen)
game:open(screenModule)
end

local function o(game,input,index,size)
local e=input.pressed
if e.up or e.down then
game:effect(d.MOVE)
local h=1
if e.up then
h=-1
end
return(index-1+h+size)%size+1
end
return index
end

local function v(game,input)
local e=game.view
local i=input.pressed
e.selected=o(game,input,e.selected,#a.MENU)
if i.b or i.start then
game:effect(d.BACK)
l(game,c.World)
return
end
if not i.a then
return
end
game:effect(d.SELECT)
local h=a.MENU[e.selected]
if h=="resume"then
l(game,c.World)
elseif h=="bag"then
l(game,c.Bag)
elseif h=="compendium"then
e.page="compendium"
e.scroll=1
e.lastScroll=1
elseif h=="options"then
e.page="options"
e.option=1
else
f.saveIfChanged(game,e.atOpen)
game:saveAndQuit()
end
end

local function p(game)
if c.Profile.fastOpen(game.profile)then
return a.OPTIONS
end
return a.OPTIONS_LOCKED
end

local function z(game,input)
local e=game.view
local h=input.pressed
local j=p(game)
e.option=o(game,input,e.option,#j)
if h.start then
game:effect(d.BACK)
l(game,c.World)
return
end
local i=j[e.option]
if h.b or(h.a and i=="back")then
game:effect(d.BACK)
e.page="menu"
return
end
if i~="back"then
f.tick(game,input,i,d.ROAD)
end
end

local function A(game,input)
local e=game.view
local h=input.pressed
if h.b or h.a or h.start then
game:effect(d.BACK)
e.page="menu"
elseif h.up and e.scroll>1 then
e.scroll=e.scroll-1
game:effect(d.MOVE)
elseif h.down and e.scroll<e.lastScroll then
e.scroll=e.scroll+1
game:effect(d.MOVE)
end
end

function a.tick(game,input)
if game.view.page=="compendium"then
A(game,input)
elseif game.view.page=="options"then
z(game,input)
else
v(game,input)
end
end

local function q(screen,title,x,y,w)
local h=screen:textWidth(title)+2*a.PLATE_PAD+4
local i=x+math.floor((w-h)/2)
local e=y+a.PLATE_DY
screen:rect(i,e,h,a.PLATE_H,b.ink(2))
screen:rect(i,e,h,1,b.ink(4))
screen:rect(i,e+a.PLATE_H-1,h,1,b.ink(1))
b.rivet(screen,i+3,e+math.floor(a.PLATE_H/2))
b.rivet(screen,i+h-4,e+math.floor(a.PLATE_H/2))
screen:textCentre(title,x+math.floor(w/2),e-1,b.ink(4))
end

local function r(game,screen,x,y)
b.icon(screen,game.sheets,"bellmark",x,y+b.ICON_DY)
end

local function y(game,screen,x,top)
for e=1,#a.MENU do
local h=top+(e-1)*a.ROW
local i=3
if e==game.view.selected then
i=4
r(game,screen,x+a.BELL_DX,h)
end
screen:text(g(a.MENU_KEYS[a.MENU[e]]),x+a.TEXT_DX,h,b.ink(i))
end
end

local function B(game,screen,x,top,w)
local k=p(game)
for j=1,#k do
local h=k[j]
local e=top+(j-1)*a.ROW
local m=j==game.view.option
local i=3
if m then
i=4
r(game,screen,x+a.BELL_DX,e)
end
if h=="back"then
screen:text(g("Back"),x+a.TEXT_DX,e,b.ink(i))
else
screen:text(f.label(h),x+a.TEXT_DX,e,b.ink(i))
local n=x+w-a.SLIDER_RIGHT
if h=="fast"then
screen:textRight(f.speedValue(game),n,e,b.ink(i))
else
f.drawSlider(screen,n-f.SLIDER_W,e,game.options[h],m)
end
end
end
end

local function s(screen,entry)
return b.richWrap(screen,g(entry.desc),a.COMP_ARROW_X-a.COMP_TEXT_X-a.COMP_LEFT)
end

local function w(game,screen)
local m=game.view
screen:rect(0,0,screen.width,screen.height,b.ink(1))
screen:textCentre(g("CompendiumTitle"),math.floor(screen.width/2),-1,b.ink(4))
screen:rect(a.COMP_LEFT,a.COMP_TOP-3,screen.width-2*a.COMP_LEFT,1,b.ink(2))
local j={}
for e=1,#a.COMPENDIUM do
j[e]=(1+#s(screen,a.COMPENDIUM[e]))*a.COMP_ROW+a.COMP_GAP
end
local x=screen.height-a.COMP_TOP
local i,n=#a.COMPENDIUM,0
while i>=1 and n+j[i]<=x do
n=n+j[i]
i=i-1
end
m.lastScroll=math.max(1,i+1)
local e=a.COMP_TOP
local h=m.scroll
while h<=#a.COMPENDIUM and e+j[h]<=screen.height do
local k=a.COMPENDIUM[h]
if k.mark then
b.markLit(screen,game.sheets,k.mark,a.COMP_LEFT,e+b.ICON_DY,4)
else
b.icon(screen,game.sheets,k.icon,a.COMP_LEFT,e+b.ICON_DY)
end
screen:text(g(k.name),a.COMP_TEXT_X,e,b.ink(4))
local t=s(screen,k)
for u=1,#t do
b.richText(screen,game.sheets,t[u],a.COMP_TEXT_X,e+u*a.COMP_ROW,3)
end
e=e+j[h]
h=h+1
end
if m.scroll>1 then
b.markLit(screen,game.sheets,"up",a.COMP_ARROW_X,a.COMP_TOP,3)
end
if h<=#a.COMPENDIUM then
b.markLit(screen,game.sheets,"down",a.COMP_ARROW_X,screen.height-b.ICON-1,3)
end
end

function a.draw(game,screen)
if game.view.page=="compendium"then
w(game,screen)
return
end
local e,h,i,j=a.BOX_X,a.BOX_Y,a.BOX_W,a.BOX_H
c.World.drawLand(game,screen,a.DIM,{x=e,y=h,w=i,h=j})
b.plate(screen,e,h,i,j)
local k=h+a.ROWS_DY
if game.view.page=="options"then
q(screen,g("OptionsTitle"),e,h,i)
B(game,screen,e,k,i)
else
q(screen,g("Paused"),e,h,i)
y(game,screen,e,k)
end
end
