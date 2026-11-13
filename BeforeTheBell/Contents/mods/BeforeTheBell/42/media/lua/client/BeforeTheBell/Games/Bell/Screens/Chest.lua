-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Screens/Sheet"

local a={}
BeforeTheBell.Bell.Chest=a

local j=BeforeTheBell.Bell
local b=j.Look
local c=j.Sheet
local f=j.Music
local i=j.Items
local g=j.Profile
local h=b.text

a.COLS=5
a.ROWS=2
a.GAP=2
a.GRID_Y=7
a.ROW_STEP=35
a.LOCKED_DIM=3
a.BANNED_DIM=-1
a.WALL_H=4
a.WALL=3
a.PLANK_STEP=9
a.PLANK_SPAN=60
a.PLANK_SHIFT=30
a.RIM_Y=76
a.RIM_H=18
a.SLOT_Y=79
a.SLOT_X=6
a.SLOT=11
a.SLOT_GAP=1
a.DOTS_Y=84
a.DOT=2
a.DOT_STEP=4
a.BADGE=11
a.CROSS=5
a.BAND_Y=94
a.BAND_TEXT_DY=0
a.MARKS={"favor","ban"}
a.MODAL_W=92
a.MODAL_Y=20
a.MODAL_PAD=4
a.MODAL_ROW=14
a.MODAL_TEXT_DY=0

local function m(profile,item)
return item.pool==i.CHALLENGE and not i.available(item,profile)
end

local function z(profile)
local d={}
for e=1,#i.list do
if i.available(i.list[e],profile)or m(profile,i.list[e])then
d[#d+1]=i.list[e]
end
end
return d
end

function a.enter(game,args)
local d=game.view
d.items=z(game.profile)
d.selected=1
d.describe=false
d.menu=nil
d.marksAtOpen=g.markText(game.profile)
d.party=args.party
end

local function n()
return a.COLS*a.ROWS
end

local function o(view,step)
local d=view.selected+step
if d>=1 and d<=#view.items then
view.selected=d
return true
end
return false
end

local function p(profile)
local k,l=g.markSlots(profile)
local q={ban=k,favor=l}
local d={}
for e=1,#a.MARKS do
if q[a.MARKS[e]]>0 then
d[#d+1]=a.MARKS[e]
end
end
return d
end

local function A(game,pressed)
local d=game.view
local e=p(game.profile)
if(pressed.up or pressed.down or pressed.left or pressed.right)and#e>1 then
d.menu=#e+1-d.menu
game:effect(f.MOVE)
elseif pressed.a then
local k=e[d.menu]
if g.canMark(game.profile,k)then
g.mark(game.profile,d.items[d.selected].id,k)
d.menu=nil
game:effect(f.SELECT)
else
game:effect(f.BUMP)
end
elseif pressed.b then
d.menu=nil
game:effect(f.BACK)
end
end

function a.tick(game,input)
local d=game.view
local e=input.pressed
if d.menu then
A(game,e)
return
end
if d.describe then
if c.step(d,e)then
game:effect(f.MOVE)
elseif e.start or e.b or e.a then
d.describe=false
game:effect(f.BACK)
end
return
end
local k=false
if e.left then k=o(d,-1)end
if e.right then k=o(d,1)end
if e.up then k=o(d,-a.COLS)end
if e.down then k=o(d,a.COLS)end
if k then
game:effect(f.MOVE)
end
if e.a and m(game.profile,d.items[d.selected])then
game:effect(f.BUMP)
elseif e.a and g.marked(game.profile,d.items[d.selected].id)then
g.unmark(game.profile,d.items[d.selected].id)
game:effect(f.BACK)
elseif e.a and#p(game.profile)==0 then
game:effect(f.BUMP)
elseif e.a then
d.menu=1
game:effect(f.SELECT)
elseif e.start then
d.describe=true
c.open(d)
game:effect(f.SELECT)
elseif e.b then
if g.markText(game.profile)~=d.marksAtOpen then
g.write(game.save,game.profile)
game:persist()
end
game:effect(f.BACK)
game:open(j.Camp,{chest=true,party=d.party})
end
end

local function B(screen,x,y,size,shade)
for d=0,size-1 do
screen:rect(x+d,y+d,1,1,b.ink(shade))
screen:rect(x+size-1-d,y+d,1,1,b.ink(shade))
end
end

local function t(game,screen,mark,x,y)
screen:rect(x,y,a.BADGE,a.BADGE,b.ink(1))
screen:rect(x+1,y+1,a.BADGE-2,a.BADGE-2,b.ink(4))
if mark=="ban"then
local d=math.floor((a.BADGE-a.CROSS)/2)
B(screen,x+d,y+d,a.CROSS,1)
else
b.mark(screen,game.sheets,"up",x+1,y+1,0)
end
end

local function C(game,screen,item,x,y,chosen)
local d=g.marked(game.profile,item.id)
local e=0
if m(game.profile,item)then
e=a.LOCKED_DIM
elseif d=="ban"then
e=a.BANNED_DIM
end
if chosen then
screen:rect(x-1,y-1,b.ITEM+2,b.ITEM+2,b.ink(4))
screen:rect(x,y,b.ITEM,b.ITEM,b.ink(1))
screen:rect(x+1,y+1,b.ITEM-2,b.ITEM-2,b.ink(4))
else
screen:rect(x-1,y-1,b.ITEM+2,b.ITEM+2,b.ink(2))
screen:rect(x,y,b.ITEM,b.ITEM,b.ink(4))
end
b.item(screen,game.sheets,item.id,x,y,e)
if d then
t(game,screen,d,x+b.ITEM-a.BADGE,y)
end
end

local function D(screen)
screen:rect(0,0,screen.width,a.WALL_H,b.ink(a.WALL))
screen:rect(0,0,screen.width,1,b.ink(4))
screen:rect(0,a.WALL_H,screen.width,1,b.ink(1))
local d=a.WALL_H+1
local q=a.RIM_Y-d
screen:rect(0,d,screen.width,q,b.ink(2))
local e=0
for k=d+a.PLANK_STEP,a.RIM_Y-1,a.PLANK_STEP do
screen:rect(0,k,screen.width,1,b.ink(1))
e=e+1
end
for k=0,e do
local l=d+k*a.PLANK_STEP
local r=math.min(a.PLANK_STEP,a.RIM_Y-l)
for s=(k%2)*a.PLANK_SHIFT,screen.width-1,a.PLANK_SPAN do
screen:rect(s,l,1,r,b.ink(1))
end
end
end

local function u(game,screen,mark,used,open,fromRight)
for d=1,open do
local e=a.SLOT_X+(d-1)*(a.SLOT+a.SLOT_GAP)
if fromRight then
e=screen.width-a.SLOT_X-d*(a.SLOT+a.SLOT_GAP)+a.SLOT_GAP
end
a.drawSlot(game,screen,mark,d<=used,e,a.SLOT_Y)
end
end

function a.drawSlot(game,screen,mark,used,x,y)
if used then
t(game,screen,mark,x,y)
else
screen:rect(x,y,a.SLOT,a.SLOT,b.ink(2))
screen:rect(x+1,y+1,a.SLOT-2,a.SLOT-2,b.ink(a.WALL))
end
end

local function y(game,screen,item)
screen:rect(0,0,screen.width,screen.height,b.ink(1))
screen:rect(c.POCKET_X-1,c.POCKET_Y-1,b.ITEM+2,b.ITEM+2,b.ink(2))
screen:rect(c.POCKET_X,c.POCKET_Y,b.ITEM,b.ITEM,b.ink(4))
b.item(screen,game.sheets,item.id,c.POCKET_X,c.POCKET_Y,a.LOCKED_DIM)
screen:text(h("Unknown"),c.HEAD_X,c.NAME_Y,b.ink(4))
screen:text(h("Kind_"..item.kind),c.HEAD_X,c.KIND_Y,b.ink(2))
local d=c.BODY_Y
local e=h("SheetUnlock")
screen:text(e,c.LEFT,d,b.ink(2))
local k=c.LEFT+screen:textWidth(e)+c.HEADER_GAP
screen:rect(k,d+7,c.LEFT+c.WIDTH-k,1,b.ink(2))
local l=b.richWrap(screen,h("Challenge_"..item.id),c.WIDTH)
for q=1,#l do
b.richText(screen,game.sheets,l[q],c.LEFT,d+q*c.ROW,b.TEXT_SHADE)
end
end

local function E(game,screen)
local d=p(game.profile)
local q=2*a.MODAL_PAD+#d*a.MODAL_ROW
local k=math.floor((screen.width-a.MODAL_W)/2)
local l=a.MODAL_Y
local r=0
for e=1,#d do
r=math.max(r,b.richWidth(screen,h("ChestMark_"..d[e])))
end
local x=k+math.floor((a.MODAL_W-r)/2)
screen:rect(k-1,l-1,a.MODAL_W+2,q+2,b.ink(1))
screen:rect(k,l,a.MODAL_W,q,b.ink(4))
screen:rect(k+1,l+1,a.MODAL_W-2,q-2,b.ink(1))
for e=1,#d do
local v=l+a.MODAL_PAD+(e-1)*a.MODAL_ROW
local w=not g.canMark(game.profile,d[e])
local s=3
if e==game.view.menu and not w then
s=4
elseif w and e~=game.view.menu then
s=2
end
if e==game.view.menu then
screen:rect(k+a.MODAL_PAD,v,a.MODAL_W-2*a.MODAL_PAD,a.MODAL_ROW,b.ink(2))
end
b.richText(screen,game.sheets,h("ChestMark_"..d[e]),x,v+a.MODAL_TEXT_DY,s)
end
end

function a.draw(game,screen)
local d=game.view
local e=game.profile
local l=d.items[d.selected]
local s=m(e,l)
if d.describe then
if s then
y(game,screen,l)
else
c.draw(game,screen,{profile=game.profile,id=l.id,rank=1,bonuses={}},d)
end
return
end
local F,G=g.markSlots(e)
local k=math.floor(screen.width/2)
screen:rect(0,0,screen.width,screen.height,b.ink(1))
D(screen)
local v=math.floor((d.selected-1)/n())
local w=math.max(1,math.ceil(#d.items/n()))
local H=a.COLS*b.ITEM+(a.COLS-1)*a.GAP
local I=math.floor((screen.width-H)/2)
for q=1,n()do
local r=v*n()+q
local x=d.items[r]
if x then
local J=(q-1)%a.COLS
local K=math.floor((q-1)/a.COLS)
C(game,screen,x,I+J*(b.ITEM+a.GAP),a.GRID_Y+K*a.ROW_STEP,r==d.selected)
end
end
screen:rect(0,a.RIM_Y,screen.width,a.RIM_H,b.ink(a.WALL))
screen:rect(0,a.RIM_Y,screen.width,1,b.ink(4))
u(game,screen,"ban",#e.marks.ban,F,false)
u(game,screen,"favor",#e.marks.favor,G,true)
local J=k-math.floor(w*a.DOT_STEP/2)
for q=0,w-1 do
local r=2
if q==v then
r=4
end
screen:rect(J+q*a.DOT_STEP,a.DOTS_Y,a.DOT,a.DOT,b.ink(r))
end
local q=a.BAND_Y-b.lift(screen,a.BAND_Y+a.BAND_TEXT_DY,2,b.ROW)
b.panel(screen,q,screen.height-q)
local x=h("Item_"..l.id)
if s then
x=h("Unknown")
end
screen:textCentre(x,k,q+a.BAND_TEXT_DY,b.ink(4))
local r=q+a.BAND_TEXT_DY+b.ROW
if d.menu then
E(game,screen)
screen:textCentre(h("ChestMenuKeys"),k,r,b.ink(3))
elseif g.marked(e,l.id)then
screen:textCentre(h("ChestKeysMarked"),k,r,b.ink(3))
elseif#p(e)==0 then
screen:textCentre(h("ChestKeysView"),k,r,b.ink(3))
else
screen:textCentre(h("ChestKeys"),k,r,b.ink(3))
end
end
