-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Map"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Screens/Grid"
require"BeforeTheBell/Games/Bell/Screens/Sheet"
require"BeforeTheBell/Games/Bell/Screens/Replace"
require"BeforeTheBell/Games/Bell/Screens/Merge"

local a={}
BeforeTheBell.Bell.Bag=a

local e=BeforeTheBell.Bell
local b=e.Look
local c=e.Music
local u=e.Items
local z=e.Build
local f=e.Run
local A=e.Map
local q=e.Profile
local h=e.Grid
local j=e.Sheet
local g=b.text

a.COLS=5
a.GAP=4
a.GRID_Y=18
a.ROW_STEP=36
a.BAND_Y=98
a.LINE_DY=-2
a.TAB_Y=40
a.PALE=-1
a.TAB_Y=23
a.DROP_PAD_X=12
a.DROP_PAD_Y=8
a.DROP_TOP=4
a.DROP_BOTTOM=3

function a.position(screen,col,row)
local d=a.COLS*b.ITEM+(a.COLS-1)*a.GAP
local i=math.floor((screen.width-d)/2)
return i+col*(b.ITEM+a.GAP),a.GRID_Y+row*a.ROW_STEP
end

local function l(run)
local d={{kind="weapon",empty=true}}
if run.weapon then
d[1]={kind="weapon",id=run.weapon.id,bonuses=run.weapon.bonuses}
end
for k=1,u.SLOTS do
local i=run.gear[k]
if i then
d[#d+1]={kind="gear",id=i.id,rank=i.rank,slot=k}
else
d[#d+1]={kind="gear",empty=true}
end
end
for i=1,u.BAG do
if run.bag[i]then
d[#d+1]={kind="consumable",id=run.bag[i]}
else
d[#d+1]={kind="consumable",empty=true}
end
end
for i=1,#d do
d[i].col=(i-1)%a.COLS
d[i].row=math.floor((i-1)/a.COLS)
end
return d
end

local function o(view,slot)
for d=1,#view.cells do
if view.cells[d].kind=="gear"and view.cells[d].slot==slot then
return d
end
end
end

function a.enter(game,args)
local d=game.view
d.selected=1
d.describe=false
d.held=nil
d.cells=l(game.run)
d.pending=args and args.pending
d.asking=false
d.askSheet=nil
d.merging=nil
d.dropping=nil
d.place=args and args.place
d.browse=args and args.browse
d.backTo=args and args.selected
if d.pending then
d.selected=o(d,f.mergeTarget(game.run,d.pending.item)or 1)
end
end

local function r(game,cell)
local d=game.view.cells[game.view.held]
if cell.kind~="gear"then
return nil
end
if cell.slot==d.slot then
return"back"
end
if not cell.empty and f.canMerge(game.run,d.slot,cell.slot)then
return"merge"
end
return"move"
end

local function B(game,from,into)
local d=game.view
local i=f.merge(game.run,from,into)
q.noteRank(game.profile,game.run.gear[i])
game:effect(c.FORGE)
d.cells=l(game.run)
d.selected=o(d,i)
end

local function C(game,cell)
local d=game.view
local i=d.cells[d.held]
local k=r(game,cell)
d.held=nil
if k==nil then
game:effect(c.BUMP)
return
end
if k=="back"then
game:effect(c.SELECT)
return
end
if k=="merge"then
d.merging={from=i.slot,into=cell.slot}
d.askSheet=nil
game:effect(c.SELECT)
return
end
local m
if cell.empty then
f.moveLast(game.run,i.slot)
m=#game.run.gear
game:effect(c.SELECT)
else
f.swap(game.run,i.slot,cell.slot)
m=cell.slot
game:effect(c.SELECT)
end
d.cells=l(game.run)
d.selected=o(d,m)
end

local function D(game,cell)
local d=game.view
if d.held then
C(game,cell)
return
end
if cell.kind=="consumable"and cell.id=="HealingPotion"then
f.drinkPotion(game.run)
game:effect(c.HEAL)
d.cells=l(game.run)
elseif cell.kind=="consumable"and cell.id=="BearTrap"and not d.pending and A.setTrap(game.map)then
f.spend(game.run,"BearTrap",1)
game:effect(c.CLANG)
d.cells=l(game.run)
elseif cell.kind=="gear"and not cell.empty then
d.held=d.selected
game:effect(c.SELECT)
else
game:effect(c.BUMP)
end
end

local function E(view)
local i={}
for d=1,#view.cells do
if view.cells[d].kind=="gear"then
i[#i+1]={col=view.cells[d].col,row=view.cells[d].row,index=d}
end
end
return i
end

local function F(game,input)
local d=game.view
local i=input.pressed
local k=E(d)
local n=1
for m=1,#k do
if k[m].index==d.selected then
n=m
end
end
local p,s=h.step(i)
if p then
local m=h.move(k,n,p,s)
if m~=n then
d.selected=k[m].index
game:effect(c.MOVE)
end
end
local m=d.cells[d.selected]
if i.b then
game:effect(c.BACK)
game:open(e.Offer,{place=d.place,opened=true})
elseif i.start then
d.describe=true
j.open(d)
game:effect(c.SELECT)
elseif i.a and m.empty then
f.take(game.run,d.pending.item)
game:open(e.Offer,{place=d.place,opened=true,placed=d.pending})
elseif i.a and f.canMergeIncoming(game.run,m.slot,d.pending.item)then
f.mergeIncoming(game.run,m.slot)
q.noteRank(game.profile,game.run.gear[m.slot])
game:open(e.Offer,{place=d.place,opened=true,placed=d.pending})
elseif i.a then
d.asking=true
game:effect(c.SELECT)
end
end

local function v(game,pressed)
local d=game.view
if d.askSheet then
if j.step(d,pressed)then
game:effect(c.MOVE)
elseif pressed.left or pressed.right then
if d.askSheet=="new"then
d.askSheet="worn"
else
d.askSheet="new"
end
j.open(d)
game:effect(c.MOVE)
elseif pressed.b or pressed.start then
d.askSheet=nil
game:effect(c.BACK)
end
return true
end
if pressed.start then
d.askSheet="new"
j.open(d)
game:effect(c.SELECT)
return true
end
return false
end

local function G(game,input)
local d=game.view
local i=input.pressed
if v(game,i)then
return
end
if i.a then
local k=d.merging
d.merging=nil
B(game,k.from,k.into)
elseif i.b then
d.held=o(d,d.merging.from)
d.merging=nil
game:effect(c.BACK)
end
end

local function H(game,input)
local d=game.view
local i=input.pressed
if i.a then
f.drop(game.run,d.dropping)
d.dropping=nil
d.cells=l(game.run)
game:effect(c.BACK)
elseif i.b then
d.held=o(d,d.dropping)
d.dropping=nil
game:effect(c.BACK)
end
end

local function I(game,input)
local d=game.view
local k=input.pressed
local i=d.cells[d.selected]
if v(game,k)then
return
end
if k.b then
d.asking=false
game:effect(c.BACK)
elseif k.a then
if f.canMergeIncoming(game.run,i.slot,d.pending.item)then
f.mergeIncoming(game.run,i.slot)
q.noteRank(game.profile,game.run.gear[i.slot])
else
f.replace(game.run,i.slot,d.pending.item)
end
game:open(e.Offer,{place=d.place,opened=true,placed=d.pending})
end
end

local function J(game,input)
local d=game.view
local i=input.pressed
local k,p=h.step(i)
local m=i.b
if k then
local n=h.move(d.cells,d.selected,k,p)
if n~=d.selected then
d.selected=n
game:effect(c.MOVE)
elseif i.left then
m=true
end
end
if m then
game:effect(c.BACK)
game:open(e.Offer,{place=d.place,opened=true,selected=d.backTo})
elseif i.start and not d.cells[d.selected].empty then
d.describe=true
j.open(d)
game:effect(c.SELECT)
elseif i.a then
game:effect(c.BUMP)
end
end

function a.tick(game,input)
local d=game.view
local i=input.pressed
if d.describe then
if j.step(d,i)then
game:effect(c.MOVE)
elseif i.a or i.b or i.start then
d.describe=false
game:effect(c.BACK)
end
return
end
if d.pending and d.asking then
I(game,input)
return
end
if d.merging then
G(game,input)
return
end
if d.dropping then
H(game,input)
return
end
if d.pending then
F(game,input)
return
end
if d.browse then
J(game,input)
return
end
local m,n=h.step(i)
if m then
local k=h.move(d.cells,d.selected,m,n)
if k~=d.selected then
d.selected=k
game:effect(c.MOVE)
end
end
local k=d.cells[d.selected]
if i.b and d.held then
d.held=nil
game:effect(c.BACK)
elseif i.b then
game:effect(c.BACK)
game:backToLand()
elseif i.start and d.held and r(game,k)=="back"then
d.dropping=k.slot
d.held=nil
game:effect(c.SELECT)
elseif i.start and not k.empty and not d.held then
d.describe=true
j.open(d)
game:effect(c.SELECT)
elseif i.a then
D(game,k)
end
end

local function K(screen,cell)
return a.position(screen,cell.col,cell.row)
end

a.STATS_Y=84
a.DIGIT_FOOT=3
a.STAT_GAP=7
a.HP_BAR_TOP=4
a.HP_BAR_H=7
a.HP_BAR_GAP=1
a.STAT_MARKS={{key="atk",mark="physical"},{key="spd",mark="speed"},{key="arm",mark="armor"}}

local function L(screen,fighter)
local d=b.ICON+b.ICON_GAP+screen:textWidth(tostring(fighter.hp))+1+a.HP_BAR_GAP+screen:textWidth(tostring(fighter.maxHp))
for i=1,#a.STAT_MARKS do
d=d+a.STAT_GAP+b.ICON+b.ICON_GAP+screen:textWidth(tostring(fighter[a.STAT_MARKS[i].key]))
end
return d
end

local function M(game,screen,fighter)
local i=a.STATS_Y
local d=math.floor((screen.width-L(screen,fighter))/2)
b.icon(screen,game.sheets,"heart",d,i+b.ICON_DY)
d=d+b.ICON+b.ICON_GAP
local k=tostring(fighter.hp)
screen:text(k,d,i,b.ink(4))
d=d+screen:textWidth(k)
screen:rect(d,i+a.HP_BAR_TOP,1,a.HP_BAR_H,b.ink(3))
d=d+1+a.HP_BAR_GAP
local m=tostring(fighter.maxHp)
screen:text(m,d,i,b.ink(4))
d=d+screen:textWidth(m)+a.STAT_GAP
for s=1,#a.STAT_MARKS do
local n=a.STAT_MARKS[s]
b.markLit(screen,game.sheets,n.mark,d,i+b.ICON_DY)
d=d+b.ICON+b.ICON_GAP
local p=tostring(fighter[n.key])
screen:text(p,d,i,b.ink(4))
d=d+screen:textWidth(p)+a.STAT_GAP
end
end

local function s(cell)
if cell.rank then
return b.itemName(cell.id,cell.rank)
end
return g("Item_"..cell.id)
end

local function N(screen,second)
local d=1
if second then
d=2
end
return a.BAND_Y-b.lift(screen,a.BAND_Y+a.LINE_DY,d,b.ROW)
end

local function O(game,view,cell)
if view.pending and cell.empty then
return g("Item_"..view.pending.item.id),g("PlaceHint")
end
if view.pending then
local d,i="SwapFor","SwapHint"
if f.canMergeIncoming(game.run,cell.slot,view.pending.item)then
d,i="MergeFor","MergeHint"
end
return g(d,g("Item_"..view.pending.item.id)),g(i)
end
if view.dropping then
return s(cell),nil
end
if view.held then
local d=r(game,cell)
local i="HoldHint"
if d then
i="HoldHint_"..d
end
return g("Holding",s(view.cells[view.held])),g(i)
end
if cell.empty then
return g("EmptySlot"),nil
end
local d="ChestKeysView"
if view.browse then
d="ChestKeysView"
elseif cell.kind=="gear"then
d="BagKeysGear"
elseif cell.kind=="consumable"and cell.id=="HealingPotion"then
d="BagKeysDrink"
elseif cell.kind=="consumable"and cell.id=="BearTrap"then
d="BagKeysTrap"
end
return s(cell),g(d)
end

local function P(screen,top,first,second)
local d=math.floor(screen.width/2)
b.panel(screen,top,screen.height-top)
screen:textCentre(first,d,top+a.LINE_DY,b.ink(4))
if second then
screen:textCentre(second,d,top+a.LINE_DY+b.ROW,b.ink(3))
end
end

local function w(game,screen,incoming,runAfter,worn)
local i=game.view
local d,k,m=incoming,"TabNew",runAfter
if i.askSheet=="worn"then
d,k,m=worn,"TabWorn",game.run
end
j.draw(game,screen,{run=m,profile=game.profile,id=d.id,rank=d.rank,bonuses={}},i)
screen:textRight(g(k),screen.width-3,a.TAB_Y,b.ink(2))
end

local function Q(game,screen)
local k=g("AskDrop",g("Item_"..game.run.gear[game.view.dropping].id))
local m=g("DropKeys")
local n=math.max(screen:textWidth(k),screen:textWidth(m))+2*a.DROP_PAD_X
local d=b.ROW+screen:lineHeight()+2*a.DROP_PAD_Y
local t=math.floor((screen.width-n)/2)
local i=math.floor((screen.height-d)/2)
local p=math.floor(screen.width/2)
b.plate(screen,t,i,n,d)
screen:textCentre(k,p,i+a.DROP_TOP,b.ink(4))
screen:textCentre(m,p,i+d-a.DROP_BOTTOM-screen:lineHeight(),b.ink(3))
end

function a.draw(game,screen)
local d=game.view
local i=d.cells[d.selected]
if d.pending and d.asking then
local m=game.run.gear[i.slot]
local n=f.canMergeIncoming(game.run,i.slot,d.pending.item)
local k={id=d.pending.item.id,rank=1}
if n then
k.rank=m.rank+1
end
if d.askSheet then
w(game,screen,k,e.Replace.runAfter(game.run,i.slot,k),m)
return
end
if n then
e.Merge.draw(game,screen,m)
else
e.Replace.draw(game,screen,i.slot,k)
end
return
end
if d.merging then
local k=game.run.gear[d.merging.into]
if d.askSheet then
w(game,screen,{id=k.id,rank=k.rank+1},game.run,k)
return
end
e.Merge.draw(game,screen,k)
return
end
if d.describe then
local k=1
if i.kind=="gear"then
k=i.rank
end
j.draw(game,screen,{run=game.run,profile=game.profile,id=i.id,rank=k,bonuses=i.bonuses},d)
return
end
local R=z.hero(game.run)
b.backdrop(screen,game.sheets.bagBack)
screen:rect(0,0,screen.width,14,b.ink(1))
screen:textCentre(g("Bag"),math.floor(screen.width/2),-1,b.ink(4))
b.amount(screen,game.sheets,"coin",game.run.gold,screen.width-4,-1,3,0,"right")
local S,x=O(game,d,i)
local y=N(screen,x)
if a.STATS_Y+screen:lineHeight()-a.DIGIT_FOOT<=y+a.LINE_DY then
M(game,screen,R)
end
for p=1,#d.cells do
local k=d.cells[p]
local m,n=K(screen,k)
if k.empty then
b.slot(screen,game.sheets,k.kind,m,n)
h.empty(screen,m,n)
else
local t=0
if p==d.held then
t=1
elseif d.pending and k.kind~="gear"then
t=a.PALE
end
b.item(screen,game.sheets,k.id,m,n,t)
if k.rank then
b.rank(screen,game.sheets,k.rank,m,n)
end
end
if p==d.selected then
h.cursor(screen,m,n,b.ITEM,b.ITEM)
end
if p==d.held then
h.select(screen,m,n,b.ITEM,b.ITEM,game.ticks,h.ON_DARK)
end
end
P(screen,y,S,x)
if d.browse then
b.bagTab(screen,"left",a.TAB_Y,d.place.kind)
end
if d.dropping then
Q(game,screen)
end
end
