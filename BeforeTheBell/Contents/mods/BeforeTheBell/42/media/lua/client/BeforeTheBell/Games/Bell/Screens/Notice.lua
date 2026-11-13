-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Run"

local a={}
BeforeTheBell.Bell.Notice=a

local f=BeforeTheBell.Bell
local b=f.Look
local k=f.Music
local c=b.text

a.MAX_LINES=5
a.DELAY=20
a.PICTURE_Y=68
a.PRESS_Y=93
a.PICTURE_SHADES={2,3,4}
a.TITLE_Y=6
a.LIST_Y=22
a.LIST_ROW=36
a.LIST_ROWS=2
a.POCKET_X=36
a.LABEL_X=76
a.ARROW_X=160
a.NAME_DY=5
a.NAME_GAP=2
a.FOE_TITLE_Y=5
a.RULE_TOP_Y=21
a.FOE_NAME_Y=25
a.LORE_Y=a.FOE_NAME_Y+b.step(15)
a.LORE_W=150
a.RULE_HALF=50
a.ACT_Y=70
a.ACT_RULE_DY=6
a.ACT_RULE_GAP=4
a.MARCH_Y=88
a.FOE_PRESS_Y=100
a.MARCH_GAP=9
a.MARCH_DIM=1
a.LOW_PRESS_Y=99
a.HERO_CENTRE=40
a.FLOOR_W=48
a.HERO_BOTTOM=96
a.INFO_X=66
a.INFO_RIGHT=172
a.INFO_TEXT_DX=b.ICON+b.ICON_GAP+2
a.INFO_Y=30
a.INFO_ROW=13
a.INFO_GAP=4
a.LIGHT_ICONS={sun=true,coin=true,heart=true,moon=true,steps=true}
a.MARK_ICONS={ban="cross",favor="up"}
a.LABELS={item="NewItem",hero="NewHero",tier="NewTier",dummy="NewAtCamp",chest="NewAtCamp",tent="NewAtCamp",mark="NewAtCamp"}

function a.enter(game,args)
local d=game.view
d.kind=args.kind
d.title=args.title
d.picture=args.picture
d.lines=args.lines
d.entries=args.entries
d.foe=args.foe
d.act=args.act
d.day=args.day
d.summary=args.summary
d.onConfirm=args.onConfirm
d.confirmWith=args.confirmWith
d.ticks=0
d.scroll=0
end

function a.tick(game,input)
local d=game.view
d.ticks=d.ticks+1
if d.kind=="list"then
local e=math.max(0,#d.entries-a.LIST_ROWS)
if input.pressed.up and d.scroll>0 then
d.scroll=d.scroll-1
game:effect(k.MOVE)
elseif input.pressed.down and d.scroll<e then
d.scroll=d.scroll+1
game:effect(k.MOVE)
end
end
if d.ticks<a.DELAY then
return
end
if input.pressed.a or input.pressed.start then
game:effect(k.SELECT)
game[d.onConfirm](game,d.confirmWith)
end
end

local function h(game,screen,y)
if game.view.ticks>=a.DELAY and math.floor(game.ticks/30)%2==0 then
screen:textCentre(c("PressA"),math.floor(screen.width/2),y,b.ink(2))
end
end

local function q(game,screen,entry,x,y)
screen:rect(x-1,y-1,b.ITEM+2,b.ITEM+2,b.ink(2))
screen:rect(x,y,b.ITEM,b.ITEM,b.ink(4))
if entry.kind=="item"then
b.item(screen,game.sheets,entry.id,x,y,0)
elseif entry.kind=="hero"then
for d=1,#f.Cast.heroes do
if f.Cast.heroes[d].id==entry.id then
b.hero(screen,game.sheets,d,x+math.floor((b.ITEM-b.HERO)/2),y+math.floor((b.ITEM-b.HERO)/2),false)
end
end
elseif entry.kind=="dummy"then
screen:layers(game.sheets.dummy,0,b.DUMMY_W,b.DUMMY_H,x+math.floor((b.ITEM-b.DUMMY_W)/2),y+math.floor((b.ITEM-b.DUMMY_H)/2),b.ALL_SHADES)
elseif entry.kind=="chest"then
b.tile(screen,game.sheets,"chest",x+math.floor((b.ITEM-b.TILE)/2),y+math.floor((b.ITEM-b.TILE)/2),0)
elseif entry.kind=="mark"then
b.tile(screen,game.sheets,"chest",x+math.floor((b.ITEM-b.TILE)/2),y+math.floor((b.ITEM-b.TILE)/2),0)
b.mark(screen,game.sheets,a.MARK_ICONS[entry.id],x+b.ITEM-b.ICON,y,0)
elseif entry.kind=="tent"then
screen:layers(game.sheets.tentIcon,0,b.TENT_ICON_W,b.TENT_ICON_H,x+math.floor((b.ITEM-b.TENT_ICON_W)/2),y+math.floor((b.ITEM-b.TENT_ICON_H)/2),b.ALL_SHADES)
else
screen:layers(game.sheets.noticePictures,b.NOTICE_PICTURES.toll*b.NOTICE_PICTURE_W,b.NOTICE_PICTURE_W,b.NOTICE_PICTURE_H,x,y+math.floor((b.ITEM-b.NOTICE_PICTURE_H)/2),a.PICTURE_SHADES)
end
end

local function r(entry)
if entry.kind=="item"then
return c("Item_"..entry.id)
elseif entry.kind=="hero"then
return c("Hero_"..entry.id)
elseif entry.kind=="dummy"then
return c("TrainingDummy")
elseif entry.kind=="chest"then
return c("CampChest")
elseif entry.kind=="tent"then
return c("Tent")
elseif entry.kind=="mark"then
return c("ChestSlot_"..entry.id)
end
return c("Tier_"..entry.id)
end

local function s(game,screen)
local d=game.view
for i=1,a.LIST_ROWS do
local e=d.entries[d.scroll+i]
if e then
local j=a.LIST_Y+(i-1)*a.LIST_ROW
q(game,screen,e,a.POCKET_X,j)
local g=b.richWrap(screen,r(e),a.ARROW_X-a.LABEL_X-a.NAME_GAP)
local l=j+a.NAME_DY-math.floor((#g-1)*b.ROW/2)
for m=1,#g do
screen:text(g[m],a.LABEL_X,l+(m-1)*b.ROW,b.ink(4))
end
screen:text(c(a.LABELS[e.kind]),a.LABEL_X,l+#g*b.ROW,b.ink(2))
end
end
if d.scroll>0 then
b.markLit(screen,game.sheets,"up",a.ARROW_X,a.LIST_Y,3)
end
if d.scroll+a.LIST_ROWS<#d.entries then
b.markLit(screen,game.sheets,"down",a.ARROW_X,a.LIST_Y+a.LIST_ROWS*a.LIST_ROW-b.ICON-4,3)
end
h(game,screen,a.LOW_PRESS_Y)
end

local function t(game,screen,act,day)
local d={}
for e=1,f.Run.DAYS do
d[#d+1]={mark="sun",day=e,night=false}
local g="moon"
if e==f.Run.DAYS then
g="bellmark"
end
d[#d+1]={mark=g,day=e,night=true}
end
local u=#d*b.ICON+(#d-1)*a.MARCH_GAP
local v=math.floor((screen.width-u)/2)
local i=math.floor(screen.width/2)
local m=c("ActLabel",act)
local n=math.ceil(screen:textWidth(m)/2)+a.ACT_RULE_GAP
local j=a.RULE_HALF-n
if j>0 then
screen:rect(i-a.RULE_HALF,a.ACT_Y+a.ACT_RULE_DY,j,1,b.ink(2))
screen:rect(i+n,a.ACT_Y+a.ACT_RULE_DY,j,1,b.ink(2))
end
screen:textCentre(m,i,a.ACT_Y,b.ink(2))
for l=1,#d do
local e=d[l]
local g=v+(l-1)*(b.ICON+a.MARCH_GAP)
local o=e.day==day and e.night
local w=e.day<day or(e.day==day and not e.night)
local p=a.MARCH_DIM
if o or w then
p=0
end
b.layers(screen,game.sheets.hud,b.ICONS[e.mark]*b.ICON,b.ICON,b.ICON,g,a.MARCH_Y,b.ICON_SHADES,p)
if o then
screen:rect(g-2,a.MARCH_Y-2,b.ICON+4,1,b.ink(4))
screen:rect(g-2,a.MARCH_Y+b.ICON+1,b.ICON+4,1,b.ink(4))
screen:rect(g-2,a.MARCH_Y-2,1,b.ICON+4,b.ink(4))
screen:rect(g+b.ICON+1,a.MARCH_Y-2,1,b.ICON+4,b.ink(4))
end
if l<#d then
screen:rect(g+b.ICON+math.floor(a.MARCH_GAP/2),a.MARCH_Y+math.floor(b.ICON/2),1,1,b.ink(2))
end
end
end

local function n(screen,y)
local d=math.floor(screen.width/2)
screen:rect(d-a.RULE_HALF,y,a.RULE_HALF*2,1,b.ink(2))
screen:rect(d-1,y-1,3,3,b.ink(2))
screen:rect(d,y,1,1,b.ink(4))
end

local function o(game,screen)
local d=game.view
local e=math.floor(screen.width/2)
n(screen,a.RULE_TOP_Y)
screen:textCentre(c("Foe_"..d.foe),e,a.FOE_NAME_Y,b.ink(4))
local g=b.richWrap(screen,c("Lore_"..d.foe),a.LORE_W)
for i=1,#g do
screen:textCentre(g[i],e,a.LORE_Y+(i-1)*b.ROW,b.ink(3))
end
t(game,screen,d.act,d.day)
h(game,screen,a.FOE_PRESS_Y)
end

local function g(game,screen,mark,value,y,shade)
if a.LIGHT_ICONS[mark]then
b.icon(screen,game.sheets,mark,a.INFO_X,y+b.ICON_DY)
else
b.markLit(screen,game.sheets,mark,a.INFO_X,y+b.ICON_DY,4)
end
screen:text(value,a.INFO_X+a.INFO_TEXT_DX,y,b.ink(shade))
end

local function p(game,screen)
local e=game.view.summary
local i=f.Fighters[e.hero]
local l=0
if not e.won then
l=1
end
local u=a.HERO_CENTRE-math.floor(i.w/2)
screen:rect(a.HERO_CENTRE-a.FLOOR_W/2,a.HERO_BOTTOM,a.FLOOR_W,1,b.ink(2))
b.layers(screen,game.sheets.fighters[e.hero],0,i.w,i.h,u,a.HERO_BOTTOM-i.h,b.ALL_SHADES,l)
local j={}
if e.killer then
j=b.richWrap(screen,c("Foe_"..e.killer),a.INFO_RIGHT-a.INFO_X-a.INFO_TEXT_DX)
end
local d=a.INFO_Y-math.max(0,#j-1)*b.ROW
g(game,screen,"sun",c("ReachedAt",e.act,e.day),d,4)
d=d+a.INFO_ROW
g(game,screen,"physical",c("Kills",e.kills),d,3)
d=d+a.INFO_ROW
g(game,screen,"coin",c("GoldCarried",e.gold),d,3)
if e.killer then
d=d+a.INFO_ROW+a.INFO_GAP
g(game,screen,"poison",c("KilledBy"),d,2)
for m=1,#j do
screen:text(j[m],a.INFO_X+a.INFO_TEXT_DX,d+m*b.ROW,b.ink(4))
end
end
h(game,screen,a.LOW_PRESS_Y)
end

function a.draw(game,screen)
local d=game.view
local e=math.floor(screen.width/2)
screen:rect(0,0,screen.width,screen.height,b.ink(1))
b.backdrop(screen,game.sheets.noticeFrame)
if d.kind=="list"then
screen:textCentre(d.title,e,a.TITLE_Y,b.ink(4))
s(game,screen)
return
end
if d.kind=="foe"then
screen:textCentre(d.title,e,a.FOE_TITLE_Y,b.ink(3))
o(game,screen)
return
end
if d.kind=="summary"then
screen:textCentre(d.title,e,a.TITLE_Y,b.ink(4))
p(game,screen)
return
end
if d.picture then
local i=e-math.floor(b.NOTICE_PICTURE_W/2)
screen:layers(game.sheets.noticePictures,b.NOTICE_PICTURES[d.picture]*b.NOTICE_PICTURE_W,b.NOTICE_PICTURE_W,b.NOTICE_PICTURE_H,i,a.PICTURE_Y,a.PICTURE_SHADES)
end
screen:textCentre(d.title,e,16,b.ink(4))
for i=1,math.min(a.MAX_LINES,#d.lines)do
b.richCentre(screen,game.sheets,d.lines[i],e,34+(i-1)*b.ROW,3)
end
h(game,screen,a.PRESS_Y)
end
