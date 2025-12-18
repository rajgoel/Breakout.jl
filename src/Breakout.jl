"""
Breakout Game Module

Contains all core functions and control systems for the Breakout game.
"""
module Breakout

# Game runner dependencies
using FileIO, Images, Colors, SimpleDirectMediaLayer, CommonRLInterface                      

# Include all game files
include("core/game.jl")
include("core/draw.jl")
include("core/flatten.jl")
include("control/keyboard.jl")
include("control/heuristic.jl")
include("control/random.jl")
include("core/renderer.jl")
include("interface.jl")

# Export main functions that external code needs
export breakout, BreakoutEnv

"""
    breakout(control_func=nothing; autorestart=true, speed=1.0, max_steps=nothing)

Launch the Breakout game with the specified control function using SDL rendering.

# Arguments
- `control_func`: Function that takes game state and returns action (-1, 0, 1)
  - If nothing, uses default keyboard control
- `autorestart`: Whether to automatically restart the game when ball falls off (default: true)
- `speed`: Game speed multiplier (1.0 = 60fps, 2.0 = 120fps equivalent)
- `max_steps`: Maximum number of steps before stopping (nothing = unlimited)

# Controls
- **Keyboard mode**: Arrow keys or WASD to move paddle, ESC to quit
- **Function mode**: AI/Agent plays automatically, ESC to quit

# Usage

Run with keyboard control:
```
using Breakout
breakout()
```

Run with heuristic control and max speed:
```
using Breakout
breakout(Breakout.heuristic_action, speed=nothing)
```
"""
function breakout(control_func=nothing; autorestart=true, speed=2.0, max_steps=nothing, game_counter=1)
    println("🎮 Starting Breakout, press ESC to stop.")
    if control_func === nothing
        get_control_action = keyboard_action
    else
        get_control_action = control_func
    end
    
    # Create window and start game loop
    create_window()
    
    try
        # Reset game to initial state
        reset()
        
        # Main game loop
        running = true
        step_count = 0
        current_game = game_counter
        if speed !== nothing
            target_frame_time = 1.0 / (60 * speed)
            last_frame_time = time()
        end
        
        while running
            # Get current game state
            game_state = get_state()
            
            # Process events
            running = process_events(game_state)
            if !running
                break
            end
            
            # Get action from control function
            action = get_control_action(game_state)
            
            # Update game
            game_over = !update(action)
            step_count += 1
            
            # Check step limit - treat as game over if max steps reached
            if max_steps !== nothing && step_count >= max_steps
                game_over = true
            end
            
            # Handle game over based on autorestart setting
            if game_over && autorestart
                reset()
                step_count = 0  # Reset step counter for new game
                current_game += 1  # Increment game counter
                game_state = get_state()  # Get new state after reset
            elseif game_over && !autorestart
                break  # Exit if game over and no autorestart
            end
            
            # Render current state
            render_display(game_state, current_game)
            
            # Control frame rate based on elapsed time
            if speed !== nothing
                current_time = time()
                elapsed = current_time - last_frame_time
                if elapsed < target_frame_time
                    sleep(target_frame_time - elapsed)
                end
                last_frame_time = time()
            end
        end
        
    finally
        close_window()
    end
    
    println("Game ended")
end

end # module Breakout
