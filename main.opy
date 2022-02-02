globalvar CheckpointPositions
globalvar Prime
globalvar TimeRemaining
globalvar Radius_VA_

playervar PlayerStates

enum Primes:
    DISABLE_SLAM = 2,
    DISABLE_UPPER = 3,
    DISABLE_PUNCH = 5,
    LEVEL_SELECT = 11,
    FIRST_CP_LEVEL = 13

enum StateIdx:
    INITIALIZED = 0,
    CURRENT_LEVEL = 1,
    CURRENT_CHECKPOINT = 2,
    CHECKPOINT_COUNTER = 3,
    LEFT_CHECKPOINT = 4


def setAbilities():
    eventPlayer.setAbility1Enabled(true if Prime[eventPlayer.PlayerStates[StateIdx.CHECKPOINT_COUNTER]] % Primes.DISABLE_UPPER else false)
    eventPlayer.setAbility2Enabled(true if Prime[eventPlayer.PlayerStates[StateIdx.CHECKPOINT_COUNTER]] % Primes.DISABLE_SLAM else false)
    eventPlayer.setSecondaryFireEnabled(true if Prime[eventPlayer.PlayerStates[StateIdx.CHECKPOINT_COUNTER]] % Primes.DISABLE_PUNCH else false)

rule "Initialize Map Data":
    disableAnnouncer()
    disableGamemodeCompletion()
    disableMusic()
    disableScoring()

    CheckpointPositions = [vect(2.670, 6.500, -71.532), vect(0.239, 1.371, -74.092)]
    Radius_VA_ = [vect(2, vect(1, 1, 1), false), vect(2, vect(1, 1, 1), false)]
    Prime = [2, 2]

rule "Player Joins":
    @Event playerJoined
    # Init player states
    eventPlayer.PlayerStates = [false, false, false, false, false]

    eventPlayer.disableMessages()
    eventPlayer.disableRespawn()
    eventPlayer.disablePlayerCollision()
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 99999)


    waitUntil(eventPlayer.hasSpawned(), 99999)
    eventPlayer.teleport(CheckpointPositions[0])
    setAbilities()
    eventPlayer.PlayerStates[StateIdx.INITIALIZED] = true

rule "Display Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.PlayerStates[StateIdx.INITIALIZED]

    eventPlayer.communicate(Comms.ACKNOWLEDGE)
    createEffect(eventPlayer, Effect.RING, Color.GREEN, CheckpointPositions[eventPlayer.PlayerStates[StateIdx.CHECKPOINT_COUNTER]], 2, EffectReeval.VISIBILITY)
    createEffect(eventPlayer, Effect.RING, Color.GREEN, CheckpointPositions[eventPlayer.PlayerStates[StateIdx.CHECKPOINT_COUNTER] + 1], 2, EffectReeval.VISIBILITY)
    
# rule "Complete Checkpoint":
#     @Event eachPlayer


rule "Match time -- Written By Hax":
    if getCurrentGamemode() == Gamemode.SKIRMISH:
        goto lbl_0
    wait(0.25)
    setMatchTime(1)
    wait(1.1)
    setMatchTime(1)
    wait(1.1)
    lbl_0:
    while true:
        setMatchTime(3600)
        wait(2875)
        TimeRemaining += true
        if TimeRemaining == 5:
            TimeRemaining = 1800
            hudHeader(getAllPlayers(), "  Server Restarts In {0} Min  ".format(ceil(TimeRemaining / 60)), HudPosition.RIGHT, -200, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
            chase(TimeRemaining, false, rate=true, ChaseReeval.NONE)
            wait(1795)
            bigMessage(getAllPlayers(), "Restarting")
            wait(5)
            if getCurrentGamemode() == Gamemode.FFA:
                declarePlayerVictory(getPlayersInSlot(1, Team.ALL))
            else:
                declareTeamVictory(Team.1)
            return




    
