-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Framework/GameTexts"
require"BeforeTheBell/Games/Bell/Data/Items"
require"BeforeTheBell/Games/Bell/Data/Cast"
require"BeforeTheBell/Games/Bell/Rules/Build"
require"BeforeTheBell/Games/Bell/Data/Fighters"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local a={}
BeforeTheBell.Bell.Look=a

a.text=SpiffBoy.GameTexts.of("Bell")
a.SPACING={CN=12,CH=12,JP=12,KO=10,TH=13,HU=12,RO=11}

function a.step(base)
local b=a.SPACING[Translator.getLanguage():name()]
if b and b>base then
return b
end
return base
end

a.TILE=12
a.HERO=16
a.FOE=32
a.FIRE_W=14
a.FIRE_H=9
a.ROW=a.step(11)
a.PLATE_SHADOW=3
a.RIVET_INSET=3
a.TILE_INDEX={
chest=0,merchant=1,forge=2,shrine=3,camp=4,
RatSwarm=5,Bandit=6,BogSlime=7,SkeletonGuard=8,WolfPack=9,
HedgeWitch=10,PlagueKnight=11,Gargoyle=12,BellCultist=13,
bearTrap=14,bearTrapShut=15,
}
a.HERO_COUNT=6
a.ALL_SHADES={1,2,3,4}
a.ITEM=32
a.DUMMY_W=14
a.TENT_W=41
a.TENT_H=25
a.TENT_ICON_W=30
a.TENT_ICON_H=26
a.SLOT_INDEX={weapon=0,gear=1,consumable=2}
a.SLOT_SHADES={3}
a.PATH_VARIANTS=4
a.PATH_MASKS=16
a.NOTICE_PICTURE_W=32
a.NOTICE_PICTURE_H=18
a.NOTICE_PICTURES={dawn=0,night=1,toll=2}
a.DUMMY_H=21
a.ICON=9
a.ICON_SHADES={3,4}
a.ICON_GAP=2
a.ICON_DY=3
a.ON_LIGHT=2
a.ICONS={sun=0,moon=1,steps=2,heart=3,coin=4,physical=5,bleed=6,poison=7,blast=8,thorns=9,pierce=10,heal=11,armor=12,speed=13,freeze=14,life=15,up=16,down=17,rank2=18,rank3=19,bellmark=20,cross=21}
a.MARK_SHADES={1,2}

local d=SpiffBoy.Cartridges.SHADES

function a.ink(index)
local b=d[index]
return b.r,b.g,b.b
end

function a.load(context)
local b={}
for c,e in pairs(BeforeTheBell.Bell.Fighters)do
b[c]=context.art("fighter_"..c)
end
return{
fighters=b,
camp=context.art("camp"),
fire=context.art("fire"),
heroes=context.art("heroes"),
tiles=context.art("tiles"),
light=context.art("light"),
lightWinter=context.art("light_winter"),
forest=context.art("forest"),
forestNight=context.art("forest_night"),
paths=context.art("paths"),
forestWinter=context.art("forest_winter"),
forestWinterNight=context.art("forest_winter_night"),
pathsWinter=context.art("paths_winter"),
prints=context.art("prints"),
snow=context.art("snow"),
hud=context.art("hud"),
fx=context.art("fx"),
bell=context.art("bell"),
items=context.art("items"),
dummy=context.art("dummy"),
tent=context.art("tent"),
tentIcon=context.art("tent_icon"),
dummyYard=context.art("dummy_yard"),
dummyBig=context.art("dummy_big"),
tentBig=context.art("tent_big"),
tentYard=context.art("tent_yard"),
slots=context.art("slots"),
bagBack=context.art("bag_back"),
stallBack=context.art("stall_back"),
forgeBack=context.art("forge_back"),
shrineBack=context.art("shrine_back"),
chestBack=context.art("chest_back"),
chestSwing=context.art("chest_swing"),
blessings=context.art("blessings"),
forgeFire=context.art("forge_fire"),
forgeBlaze=context.art("forge_blaze"),
candle=context.art("candle"),
noticeFrame=context.art("notice_frame"),
noticePictures=context.art("notice_pictures"),
}
end

function a.layers(screen,texture,sx,sw,sh,x,y,shades,dim)
if dim==0 then
screen:layers(texture,sx,sw,sh,x,y,shades)
return
end
for c=1,#shades do
local b=shades[c]
screen:sheet(texture,sx,(b-1)*sh,sw,sh,x,y,1,math.max(1,math.min(#d,b-dim)))
end
end

function a.icon(screen,sheets,name,x,y)
screen:layers(sheets.hud,a.ICONS[name]*a.ICON,a.ICON,a.ICON,x,y,a.ICON_SHADES)
end

function a.mark(screen,sheets,name,x,y,fade)
for b=1,#a.MARK_SHADES do
local c=a.MARK_SHADES[b]+fade
if c<#d then
screen:sheet(sheets.hud,a.ICONS[name]*a.ICON,(a.MARK_SHADES[b]-1)*a.ICON,a.ICON,a.ICON,x,y,1,c)
end
end
end

a.TAB_W=13
a.TAB_H=22
a.TAB_BAG={"..1111..",".1.11.1.","..1..1..",".133331.","13333331","13311331","13333331",".111111."}
a.TAB_RIGHT={"1..","11.","111","11.","1.."}
a.TAB_PLACES={
chest={"........",".111111.","13333331","11111111","13311331","13333331","13333331","11111111"},
merchant={"11111111","13131313","11111111",".1....1.",".1....1.","11111111","13333331","11111111"},
}
a.TAB_LEFT={"..1",".11","111",".11","..1"}

local function f(screen,rows,x,y)
local h={["1"]=4,["3"]=3}
for i=1,#rows do
local e=rows[i]
local b=1
while b<=#e do
local g=e:sub(b,b)
local c=b
while c<#e and e:sub(c+1,c+1)==g do
c=c+1
end
if h[g]then
screen:rect(x+b-1,y+i-1,c-b+1,1,a.ink(h[g]))
end
b=c+1
end
end
end

function a.bagTab(screen,side,y,place)
local b=0
if side=="right"then
b=screen.width-a.TAB_W
end
screen:rect(b,y,a.TAB_W,a.TAB_H,a.ink(4))
if side=="right"then
screen:rect(b+1,y+1,a.TAB_W-1,a.TAB_H-2,a.ink(1))
f(screen,a.TAB_BAG,b+3,y+3)
f(screen,a.TAB_RIGHT,b+5,y+14)
else
screen:rect(b,y+1,a.TAB_W-1,a.TAB_H-2,a.ink(1))
f(screen,a.TAB_PLACES[place],b+2,y+3)
f(screen,a.TAB_LEFT,b+4,y+14)
end
end

function a.layersClip(screen,texture,sx,sw,sh,x,y,shades,dim,clip)
local b,c=math.max(x,clip.x),math.max(y,clip.y)
local e,g=math.min(x+sw,clip.x+clip.w),math.min(y+sh,clip.y+clip.h)
if e<=b or g<=c then
return
end
for i=1,#shades do
local h=shades[i]
screen:sheet(texture,sx+b-x,(h-1)*sh+c-y,e-b,g-c,b,c,1,math.max(1,math.min(#d,h-dim)))
end
end

function a.markLit(screen,sheets,name,x,y,bright)
local c=bright or#d
for e=1,#a.MARK_SHADES do
local b=a.MARK_SHADES[e]
screen:sheet(sheets.hud,a.ICONS[name]*a.ICON,(b-1)*a.ICON,a.ICON,a.ICON,x,y,1,c-b+1)
end
end

function a.amount(screen,sheets,icon,value,x,y,shade,dim,align)
local c=tostring(value)
local e=a.ICON+a.ICON_GAP+screen:textWidth(c)
local b=x
if align=="right"then
b=x-e
elseif align=="centre"then
b=x-math.floor(e/2)
end
a.layers(screen,sheets.hud,a.ICONS[icon]*a.ICON,a.ICON,a.ICON,b,y+a.ICON_DY,a.ICON_SHADES,dim)
screen:text(c,b+a.ICON+a.ICON_GAP,y,a.ink(shade))
end

function a.hero(screen,sheets,index,x,y,dimmed)
local b=index-1
if dimmed then
b=b+a.HERO_COUNT
end
screen:layers(sheets.heroes,b*a.HERO,a.HERO,a.HERO,x,y,{1,2,3,4})
end

function a.silhouette(screen,sheets,index,x,y)
local b=index-1+2*a.HERO_COUNT
screen:layers(sheets.heroes,b*a.HERO,a.HERO,a.HERO,x,y,{1})
end

function a.item(screen,sheets,id,x,y,dim)
a.layers(screen,sheets.items,a.ITEM_INDEX[id]*a.ITEM,a.ITEM,a.ITEM,x,y,a.ALL_SHADES,dim)
end

function a.backdrop(screen,texture)
screen:layers(texture,0,screen.width,screen.height,0,0,a.ALL_SHADES)
end

a.RANK_PLATE=a.ICON+2

function a.rank(screen,sheets,rank,x,y)
if rank<2 then
return
end
local b=x+a.ITEM-a.RANK_PLATE
screen:rect(b,y,a.RANK_PLATE,a.RANK_PLATE,a.ink(1))
screen:rect(b+1,y+1,a.ICON,a.ICON,a.ink(4))
a.mark(screen,sheets,"rank"..rank,b+1,y+1,0)
end

function a.itemName(id,rank)
return a.text("Item_"..id)..string.rep("+",rank-1)
end

function a.slot(screen,sheets,kind,x,y)
screen:layers(sheets.slots,a.SLOT_INDEX[kind]*a.ITEM,a.ITEM,a.ITEM,x,y,a.SLOT_SHADES)
end

function a.tile(screen,sheets,name,x,y,dim)
a.layers(screen,sheets.tiles,a.TILE_INDEX[name]*a.TILE,a.TILE,a.TILE,x,y,a.ALL_SHADES,dim)
end

function a.walker(screen,sheets,index,x,y,dim)
a.layers(screen,sheets.heroes,(index-1)*a.HERO,a.HERO,a.HERO,x,y,a.ALL_SHADES,dim)
end

function a.fighter(screen,sheets,id,x,bottom,alignRight,dustFrame)
local b=BeforeTheBell.Bell.Fighters[id]
local c=x
if alignRight then
c=x-b.w
end
screen:layers(sheets.fighters[id],(dustFrame or 0)*b.w,b.w,b.h,c,bottom-b.h,a.ALL_SHADES)
end

function a.lift(screen,y,rows,step)
return math.max(0,y+(rows-1)*step+screen:lineHeight()-screen.height)
end

function a.rivet(screen,x,y)
screen:rect(x-1,y,3,1,a.ink(3))
screen:rect(x,y-1,1,3,a.ink(3))
screen:rect(x,y,1,1,a.ink(4))
end

function a.plate(screen,x,y,w,h)
screen:rect(x+a.PLATE_SHADOW,y+a.PLATE_SHADOW,w,h,a.ink(1))
screen:rect(x,y,w,h,a.ink(1))
screen:rect(x+1,y,w-2,1,a.ink(3))
screen:rect(x+1,y+h-1,w-2,1,a.ink(3))
screen:rect(x,y+1,1,h-2,a.ink(3))
screen:rect(x+w-1,y+1,1,h-2,a.ink(3))
local b=a.RIVET_INSET
a.rivet(screen,x+b,y+b)
a.rivet(screen,x+w-1-b,y+b)
a.rivet(screen,x+b,y+h-1-b)
a.rivet(screen,x+w-1-b,y+h-1-b)
end

function a.panel(screen,y,h)
screen:rect(0,y,screen.width,h,a.ink(1))
screen:rect(0,y,screen.width,1,a.ink(3))
end

function a.list(screen,lines,selected,top,x)
for b=1,#lines do
local c=top+(b-1)*a.ROW
if b==selected then
screen:rect(0,c,screen.width,a.ROW,a.ink(1))
screen:text(lines[b],x,c-1,a.ink(4))
else
screen:text(lines[b],x,c-1,a.ink(1))
end
end
end

a.TOKENS={atk="physical",arm="armor",spd="speed",hp="life",thorns="thorns",poison="poison",bleed="bleed",freeze="freeze",ban="cross",favor="up"}
a.TOKEN_ICONS={gold="coin",heart="heart"}
a.TOKEN_GAP=1
a.WORD_GAP=4

local function j(value)
local b={}
local c=1
while true do
local e,h,g=string.find(value,"%[(%a+)%]",c)
if e==nil then
break
end
if e>c then
b[#b+1]={text=string.sub(value,c,e-1)}
end
if a.TOKEN_ICONS[g]then
b[#b+1]={icon=a.TOKEN_ICONS[g]}
else
b[#b+1]={mark=a.TOKENS[g]}
end
c=h+1
end
if c<=string.len(value)then
b[#b+1]={text=string.sub(value,c)}
end
return b
end

function a.richWidth(screen,value)
local b=0
local c=j(value)
for e=1,#c do
if c[e].mark or c[e].icon then
b=b+a.ICON+a.TOKEN_GAP
else
b=b+screen:textWidth(c[e].text)
end
end
return b
end

local function l(screen,word,width)
local b={}
local c=1
while c<=#word do
local e,h=string.find(word,"%[%a+%]",c)
local g=string.sub(word,c)
if e then
g=string.sub(word,c,e-1)
end
if g~=""then
local i=screen:wrapText(g,width)
for k=1,#i do
b[#b+1]=i[k]
end
end
if not e then
break
end
b[#b+1]=string.sub(word,e,h)
c=h+1
end
return b
end

function a.richWrap(screen,value,width)
local c={}
local b=""
for g in string.gmatch(value,"[^ ]+")do
local e={g}
local k=" "
if a.richWidth(screen,g)>width then
e=l(screen,g,width)
end
for h=1,#e do
local i=e[h]
if b~=""then
i=b..k..e[h]
end
if b~=""and a.richWidth(screen,i)>width then
c[#c+1]=b
b=e[h]
else
b=i
end
k=""
end
end
if b~=""then
c[#c+1]=b
end
return c
end

function a.richText(screen,sheets,value,x,y,shade)
local b=j(value)
for c=1,#b do
if b[c].icon then
a.icon(screen,sheets,b[c].icon,x,y+a.ICON_DY)
x=x+a.ICON+a.TOKEN_GAP
elseif b[c].mark then
a.markLit(screen,sheets,b[c].mark,x,y+a.ICON_DY,math.max(shade,3))
x=x+a.ICON+a.TOKEN_GAP
else
screen:text(b[c].text,x,y,a.ink(shade))
x=x+screen:textWidth(b[c].text)
end
end
end

function a.richCentre(screen,sheets,value,centre,y,shade)
a.richText(screen,sheets,value,centre-math.floor(a.richWidth(screen,value)/2),y,shade)
end

a.TEXT_SHADE=3
a.FAINT_SHADE=2

a.ITEM_INDEX={}
for b=1,#BeforeTheBell.Bell.Items.list do
a.ITEM_INDEX[BeforeTheBell.Bell.Items.list[b].id]=b-1
end

a.BLESSING_INDEX={}
for b=1,#BeforeTheBell.Bell.Cast.blessings do
a.BLESSING_INDEX[BeforeTheBell.Bell.Cast.blessings[b].id]=b-1
end

function a.blessing(screen,sheets,id,x,y,dim)
a.layers(screen,sheets.blessings,a.BLESSING_INDEX[id]*a.ITEM,a.ITEM,a.ITEM,x,y,a.ALL_SHADES,dim)
end
