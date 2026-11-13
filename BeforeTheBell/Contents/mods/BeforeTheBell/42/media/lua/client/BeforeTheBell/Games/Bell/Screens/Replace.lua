-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Screens/Sheet"

local a={}
BeforeTheBell.Bell.Replace=a

local c=BeforeTheBell.Bell
local b=c.Look
local e=c.Items
local d=b.text

a.TOP_H=14
a.ROW_Y={18,60}
a.POCKET_X=6
a.TEXT_X=44
a.TEXT_W=130
a.LINE=b.step(9)
a.NAME_GAP=2
a.TEXT_DY=-3
a.DIVIDER_Y=57
a.BAND_Y=98
a.BAND_LINE_DY=-2
a.STAT_GAP=6
a.SLOTS_DY=1

function a.describe(screen,piece)
local f=e.byId[piece.id]
local g=e.effects(f,nil,piece.rank)
if g then
for i=1,#c.Sheet.STATS do
local h=g[c.Sheet.STATS[i].key]
if h and h~=0 then
return{{stats=g}}
end
end
end
local h={}
if c.Sheet.hasEffect(f)then
local i=b.richWrap(screen,b.text("Effect_"..f.id,unpack(e.numbers(f,piece.rank))),a.TEXT_W)
for j=1,math.min(2,#i)do
h[#h+1]={text=i[j]}
end
end
return h
end

local function n(game,screen,stats,x,y,shade)
for i=1,#c.Sheet.STATS do
local f=c.Sheet.STATS[i]
local g=stats[f.key]
if g and g~=0 then
local h=c.Sheet.statLabel(f.key,g)
b.markLit(screen,game.sheets,f.mark,x,y+b.ICON_DY,shade+1)
x=x+b.ICON+b.ICON_GAP
screen:text(h,x,y,b.ink(shade+1))
x=x+screen:textWidth(h)+a.STAT_GAP
end
end
end

local function k(id)
for g=1,#e.sets do
local f=e.sets[g]
for h=1,#f.items do
if f.items[h]==id then
return f
end
end
end
return nil
end

local function o(set,owned)
local f=0
for g=1,#set.items do
if owned[set.items[g]]then
f=f+1
end
end
return f
end

function a.runAfter(run,slot,incoming)
local g={}
for f=1,#run.gear do
if f==slot then
g[f]={id=incoming.id,rank=incoming.rank}
else
g[f]=run.gear[f]
end
end
return{weapon=run.weapon,gear=g,bag=run.bag,gold=run.gold}
end

function a.drawLines(game,screen,rows,x,y,shade)
for f=1,#rows do
if rows[f].stats then
n(game,screen,rows[f].stats,x,y,shade)
else
b.richText(screen,game.sheets,rows[f].text,x,y,shade)
end
y=y+a.LINE
end
return y
end

function a.drawPocket(game,screen,piece,y)
screen:rect(a.POCKET_X-1,y-1,b.ITEM+2,b.ITEM+2,b.ink(2))
screen:rect(a.POCKET_X,y,b.ITEM,b.ITEM,b.ink(4))
b.item(screen,game.sheets,piece.id,a.POCKET_X,y,0)
b.rank(screen,game.sheets,piece.rank,a.POCKET_X,y)
end

function a.drawArrow(game,screen)
local f=math.floor((a.ROW_Y[1]+b.ITEM+a.ROW_Y[2]-1)/2)-math.floor(b.ICON/2)
b.markLit(screen,game.sheets,"down",a.POCKET_X+math.floor((b.ITEM-b.ICON)/2),f,4)
end

function a.bandTop(screen)
return a.BAND_Y-b.lift(screen,a.BAND_Y+a.BAND_LINE_DY,2,b.ROW)
end

function a.drawBand(screen,key,id,keys)
local g=math.floor(screen.width/2)
local f=a.bandTop(screen)
b.panel(screen,f,screen.height-f)
screen:textCentre(d(key,d("Item_"..id)),g,f+a.BAND_LINE_DY,b.ink(4))
screen:textCentre(d(keys),g,f+a.BAND_LINE_DY+b.ROW,b.ink(3))
end

function a.drawPage(screen,key)
screen:rect(0,0,screen.width,screen.height,b.ink(1))
screen:rect(0,a.TOP_H,screen.width,1,b.ink(2))
screen:textCentre(d(key),math.floor(screen.width/2),-1,b.ink(4))
end

local function g(screen,piece)
local f=#a.describe(screen,piece)
if k(piece.id)then
f=f+1
end
return f*a.LINE+a.NAME_GAP+screen:lineHeight()
end

local function h(game,screen,piece,y,top,owned)
local i=b.TEXT_SHADE
a.drawPocket(game,screen,piece,y)
screen:text(d("Item_"..piece.id),a.TEXT_X,top,b.ink(i+1))
local j=a.describe(screen,piece)
a.drawLines(game,screen,j,a.TEXT_X,top+a.LINE+a.NAME_GAP,i)
local f=k(piece.id)
if f then
local l=o(f,owned)
local m=b.FAINT_SHADE
if l==#f.items then
m=b.TEXT_SHADE+1
end
local p=top+(#j+1)*a.LINE+a.NAME_GAP
screen:text(d("SetCount",d("Set_"..f.id),l,#f.items),a.TEXT_X,p,b.ink(m))
end
end

function a.drawWeapon(game,screen,incoming)
local f={id=game.run.weapon.id,rank=1}
local i={id=incoming.id,rank=1}
local j=math.min(a.ROW_Y[2]+a.TEXT_DY,a.bandTop(screen)-g(screen,i))
a.drawPage(screen,"TitleReplace")
local l=a.ROW_Y[1]+a.TEXT_DY
h(game,screen,f,a.ROW_Y[1],l,c.Build.owned(game.run))
c.Sheet.drawSlots(game,screen,game.run.weapon.bonuses,c.Run.FORGE_SLOTS,a.TEXT_X,l+g(screen,f)+a.SLOTS_DY)
screen:rect(a.TEXT_X,math.min(a.DIVIDER_Y,j),screen.width-a.TEXT_X-4,1,b.ink(2))
a.drawArrow(game,screen)
h(game,screen,i,a.ROW_Y[2],j,c.Build.owned(game.run))
c.Sheet.drawSlots(game,screen,{},c.Run.FORGE_SLOTS,a.TEXT_X,j+g(screen,i)+a.SLOTS_DY)
a.drawBand(screen,"AskReplace",f.id,"ReplaceKeys")
end

function a.draw(game,screen,slot,incoming)
local f=game.run.gear[slot]
local i=math.min(a.ROW_Y[2]+a.TEXT_DY,a.bandTop(screen)-g(screen,incoming))
a.drawPage(screen,"TitleReplace")
h(game,screen,f,a.ROW_Y[1],a.ROW_Y[1]+a.TEXT_DY,c.Build.owned(game.run))
screen:rect(a.TEXT_X,math.min(a.DIVIDER_Y,i),screen.width-a.TEXT_X-4,1,b.ink(2))
a.drawArrow(game,screen)
h(game,screen,incoming,a.ROW_Y[2],i,c.Build.owned(a.runAfter(game.run,slot,incoming)))
a.drawBand(screen,"AskReplace",f.id,"ReplaceKeys")
end
