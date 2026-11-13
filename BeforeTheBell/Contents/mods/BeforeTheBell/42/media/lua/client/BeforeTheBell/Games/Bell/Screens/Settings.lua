-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Games/Bell/Look"
require"BeforeTheBell/Games/Bell/Music"
require"BeforeTheBell/Games/Bell/Rules/Profile"

local a={}
BeforeTheBell.Bell.Settings=a

local g=BeforeTheBell.Bell
local b=g.Look
local j=g.Music
local h=g.Profile
local i=b.text

a.ENTRIES={"music","effects","fast"}
a.LABELS={music="OptMusic",effects="OptEffects",fast="OptSpeed"}
a.SLIDER_W=41
a.GROOVE_DY=5
a.TICK_DY=7
a.TICK_H=2
a.KNOB=2

function a.snapshot(game)
return{music=game.options.music,effects=game.options.effects,fast=game.options.fast}
end

function a.saveIfChanged(game,snapshot)
local c=game.options
if c.music~=snapshot.music or c.effects~=snapshot.effects or c.fast~=snapshot.fast then
h.writeOptions(game.save,c)
game:persist()
end
end

function a.tick(game,input,entry,tune)
local d=input.pressed
local c=0
if d.left then
c=-1
elseif d.right then
c=1
end
if entry=="fast"then
if c==0 and not d.a then
return false
end
game.options.fast=not game.options.fast
game:effect(j.SELECT)
return true
end
if c==0 then
return false
end
local e=math.max(0,math.min(h.LEVELS,game.options[entry]+c))
if e~=game.options[entry]then
game:setLevel(entry,e,tune)
end
game:effect(j.MOVE)
return true
end

function a.label(entry)
return i(a.LABELS[entry])
end

function a.speedValue(game)
if game.options.fast then
return i("SpeedFast")
end
return i("SpeedNormal")
end

function a.drawSlider(screen,x,y,level,chosen)
local k=a.SLIDER_W-1
local c=x+math.floor(level*k/h.LEVELS)
local d=y+a.GROOVE_DY
screen:rect(x,d,a.SLIDER_W,1,b.ink(2))
if c>x then
screen:rect(x,d,c-x,1,b.ink(3))
end
for e=0,2 do
screen:rect(x+math.floor(e*k/2),y+a.TICK_DY,1,a.TICK_H,b.ink(2))
end
local e=3
if chosen then
e=4
end
local f=a.KNOB
screen:rect(c,d-f,1,2*f+1,b.ink(e))
screen:rect(c-1,d-1,3,3,b.ink(e))
screen:rect(c-f,d,2*f+1,1,b.ink(e))
screen:rect(c,d,1,1,b.ink(e-1))
end

function a.rowWidth(screen,game,entry,gap)
local c=a.SLIDER_W
if entry=="fast"then
c=screen:textWidth(a.speedValue(game))
end
return screen:textWidth(a.label(entry))+gap+c
end

function a.drawValue(game,screen,entry,x,y,chosen)
if entry=="fast"then
local c=3
if chosen then
c=4
end
screen:text(a.speedValue(game),x,y,b.ink(c))
return
end
a.drawSlider(screen,x,y,game.options[entry],chosen)
end
