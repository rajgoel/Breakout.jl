import CommonRLInterface as RL

export BreakoutEnv

"""
    BreakoutEnv(representation=:full; frame_skip=4, max_steps=20000, discrete=true)

Create a Breakout environment implementing CommonRLInterface.

# Arguments
- `frame_skip=4`: Number of frames to repeat each action
- `max_steps=20000`: Maximum steps before episode termination
- `discrete=true`: Whether to use discrete actions [-1, 0, 1] or continuous range
- `representation=:full`: State representation mode
  - `:minimal`: paddle_x, ball_x (2 features)
  - `:brickless`: paddle_x, ball_x, ball_y, ball_vx, ball_vy (5 features)
  - `:full`: all features including brick positions (89 features)
  - `:pixels`: raw screenshot as flattened vector
"""
mutable struct BreakoutEnv <: RL.AbstractEnv
    game_state::Breakout.GameState
    discrete::Bool
    game_over::Bool
    frame_skip::Int
    max_steps::Int
    current_steps::Int
    representation::Symbol
    
    function BreakoutEnv(representation=:full; frame_skip=4, max_steps=20000, discrete=true)
        game_state = Breakout.GameState()
        env = new(game_state, discrete, false, frame_skip, max_steps, 0, representation)
        RL.reset!(env)
        return env
    end
end

"""
Reset environment to initial state.
"""
function RL.reset!(env::BreakoutEnv)
    Breakout.reset!(env.game_state, false)
    env.game_over = false
    env.current_steps = 0
end

"""
Return available actions: discrete [-1,0,1] or continuous range (-1,1).
"""
function RL.actions(env::BreakoutEnv)
    if env.discrete
          return [-1, 0, 1] # Array of valid actions
    else
          return (-1, 1) # Tuple: (min, max) range
    end
end

"""
Get current state observation based on representation mode.
"""
function RL.observe(env::BreakoutEnv)
    if env.representation == :pixels
        return vec(render_screenshot(env.game_state))
    end   
    return Breakout.flatten(env.game_state, env.representation)
end

"""
Execute action and return reward.
"""
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
    
    reward = Float32(env.game_state.score - prev_score)
    return reward
end

"""
Check if episode is terminated.
"""
function RL.terminated(env::BreakoutEnv)
    return env.game_over
end

