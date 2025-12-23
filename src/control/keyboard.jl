"""
Keyboard control functions for Breakout.

Provides human player input through SDL keyboard events.
"""

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

# Global keyboard state
mutable struct KeyboardState
    left::Bool
    right::Bool
    KeyboardState() = new(false, false)
end

const keyboard_state = KeyboardState()

"""
    update_keyboard_state()

Update keyboard state from SDL events. Should be called each frame.
"""
function update_keyboard_state()
    # Get current keyboard state from SDL
    keyboard_state_ptr = SDL_GetKeyboardState(C_NULL)
    
    # Check arrow keys
    keyboard_state.left = Bool(unsafe_load(keyboard_state_ptr, SDL_SCANCODE_LEFT + 1))
    keyboard_state.right = Bool(unsafe_load(keyboard_state_ptr, SDL_SCANCODE_RIGHT + 1))
end

"""
    keyboard_action(game_state::GameState) -> Int

Get paddle movement action from keyboard input.

# Arguments
- `game_state`: Current game state (ignored for keyboard input)

# Returns
- `-1`: Move paddle left (LEFT arrow)
- `1`: Move paddle right (RIGHT arrow)  
- `0`: No movement
"""
function keyboard_action(game_state::GameState)
    update_keyboard_state()
    
    if keyboard_state.left
        return -1
    elseif keyboard_state.right
        return 1
    else
        return 0
    end
end

