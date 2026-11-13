-- Before the Bell (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"BeforeTheBell/Core"
require"SpiffBoy/Framework/Cartridges"

SpiffBoy.Cartridges.register({
api=1,
id="Bell",
item="BeforeTheBell.Cartridge_Bell",
title="Before the Bell",
mod=BeforeTheBell.MOD_ID,
game="BeforeTheBellBellGame",
art="media/ui/BeforeTheBell/Games/Bell/",
texts="media/lua/shared/BeforeTheBell/Games/Bell/Translate/",
loot={weight=2},
})
