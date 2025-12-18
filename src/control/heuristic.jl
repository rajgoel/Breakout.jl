"""
Heuristic control functions for Breakout.

Provides AI agent that uses ball-following strategy to play the game.
"""

"""
    heuristic_action(game_state::GameState) -> Int

Get paddle movement action using ball-following heuristic strategy.

Implements a simple but effective strategy: move the paddle toward the ball's
horizontal position with a small dead zone to reduce jittery movement.

# Arguments
- `game_state`: Current game state struct

# Returns
- `-1`: Move paddle left (ball is to the left)
- `1`: Move paddle right (ball is to the right)
- `0`: No movement (ball is approximately centered)
"""
function heuristic_action(game_state::GameState)
    # Extract game state components
    ball_cx = game_state.ball.x + BALL_SIZE/2
    paddle_cx = game_state.paddle.x + game_state.paddle.w/2
    
    # Ball-following heuristic with small dead zone
    if ball_cx < paddle_cx - 1
        return -1  # Move left
    elseif ball_cx > paddle_cx + 1
        return 1   # Move right
    else
        return 0   # Stay in place (dead zone)
    end
end

