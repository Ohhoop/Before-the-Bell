-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"
require"SpiffBoy/Core/Tunes"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local a={}
BeforeTheBell.Bell.Music=a

a.CAMP="camp"
a.ROAD="road"
a.BATTLE="battle"
a.BOSS="boss"
a.MARKET="market"
a.SHRINE="shrine"
a.SMITHY="smithy"
a.MOVE="move"
a.SELECT="select"
a.BACK="back"
a.BUMP="bump"
a.STEP="step"
a.HIT="hit"
a.HURT="hurt"
a.HEAL="heal"
a.COIN="coin"
a.FORGE="forge"
a.CLANG="clang"
a.HISS="hiss"
a.CHEST="chest"
a.BLESS="bless"
a.NIGHT="night"
a.DAWN="dawn"
a.WIN="win"
a.LOSE="lose"
a.TOLL="toll"
a.RING="ring"
a.ENCOUNTER="encounter"

SpiffBoy.Tunes.register("Bell",{
[a.CAMP]={
loop=true,
pulse1="t84 @2 v8 y0 q7 o4 l4 d f a | g2 e | f e d | c2. | d f a | >c2< a | g e c | d2."
.." | a >c d | c2< a | g f e | f2. | d f a | g2 e | f e c | d2.",
wave="t84 @19 v1 o3 l2. d | c | d | a | d | f | c | d | f | f | c | f | d | c | c | d",
noise="t84 l8 [v2 y1 n101 r r v1 y1 n76 r r]16",
},
[a.ROAD]={
loop=true,
pulse1="t108 @1 v9 y0 q6 o4 l8 a4 >c4< b a g e | f4 a4 g4 e4 | a4 >c4 d4 e4 | d2 c4< b4"
.." | a4 >c4< b a g e | f4 a4 g4 b4 | >c4< b4 a4 g4 | a2 r2",
wave="t108 @19 v1 o3 l4 a a e e | f f c c | a a f f | g g e e | a a e e | f f g g | a a e e | a r a r",
noise="t108 l8 [v6 y1 n{44 106} r v3 y1 n84 r v5 y2 n68 r v3 y1 n84 r]8",
},
[a.BATTLE]={
loop=true,
pulse1="t150 @2 v10 y1 q5 o4 l8 e e f e g4 f e | e e f e b4 a g | a a b- a >c4< b- a | g4 f4 e2"
.." | e e f e g4 f e | e e f e >c4< b a | b4 a4 g4 f4 | e2 r2",
wave="t150 @19 v2 o2 l8 [e e >e< e e e >e< e]2 [f f >f< f f f >f< f]1 [e e >e< e e e >e< e]1"
.." [e e >e< e e e >e< e]2 [a a >a< a g g >g< g]1 e e >e< e e r e r",
noise="t150 l8 [v9 y1 n{44 106} v4 y1 n84 v8 y2 n68 v4 y1 n84 v9 y1 n{44 106} v9 y1 n{44 106} v8 y2 n68 v4 y1 n84]8",
},
[a.BOSS]={
loop=true,
pulse1="t176 @3 v11 y1 q6 o4 l4 b >d c+< b | a2 f+2 | g b a g | f+1 | b >d e f+ | g2 f+2 | e d c+< a | b1",
wave="t176 @19 v2 o2 l8 [b b b b b b b b]2 [g g g g a a a a]1 [f+ f+ f+ f+ f+ f+ f+ f+]1"
.." [b b b b b b b b]2 [e e e e f+ f+ f+ f+]1 [b b b b b r b r]1",
noise="t176 l8 [v10 y1 n{44 106} r v8 y2 n68 v10 y1 n{44 106} v10 y1 n{44 106} r v8 y2 n68 v4 y1 n84]8",
},
[a.MARKET]={
loop=true,
pulse1="t132 @1 v9 y1 q5 o5 l8 g b >d< b >c< a f+ a | g b >d g4 d< b g | e g >c< g f+ a >d< a | g4 d4 g4 r4"
.." | a >c e c d< b g b | >c< a f+ a g4 r4 | e g b g f+ a >c< a | g4 d4 g4 r4",
wave="t132 @19 v1 o3 l4 g >d< g >d< | g >d< g >d< | c g d a | g >d< g r | a >e< a >e< | d a g r | c g d a | g >d< g r",
noise="t132 l8 [v3 y1 n84 r v5 y2 n68 r]16",
},
[a.SHRINE]={
loop=true,
pulse1="t72 @2 v7 y3 q7 o5 l4 a2 f+ | e2 d | f+2 a | b2. | a2 >d< | c+2 a | b a f+ | a2.",
wave="t72 @19 v1 o3 l2. d | a | d | g | f+ | a | g | d",
},
[a.SMITHY]={
loop=true,
pulse1="t96 @2 v9 y2 q6 o3 l4 d d8 e8 f e | d c d2 | f f8 g8 a g | f e d2"
.." | a a8 b-8 a g | f g a2 | g f e c | d2 r2",
wave="t96 @19 v1 o2 l4 [d d d d]2 [f f f f]1 [d d d d]1 [a a a a]1 [f f g g]1 [g g a a]1 [d d d r]1",
noise="t96 l8 [v10 y2 n26 r v4 y1 n84 r v7 y1 n{98 110} r v4 y1 n84 r]8",
},
[a.MOVE]={pulse2="t300 @0 v7 y1 l64 o5 a"},
[a.SELECT]={pulse2="t260 @3 v10 y2 l32 o4 d a >d"},
[a.BACK]={pulse2="t260 @3 v9 y2 l32 o5 d <a"},
[a.BUMP]={noise="t240 l32 v8 y1 n{98 110}"},
[a.STEP]={noise="t300 l64 v3 y1 n86"},
[a.HIT]={noise="t240 l16 v12 y2 n{26 66 102}"},
[a.HURT]={pulse2="t240 @1 v12 y2 l32 o4 f+ c <f+",noise="t240 l16 v9 y2 n{66 98}"},
[a.HEAL]={pulse2="t220 @2 v9 y3 l32 o5 d f+ a f+ >d"},
[a.COIN]={pulse2="t260 @1 v10 y2 l32 o6 d a16"},
[a.FORGE]={pulse2="t200 @0 v11 y3 l16 o6 c+ r c+",noise="t200 l16 v10 y1 n26 r n26"},
[a.CLANG]={pulse2="t220 @0 v15 y3 l16 o6 {a+ >e}"},
[a.HISS]={noise="t70 l2 v11 y7 n{16 16 16 16 32 32 32 40}"},
[a.CHEST]={pulse2="t150 @1 v9 y3 l16 r8 o4 g a >c e",noise="t120 l4 v6 y4 n{96 104 112}"},
[a.BLESS]={pulse2="t160 @2 v9 y4 l16 o5 d a >d e8"},
[a.NIGHT]={pulse2="t120 @2 v10 y5 l8 o4 d c <a- g4"},
[a.DAWN]={pulse2="t180 @1 v10 y3 l16 o5 d e f+ a4"},
[a.WIN]={pulse2="t180 @2 v11 y3 l16 o5 d d a a >d8 c+ d4"},
[a.LOSE]={pulse2="t110 @2 v10 y4 l8 o4 a f d <a2"},
[a.ENCOUNTER]={pulse2="t180 @2 v12 y2 l32 o4 a >c+ e a >c+ e a8 r8 <a4",noise="t180 l16 v11 y3 n{26 66} r r r r r v9 y4 n{26 54}"},
[a.RING]={pulse2="t150 @2 v13 y6 l8 o5 r d r d2",noise="t150 l8 r v6 y5 n{30 54} r v5 y5 n{30 54}"},
[a.TOLL]={pulse2="t90 @2 v13 y6 l4 o5 d r d2",noise="t90 l4 v6 y5 n{30 54} r v5 y5 n{30 54} r"},
})
