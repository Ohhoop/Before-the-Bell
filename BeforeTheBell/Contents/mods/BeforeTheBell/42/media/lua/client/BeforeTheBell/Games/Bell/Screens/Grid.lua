-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"

local a={}
BeforeTheBell.Bell.Grid=a

local b=BeforeTheBell.Bell.Look

a.CURSOR_RINGS=4

function a.move(cells,index,dx,dy)
local c=cells[index]
if dx~=0 then
for d=1,#cells do
if cells[d].row==c.row and cells[d].col==c.col+dx then
return d
end
end
return index
end
local f,d=index,nil
for e=1,#cells do
if cells[e].row==c.row+dy then
local g=math.abs(cells[e].col-c.col)
if d==nil or g<d then
f,d=e,g
end
end
end
return f
end

function a.step(pressed)
if pressed.left then return-1,0 end
if pressed.right then return 1,0 end
if pressed.up then return 0,-1 end
if pressed.down then return 0,1 end
return nil
end

function a.empty(screen,x,y)
local c=b.ITEM
screen:rect(x,y,c,1,b.ink(2))
screen:rect(x,y+c-1,c,1,b.ink(2))
screen:rect(x,y,1,c,b.ink(2))
screen:rect(x+c-1,y,1,c,b.ink(2))
end

function a.cursor(screen,x,y,w,h)
for c=1,a.CURSOR_RINGS do
local d=4
if c==1 or c==a.CURSOR_RINGS then
d=1
end
screen:rect(x-c,y-c,w+2*c,1,b.ink(d))
screen:rect(x-c,y+h+c-1,w+2*c,1,b.ink(d))
screen:rect(x-c,y-c+1,1,h+2*c-2,b.ink(d))
screen:rect(x+w+c-1,y-c+1,1,h+2*c-2,b.ink(d))
end
end

a.CORNER=5
a.PULSE_TICKS=16
a.CORNER_OUT=2
a.ON_DARK=4
a.ON_LIGHT=1

function a.select(screen,x,y,w,h,ticks,shade)
local d=a.CORNER_OUT+(math.floor(ticks/a.PULSE_TICKS)%2)
local e,f=x-d,y-d
local g,i=x+w+d-1,y+h+d-1
local c=a.CORNER
screen:rect(e,f,c,1,b.ink(shade))
screen:rect(e,f,1,c,b.ink(shade))
screen:rect(g-c+1,f,c,1,b.ink(shade))
screen:rect(g,f,1,c,b.ink(shade))
screen:rect(e,i,c,1,b.ink(shade))
screen:rect(e,i-c+1,1,c,b.ink(shade))
screen:rect(g-c+1,i,c,1,b.ink(shade))
screen:rect(g,i-c+1,1,c,b.ink(shade))
end

