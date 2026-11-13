-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Rules/Map"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Build"

local a={}
BeforeTheBell.Bell.World=a

local e=BeforeTheBell.Bell
local b=e.Look
local f=e.Music
local c=e.Map
local z=e.Run
local A=e.Cast
local N=b.text

a.TOP=14
a.VIEW_TOP=13
a.VIEW_COLS=15
a.VIEW_ROWS=9
a.HERO_COL=7
a.HERO_ROW=4
a.REPEAT_DELAY=14
a.REPEAT_TICKS=7
a.HERO_DY=-4
a.HERO_DX=-2
a.PATH_SHADES={3,4}
a.NO_COVER={x=0,y=0,w=0,h=0}
a.VIEW_HEIGHT=108
a.PRINT_SHADES={1,1,2,2,3,3}
a.SNOW_LAYERS={{cell=0,ticks=6},{cell=1,ticks=3}}
a.SNOW_SHADE=4
a.MEET_HOLD=24
a.MEET_WIPE=24
a.MEET_BAND=8
a.MEET_SPREAD=5
a.LIGHT={reach=6,size=28,lit={merchant=true,forge=true,shrine=true}}
a.SCREEN={x=0,y=0,w=1000,h=1000}

function a.enter(game,args)
game:playMusic(f.ROAD)
game.view.held=0
game.view.meeting=nil
end

local function r(game,foe,place)
game:stopMusic()
game:effect(f.ENCOUNTER)
game.view.meeting={ticks=0,foe=foe,place=place}
end

local function B(game)
local d=game.view.meeting
d.ticks=d.ticks+1
if d.ticks>=a.MEET_HOLD+a.MEET_WIPE then
game.view.meeting=nil
game:startFight(d.foe.definition,"roamer",d.foe,d.place)
end
end

local function C(screen,ticks)
local d=ticks-a.MEET_HOLD
if d<=0 then
return
end
local g=math.min(a.MEET_BAND,math.ceil(d*a.MEET_BAND/a.MEET_WIPE))
for h=0,screen.height-1,a.MEET_BAND do
screen:rect(0,h,screen.width,g,b.ink(1))
end
end

local function h(map,x,y)
return(x-map.heroX+a.HERO_COL)*b.TILE,a.VIEW_TOP+(y-map.heroY+a.HERO_ROW)*b.TILE
end

local function D(x,y)
return((x*7+y*13)*(x+3*y+1))%b.PATH_VARIANTS
end

local function l(value,size)
return((value%size)+size)%size
end

local function E(map,x,y)
local d=0
if c.walkable(map,x,y-1)then d=d+1 end
if c.walkable(map,x+1,y)then d=d+2 end
if c.walkable(map,x,y+1)then d=d+4 end
if c.walkable(map,x-1,y)then d=d+8 end
return d
end

local function F(game,input)
local g=game.view
local d=input.pressed
if d.left or d.right or d.up or d.down then
g.held=1
if d.left then return-1,0 end
if d.right then return 1,0 end
if d.up then return 0,-1 end
return 0,1
end
local j,i=input:axes()
if j~=0 and i~=0 then
i=0
end
if j==0 and i==0 then
g.held=0
return 0,0
end
g.held=g.held+1
if g.held>=a.REPEAT_DELAY and(g.held-a.REPEAT_DELAY)%a.REPEAT_TICKS==0 then
return j,i
end
return 0,0
end

local function G(game,place)
game:effect(f.SELECT)
game:open(e.Offer,{place=place})
end

local function H(game,dx,dy)
local d=game.map
local g=c.foeAt(d,d.heroX+dx,d.heroY+dy)
if c.stepHero(d,dx,dy)=="blocked"then
game:effect(f.BUMP)
return
end
game:effect(f.STEP)
if g then
r(game,g,c.placeAt(d,d.heroX,d.heroY))
return
end
local i=c.placeAt(d,d.heroX,d.heroY)
if i then
G(game,i)
return
end
local j=c.moveFoes(d,game.random,BeforeTheBell.Bell.Build.hero(game.run).flags.shadows)
if d.sprung then
d.sprung=false
game:effect(f.CLANG)
end
if j then
r(game,j,nil)
return
end
if d.energy<=0 then
game:phaseEnds()
end
end

function a.tick(game,input)
if game.view.meeting then
B(game)
return
end
if game.map.energy<=0 then
game:phaseEnds()
return
end
if input.pressed.start then
game:effect(f.SELECT)
game:open(e.Pause)
return
end
if input.pressed.b then
game:effect(f.SELECT)
game:open(e.Bag)
return
end
local d,g=F(game,input)
if d~=0 or g~=0 then
H(game,d,g)
end
end

local function I(game,screen)
local j=game.run
screen:rect(0,0,screen.width,a.TOP-1,b.ink(1))
local m="sun"
if game.map.phase==c.NIGHT then
m="moon"
end
local g={
{m,tostring(j.day),4},
{"steps",tostring(game.map.energy),3},
{"heart",j.hp.."/"..z.maxHealth(j),4},
{"coin",tostring(j.gold),3},
}
local k=0
for d=1,#g do
k=k+b.ICON+b.ICON_GAP+screen:textWidth(g[d][2])
end
local o=math.floor((screen.width-4-k)/(#g-1))
local d=2
for n=1,#g do
local i=g[n]
if n==#g then
d=screen.width-2-screen:textWidth(i[2])-b.ICON-b.ICON_GAP
end
b.icon(screen,game.sheets,i[1],d,2)
d=d+b.ICON+b.ICON_GAP
screen:text(i[2],d,-1,b.ink(i[3]))
d=d+screen:textWidth(i[2])+o
end
end

local function s(game,screen,x,y,dim,clip)
local d=game.map
if not c.walkable(d,x,y)then
return
end
local g=game.sheets.paths
if d.winter then
g=game.sheets.pathsWinter
end
local i,j=h(d,x,y)
local k=D(x,y)*b.PATH_MASKS+E(d,x,y)
b.layersClip(screen,g,k*b.TILE,b.TILE,b.TILE,i,j,a.PATH_SHADES,dim,clip)
end

local function J(game,screen,forest,darker,clip)
local o=game.map
local p=a.VIEW_COLS*b.TILE
local n=a.VIEW_HEIGHT
local i=l(o.heroX-a.HERO_COL,a.VIEW_COLS)*b.TILE
local j=l(o.heroY-a.HERO_ROW,a.VIEW_ROWS)*b.TILE
local q={{i,p-i,0},{0,i,p-i}}
local t={{j,n-j,a.VIEW_TOP},{0,j,a.VIEW_TOP+n-j}}
for u=1,#b.ALL_SHADES do
for x=1,#q do
local d=q[x]
for y=1,#t do
local g=t[y]
local k,m=math.max(d[3],clip.x),math.max(g[3],clip.y)
local v,w=math.min(d[3]+d[2],clip.x+clip.w),math.min(g[3]+g[2],clip.y+clip.h)
if v>k and w>m then
screen:sheet(forest,d[1]+k-d[3],(u-1)*n+g[1]+m-g[3],v-k,w-m,k,m,1,math.max(1,u-darker))
end
end
end
end
end

local function w(game,screen,dim)
local d=game.map
for i=1,#d.trail do
local g=d.trail[i]
local k,m=h(d,g.x,g.y)
local j=1
if g.horizontal then
j=0
end
local n=math.max(1,a.PRINT_SHADES[i]-dim)
screen:sheet(game.sheets.prints,j*b.TILE,(a.SNOW_SHADE-1)*b.TILE,b.TILE,b.TILE,k,m,1,n)
end
end

local function K(game,screen,dim)
local j=game.sheets.snow
local g=a.VIEW_HEIGHT
local i=screen.width
local k=(a.SNOW_SHADE-1)*g
local m=math.max(1,a.SNOW_SHADE-dim)
for p=1,#a.SNOW_LAYERS do
local n=a.SNOW_LAYERS[p]
local d=math.floor(game.ticks/n.ticks)%g
local o=n.cell*i
screen:sheet(j,o,k,i,g-d,0,a.VIEW_TOP+d,1,m)
if d>0 then
screen:sheet(j,o,k+g-d,i,d,0,a.VIEW_TOP,1,m)
end
end
end

local function t(game,screen,x,y,dim,clip)
local i=game.map
local n=game.sheets
local d,o=h(i,x,y)
local function g(name,tx)
b.layersClip(screen,n.tiles,b.TILE_INDEX[name]*b.TILE,b.TILE,b.TILE,tx,o,b.ALL_SHADES,dim,clip)
end
if c.trapAt(i,x,y)then
g("bearTrap",d)
end
if x==c.CAMP_X and y==c.CAMP_Y then
g("camp",d)
end
local k=c.placeAt(i,x,y)
if k then
g(k.kind,d)
end
local j=c.foeAt(i,x,y)
if j then
local m=game.view.meeting
if m and m.foe==j then
d=d+a.MEET_SPREAD
end
g(j.definition.id,d)
if j.caught then
g("bearTrapShut",d)
end
end
end

local function m(px,py,cover)
return px>=cover.x and py>=cover.y and px+b.TILE<=cover.x+cover.w and py+b.TILE<=cover.y+cover.h
end

local function x(game,cover)
local g=game.map
local i={}
for n=1,#g.places do
local d=g.places[n]
local j,k=h(g,d.x,d.y)
local o=math.abs(d.x-g.heroX)<=a.HERO_COL+1 and math.abs(d.y-g.heroY)<=a.HERO_ROW+1
if a.LIGHT.lit[d.kind]and o and not m(j,k,cover)then
i[#i+1]={place=d,x=j,y=k}
end
end
return i
end

local function y(game,screen,darker,lit)
local p=game.map
local j=game.sheets.light
if p.winter then
j=game.sheets.lightWinter
end
local d=a.LIGHT.size
local k=a.VIEW_ROWS
for g=1,#lit do
local q=l(lit[g].place.x,a.VIEW_COLS)
local u=l(lit[g].place.y,k)
local v=lit[g].x+math.floor(b.TILE/2)-d/2
local n=lit[g].y+math.floor(b.TILE/2)-d/2
local i=math.max(0,a.VIEW_TOP-n)
for o=1,#b.ALL_SHADES do
screen:sheet(j,q*d,(o-1)*k*d+u*d+i,d,d-i,v,n+i,1,math.max(1,o-darker))
end
end
end

local function L(game,screen,darker,lit)
local i=a.LIGHT.reach
local d=b.TILE
for p=1,#lit do
local n,j,k=lit[p].place,lit[p].x,lit[p].y
local o={
{0,0,{x=j,y=k,w=d,h=d}},
{-1,0,{x=j-i,y=k,w=i,h=d}},
{1,0,{x=j+d,y=k,w=i,h=d}},
{0,-1,{x=j,y=k-i,w=d,h=i}},
{0,1,{x=j,y=k+d,w=d,h=i}},
}
for q=1,#o do
local u,v,g=o[q][1],o[q][2],o[q][3]
if g.y<a.VIEW_TOP then
g.h=g.h-(a.VIEW_TOP-g.y)
g.y=a.VIEW_TOP
end
if g.h>0 then
s(game,screen,n.x+u,n.y+v,darker,g)
t(game,screen,n.x+u,n.y+v,darker,g)
end
end
end
end

function a.drawLand(game,screen,darker,cover)
local d=game.map
local i=game.sheets
local j=d.phase==c.NIGHT
local g=darker
if j then
g=g+1
end
local k=i.forest
if d.winter and j then
k=i.forestWinterNight
elseif d.winter then
k=i.forestWinter
elseif j then
k=i.forestNight
end
J(game,screen,k,darker,a.SCREEN)
local p={}
if j then
p=x(game,cover)
y(game,screen,darker,p)
end
local n,o=d.heroX-a.HERO_COL,d.heroY-a.HERO_ROW
for q=0,a.VIEW_ROWS-1 do
for u=0,a.VIEW_COLS-1 do
local v,M=h(d,n+u,o+q)
if not m(v,M,cover)then
s(game,screen,n+u,o+q,g,a.SCREEN)
end
end
end
if d.winter then
w(game,screen,g)
end
for q=0,a.VIEW_ROWS-1 do
for u=0,a.VIEW_COLS-1 do
local v,M=h(d,n+u,o+q)
if not m(v,M,cover)then
t(game,screen,n+u,o+q,g,a.SCREEN)
end
end
end
L(game,screen,darker,p)
local q,u=h(d,d.heroX,d.heroY)
if not m(q,u,cover)then
local v=0
if game.view.meeting then
v=a.MEET_SPREAD
end
b.walker(screen,i,A.heroIndex(game.run.hero),q+a.HERO_DX-v,u+a.HERO_DY,g)
end
if d.winter then
K(game,screen,g)
end
I(game,screen)
end

function a.draw(game,screen)
a.drawLand(game,screen,0,a.NO_COVER)
if game.view.meeting then
C(screen,game.view.meeting.ticks)
end
end
