-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Profile"

local a={}
BeforeTheBell.Bell.Dummy=a

local d=BeforeTheBell.Bell
local b=d.Look
local e=d.Music
local f=d.Cast
local p=d.Profile
local i=b.text

a.SPLIT=86
a.YARD_W=93
a.TOP_H=14
a.BOX_X=3
a.BOX_Y=20
a.BOX_H=17
a.BOX_GAP=4
a.TEXT_DY=1
a.KEYS_Y=105
a.BIG_W=48
a.BIG_H=60
a.BIG_X=109
a.BIG_Y=39
a.FRAMES={[0]=0,[1]=1,[2]=2,[3]=3,[4]=4,[-1]=5,[-2]=6}
a.STEP_TICKS=3
a.TARGET_X=133
a.TARGET_Y=69
a.SPOTS={{0,0},{-4,-6},{3,5},{5,-3},{-3,3}}
a.HITS={
atk={period=30,leans={3,2,1,-1,0},spark="slash",sound="HIT"},
arm={period=46,leans={4,4,3,2,1,-2,-1,0},spark="burst",sound="CLANG"},
spd={period=12,leans={2,1,0},spark="tap",sound="HIT"},
}
a.SPARK_STEPS=2
a.STRAW_STEPS=4

local function h()
local c={f.NONE}
for g=1,#f.TRAINING do
c[#c+1]=f.TRAINING[g]
end
return c
end

function a.enter(game,args)
local c=game.view
local g=h()
c.party=args.party
c.selected=1
for j=1,#g do
if g[j]==game.profile.training then
c.selected=j
end
end
c.trainingAtOpen=game.profile.training
c.hitStart=game.ticks
end

local function k(game)
local c=game.profile.training
if c==nil or c==f.NONE then
return nil
end
local g=a.HITS[c]
local j=game.ticks-game.view.hitStart
return g,math.floor((j%g.period)/a.STEP_TICKS),math.floor(j/g.period)
end

function a.tick(game,input)
local c=game.view
local g=input.pressed
local j=k(game)
if j and(game.ticks-c.hitStart)%j.period==0 then
game:effect(e[j.sound])
end
if g.up and c.selected>1 then
c.selected=c.selected-1
game:effect(e.MOVE)
elseif g.down and c.selected<#h()then
c.selected=c.selected+1
game:effect(e.MOVE)
elseif g.a then
local l=h()[c.selected]
if l~=game.profile.training then
game.profile.training=l
c.hitStart=game.ticks
end
game:effect(e.SELECT)
elseif g.b then
if game.profile.training~=c.trainingAtOpen then
p.write(game.save,game.profile)
game:persist()
end
game:effect(e.BACK)
game:open(d.Camp,{dummy=true,party=c.party})
end
end

local function q(screen,kind,x,y)
if kind=="slash"then
for c=-3,3 do
screen:rect(x+c,y-c,1,1,b.ink(4))
end
screen:rect(x,y,1,1,b.ink(1))
elseif kind=="burst"then
for c=1,3 do
screen:rect(x-c-1,y,1,1,b.ink(4))
screen:rect(x+c+1,y,1,1,b.ink(4))
screen:rect(x,y-c-1,1,1,b.ink(4))
screen:rect(x,y+c+1,1,1,b.ink(4))
end
screen:rect(x-2,y-2,1,1,b.ink(4))
screen:rect(x+2,y-2,1,1,b.ink(4))
screen:rect(x-2,y+2,1,1,b.ink(4))
screen:rect(x+2,y+2,1,1,b.ink(4))
screen:rect(x-1,y-1,3,3,b.ink(1))
else
screen:rect(x-1,y,3,1,b.ink(4))
screen:rect(x,y-1,1,3,b.ink(4))
end
end

local function r(screen,x,y,step)
local c=step+2
screen:rect(x-c-1,y-c,2,1,b.ink(4))
screen:rect(x+c,y-c+1,2,1,b.ink(4))
screen:rect(x+c-1,y+c,1,2,b.ink(3))
end

local function s(game,screen)
local l=game.sheets
b.layers(screen,l.dummyYard,0,a.YARD_W,screen.height,a.SPLIT+1,0,b.ALL_SHADES,0)
local c,g,t=k(game)
local j=0
if c and g<#c.leans then
j=c.leans[g+1]
end
b.layers(screen,l.dummyBig,a.FRAMES[j]*a.BIG_W,a.BIG_W,a.BIG_H,a.BIG_X,a.BIG_Y,b.ALL_SHADES,0)
if c==nil then
return
end
local m=a.SPOTS[t%#a.SPOTS+1]
local n,o=a.TARGET_X+m[1]+j,a.TARGET_Y+m[2]
if g<a.SPARK_STEPS then
q(screen,c.spark,n,o)
end
if c.spark~="tap"and g<a.STRAW_STEPS then
r(screen,n,o,g)
end
end

local function m(game,screen,choice,y,cursor,kept)
local c=a.SPLIT-2*a.BOX_X
local g,j,l=2,1,b.FAINT_SHADE
if cursor then
g,l=4,b.TEXT_SHADE
end
if kept then
j=2
end
screen:rect(a.BOX_X,y,c,a.BOX_H,b.ink(g))
screen:rect(a.BOX_X+1,y+1,c-2,a.BOX_H-2,b.ink(j))
b.richCentre(screen,game.sheets,i("Train_"..choice,f.TRAINING_BONUS),a.BOX_X+math.floor(c/2),y+a.TEXT_DY,l+1)
end

function a.draw(game,screen)
local l=game.view
local j=math.floor(a.SPLIT/2)
screen:rect(0,0,a.SPLIT,screen.height,b.ink(1))
screen:rect(0,a.TOP_H,a.SPLIT,1,b.ink(2))
screen:textCentre(i("DummyTitle"),j,-1,b.ink(4))
local g=h()
for c=1,#g do
m(game,screen,g[c],a.BOX_Y+(c-1)*(a.BOX_H+a.BOX_GAP),c==l.selected,g[c]==game.profile.training)
end
screen:textCentre(i("DummyKeys"),j,a.KEYS_Y-b.lift(screen,a.KEYS_Y,1,0),b.ink(2))
screen:rect(a.SPLIT,0,1,screen.height,b.ink(1))
s(game,screen)
end
