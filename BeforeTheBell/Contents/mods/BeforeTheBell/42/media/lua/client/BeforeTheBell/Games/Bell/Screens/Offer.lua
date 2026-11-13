-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Rules/Map"
require"BeforeTheBell/Games/Bell/Screens/Grid"
require"BeforeTheBell/Games/Bell/Screens/Bag"
require"BeforeTheBell/Games/Bell/Screens/Sheet"
require"BeforeTheBell/Games/Bell/Data/Effects"

local a={}
BeforeTheBell.Bell.Offer=a

local e=BeforeTheBell.Bell
local b=e.Look
local c=e.Music
local n=e.Items
local g=e.Run
local u=e.Map
local i=e.Grid
local j=e.Sheet
local f=b.text

a.MESSAGE_TICKS=90
a.STALL_COLS=3
a.MERCHANT_COLS=4
a.GAP=8
a.GRID_Y=15
a.ROW_STEP=47
a.PRICE_Y=30
a.MARK_Y=43
a.BAND_Y=108
a.PLACE_BAND_Y=96
a.PLACE_LINE_Y=95
a.WEAPON_X=22
a.WEAPON_Y=22
a.SOCKET_X=64
a.SOCKET_Y=24
a.SOCKET_H=13
a.SOCKET_STEP=17
a.CARD_Y=66
a.CARD_H=22
a.CARD_GAP=8
a.NICHE_Y=30
a.NICHE_GAP=14
a.NICHE_PRICE_Y=32
a.NICHE_MARK_Y=47
a.MAX_GAP=2
a.FIRE_X=125
a.FIRE_Y=35
a.FIRE_W=40
a.FIRE_H=20
a.FIRE_FRAMES=4
a.FIRE_TICKS=12
a.BLAZE_Y=25
a.BLAZE_H=30
a.BLAZE_TICKS=7
a.FORGE_TICKS=160
a.CLANGS={24,64,104}
a.SPARK_TICKS=5
a.SPARK="arrow"
a.FLAME_SHADES={3,4}
a.CANDLES={{x=8,y=47,offset=0},{x=168,y=47,offset=2}}
a.CANDLE_W=5
a.CANDLE_H=7
a.CANDLE_FRAMES=4
a.CANDLE_TICKS=9
a.CHEST_ITEM_Y=42
a.CHEST_GAP=14
a.CHEST_MARK_Y=34
a.OPEN_TICKS=31
a.SWING_X=20
a.SWING_Y=16
a.SWING_W=140
a.SWING_H=64
a.SWING_FRAMES=10
a.UNLOCK_TICKS=15
a.JIGGLE_FROM=2
a.SPARKLE_TICKS=24
a.SPARKLE_STEP=4
a.SPARKLE_FRAME_TICKS=3
a.PLENTY_BOX={sx=88,sy=14,w=44,h=36,dx=40}
a.PLENTY_TICKS=66
a.PLENTY_SPARKS=12
a.PLENTY_FADE=36
a.PLENTY_FADE_STEPS=3
a.PLENTY_REACH=30
a.TAB_Y={merchant=46,chest=40}
a.THEMES={chest=c.ROAD,merchant=c.MARKET,forge=c.SMITHY,shrine=c.SHRINE}
a.BONUS_MARKS={atk="physical",arm="armor",spd="speed",hp="life",thorns="thorns"}

local function D(game,place)
if place.offer then
return place.offer
end
local d=game.run
if place.kind=="chest"then
place.offer=g.chestOffer(d,game.random,game.profile)
elseif place.kind=="merchant"then
place.offer=g.merchantOffer(d,game.random,game.profile)
elseif place.kind=="shrine"then
place.offer=g.shrineOffer(d,game.random)
end
return place.offer
end

local function E(entries)
local d={}
local k=0
for l=1,#entries do
local h=entries[l]
if h.item.kind==n.CONSUMABLE then
d[#d+1]={entry=h,col=a.MERCHANT_COLS-1,row=1}
elseif h.plenty then
d[#d+1]={entry=h,col=a.MERCHANT_COLS-1,row=0}
else
d[#d+1]={entry=h,col=k%a.STALL_COLS,row=math.floor(k/a.STALL_COLS)}
k=k+1
end
end
return d
end

function a.enter(game,args)
local d=game.view
d.place=args.place
d.selected=args.selected or 1
d.phase="list"
d.describe=false
d.message=nil
d.messageTicks=0
d.entries=a.entries(game)
d.opening=a.OPEN_TICKS
d.sparkle=a.SPARKLE_TICKS
d.placed=args.placed
game:playMusic(a.THEMES[d.place.kind])
if d.place.kind=="chest"and not args.opened then
d.opening=0
d.sparkle=0
game:effect(c.CHEST)
end
if d.place.kind=="merchant"then
d.stalls=E(d.entries)
d.plenty=nil
for h=1,#d.entries do
if d.entries[h].plenty and not d.entries[h].revealed then
d.entries[h].revealed=true
d.plenty=0
end
end
elseif d.place.kind=="forge"and#d.entries>0 then
local h=d.entries[1].item.id
d.place.choices=d.place.choices or{}
if d.place.choices[h]==nil then
d.place.choices[h]=g.forgeChoices(game.random)
end
d.forging=d.entries[1]
d.bonuses=d.place.choices[h]
d.bonus=1
d.phase="bonus"
end
end

function a.entries(game)
local d=game.view.place
if d.kind=="forge"then
return g.forgeOffer(game.run)
end
return D(game,d)
end

local function o(game,key)
game.view.message=f(key)
game.view.messageTicks=a.MESSAGE_TICKS
end

local function k(game,used)
if used then
u.removePlace(game.map,game.view.place)
end
game:effect(c.BACK)
game:backToLand()
end

local function v(game,entry)
local d=game.view
e.Profile.noteSets(game.profile,game.run)
game:effect(c.COIN)
if d.place.kind=="chest"then
k(game,true)
return
end
game.run.gold=game.run.gold-entry.price
entry.sold=true
d.phase="list"
end

local function p(game,entry)
local d=game.view
if entry.sold then
game:effect(c.BUMP)
return
end
if game.run.gold<entry.price then
game:effect(c.BUMP)
o(game,"NoGold")
return
end
if entry.item.kind==n.GEAR and g.mergeTarget(game.run,entry.item)then
game:effect(c.MOVE)
game:open(e.Bag,{pending=entry,place=d.place})
return
end
if entry.item.kind==n.WEAPON and game.run.weapon and not d.confirmed then
d.weaponAsk=entry
game:effect(c.SELECT)
return
end
d.confirmed=nil
local h=g.take(game.run,entry.item)
if h=="taken"then
v(game,entry)
elseif h=="full"then
game:effect(c.MOVE)
game:open(e.Bag,{pending=entry,place=d.place})
else
game:effect(c.BUMP)
o(game,"BagFull")
end
end

local function F(game,input)
local d=game.view
local h=input.pressed
if d.describe then
if j.step(d,h)then
game:effect(c.MOVE)
elseif h.b or h.start then
d.describe=false
game:effect(c.BACK)
end
return
end
if h.a then
local l=d.weaponAsk
d.weaponAsk=nil
d.confirmed=true
p(game,l)
elseif h.b then
d.weaponAsk=nil
game:effect(c.BACK)
elseif h.start then
d.describe=true
j.open(d)
game:effect(c.SELECT)
end
end

local function G(game,entry)
if game.view.place.kind=="shrine"then
if g.bless(game.run,entry)then
game:effect(c.BLESS)
k(game,true)
u.shrinesToChests(game.map)
else
game:effect(c.BUMP)
o(game,"CannotPay")
end
else
p(game,entry)
end
end

local function w(game,slot)
local d=game.view
g.forge(game.run,d.forging,d.bonuses[d.bonus],slot)
d.forged=d.bonuses[d.bonus]
d.phase="forging"
d.forgeTicks=0
game:effect(c.HISS)
end

local function H(game)
local d=game.view
d.forgeTicks=d.forgeTicks+1
for h=1,#a.CLANGS do
if d.forgeTicks==a.CLANGS[h]then
game:effect(c.CLANG)
end
end
if d.forgeTicks>=a.FORGE_TICKS then
k(game,true)
end
end

local function I(game,input)
local d=game.view
local h=input.pressed
if h.left or h.right then
local l=h.left and-1 or 1
d.bonus=(d.bonus-1+l+#d.bonuses)%#d.bonuses+1
game:effect(c.MOVE)
end
if h.a then
if game.run.gold<d.forging.price then
game:effect(c.BUMP)
o(game,"NoGold")
elseif g.forgeFull(game.run)then
d.phase="slot"
d.slot=1
game:effect(c.MOVE)
else
w(game,nil)
end
elseif h.b then
k(game,false)
end
end

local function J(game,input)
local h=game.view
local d=input.pressed
if d.up or d.down then
local l=d.up and-1 or 1
h.slot=(h.slot-1+l+g.FORGE_SLOTS)%g.FORGE_SLOTS+1
game:effect(c.MOVE)
end
if d.a then
w(game,h.slot)
elseif d.b then
h.phase="bonus"
game:effect(c.BACK)
end
end

local function z(game)
local d=game.view
game:effect(c.MOVE)
game:open(e.Bag,{browse=true,place=d.place,selected=d.selected})
end

local function K(game,input)
local d=game.view
local h=input.pressed
d.sparkle=d.sparkle+1
if d.opening<a.OPEN_TICKS then
d.opening=d.opening+1
d.sparkle=0
return
end
if d.describe then
if j.step(d,h)then
game:effect(c.MOVE)
elseif h.a or h.b or h.start then
d.describe=false
game:effect(c.BACK)
end
return
end
if h.b then
k(game,false)
return
end
if#d.entries==0 then
return
end
if h.right and d.selected==#d.entries then
z(game)
return
end
if h.left or h.right then
local l=h.left and-1 or 1
d.selected=(d.selected-1+l+#d.entries)%#d.entries+1
game:effect(c.MOVE)
end
if h.start then
d.describe=true
j.open(d)
game:effect(c.SELECT)
elseif h.a then
p(game,d.entries[d.selected])
end
end

local function L(game,input)
local d=game.view
local h=input.pressed
if h.b then
k(game,false)
return
end
if#d.entries==0 then
return
end
if h.left or h.right then
local l=h.left and-1 or 1
d.selected=(d.selected-1+l+#d.entries)%#d.entries+1
game:effect(c.MOVE)
end
if h.a then
G(game,d.entries[d.selected])
end
end

local function M(game,input)
local d=game.view
local h=input.pressed
if d.describe then
if j.step(d,h)then
game:effect(c.MOVE)
elseif h.a or h.b or h.start then
d.describe=false
game:effect(c.BACK)
end
return
end
if h.b then
k(game,false)
return
end
if#d.stalls==0 then
return
end
local l,q=i.step(h)
if l then
local m=i.move(d.stalls,d.selected,l,q)
if m~=d.selected then
d.selected=m
game:effect(c.MOVE)
elseif h.right then
z(game)
return
end
end
local m=d.stalls[d.selected].entry
if h.start and not m.sold then
d.describe=true
j.open(d)
game:effect(c.SELECT)
elseif h.a then
p(game,m)
end
end

function a.tick(game,input)
local d=game.view
if d.placed then
local h=d.placed
d.placed=nil
v(game,h)
return
end
if d.messageTicks>0 then
d.messageTicks=d.messageTicks-1
end
if d.weaponAsk then
F(game,input)
return
end
if d.phase=="forging"then
H(game)
return
end
if d.phase=="bonus"then
I(game,input)
return
end
if d.phase=="slot"then
J(game,input)
return
end
if d.place.kind=="merchant"then
if d.plenty and d.plenty<a.PLENTY_TICKS+a.PLENTY_FADE+a.SPARKLE_TICKS then
d.plenty=d.plenty+1
if d.plenty==1 then
game:effect(c.BLESS)
elseif d.plenty==a.PLENTY_TICKS+a.PLENTY_FADE then
game:effect(c.COIN)
end
return
end
M(game,input)
return
end
if d.place.kind=="forge"then
if input.pressed.b or input.pressed.a then
k(game,false)
end
return
end
if d.place.kind=="shrine"then
L(game,input)
return
end
if d.place.kind=="chest"then
K(game,input)
return
end
end

local function N(game,screen,ticks)
local d=a.PLENTY_BOX
local h,l=d.w,d.h
if ticks~=nil and ticks<a.PLENTY_TICKS then
local m=1-(1-ticks/a.PLENTY_TICKS)^2
h=math.max(2,math.floor(d.w*m/2)*2)
l=math.max(2,math.floor(d.h*m/2)*2)
end
local m,q=(d.w-h)/2,(d.h-l)/2
for r=1,4 do
screen:sheet(game.sheets.stallBack,d.sx+m,(r-1)*screen.height+d.sy+q,h,l,d.sx+d.dx+m,d.sy+q,1,r)
end
end

local function O(screen,ticks)
local h=a.PLENTY_BOX
local x,y=h.sx+h.dx+h.w/2,h.sy+h.h/2
local q=ticks/a.PLENTY_TICKS
for r=1,a.PLENTY_SPARKS do
local s=2*math.pi*r/a.PLENTY_SPARKS+q*2.5
local t=a.PLENTY_REACH*q*(0.6+0.4*(r%3)/2)
local m=math.floor(x+math.cos(s)*t)
local l=math.floor(y+math.sin(s)*t*0.8)
if l>a.PLENTY_BOX.sy then
local d=2
if q>0.7 or r%2==0 then
d=1
end
screen:rect(m-d-1,l-1,2*d+3,3,b.ink(1))
screen:rect(m-1,l-d-1,3,2*d+3,b.ink(1))
screen:rect(m-d,l,2*d+1,1,b.ink(4))
screen:rect(m,l-d,1,2*d+1,b.ink(4))
end
end
end

local function P(ticks)
local d=ticks-a.PLENTY_TICKS
if d>=a.PLENTY_FADE then
return 0
end
return a.PLENTY_FADE_STEPS-math.floor(d*a.PLENTY_FADE_STEPS/a.PLENTY_FADE)
end

local function Q(game,screen,ticks,x,y)
local h=e.Effects.list.arrow
local d=math.floor(ticks/a.SPARKLE_FRAME_TICKS)
if d>=0 and d<h.count then
screen:layers(game.sheets.fx,(h.right+d)*e.Effects.CELL,e.Effects.CELL,e.Effects.CELL,x+8,y-4,b.ALL_SHADES)
end
end

local function R(game,screen)
local d=game.view
local q=math.floor(screen.width/2)
if d.describe then
j.draw(game,screen,{run=game.run,profile=game.profile,id=d.stalls[d.selected].entry.item.id,rank=1,bonuses={}},d)
return
end
b.backdrop(screen,game.sheets.stallBack)
screen:rect(0,0,screen.width,14,b.ink(1))
screen:textCentre(f("Place_merchant"),math.floor(screen.width/2),-1,b.ink(4))
b.amount(screen,game.sheets,"coin",game.run.gold,screen.width-4,-1,3,0,"right")
local y=a.MERCHANT_COLS*b.ITEM+(a.MERCHANT_COLS-1)*a.GAP
local A=math.floor((screen.width-y)/2)
for s=1,#d.stalls do
local h=d.stalls[s]
local l=A+h.col*(b.ITEM+a.GAP)
local m=a.GRID_Y+h.row*a.ROW_STEP
local t=h.entry.plenty and d.plenty~=nil and d.plenty<a.PLENTY_TICKS
if h.entry.plenty then
N(game,screen,d.plenty)
if t then
O(screen,d.plenty)
end
end
if t then
l=nil
elseif h.entry.sold then
i.empty(screen,l,m)
else
local r=0
if h.entry.plenty and d.plenty~=nil then
r=P(d.plenty)
end
b.item(screen,game.sheets,h.entry.item.id,l,m,-r)
local x=2
if game.run.gold<h.entry.price then
x=3
end
b.amount(screen,game.sheets,"coin",h.entry.price,l+math.floor(b.ITEM/2),m+a.PRICE_Y,math.min(4,x+r),b.ON_LIGHT-2*r,"centre")
end
if l and s==d.selected then
i.cursor(screen,l,m,b.ITEM,a.MARK_Y-2)
end
if l and h.entry.plenty and d.plenty~=nil and d.plenty>=a.PLENTY_TICKS+a.PLENTY_FADE and d.plenty<a.PLENTY_TICKS+a.PLENTY_FADE+a.SPARKLE_TICKS then
Q(game,screen,d.plenty-a.PLENTY_TICKS-a.PLENTY_FADE,l,m)
end
end
local h=a.BAND_Y-b.lift(screen,a.BAND_Y-1,1,0)
b.panel(screen,h,screen.height-h)
if d.messageTicks>0 then
screen:textCentre(d.message,q,h-1,b.ink(4))
elseif#d.stalls==0 then
screen:textCentre(f("Empty"),q,h-1,b.ink(3))
elseif d.stalls[d.selected].entry.sold then
screen:textCentre(f("Sold"),q,h-1,b.ink(3))
else
screen:textCentre(f("Item_"..d.stalls[d.selected].entry.item.id),q,h-1,b.ink(4))
end
end

local function h(game,screen,first,second)
local l=math.floor(screen.width/2)
local d=b.lift(screen,a.PLACE_LINE_Y,2,b.ROW)
b.panel(screen,a.PLACE_BAND_Y-d,screen.height-a.PLACE_BAND_Y+d)
b.richCentre(screen,game.sheets,first,l,a.PLACE_LINE_Y-d,4)
if second then
b.richCentre(screen,game.sheets,second,l,a.PLACE_LINE_Y-d+b.ROW,3)
end
end

local function q(game,screen)
screen:rect(0,0,screen.width,14,b.ink(1))
screen:textCentre(f("Place_"..game.view.place.kind),math.floor(screen.width/2),-1,b.ink(4))
b.amount(screen,game.sheets,"coin",game.run.gold,screen.width-4,-1,3,0,"right")
end

local function A(game,screen,bonus,x,y)
b.mark(screen,game.sheets,a.BONUS_MARKS[bonus],x,y+b.ICON_DY,0)
screen:text("+"..n.FORGE_BONUS[bonus],x+b.ICON+b.ICON_GAP,y,b.ink(1))
end

local function S(game,screen,ticks)
local l=e.Effects.list[a.SPARK]
for m=1,#a.CLANGS do
local d=math.floor((ticks-a.CLANGS[m])/a.SPARK_TICKS)
if d>=0 and d<l.count then
screen:layers(game.sheets.fx,(l.right+d)*e.Effects.CELL,e.Effects.CELL,e.Effects.CELL,a.WEAPON_X,a.WEAPON_Y,b.ALL_SHADES)
end
end
end

local function T(game,screen)
local d=game.view
b.backdrop(screen,game.sheets.forgeBack)
if d.phase=="forging"then
local l=math.floor(d.forgeTicks/a.BLAZE_TICKS)%a.FIRE_FRAMES
screen:layers(game.sheets.forgeBlaze,l*a.FIRE_W,a.FIRE_W,a.BLAZE_H,a.FIRE_X,a.BLAZE_Y,a.FLAME_SHADES)
else
local l=math.floor(game.ticks/a.FIRE_TICKS)%a.FIRE_FRAMES
screen:layers(game.sheets.forgeFire,l*a.FIRE_W,a.FIRE_W,a.FIRE_H,a.FIRE_X,a.FIRE_Y,a.FLAME_SHADES)
end
q(game,screen)
if d.forging==nil then
h(game,screen,f("NoWeapon"),nil)
return
end
b.item(screen,game.sheets,d.forging.item.id,a.WEAPON_X,a.WEAPON_Y,0)
if d.phase=="forging"then
S(game,screen,d.forgeTicks)
end
local r=game.run.weapon.bonuses
for m=1,g.FORGE_SLOTS do
local l=a.SOCKET_Y+(m-1)*a.SOCKET_STEP
screen:rect(a.SOCKET_X,l,b.ITEM,a.SOCKET_H,b.ink(1))
if r[m]then
screen:rect(a.SOCKET_X+1,l+1,b.ITEM-2,a.SOCKET_H-2,b.ink(4))
A(game,screen,r[m],a.SOCKET_X+4,l)
else
screen:rect(a.SOCKET_X+1,l+1,b.ITEM-2,a.SOCKET_H-2,b.ink(2))
screen:rect(a.SOCKET_X+4,l+math.floor(a.SOCKET_H/2),b.ITEM-8,1,b.ink(3))
end
if d.phase=="slot"and m==d.slot then
i.cursor(screen,a.SOCKET_X,l,b.ITEM,a.SOCKET_H)
end
end
local x=#d.bonuses*b.ITEM+(#d.bonuses-1)*a.CARD_GAP
local y=math.floor((screen.width-x)/2)
for m=1,#d.bonuses do
local l=y+(m-1)*(b.ITEM+a.CARD_GAP)
screen:rect(l,a.CARD_Y,b.ITEM,a.CARD_H,b.ink(1))
screen:rect(l+1,a.CARD_Y+1,b.ITEM-2,a.CARD_H-2,b.ink(4))
A(game,screen,d.bonuses[m],l+5,a.CARD_Y+3)
if d.phase=="bonus"and m==d.bonus then
i.cursor(screen,l,a.CARD_Y,b.ITEM,a.CARD_H)
end
if d.phase=="slot"and m==d.bonus then
i.select(screen,l,a.CARD_Y,b.ITEM,a.CARD_H,game.ticks,i.ON_LIGHT)
end
end
local m=f("Bonus_"..d.bonuses[d.bonus])
if d.phase=="forging"then
h(game,screen,f("ForgedWith",f("Bonus_"..d.forged)),nil)
return
end
if d.phase=="slot"then
h(game,screen,f("ForgeReplace",f("Bonus_"..r[d.slot])),f("ReplaceHint"))
return
end
if d.messageTicks>0 then
h(game,screen,m,d.message)
return
end
h(game,screen,m,nil)
local l=f("ForgeFor")
local B=tostring(d.forging.price)
local C=screen:textWidth(l)+b.ICON_GAP*2+b.ICON+screen:textWidth(B)
local s=math.floor((screen.width-C)/2)
local t=a.PLACE_LINE_Y-b.lift(screen,a.PLACE_LINE_Y,2,b.ROW)+b.ROW
screen:text(l,s,t,b.ink(3))
b.amount(screen,game.sheets,"coin",d.forging.price,s+screen:textWidth(l)+b.ICON_GAP,t,3,0,"left")
end

local function U(game,screen,ticks)
local l=0
local d=0
if ticks<a.UNLOCK_TICKS then
if ticks>=a.JIGGLE_FROM and ticks%4<2 then
d=1
end
else
local m=(ticks-a.UNLOCK_TICKS)/(a.OPEN_TICKS-a.UNLOCK_TICKS)
local r=1-(1-m)*(1-m)
l=math.min(a.SWING_FRAMES-1,math.floor(r*a.SWING_FRAMES))
end
if d>0 then
screen:rect(a.SWING_X,a.SWING_Y,a.SWING_W,d,b.ink(3))
end
screen:layers(game.sheets.chestSwing,l*a.SWING_W,a.SWING_W,a.SWING_H,a.SWING_X,a.SWING_Y+d,b.ALL_SHADES)
end

local function V(game,screen,ticks,left)
local m=e.Effects.list.arrow
for d=1,3 do
local l=math.floor((ticks-(d-1)*a.SPARKLE_STEP)/a.SPARKLE_FRAME_TICKS)
if l>=0 and l<m.count then
local r=left+(d-1)*(b.ITEM+a.CHEST_GAP)
screen:layers(game.sheets.fx,(m.right+l)*e.Effects.CELL,e.Effects.CELL,e.Effects.CELL,r+8-(d%2)*10,a.CHEST_ITEM_Y-8+(d%2)*6,b.ALL_SHADES)
end
end
end

local function W(game,screen)
local d=game.view
if d.describe then
j.draw(game,screen,{run=game.run,profile=game.profile,id=d.entries[d.selected].item.id,rank=1,bonuses={}},d)
return
end
b.backdrop(screen,game.sheets.chestBack)
q(game,screen)
if#d.entries==0 then
h(game,screen,f("Empty"),nil)
return
end
local s=#d.entries*b.ITEM+(#d.entries-1)*a.CHEST_GAP
local m=math.floor((screen.width-s)/2)
for l=1,#d.entries do
local r=m+(l-1)*(b.ITEM+a.CHEST_GAP)
b.item(screen,game.sheets,d.entries[l].item.id,r,a.CHEST_ITEM_Y,0)
if l==d.selected and d.opening>=a.OPEN_TICKS then
i.cursor(screen,r,a.CHEST_ITEM_Y,b.ITEM,b.ITEM)
end
end
if d.opening<a.OPEN_TICKS then
U(game,screen,d.opening)
h(game,screen,"",nil)
return
end
if d.sparkle<a.SPARKLE_TICKS then
V(game,screen,d.sparkle,m)
end
local l=f("StartDetails")
if d.messageTicks>0 then
l=d.message
end
h(game,screen,f("Item_"..d.entries[d.selected].item.id),l)
end

local function X(game,screen)
local d=game.view
b.backdrop(screen,game.sheets.shrineBack)
for m=1,#a.CANDLES do
local l=a.CANDLES[m]
local r=(math.floor(game.ticks/a.CANDLE_TICKS)+l.offset)%a.CANDLE_FRAMES
screen:layers(game.sheets.candle,r*a.CANDLE_W,a.CANDLE_W,a.CANDLE_H,l.x,l.y,a.FLAME_SHADES)
end
q(game,screen)
if#d.entries==0 then
h(game,screen,f("Empty"),nil)
return
end
local Y=#d.entries*b.ITEM+(#d.entries-1)*a.NICHE_GAP
local Z=math.floor((screen.width-Y)/2)
for r=1,#d.entries do
local m=d.entries[r]
local l=Z+(r-1)*(b.ITEM+a.NICHE_GAP)
screen:rect(l-2,a.NICHE_Y-1,b.ITEM+4,b.ITEM+2,b.ink(1))
screen:rect(l-1,a.NICHE_Y,b.ITEM+2,b.ITEM,b.ink(2))
screen:rect(l+1,a.NICHE_Y+2,b.ITEM-2,b.ITEM-2,b.ink(4))
b.blessing(screen,game.sheets,m.blessing.id,l,a.NICHE_Y,0)
local s=a.NICHE_Y+a.NICHE_PRICE_Y
local x=l+math.floor(b.ITEM/2)
if m.health>0 then
local y=tostring(m.health)
local t=f("MaxWord")
local B=b.ICON+b.ICON_GAP+screen:textWidth(y)+a.MAX_GAP+screen:textWidth(t)
local C=x-math.floor(B/2)
b.amount(screen,game.sheets,"heart",y,C,s,2,b.ON_LIGHT,"left")
screen:text(t,C+B-screen:textWidth(t),s,b.ink(2))
else
b.amount(screen,game.sheets,"coin",m.gold,x,s,2,b.ON_LIGHT,"centre")
end
if r==d.selected then
i.cursor(screen,l-2,a.NICHE_Y-1,b.ITEM+4,a.NICHE_MARK_Y-1)
end
end
local l=d.entries[d.selected]
local m=f("BlessDesc_"..l.blessing.id)
if d.messageTicks>0 then
m=d.message
end
h(game,screen,f("Bless_"..l.blessing.id),m)
end

function a.draw(game,screen)
local d=game.view
if d.weaponAsk and d.describe then
j.draw(game,screen,{run=game.run,profile=game.profile,id=d.weaponAsk.item.id,rank=1,bonuses={}},d)
return
end
if d.weaponAsk then
e.Replace.drawWeapon(game,screen,d.weaponAsk.item)
return
end
local l=d.place.kind
if l=="merchant"then
R(game,screen)
if not d.describe then
b.bagTab(screen,"right",a.TAB_Y.merchant)
end
return
end
if l=="forge"then
T(game,screen)
return
end
if l=="shrine"then
X(game,screen)
return
end
W(game,screen)
if not d.describe and d.opening>=a.OPEN_TICKS then
b.bagTab(screen,"right",a.TAB_Y.chest)
end
end
