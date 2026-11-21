extends RefCounted

## GameSpice Team's API level. The rule for bumping it is on [GSAddonApi].
##
## LEVEL rises for anything new a game could call; OLDEST rises to LEVEL when a callable
## is removed or changes meaning.

# 1 is everything before this file existed; 2 GSTeamRotation; 3 GSTeamRotation.pick
# rest_first; 4 GSTeamBlockRules, GSTeamBlockConfig and GSTeamBlockCommands; 5 GSTeamMenuServer;
# 6 GSTeamSet.palette_colour, palette_name and the PALETTE_* tables.
const LEVEL := 6
const OLDEST := 1
