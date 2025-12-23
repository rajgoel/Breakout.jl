import CommonRLInterface as RL

export BreakoutEnv

mutable struct BreakoutEnv <: RL.AbstractEnv
    game_state::Breakout.GameState
    discrete::Bool
    game_over::Bool
    frame_skip::Int
    max_steps::Int
    current_steps::Int
    flattened::Vector{Float32}
    
    function BreakoutEnv(; frame_skip=4, max_steps=20000, discrete=true)
        game_state = Breakout.GameState()
        env = new(game_state, discrete, false, frame_skip, max_steps, 0, Float32[])
        RL.reset!(env)
        return env
    end
end

function RL.reset!(env::BreakoutEnv)
    Breakout.reset!(env.game_state, false)
    env.flattened = Breakout.flatten(env.game_state)
    env.game_over = false
    env.current_steps = 0
end

function RL.actions(env::BreakoutEnv)
    if env.discrete
          return [-1, 0, 1] # Array of valid actions
    else
          return (-1, 1) # Tuple: (min, max) range
    end
end

function RL.observe(env::BreakoutEnv)
    return env.flattened
end

function RL.act!(env::BreakoutEnv, action)
    prev_score = env.game_state.score
    
    # Repeat action for frame_skip frames
    for _ in 1:env.frame_skip
        env.current_steps += 1
        
        # Check if max steps reached
        if env.current_steps >= env.max_steps
            env.game_over = true
            break
        end
        
        env.game_over = !Breakout.update!(env.game_state, action)
        if env.game_over
            break  # Stop if game ends mid-skip
        end
    end
    
    env.flattened = Breakout.flatten(env.game_state)
    reward = Float32(env.game_state.score - prev_score)
    return reward
end

function RL.terminated(env::BreakoutEnv)
    return env.game_over
end

