-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Data/Effects"
require"BeforeTheBell/Games/Bell/Data/Strikes"
require"BeforeTheBell/Games/Bell/Rules/Run"

local a={}
BeforeTheBell.Bell.Battle=a

local e=BeforeTheBell.Bell
local b=e.Look
local h=e.Music
local k=e.Items
local n=e.Cast
local d=b.text

a.STEP_TICKS=50
a.STATS_CORE={"hp","atk","arm","spd"}
a.STATS_STATUS={"poison","bleed","freeze","thorns"}
a.STATS_Y=10
a.STATS_ROW=b.step(10)
a.STATS_HEADER_ROW=b.step(10)
a.STATS_SECTION_GAP=1
a.STATS_HEADER_GAP=2
a.STATS_FOOT=16
a.STATS_EDGE=4
a.STAT_MARK_X=60
a.STAT_LABEL_X=72
a.STAT_ZERO_SHADE=2
a.STAT_MARKS={atk="physical",arm="armor",spd="speed",poison="poison",bleed="bleed",freeze="freeze",thorns="thorns"}
a.LUNGE_TICKS=12
a.DUST_TICKS=3
a.KILL_STEP_TICKS=10
a.LUNGE_STEP=3
a.BLINK_FROM=3
a.BLINK_TO=5
a.POP_TICKS=28
a.POP_RISE=10
a.SIDE_GAP=4
a.SIDE_TOP=20
a.SIDE_ROW=b.step(11)
a.POP_BASE=86
a.TILES={{key="hp",mark="life"},{key="atk",mark="physical"},{key="spd",mark="speed"},{key="arm",mark="armor"}}
a.TILE_W=12
a.TILE_Y=1
a.TILE_VALUE_DY=6
a.TILES_LEFT=2
a.HP_BAR_GAP=1
a.HP_BAR_TOP=4
a.HP_BAR_H=7
a.TILE_PAD=3
a.TILES_MIN_GAP=4
a.TILE_DROP=17
a.LOSS_DY=13
a.SIDE_MARKS={{key="poison",mark="poison"},{key="bleed",mark="bleed"},{key="freeze",mark="freeze"},{key="thorns",mark="thorns"}}
a.POP_FADE_FROM=14
a.POP_FADE_STEP=5
a.POP_FADE_LAST=2
a.STRIKES={hit=true,blast=true,toll=true,thorns=true,tick_poison=true,tick_bleed=true,damage=true}
a.POP_MARKS={hit="physical",damage="physical",blast="blast",toll="pierce",thorns="thorns",tick_poison="poison",tick_bleed="bleed",heal="heal",revive="heal"}
a.TOP=16
a.GROUND=114
a.BAND_H=24
a.BAND_LINE_DY=-2
a.BAND_SLIDE=8
a.GEAR_POP={x=38,margin=6,inTicks=12,outTicks=12,steps=3,rankDx=2,rankDy=-2}
a.RING={{-1,0},{1,0},{0,-1},{0,1}}
a.SPOKEN={phase=true,miss=true,block=true,ward=true}
a.MARGIN=6
a.SHAKE_TICKS=6
a.SHAKE=3
a.RISERS={TheBellItself=true}
a.RISE_TICKS=72
a.MORPHERS={TheTollerWinged="TheToller"}
a.MORPH_TICKS=96
a.MORPH_FLICKERS={18,12,9,6,4,3}
a.PRESS_BLINK=30
a.PHASE_DELAY=16
a.QUAKE=2
a.FRAME_TICKS=3
a.FLIGHT_TICKS=8
a.FLIGHT_ARC=14
a.FLIGHT_LOB={bomb=true}
a.GAUGE_DY=2
a.GAUGE_W=34
a.GAUGE_H=3
a.GAUGE_FILL_FROM=31

local function _(id)
if id==nil then
return""
end
if k.byId[id]then
return d("Item_"..id)
end
if n.heroById[id]then
return d("Hero_"..id)
end
if n.blessingById[id]then
return d("Bless_"..id)
end
if n.isFoe(id)then
return d("Foe_"..id)
end
if k.setById[id]then
return d("Set_"..id)
end
return d("Src_"..id)
end

function a.enter(game,args)
local c=game.view
if args.kind=="boss"then
game:playMusic(h.BOSS)
else
game:playMusic(h.BATTLE)
end
c.args=args
c.result=args.result
c.index=1
c.timer=0
c.lineTicks=0
c.shake=0
c.shakeSide=nil
c.anim=nil
c.rise=nil
c.morph=nil
c.waiting=false
c.stats=false
c.dust=0
end

local function F(game,event)
local c=game.view
c.lineTicks=0
local f=0
if a.STRIKES[event.kind]or event.kind=="heal"or event.kind=="revive"then
local g=c.result.events[c.index-1]
local j=g~=nil and g.kind=="hit"and g.side==event.side and c.anim~=nil and c.anim.effect~=nil and not c.anim.back
local i=e.Strikes.of(event,e.Run.weaponId(game.run),event.foe.id,j)
if i and e.Effects.list[i].flightRight then
f=a.FLIGHT_TICKS
end
c.anim={ticks=0,kind=event.kind,side=event.side,value=event.value,effect=i,delay=f,back=j}
end
if event.kind=="hit"or event.kind=="blast"or event.kind=="toll"or event.kind=="thorns"then
c.shake=a.SHAKE_TICKS+f
c.shakeSide=event.side
if event.side=="hero"then
game:effect(h.HURT)
else
game:effect(h.HIT)
end
elseif event.kind=="heal"or event.kind=="revive"then
game:effect(h.HEAL)
elseif event.kind=="phase"and a.RISERS[event.source]then
c.rise={ticks=0}
game:effect(h.TOLL)
elseif event.kind=="phase"and a.MORPHERS[event.source]then
c.morph={ticks=0,from=a.MORPHERS[event.source]}
game:effect(h.TOLL)
end
if event.kind=="phase"then
c.waiting=true
end
end

function a.tick(game,input)
local c=game.view
local f=c.result.events
if c.stats then
if input.pressed.start or input.pressed.b then
c.stats=false
game:effect(h.BACK)
end
return
end
c.lineTicks=c.lineTicks+1
if c.result.won and f[c.index].foe.hp<=0 and f[c.index].foe.id==f[#f].foe.id then
c.dust=c.dust+1
end
if input.pressed.start and c.index<#f then
c.stats=true
game:effect(h.SELECT)
return
end
if c.shake>0 then
c.shake=c.shake-1
end
if c.anim then
c.anim.ticks=c.anim.ticks+1
if c.anim.ticks>a.POP_TICKS+c.anim.delay then
c.anim=nil
end
end
if c.index>=#f then
if input.pressed.a or input.pressed.start then
game:effect(h.SELECT)
game:afterFight(c.args)
end
return
end
if c.rise then
c.rise.ticks=c.rise.ticks+1
if c.rise.ticks>=a.RISE_TICKS then
c.rise=nil
end
return
end
if c.morph then
c.morph.ticks=c.morph.ticks+1
if c.morph.ticks>=a.MORPH_TICKS then
c.morph=nil
end
return
end
if c.waiting then
if input.pressed.a then
c.waiting=false
c.timer=a.STEP_TICKS
game:effect(h.SELECT)
end
return
end
c.timer=c.timer+1
local g=a.STEP_TICKS
if c.dust>0 then
g=a.KILL_STEP_TICKS
elseif f[c.index].foe.hp<=0 and f[c.index+1].kind=="phase"then
g=a.PHASE_DELAY
end
if c.timer>=g then
c.timer=0
c.index=c.index+1
F(game,f[c.index])
while f[c.index+1]and f[c.index+1].joined do
c.index=c.index+1
F(game,f[c.index])
end
if c.index>=#f and c.result.won then
game:stopMusic()
game:effect(h.WIN)
elseif c.index>=#f then
game:stopMusic()
game:effect(h.LOSE)
end
end
end

local function G(values,key)
return tostring(values[key])
end

local function H(screen,values)
return screen:textWidth(tostring(math.max(0,values.hp)))+1+a.HP_BAR_GAP+screen:textWidth(tostring(values.maxHp))
end

local function aa(game,screen,values,left,width,y)
local f,l=tostring(math.max(0,values.hp)),tostring(values.maxHp)
local g=left+math.floor(width/2)
b.mark(screen,game.sheets,"life",g-math.floor(b.ICON/2),y,0)
local i=g-math.floor(H(screen,values)/2)
local c=y+a.TILE_VALUE_DY
screen:text(f,i,c,b.ink(1))
local j=i+screen:textWidth(f)
screen:rect(j,c+a.HP_BAR_TOP,1,a.HP_BAR_H,b.ink(2))
screen:text(l,j+1+a.HP_BAR_GAP,c,b.ink(1))
end

local function o(screen,values,tight)
local f,i={},0
for c=1,#a.TILES do
local g
if a.TILES[c].key=="hp"then
g=H(screen,values)
else
g=screen:textWidth(G(values,a.TILES[c].key))
end
if tight then
f[c]=math.max(b.ICON,g)+1
else
f[c]=math.max(a.TILE_W,g+a.TILE_PAD)
end
i=i+f[c]
end
return f,i
end

local function ab(screen,hero,foe)
local g,f=o(screen,hero,false)
local i,c=o(screen,foe,false)
if a.TILES_LEFT+f+a.TILES_MIN_GAP>screen.width-a.TILES_LEFT-c then
g,f=o(screen,hero,true)
i,c=o(screen,foe,true)
end
local j=a.TILE_Y
if a.TILES_LEFT+f+a.TILES_MIN_GAP>screen.width-a.TILES_LEFT-c then
j=a.TILE_Y+a.TILE_DROP
end
return{
hero={left=a.TILES_LEFT,widths=g,top=a.TILE_Y,mirror=false},
foe={left=screen.width-a.TILES_LEFT-c,widths=i,top=j,mirror=true},
}
end

local function I(game,screen,values,place,quake,losses,gains)
local c=place.top+quake.y
local g=place.left+quake.x
local q=#a.TILES
for r=1,q do
local j=r
if place.mirror then
j=q-r+1
end
local f=a.TILES[j]
local l=place.widths[j]
local i=g+math.floor(l/2)
if f.key=="hp"then
aa(game,screen,values,g,l,c)
else
b.mark(screen,game.sheets,f.mark,i-math.floor(b.ICON/2),c,0)
screen:textCentre(G(values,f.key),i,c+a.TILE_VALUE_DY,b.ink(1))
end
local m=losses[f.key]
if m then
screen:textCentre(d("PopDamage",m.value),i,c+a.TILE_VALUE_DY+a.LOSS_DY-4,b.ink(1+m.fade))
end
local p=gains[f.key]
if p then
screen:textCentre(d("PopHeal",p.value),i,c+a.TILE_VALUE_DY+a.LOSS_DY-4,b.ink(1+p.fade))
end
g=g+l
end
end

local function J(screen,fill,centreX,alignRight,quake)
local c=centreX-math.floor(a.GAUGE_W/2)+quake.x
local f=a.GROUND+a.GAUGE_DY+quake.y
local g=a.GAUGE_W-2
local i=math.floor(g*math.min(1,fill)+0.5)
screen:rect(c,f,a.GAUGE_W,a.GAUGE_H,b.ink(1))
screen:rect(c+1,f+1,g,a.GAUGE_H-2,b.ink(4))
if i>0 then
local j=c+1
if alignRight then
j=c+1+g-i
end
screen:rect(j,f+1,i,a.GAUGE_H-2,b.ink(2))
end
end

local function K(view,side)
local i=view.result.events
local c=i[view.index][side].gauge
local f=i[view.index+1]
if f and f.opens and view.timer>=a.GAUGE_FILL_FROM then
local g=f[side].gauge
if f.opens==side then
g=g+e.Combat.GAUGE_FULL
end
local j=(view.timer-a.GAUGE_FILL_FROM)/(a.STEP_TICKS-a.GAUGE_FILL_FROM)
c=c+(g-c)*j
end
return c/e.Combat.GAUGE_FULL
end

local function L(values)
local c={}
for g=1,#a.SIDE_MARKS do
local f=a.SIDE_MARKS[g]
if values[f.key]>0 then
c[#c+1]={mark=f.mark,label=tostring(values[f.key]),fade=0}
end
end
return c
end

local function M(game,screen,rows,x,top,alignRight)
for g=1,#rows do
local c=rows[g]
local i=top+(g-1)*a.SIDE_ROW
local f=x
if alignRight then
f=x-b.ICON-b.ICON_GAP-screen:textWidth(c.label)
end
b.mark(screen,game.sheets,c.mark,f,i+b.ICON_DY,c.fade)
screen:text(c.label,f+b.ICON+b.ICON_GAP,i,b.ink(1+c.fade))
end
end

local function N(screen,rows)
local c=0
for f=1,#rows do
c=math.max(c,b.ICON+b.ICON_GAP+screen:textWidth(rows[f].label))
end
return c
end

local function t(view,side,key)
local f=view.result.events
local c=f[view.index-1]
local g=f[view.index]
if c==nil or c[side].id~=g[side].id then
return nil
end
local i=g[side][key]-c[side][key]
if i<=0 then
return nil
end
local j=math.floor(math.max(0,view.timer-a.POP_FADE_FROM)/a.POP_FADE_STEP)
if j>a.POP_FADE_LAST then
return nil
end
return{value=i,fade=j}
end

local function O(view,side)
return{atk=t(view,side,"atk"),spd=t(view,side,"spd"),arm=t(view,side,"arm")}
end

local function p(view,side,key)
local g=view.result.events
local c=g[view.index-1]
local i=g[view.index]
if c==nil or c[side].id~=i[side].id then
return nil
end
local j=c[side][key]-math.max(0,i[side][key])
if j<=0 then
return nil
end
local f=view.timer
if view.anim and view.anim.side==side then
f=view.anim.ticks-view.anim.delay
end
if f<0 then
return nil
end
local l=math.floor(math.max(0,f-a.POP_FADE_FROM)/a.POP_FADE_STEP)
if l>a.POP_FADE_LAST then
return nil
end
return{value=j,fade=l}
end

local function P(view,side)
return{hp=p(view,side,"hp"),atk=p(view,side,"atk"),spd=p(view,side,"spd"),arm=p(view,side,"arm")}
end

local function Q(id)
return math.max(a.SIDE_TOP,a.GROUND-BeforeTheBell.Bell.Fighters[id].h)
end

local function R(id)
local c=a.GROUND-BeforeTheBell.Bell.Fighters[id].h-a.SIDE_GAP-#a.SIDE_MARKS*a.SIDE_ROW
if c<a.SIDE_TOP then
return nil
end
return c
end

local function S(screen,key,y)
local c=d(key)
screen:text(c,a.STATS_EDGE,y,b.ink(2))
local f=a.STATS_EDGE+screen:textWidth(c)+a.STATS_HEADER_GAP
screen:rect(f,y+7,screen.width-a.STATS_EDGE-f,1,b.ink(2))
end

local function T(game,screen,event,key,y,fadeZero)
local c,f=event.hero[key],event.foe[key]
local g,i=4,4
if key=="hp"then
c=math.max(0,event.hero.hp).."/"..event.hero.maxHp
f=math.max(0,event.foe.hp).."/"..event.foe.maxHp
b.icon(screen,game.sheets,"heart",a.STAT_MARK_X,y+b.ICON_DY)
else
b.markLit(screen,game.sheets,a.STAT_MARKS[key],a.STAT_MARK_X,y+b.ICON_DY)
if fadeZero and c==0 then
g=a.STAT_ZERO_SHADE
end
if fadeZero and f==0 then
i=a.STAT_ZERO_SHADE
end
end
screen:text(tostring(c),a.STATS_EDGE,y,b.ink(g))
screen:text(d("Stat_"..key),a.STAT_LABEL_X,y,b.ink(3))
screen:textRight(tostring(f),screen.width-a.STATS_EDGE,y,b.ink(i))
end

local function ac(game,screen,event)
local i=math.floor(screen.width/2)
screen:rect(0,0,screen.width,screen.height,b.ink(1))
screen:text(d("Hero_"..game.view.result.hero.id),a.STATS_EDGE,-1,b.ink(4))
screen:textRight(d("Foe_"..event.foe.id),screen.width-a.STATS_EDGE,-1,b.ink(4))
local c=a.STATS_Y
S(screen,"StatsFight",c)
c=c+a.STATS_HEADER_ROW
for f=1,#a.STATS_CORE do
T(game,screen,event,a.STATS_CORE[f],c,false)
c=c+a.STATS_ROW
end
local f={}
for j=1,#a.STATS_STATUS do
local g=a.STATS_STATUS[j]
if event.hero[g]~=0 or event.foe[g]~=0 then
f[#f+1]=g
end
end
if#f>0 then
c=c+a.STATS_SECTION_GAP
S(screen,"StatsStatus",c)
c=c+a.STATS_HEADER_ROW
for g=1,#f do
T(game,screen,event,f[g],c,true)
c=c+a.STATS_ROW
end
end
screen:textCentre(d("PressStart"),i,screen.height-a.STATS_FOOT,b.ink(2))
end

local function ad(event)
local c=event.source
if c==nil then
return false
end
local f=k.byId[c]
if f then
return f.kind~=k.WEAPON
end
return n.blessingById[c]~=nil
end

local function ae(game,screen,name,x,y,fade)
local f=b.ICONS[name]*b.ICON
for g=1,#b.MARK_SHADES do
local i=(b.MARK_SHADES[g]-1)*b.ICON
for j,c in ipairs(a.RING)do
screen:sheet(game.sheets.hud,f,i,b.ICON,b.ICON,x+c[1],y+c[2],1,4)
end
end
b.mark(screen,game.sheets,name,x,y,fade)
end

local function af(game,screen,id,rank,ticks)
local c=a.GEAR_POP
local f=0
if ticks<c.inTicks then
f=c.steps-math.floor(ticks*c.steps/c.inTicks)
end
local j=a.STEP_TICKS-ticks
if j<c.outTicks then
f=math.ceil((c.outTicks-j)*c.steps/c.outTicks)
end
if f>=c.steps then
return
end
local g,i=c.x,screen.height-b.ITEM-c.margin
if k.byId[id]then
b.item(screen,game.sheets,id,g,i,-f)
if rank and rank>1 then
ae(game,screen,"rank"..rank,g+b.ITEM-b.ICON+a.GEAR_POP.rankDx,i+a.GEAR_POP.rankDy,f)
end
else
b.blessing(screen,game.sheets,id,g,i,-f)
end
end

local function ag(view,event)
local c=d("Hero_"..view.result.hero.id)
if event.side=="foe"then
c=d("Foe_"..event.foe.id)
end
if event.kind=="phase"then
return d("Phase_"..event.source)
end
return d("Ev_"..event.kind,c,event.value,_(event.source))
end

local function U(anim,targetSide)
if anim==nil or anim.kind~="hit"or anim.side~=targetSide or anim.delay>0 or anim.ticks>=a.LUNGE_TICKS then
return 0
end
local c=a.LUNGE_TICKS/2
if anim.ticks<c then
return anim.ticks*a.LUNGE_STEP
end
return(a.LUNGE_TICKS-anim.ticks)*a.LUNGE_STEP
end

local function V(anim,side)
return anim~=nil and a.STRIKES[anim.kind]and anim.side==side
and anim.ticks-anim.delay>=a.BLINK_FROM and anim.ticks-anim.delay<=a.BLINK_TO
end

local function ah(rise,foeHeight)
if rise==nil then
return{x=0,y=0},0
end
local c,f=a.QUAKE,0
if rise.ticks%2==1 then
c=-a.QUAKE
end
if rise.ticks%4<2 then
f=a.QUAKE
end
return{x=c,y=f},math.floor((a.RISE_TICKS-rise.ticks)*foeHeight/a.RISE_TICKS)
end

local function q(screen,id,side)
local c=BeforeTheBell.Bell.Fighters[id]
local f=a.MARGIN+math.floor(c.w/2)
if side=="foe"then
f=screen.width-a.MARGIN-math.floor(c.w/2)
end
return f,a.GROUND-math.floor(c.h/2)
end

local function ai(game,screen,view,heroId,foeId)
local c=view.anim
if c==nil or c.effect==nil then
return
end
local f=e.Effects.list[c.effect]
local g=math.floor(e.Effects.CELL/2)
local m,r,s,j=foeId,heroId,"hero","Right"
if c.side=="hero"then
m,r,s,j=heroId,foeId,"foe","Left"
end
local u,v=q(screen,m,c.side)
if c.ticks<c.delay then
local w,x=q(screen,r,s)
local i=c.ticks/c.delay
local y=math.floor(w+(u-w)*i)
local l=math.floor(x+(v-x)*i)
if a.FLIGHT_LOB[c.effect]then
l=l-math.floor(a.FLIGHT_ARC*4*i*(1-i))
end
local z=f["flight"..j]
screen:layers(game.sheets.fx,z*e.Effects.CELL,e.Effects.CELL,e.Effects.CELL,y-g,l-g,b.ALL_SHADES)
return
end
local i=math.floor((c.ticks-c.delay)/a.FRAME_TICKS)
if i>=f.count then
return
end
local l=f.right
if j=="Left"then
l=f.left
end
screen:layers(game.sheets.fx,(l+i)*e.Effects.CELL,e.Effects.CELL,e.Effects.CELL,u-g,v-g,b.ALL_SHADES)
end

local function aj(game,screen,view,panels)
local c=view.anim
if c==nil or c.value==nil or c.value<=0 or c.ticks<c.delay then
return
end
local m=c.ticks-c.delay
local j=d("PopDamage",c.value)
if c.kind=="heal"or c.kind=="revive"then
j=d("PopHeal",c.value)
end
local l=b.ICON+b.ICON_GAP+screen:textWidth(j)
local g=panels[c.side]
local i=a.POP_BASE
local f=g.edge
if c.side=="hero"and f+l>panels.foe.edge then
f=g.x
i=math.max(i,g.bottom+a.POP_RISE+a.SIDE_GAP)
elseif c.side=="foe"then
f=g.edge-l
if f<panels.hero.edge then
f=g.x-l
i=math.max(i,g.bottom+a.POP_RISE+a.SIDE_GAP)
end
end
local r=i-math.floor(m*a.POP_RISE/a.POP_TICKS)
local s=math.min(a.POP_FADE_LAST,math.floor(math.max(0,m-a.POP_FADE_FROM)/a.POP_FADE_STEP))
b.mark(screen,game.sheets,a.POP_MARKS[c.kind],f,r+b.ICON_DY,s)
screen:text(j,f+b.ICON+b.ICON_GAP,r,b.ink(1+s))
end

local function ak(game,screen,line,ticks,press,pressShown)
local i=math.floor(screen.width/2)
local j=b.richWrap(screen,line,screen.width-8)
local c=math.min(2,#j)
local l=c
if press then
l=c+1
end
local g=a.BAND_H+math.max(0,l-2)*b.ROW+b.lift(screen,screen.height-a.BAND_H+a.BAND_LINE_DY,2,b.ROW)
local r=math.max(0,g-math.floor(ticks*g/a.BAND_SLIDE))
local f=screen.height-g+r
b.panel(screen,f,screen.height-f)
for m=1,c do
b.richCentre(screen,game.sheets,j[m],i,f+a.BAND_LINE_DY+(m-1)*b.ROW,4)
end
if pressShown and math.floor(game.ticks/a.PRESS_BLINK)%2==0 then
screen:textCentre(d("PressA"),i,f+a.BAND_LINE_DY+c*b.ROW,b.ink(2))
end
end

local function al(morph,foeId)
if morph==nil then
return foeId
end
local c=math.floor(morph.ticks*#a.MORPH_FLICKERS/a.MORPH_TICKS)+1
local f=a.MORPH_FLICKERS[math.min(c,#a.MORPH_FLICKERS)]
if math.floor(morph.ticks/f)%2==0 then
return morph.from
end
return foeId
end

local function am(view)
if view.dust==0 then
return 0
end
return math.floor((view.dust-1)/a.DUST_TICKS)+1
end

function a.draw(game,screen)
local c=game.view
local u=c.result.events
local g=u[c.index]
if c.stats then
ac(game,screen,g)
return
end
local aq=math.floor(screen.width/2)
local j,i=c.result.hero.id,g.foe.id
screen:rect(0,a.GROUND,screen.width,screen.height-a.GROUND,b.ink(3))
local f,W=ah(c.rise or c.morph,BeforeTheBell.Bell.Fighters[i].h)
if c.morph then
W=0
end
local an=al(c.morph,i)
local v,w=f.x,f.x
if c.shake>0 and c.shake<=a.SHAKE_TICKS and c.shake%2==1 then
if c.shakeSide=="hero"then v=v-a.SHAKE else w=w+a.SHAKE end
end
local ao,ap=U(c.anim,"foe"),U(c.anim,"hero")
if not V(c.anim,"hero")then
b.fighter(screen,game.sheets,j,a.MARGIN+v+ao,a.GROUND+f.y,false)
end
local X=am(c)
if not V(c.anim,"foe")and X<=BeforeTheBell.Bell.Fighters[i].dust then
b.fighter(screen,game.sheets,an,screen.width-a.MARGIN+w-ap,a.GROUND+f.y+W,true,X)
end
ai(game,screen,c,j,i)
if c.index<#u and not a.SPOKEN[g.kind]and ad(g)then
af(game,screen,g.source,g.rank,c.lineTicks)
end
local r=L(g.hero)
local x=L(g.foe)
local y=a.MARGIN+BeforeTheBell.Bell.Fighters[j].w+a.SIDE_GAP+f.x
local z=screen.width-a.MARGIN-BeforeTheBell.Bell.Fighters[i].w-a.SIDE_GAP+f.x
local A,s,B=y,Q(j)+f.y,y+N(screen,r)+a.SIDE_GAP
local C=R(j)
if C then
A,s,B=a.MARGIN+f.x,C+f.y,y
end
local D,l,E=z,Q(i)+f.y,z-N(screen,x)-a.SIDE_GAP
local Y=R(i)
if Y then
D,l,E=screen.width-a.MARGIN+f.x,Y+f.y,z
elseif C==nil and B>E then
l=math.max(l,s+#r*a.SIDE_ROW+a.SIDE_GAP)
end
M(game,screen,r,A,s,false)
aj(game,screen,c,{
hero={edge=B,x=A,bottom=s+#r*a.SIDE_ROW},
foe={edge=E,x=D,bottom=l+#x*a.SIDE_ROW},
})
local Z=ab(screen,g.hero,g.foe)
I(game,screen,g.hero,Z.hero,f,P(c,"hero"),O(c,"hero"))
J(screen,K(c,"hero"),q(screen,j,"hero"),false,f)
if c.rise==nil and c.morph==nil then
M(game,screen,x,D,l,true)
I(game,screen,g.foe,Z.foe,f,P(c,"foe"),O(c,"foe"))
J(screen,K(c,"foe"),q(screen,i,"foe"),true,f)
end
local m=nil
if c.index>=#u then
if c.result.won then
m=d("Won",c.result.gold)
else
m=d("Lost")
end
elseif a.SPOKEN[g.kind]then
m=ag(c,g)
end
if m then
ak(game,screen,m,c.lineTicks,c.waiting,c.waiting and c.rise==nil and c.morph==nil)
end
end
