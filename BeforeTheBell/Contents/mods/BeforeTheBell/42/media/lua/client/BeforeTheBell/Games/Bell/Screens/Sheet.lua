-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Rules/Run"
require"BeforeTheBell/Games/Bell/Rules/Profile"

local a={}
BeforeTheBell.Bell.Sheet=a

local i=BeforeTheBell.Bell
local b=i.Look
local d=i.Items
local e=b.text

a.POCKET_X=4
a.POCKET_Y=4
a.HEAD_X=42
a.NAME_Y=1
a.KIND_Y=a.NAME_Y+b.step(12)
a.STAT_GAP=6
a.BODY_Y=41
a.ROW=b.step(10)
a.HEADER_GAP=2
a.LEFT=4
a.WIDTH=166
a.ARROW_X=172
a.INDENT=12
a.SECTION_GAP=3
a.PART_GAP=3
a.SLOT_W=36
a.SLOT_H=12
a.SLOT_GAP=4
a.SLOT_PAD=3
a.MARKS={atk="physical",arm="armor",spd="speed",hp="life",thorns="thorns"}
a.STATS={{key="atk",mark="physical"},{key="arm",mark="armor"},{key="spd",mark="speed"},{key="hp",mark="life"},{key="thorns",mark="thorns"}}

function a.statLabel(key,value)
local c=tostring(value)
if value>0 then
c="+"..c
end
if key=="hp"then
c=e("MaxHealthValue",c)
end
return c
end

local function k(stats)
local c={}
for h=1,#a.STATS do
local f=a.STATS[h]
local g=stats[f.key]
if g and g~=0 then
c[#c+1]={mark=f.mark,label=a.statLabel(f.key,g)}
end
end
return c
end

function a.hasEffect(item)
return item.hooks~=nil or item.flags~=nil or item.stands~=nil or item.kind==d.CONSUMABLE
end

local function u(screen,run,profile,item,rank,bonuses)
local c={}
local function l(key)
local f=0
if#c>0 then
f=a.SECTION_GAP
end
c[#c+1]={header=e(key),pad=f}
end
local function h(value,shade,indent)
local f=b.richWrap(screen,value,a.WIDTH-indent)
for g=1,#f do
c[#c+1]={text=f[g],shade=shade,indent=indent,pad=0}
end
end
local m=#d.RANK_SCALE
local function o(target,shade,withStats,held)
if not held and not i.Profile.rankKnown(profile,item.id,target)then
c[#c+1]={rankMark="rank"..target,stats={},shade=b.FAINT_SHADE,text=e("Unknown"),pad=0}
return
end
local n=d.effects(item,nil,target)
local g={}
if n and withStats then
g=k(n)
end
local p={rankMark="rank"..target,stats=g,shade=shade,pad=0}
c[#c+1]=p
local f={}
local r=target==m and item.mastery~=nil and item.mastery.replace
if a.hasEffect(item)and not r then
f[#f+1]=b.text("Effect_"..item.id,unpack(d.numbers(item,target)))
end
if target==m and item.mastery then
f[#f+1]=e("Mastery_"..item.id)
end
if#f>0 then
local j=b.richWrap(screen,table.concat(f," "),a.WIDTH-a.INDENT)
local q=1
if#g==0 then
p.text=j[1]
q=2
end
for s=q,#j do
c[#c+1]={text=j[s],shade=shade,indent=a.INDENT,pad=0}
end
end
end
l("SheetEffect")
if item.kind==d.GEAR and rank>1 then
o(rank,b.TEXT_SHADE,true,true)
else
local f=d.effects(item,nil,rank)
if f and#k(f)>0 then
c[#c+1]={stats=k(f),shade=b.TEXT_SHADE,pad=0}
end
if a.hasEffect(item)then
h(b.text("Effect_"..item.id,unpack(d.numbers(item,rank))),b.TEXT_SHADE,0)
end
end
local g=nil
if run then
g=i.Build.owned(run)
end
for v=1,#d.sets do
local f=d.sets[v]
local p=false
for j=1,#f.items do
if f.items[j]==item.id then
p=true
end
end
if p then
local n=0
for j=1,#f.items do
if g and g[f.items[j]]then
n=n+1
end
end
local q=g~=nil and n==#f.items
local r=b.FAINT_SHADE
if q then
r=b.TEXT_SHADE
end
l("SheetSet")
if g then
h(e("SetCount",e("Set_"..f.id),n,#f.items),4,0)
else
h(e("Set_"..f.id),4,0)
end
if q or profile.sets[f.id]then
h(e("SetDesc_"..f.id),r,0)
else
h(e("Unknown"),b.FAINT_SHADE,0)
end
for j=1,#f.items do
local s=b.FAINT_SHADE
if g and g[f.items[j]]then
s=b.TEXT_SHADE
end
local t=0
if j==1 then
t=a.PART_GAP
end
local w=d.available(d.byId[f.items[j]],profile)or(g~=nil and g[f.items[j]]~=nil)
c[#c+1]={piece=f.items[j],known=w,shade=s,pad=t}
end
end
end
if item.kind==d.GEAR and rank<m then
l("SheetMerge")
for f=rank+1,m do
o(f,b.FAINT_SHADE,true,false)
end
end
if item.kind==d.WEAPON then
l("SheetForge")
c[#c+1]={slots=bonuses,count=i.Run.FORGE_SLOTS,pad=a.SLOT_PAD}
if#bonuses>0 then
c[#c+1]={total=k(d.effects(item,bonuses,rank)),shade=b.TEXT_SHADE,pad=a.SLOT_PAD}
end
end
return c
end

function a.drawSlots(game,screen,bonuses,count,left,y)
for f=1,count do
local c=left+(f-1)*(a.SLOT_W+a.SLOT_GAP)
screen:rect(c,y,a.SLOT_W,a.SLOT_H,b.ink(3))
if bonuses[f]then
screen:rect(c+1,y+1,a.SLOT_W-2,a.SLOT_H-2,b.ink(4))
b.mark(screen,game.sheets,a.MARKS[bonuses[f]],c+3,y+2,0)
screen:text("+"..d.FORGE_BONUS[bonuses[f]],c+3+b.ICON+b.ICON_GAP,y-2,b.ink(1))
else
screen:rect(c+1,y+1,a.SLOT_W-2,a.SLOT_H-2,b.ink(1))
for g=c+4,c+a.SLOT_W-6,4 do
screen:rect(g,y+math.floor(a.SLOT_H/2),2,1,b.ink(2))
end
end
end
end

local function m(game,screen,list,x,y,shade)
for c=1,#list do
b.markLit(screen,game.sheets,list[c].mark,x,y+b.ICON_DY,shade+1)
x=x+b.ICON+b.ICON_GAP
screen:text(list[c].label,x,y,b.ink(shade+1))
x=x+screen:textWidth(list[c].label)+a.STAT_GAP
end
end

local function j(row)
return a.ROW+row.pad
end

local function p(game,screen,row,y)
if row.header then
y=y+row.pad
screen:text(row.header,a.LEFT,y,b.ink(2))
local c=a.LEFT+screen:textWidth(row.header)+a.HEADER_GAP
screen:rect(c,y+7,a.LEFT+a.WIDTH-c,1,b.ink(2))
elseif row.piece then
y=y+row.pad
screen:rect(a.LEFT+2,y+6,2,2,b.ink(row.shade))
local c=e("Unknown")
if row.known then
c=e("Item_"..row.piece)
end
screen:text(c,a.LEFT+7,y,b.ink(row.shade))
elseif row.slots then
y=y+row.pad
a.drawSlots(game,screen,row.slots,row.count,a.LEFT,y)
elseif row.total then
y=y+row.pad
local c=e("SheetTotal")
screen:text(c,a.LEFT,y,b.ink(2))
m(game,screen,row.total,a.LEFT+screen:textWidth(c)+a.STAT_GAP,y,row.shade)
elseif row.rankMark then
b.markLit(screen,game.sheets,row.rankMark,a.LEFT,y+b.ICON_DY,row.shade+1)
m(game,screen,row.stats,a.LEFT+a.INDENT,y,row.shade)
if row.text then
b.richText(screen,game.sheets,row.text,a.LEFT+a.INDENT,y,row.shade)
end
elseif row.stats then
m(game,screen,row.stats,a.LEFT,y,row.shade)
else
b.richText(screen,game.sheets,row.text,a.LEFT+row.indent,y,row.shade)
end
end

function a.draw(game,screen,info,view)
local g=d.byId[info.id]
local o=info.rank
screen:rect(0,0,screen.width,screen.height,b.ink(1))
local c=u(screen,info.run,info.profile,g,o,info.bonuses)
local q=screen.height-a.BODY_Y
local f=#c
local n=0
while f>0 and n+j(c[f])<=q do
n=n+j(c[f])
f=f-1
end
view.sheetScroll=math.max(0,math.min(view.sheetScroll,f))
local l=a.BODY_Y
local h=view.sheetScroll+1
while c[h]and l+j(c[h])<=screen.height do
p(game,screen,c[h],l)
l=l+j(c[h])
h=h+1
end
screen:rect(0,0,screen.width,a.BODY_Y-1,b.ink(1))
screen:rect(a.POCKET_X-1,a.POCKET_Y-1,b.ITEM+2,b.ITEM+2,b.ink(2))
screen:rect(a.POCKET_X,a.POCKET_Y,b.ITEM,b.ITEM,b.ink(4))
b.item(screen,game.sheets,g.id,a.POCKET_X,a.POCKET_Y,0)
if g.kind==d.GEAR then
b.rank(screen,game.sheets,o,a.POCKET_X,a.POCKET_Y)
end
screen:text(e("Item_"..g.id),a.HEAD_X,a.NAME_Y,b.ink(4))
screen:text(e("Kind_"..g.kind).."  "..e("Rarity_"..g.rarity),a.HEAD_X,a.KIND_Y,b.ink(2))
if view.sheetScroll>0 then
b.markLit(screen,game.sheets,"up",a.ARROW_X,a.BODY_Y,3)
end
if view.sheetScroll<f then
b.markLit(screen,game.sheets,"down",a.ARROW_X,screen.height-b.ICON-1,3)
end
end

function a.open(view)
view.sheetScroll=0
end

function a.step(view,pressed)
if pressed.up then
view.sheetScroll=math.max(0,view.sheetScroll-1)
return true
end
if pressed.down then
view.sheetScroll=view.sheetScroll+1
return true
end
return false
end
