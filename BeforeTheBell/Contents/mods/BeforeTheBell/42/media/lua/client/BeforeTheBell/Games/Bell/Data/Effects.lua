-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"

BeforeTheBell.Bell=BeforeTheBell.Bell or{}

local a={}
BeforeTheBell.Bell.Effects=a

a.CELL=32
a.list={
slash={right=0,left=4,count=4},
slashBack={right=8,left=12,count=4},
thrust={right=16,left=20,count=4},
smash={right=24,left=28,count=4},
bite={right=32,left=36,count=4},
claw={right=40,left=44,count=4},
lash={right=48,left=52,count=4},
hex={right=56,left=60,count=4,flightRight=64,flightLeft=65},
frost={right=66,left=70,count=4,flightRight=74,flightLeft=75},
arrow={right=76,left=80,count=4,flightRight=84,flightLeft=85},
wave={right=86,left=90,count=4},
blast={right=94,left=98,count=4},
bomb={right=102,left=106,count=4,flightRight=110,flightLeft=111},
}
