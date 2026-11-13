-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Profile"

local a={}
BeforeTheBell.Bell.Tent=a

local d=BeforeTheBell.Bell
local b=d.Look
local f=d.Music
local i=d.Cast
local g=d.Run
local n=d.Profile
local e=b.text

a.SPLIT=86
a.YARD_W=93
a.TOP_H=14
a.BOX_X=3
a.BOX_Y=20
a.BOX_H=17
a.BOX_GAP=4
a.TEXT_DY=1
a.KEYS_Y=105
a.DESC_LINE=b.step(10)
a.DESC_Y=a.KEYS_Y-2*a.DESC_LINE-1
a.BIG_W=83
a.BIG_H=52
a.BIG_X=97
a.BIG_Y=52
a.FRAMES={none=0,rest=1,forage=2}
a.Z_X=138
a.Z_Y=50
a.Z_COUNT=3
a.Z_LIFE=72
a.Z_RISE=26
a.Z_DRIFT=10
a.Z_SIZES={3,4,5}
a.Z_SHADES={4,4,3,2}
a.FLAME_X=170
a.FLAME_Y=81
a.FLAME_TICKS=5
a.FLAMES={
{{0,-7,1,3},{-1,-6,2,3},{-1,-5,3,3},{0,-5,1,4},{-1,-4,3,3},{0,-4,1,4},{-2,-3,4,3},{-1,-3,2,4},{-1,-2,3,3},{-1,-1,3,2}},
{{1,-7,1,3},{0,-6,2,3},{0,-5,2,3},{0,-5,1,4},{-1,-4,3,3},{0,-4,1,4},{-1,-3,3,3},{-1,-3,2,4},{-2,-2,4,3},{-1,-1,3,2}},
{{0,-5,1,3},{-1,-4,3,3},{0,-4,1,4},{-2,-3,4,3},{-1,-3,2,4},{-1,-2,3,3},{0,-2,1,4},{-1,-1,3,2}},
{{-1,-7,1,3},{-1,-6,2,3},{-2,-5,3,3},{-1,-5,1,4},{-1,-4,3,3},{0,-4,1,4},{-2,-3,4,3},{-1,-3,2,4},{-1,-2,3,3},{-1,-1,3,2}},
}

local function j()
local c={i.NONE}
for h=1,#i.TENT do
c[#c+1]=i.TENT[h]
end
return c
end

function a.enter(game,args)
local c=game.view
local h=j()
c.party=args.party
c.selected=1
for k=1,#h do
if h[k]==game.profile.tent then
c.selected=k
end
end
end

function a.tick(game,input)
local c=game.view
local h=input.pressed
local k=j()
if h.up and c.selected>1 then
c.selected=c.selected-1
game:effect(f.MOVE)
elseif h.down and c.selected<#k then
c.selected=c.selected+1
game:effect(f.MOVE)
elseif h.a then
local l=k[c.selected]
if l~=game.profile.tent then
game.profile.tent=l
n.write(game.save,game.profile)
game:persist()
end
game:effect(f.SELECT)
game:open(d.Camp,{tent=true,party=c.party})
elseif h.b then
game:effect(f.BACK)
game:open(d.Camp,{tent=true,party=c.party})
end
end

local function o(choice)
if choice=="rest"then
return e("TentDesc_rest",g.REST_MIN,g.REST_MAX)
elseif choice=="forage"then
return e("TentDesc_forage",g.FORAGE_MIN,g.FORAGE_MAX)
end
return e("TentDesc_none")
end

local function p(game,screen,choice,y,cursor)
local c=a.SPLIT-2*a.BOX_X
local h,k=2,b.FAINT_SHADE
if cursor then
h,k=4,b.TEXT_SHADE
end
screen:rect(a.BOX_X,y,c,a.BOX_H,b.ink(h))
screen:rect(a.BOX_X+1,y+1,c-2,a.BOX_H-2,b.ink(1))
b.richCentre(screen,game.sheets,e("TentName_"..choice),a.BOX_X+math.floor(c/2),y+a.TEXT_DY,k+1)
end

local function q(screen,x,y,size,shade)
screen:rect(x,y,size,1,b.ink(shade))
for c=1,size-2 do
screen:rect(x+size-1-c,y+c,1,1,b.ink(shade))
end
screen:rect(x,y+size-1,size,1,b.ink(shade))
end

local function r(game,screen)
for h=1,a.Z_COUNT do
local k=(game.ticks+(h-1)*math.floor(a.Z_LIFE/a.Z_COUNT))%a.Z_LIFE
local c=k/a.Z_LIFE
local l=a.Z_SIZES[math.min(#a.Z_SIZES,math.floor(c*#a.Z_SIZES)+1)]
local m=a.Z_SHADES[math.min(#a.Z_SHADES,math.floor(c*#a.Z_SHADES)+1)]
local s=a.Z_X+math.floor(c*a.Z_DRIFT)
local t=a.Z_Y-math.floor(c*a.Z_RISE)
q(screen,s,t,l,m)
end
end

local function s(game,screen)
local h=a.FLAMES[math.floor(game.ticks/a.FLAME_TICKS)%#a.FLAMES+1]
for k=1,#h do
local c=h[k]
screen:rect(a.FLAME_X+c[1],a.FLAME_Y+c[2],c[3],1,b.ink(c[4]))
end
end

function a.draw(game,screen)
local m=game.view
local h=math.floor(a.SPLIT/2)
local k=j()
local c=k[m.selected]
screen:rect(0,0,a.SPLIT,screen.height,b.ink(1))
screen:rect(0,a.TOP_H,a.SPLIT,1,b.ink(2))
screen:textCentre(e("Tent"),h,-1,b.ink(4))
for l=1,#k do
p(game,screen,k[l],a.BOX_Y+(l-1)*(a.BOX_H+a.BOX_GAP),l==m.selected)
end
local l=b.lift(screen,a.KEYS_Y,1,0)
screen:textCentre(e("TentDawn"),h,a.DESC_Y-l,b.ink(b.FAINT_SHADE))
b.richCentre(screen,game.sheets,o(c),h,a.DESC_Y-l+a.DESC_LINE,b.TEXT_SHADE+1)
screen:textCentre(e("TentKeys"),h,a.KEYS_Y-l,b.ink(2))
screen:rect(a.SPLIT,0,1,screen.height,b.ink(1))
b.layers(screen,game.sheets.tentYard,a.FRAMES[c]*a.YARD_W,a.YARD_W,screen.height,a.SPLIT+1,0,b.ALL_SHADES,0)
b.layers(screen,game.sheets.tentBig,a.FRAMES[c]*a.BIG_W,a.BIG_W,a.BIG_H,a.BIG_X,a.BIG_Y,b.ALL_SHADES,0)
if c=="rest"then
r(game,screen)
elseif c=="forage"then
s(game,screen)
end
end
