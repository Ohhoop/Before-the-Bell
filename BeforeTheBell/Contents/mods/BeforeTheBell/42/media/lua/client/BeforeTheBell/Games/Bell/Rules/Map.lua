-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Random"
require"BeforeTheBell/Games/Bell/Data/Cast"

local a={}
BeforeTheBell.Bell.Map=a

a.TRAP_DAMAGE=6

local q=BeforeTheBell.Bell.Cast

a.COLS=150
a.ROWS=150
a.PATH=0
a.FOREST=1
a.CAMP_X=75
a.CAMP_Y=75
a.ENERGY=60
a.WINTER_ENERGY=40
a.TRAIL_STEPS=6
a.FOE_CELLS=200
a.PLACE_CELLS={chest=150,merchant=400,forge=400,shrine=1440}
a.PLACE_SPACING={chest=8,merchant=14,forge=15,shrine=30}
a.PLACE_GAP=2
a.PLACE_GROWTH={merchant=25,shrine=10}
a.FIRST_VIEW={cols=7,rows=4}
a.SHRINE_DISTANCE=40
a.ROAMERS={4.4,5,6,7,8}
a.CHASE_RANGE=5
a.NIGHT_CHASE_RANGE=30
a.NIGHT_STEPS=30
a.MAX_ENERGY=math.max(a.ENERGY,a.WINTER_ENERGY,a.NIGHT_STEPS)
a.DAY="day"
a.NIGHT="night"
a.SPAWN_DISTANCE=7
a.RESUME_GAP=3
a.LOOP_CHANCE=0.3
a.SEED_MAX=2147483646
a.FOE_PASSABLE={chest=true,shrine=true}
a.LAYOUTS_KEPT=4

local l={}
local j={}

local c={{1,0},{-1,0},{0,1},{0,-1}}

local function g(x,y)
return x>=1 and x<=a.COLS and y>=1 and y<=a.ROWS
end

local function b(x,y)
return(y-1)*a.COLS+x
end

local function m(x,y)
return x%2==1 and y%2==1 and g(x,y)
end

local function A(list,random)
for d=#list,2,-1 do
local e=random:int(1,d)
list[d],list[e]=list[e],list[d]
end
end

function a.newSeed(random)
return random:int(1,a.SEED_MAX)
end

local function B(seed)
local k=SpiffBoyRandom.new(seed)
local d={}
for e=1,a.ROWS do
d[e]={}
for f=1,a.COLS do
d[e][f]=a.FOREST
end
end
d[a.CAMP_Y][a.CAMP_X]=a.PATH
local h={{a.CAMP_X,a.CAMP_Y}}
while#h>0 do
local e=h[#h]
local i={}
for f=1,#c do
local n,o=e[1]+c[f][1]*2,e[2]+c[f][2]*2
if m(n,o)and d[o][n]==a.FOREST then
i[#i+1]=c[f]
end
end
if#i==0 then
table.remove(h)
else
local f=i[k:int(1,#i)]
d[e[2]+f[2]][e[1]+f[1]]=a.PATH
d[e[2]+f[2]*2][e[1]+f[1]*2]=a.PATH
h[#h+1]={e[1]+f[1]*2,e[2]+f[2]*2}
end
end
for f=1,a.ROWS do
for e=1,a.COLS do
local r=(e%2==0 and f%2==1)or(e%2==1 and f%2==0)
if r and d[f][e]==a.FOREST then
local s=e%2==0
local i,n,o,p=e-1,f,e+1,f
if not s then
i,n,o,p=e,f-1,e,f+1
end
if m(i,n)and m(o,p)and k:chance(a.LOOP_CHANCE)then
d[f][e]=a.PATH
end
end
end
end
return d
end

function a.layout(seed)
local d=l[seed]
if d then
return d
end
d=B(seed)
if#j>=a.LAYOUTS_KEPT then
l[table.remove(j,1)]=nil
end
l[seed]=d
j[#j+1]=seed
return d
end

local function r(cells,fromX,fromY,limit)
local d={}
d[b(fromX,fromY)]=0
local h={{fromX,fromY}}
local i=1
while i<=#h do
local k=h[i]
i=i+1
local n=d[b(k[1],k[2])]
if limit==nil or n<limit then
for o=1,#c do
local e,f=k[1]+c[o][1],k[2]+c[o][2]
if g(e,f)and cells[f][e]==a.PATH and d[b(e,f)]==nil then
d[b(e,f)]=n+1
h[#h+1]={e,f}
end
end
end
end
return d
end

local function s(cells)
return math.max(1,math.floor(a.COLS*a.ROWS/cells))
end

local function t(map,x,y,kind)
local d={x=x,y=y,kind=kind,number=#map.places+1}
map.places[#map.places+1]=d
map.placeCells[b(x,y)]=d
end

local function C(map,x,y,definition)
local d={x=x,y=y,definition=definition,wound=0,caught=false,number=#map.foes+1}
map.foes[#map.foes+1]=d
map.foeCells[b(x,y)]=d
end

local function n(map,foe,x,y)
map.foeCells[b(foe.x,foe.y)]=nil
foe.x,foe.y=x,y
map.foeCells[b(x,y)]=foe
end

local function u(map,free,taken,fromCamp,start,kind,nearest)
local p=a.PLACE_SPACING[kind]
for d=start,#free do
local h,i=free[d][1],free[d][2]
local k=b(h,i)
local e=not taken[k]and fromCamp[k]>=nearest
for v=1,#map.places do
local f=map.places[v]
local o=a.PLACE_GAP
if f.kind==kind then
o=p
end
if e and math.max(math.abs(f.x-h),math.abs(f.y-i))<o then
e=false
end
end
if e then
return free[d],d
end
end
return nil,#free+1
end

local function D(act,day)
local d={"chest","merchant"}
if day%2==0 or(act==#q.bosses and day==3)then
d[#d+1]="forge"
end
return d
end

local function E(day)
return day%2==1
end

local function v(kind,act)
local d=a.PLACE_GROWTH[kind]or 0
return math.floor(s(a.PLACE_CELLS[kind])*(100+d*(act-1))/100)
end

local function w(map,x,y,foe)
for e=-1,1 do
for f=-1,1 do
local d=a.foeAt(map,x+f,y+e)
if d~=nil and d~=foe then
return true
end
end
end
return false
end

function a.generate(random,seed,act,day,rules,blessed,firstChest)
local x=a.layout(seed)
local i=r(x,a.CAMP_X,a.CAMP_Y)
local e={}
for d=1,a.ROWS do
for f=1,a.COLS do
local h=i[b(f,d)]
if x[d][f]==a.PATH and h~=nil and h>1 then
e[#e+1]={f,d}
end
end
end
A(e,random)
local d={
seed=seed,places={},foes={},placeCells={},foeCells={},heroX=a.CAMP_X,heroY=a.CAMP_Y,
energy=a.ENERGY,steps=0,restless=rules.restless,phase=a.DAY,
winter=rules.winter,trail={},traps={},sprung=false,blessed=blessed,
}
if rules.winter then
d.energy=a.WINTER_ENERGY
end
local h={}
local function y(kind,count,nearest)
local k=1
for p=1,count do
local f,o=u(d,e,h,i,k,kind,nearest)
if f==nil then
return
end
h[b(f[1],f[2])]=true
t(d,f[1],f[2],kind)
k=o+1
end
end
if firstChest then
local k={}
for f=1,#e do
local o,p=e[f][1],e[f][2]
if math.abs(o-a.CAMP_X)<=a.FIRST_VIEW.cols and math.abs(p-a.CAMP_Y)<=a.FIRST_VIEW.rows then
k[#k+1]=e[f]
end
end
local f=u(d,k,h,i,1,"chest",0)
if f then
h[b(f[1],f[2])]=true
t(d,f[1],f[2],"chest")
end
end
local o=D(act,day)
for f=1,#o do
y(o[f],v(o[f],act),0)
end
if E(day)then
local f="shrine"
if blessed then
f="chest"
end
y(f,v("shrine",act),a.SHRINE_DISTANCE)
end
local z=q.roamers[act]
local p=math.floor(a.ROAMERS[act+day-1]*s(a.FOE_CELLS))
local k=1
while p>0 and k<=#e do
local f=e[k]
k=k+1
if not h[b(f[1],f[2])]and i[b(f[1],f[2])]>=a.SPAWN_DISTANCE and not w(d,f[1],f[2],nil)then
C(d,f[1],f[2],z[random:int(1,#z)])
p=p-1
end
end
d.placeTotal=#d.places
d.foeTotal=#d.foes
return d
end

function a.placeAt(map,x,y)
if not g(x,y)then
return nil
end
return map.placeCells[b(x,y)]
end

function a.foeAt(map,x,y)
if not g(x,y)then
return nil
end
return map.foeCells[b(x,y)]
end

function a.walkable(map,x,y)
return g(x,y)and a.layout(map.seed)[y][x]==a.PATH
end

function a.shrinesToChests(map)
for d=1,#map.places do
if map.places[d].kind=="shrine"then
map.places[d].kind="chest"
map.places[d].offer=nil
end
end
end

function a.removePlace(map,place)
for d=#map.places,1,-1 do
if map.places[d]==place then
table.remove(map.places,d)
end
end
map.placeCells[b(place.x,place.y)]=nil
end

function a.removeFoe(map,foe)
for d=#map.foes,1,-1 do
if map.foes[d]==foe then
table.remove(map.foes,d)
end
end
if map.foeCells[b(foe.x,foe.y)]==foe then
map.foeCells[b(foe.x,foe.y)]=nil
end
end

function a.clearAround(map,x,y,reach)
for e=#map.foes,1,-1 do
local d=map.foes[e]
if math.max(math.abs(d.x-x),math.abs(d.y-y))<=reach then
a.removeFoe(map,d)
end
end
end

function a.trapAt(map,x,y)
return map.traps[b(x,y)]
end

function a.placeTrap(map,x,y)
local d=b(x,y)
if map.traps[d]or(x==a.CAMP_X and y==a.CAMP_Y)then
return false
end
map.traps[d]={x=x,y=y}
return true
end

function a.setTrap(map)
return a.placeTrap(map,map.heroX,map.heroY)
end

local function h(map,foe)
local d=b(foe.x,foe.y)
if not map.traps[d]then
return
end
map.traps[d]=nil
foe.wound=foe.wound+a.TRAP_DAMAGE
foe.caught=true
map.sprung=true
end

local function i(map,x,y,foe)
if not a.walkable(map,x,y)or w(map,x,y,foe)then
return false
end
local d=a.placeAt(map,x,y)
return d==nil or a.FOE_PASSABLE[d.kind]==true
end

local function p(map)
if map.phase==a.NIGHT then
return a.NIGHT_CHASE_RANGE
end
return a.CHASE_RANGE
end

local function x(map,foe,toHero,random)
if foe.caught then
return false
end
local k=toHero[b(foe.x,foe.y)]
if k~=nil then
for o=1,#c do
local d,e=foe.x+c[o][1],foe.y+c[o][2]
local f=nil
if g(d,e)then
f=toHero[b(d,e)]
end
if f~=nil and f<k then
if d==map.heroX and e==map.heroY then
n(map,foe,d,e)
return true
end
if i(map,d,e,foe)then
n(map,foe,d,e)
h(map,foe)
return false
end
end
end
end
local d=c[random:int(1,#c)]
if i(map,foe.x+d[1],foe.y+d[2],foe)then
n(map,foe,foe.x+d[1],foe.y+d[2])
h(map,foe)
end
return false
end

function a.moveFoes(map,random,hidden)
if not map.restless and map.steps%2==1 then
return nil
end
local d={}
if not hidden then
d=r(a.layout(map.seed),map.heroX,map.heroY,p(map))
end
for e=1,#map.foes do
if x(map,map.foes[e],d,random)then
return map.foes[e]
end
end
return nil
end

function a.startNight(map)
map.phase=a.NIGHT
map.energy=a.NIGHT_STEPS
end

local function f(map,dy)
if not map.winter then
return
end
table.insert(map.trail,1,{x=map.heroX,y=map.heroY,horizontal=dy==0})
while#map.trail>a.TRAIL_STEPS do
table.remove(map.trail)
end
end

function a.stepHero(map,dx,dy)
local d,e=map.heroX+dx,map.heroY+dy
if not a.walkable(map,d,e)then
return"blocked"
end
f(map,dy)
map.heroX,map.heroY=d,e
map.energy=map.energy-1
map.steps=map.steps+1
return"moved"
end
