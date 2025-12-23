"""
Functions for flattening the game state.

Converts game state into flattened vectors suitable for neural network input.
"""

"""
    flatten(game_state::GameState, representation=:full) -> Vector{Float32}

Convert game state to flattened vector suitable for neural network input.

# Arguments
- `game_state`: GameState struct containing game information  
- `representation`: State representation mode
  - `:minimal`: 2 features representing the x-coordinate of the paddle and the ball
  - `:brickless`: 5 features representing the x-coordinate of the paddle and the ball, the horizontal movement of the ball, the y-coordinate of the ball, and the vertical movement of the ball
  - `:full`: all features including one-hot encoding of bricks (89 features)

# Returns
Vector{Float32} with features depending on representation mode
"""
function flatten(game_state::GameState, representation=:full)
    # Set normalized continuous features
    playable_width = GAME_WIDTH - 2 * WALL_THICKNESS
    playable_height = GAME_HEIGHT - SCORE_AREA_HEIGHT - WALL_THICKNESS

    # Create output vector with sufficient size
    grid_size = ROWS * COLS
    output = zeros(Float32, grid_size + 5)

    paddle_cx = game_state.paddle.x + game_state.paddle.w/2
    ball_cx = game_state.ball.x + BALL_SIZE/2

    output[1] = Float32((paddle_cx - WALL_THICKNESS) / playable_width)                 # Paddle X: [0, 1]
    output[2] = Float32((ball_cx - WALL_THICKNESS) / playable_width)                    # Ball X: [0, 1]

    if ( representation == :minimal ) 
        return output[1:2]
    end

    ball_vx = game_state.ball_vel[1]
    ball_cy = game_state.ball.y + BALL_SIZE/2
    ball_vy = game_state.ball_vel[2]
    
    output[3] = Float32(ball_vx)                                                        # Ball vel X: [-1, 1]
    output[4] = Float32((ball_cy - (SCORE_AREA_HEIGHT + WALL_THICKNESS)) / playable_height)  # Ball Y: [0, 1]
    output[5] = Float32(ball_vy)                                                        # Ball vel Y: {-1, 1}

    if ( representation == :brickless ) 
        return output[1:5]
    end
    
    Δ = 6
    # One-hot encoding for each brick position
    for brick in game_state.bricks
        # Convert to 0-based grid coordinates
        col = Int((brick.rect.x - WALL_THICKNESS) ÷ BRICK_WIDTH)
        row = Int((brick.rect.y - (SCORE_AREA_HEIGHT + WALL_THICKNESS + 30)) ÷ BRICK_HEIGHT)
        
        # Assert valid indices
        @assert 0 ≤ row < ROWS "Row index $row out of bounds [0, $(ROWS-1)]"
        @assert 0 ≤ col < COLS "Col index $col out of bounds [0, $(COLS-1)]"
        
        output[row * COLS + col +  Δ] = 1.0f0
    end

    return output
end

