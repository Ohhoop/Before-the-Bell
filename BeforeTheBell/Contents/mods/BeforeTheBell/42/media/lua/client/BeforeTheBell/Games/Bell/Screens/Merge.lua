-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Profile"
require"BeforeTheBell/Games/Bell/Screens/Replace"

local d={}
BeforeTheBell.Bell.Merge=d

local g=BeforeTheBell.Bell
local e=g.Look
local i=g.Items
local c=g.Replace
local h=e.text

d.TOP_Y=15
d.BLOCK_GAP=2
d.LAST_Y=82
d.INDENT=12

local function k(rank)
return{{mark="rank"..rank,text=h("Unknown")}}
end

local function l(a,b)
if#a~=#b then
return false
end
for f=1,#a do
if a[f].text~=b[f].text then
return false
end
if a[f].stats or b[f].stats then
if not(a[f].stats and b[f].stats)then
return false
end
for m=1,#g.Sheet.STATS do
local j=g.Sheet.STATS[m].key
if a[f].stats[j]~=b[f].stats[j]then
return false
end
end
end
end
return true
end

local function m(screen,item,rank)
local a=c.describe(screen,{id=item.id,rank=rank})
if l(a,c.describe(screen,{id=item.id,rank=rank-1}))then
a={}
end
if rank==#i.RANK_SCALE and item.mastery then
local b=e.richWrap(screen,h("Mastery_"..item.id),c.TEXT_W-d.INDENT)
for f=1,#b do
local j={text=b[f],indent=d.INDENT}
if f==1 then
j.mark="rank"..rank
end
a[#a+1]=j
end
end
return a
end

local function j(game,screen,rows,y,shade)
for b=1,#rows do
local a=rows[b]
if a.mark then
e.markLit(screen,game.sheets,a.mark,c.TEXT_X,y+e.ICON_DY,shade+1)
e.richText(screen,game.sheets,a.text,c.TEXT_X+d.INDENT,y,shade)
y=y+c.LINE
elseif a.indent then
e.richText(screen,game.sheets,a.text,c.TEXT_X+a.indent,y,shade)
y=y+c.LINE
else
y=c.drawLines(game,screen,{a},c.TEXT_X,y,shade)
end
end
return y
end

function d.draw(game,screen,piece)
local n=i.byId[piece.id]
local a=piece.rank+1
c.drawPage(screen,"TitleMerge")
c.drawPocket(game,screen,piece,c.ROW_Y[1])
c.drawArrow(game,screen)
c.drawPocket(game,screen,{id=piece.id,rank=a},c.ROW_Y[2])
screen:text(h("Item_"..piece.id),c.TEXT_X,d.TOP_Y,e.ink(e.TEXT_SHADE+1))
local b=d.TOP_Y+c.LINE+c.NAME_GAP
b=j(game,screen,c.describe(screen,piece),b,e.TEXT_SHADE)
local f=k(a)
if g.Profile.rankKnown(game.profile,piece.id,a)then
f=m(screen,n,a)
end
local o=math.min(c.ROW_Y[2]-3,d.LAST_Y-(#f-1)*c.LINE)
j(game,screen,f,math.max(o,b+d.BLOCK_GAP),e.TEXT_SHADE)
c.drawBand(screen,"AskMerge",piece.id,"ReplaceKeys")
end
