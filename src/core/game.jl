"""
Core game logic for Breakout.

Manages game state, physics, collisions, and scoring mechanics.
"""

using Colors

# Game dimensions and layout
const SCORE_AREA_HEIGHT = 20
const WALL_THICKNESS = 10
const COLS = 14  # Brick columns
const ROWS = 6   # Brick rows
const BRICK_WIDTH = 10
const BRICK_HEIGHT = 6
const GAME_WIDTH = COLS * BRICK_WIDTH + 2 * WALL_THICKNESS  # 160 pixels
const GAME_HEIGHT = 210  # Classic Atari height

# Game object sizes
const BALL_SIZE = 2
const PADDLE_WIDTH = 20
const PADDLE_HEIGHT = 3
const MAX_VX = 1.0  # Maximum vertical speed

# Simple Rectangle struct for collision detection
mutable struct Rect
    x::Float32
    y::Float32
    w::Float32
    h::Float32
end

# Collision detection for axis-aligned rectangles
function collide(rect1::Rect, rect2::Rect)
    return !((rect1.x + rect1.w) < rect2.x || rect1.x > (rect2.x + rect2.w) ||
             (rect1.y + rect1.h) < rect2.y || rect1.y > (rect2.y + rect2.h))
end

struct Brick
    rect::Rect
    color
    points::Int
end

# Game state struct to replace global variables
mutable struct GameState
    score::Int
    ball::Rect
    ball_vel::Tuple{Float64, Float64}
    paddle::Rect
    bricks::Vector{Brick}
    
    function GameState()
        score = 0
        ball = Rect(GAME_WIDTH / 2, GAME_HEIGHT / 2, BALL_SIZE, BALL_SIZE)
        ball_vel = (0.0, 0.0)
        paddle = Rect(GAME_WIDTH / 2 - PADDLE_WIDTH/2, GAME_HEIGHT - 8, PADDLE_WIDTH, PADDLE_HEIGHT)
        bricks = Brick[]
        new(score, ball, ball_vel, paddle, bricks)
    end
end

"""
Initialize game state with Atari-style brick layout and ball position
"""
function reset!(game_state::GameState, keep_score=false)
    empty!(game_state.bricks)
    if !keep_score
        game_state.score = 0  # Reset score on game over
    end
    
    # Authentic Atari color palette with point values - 1 row per color
    atari_colors = [
        RGB(0.8, 0.2, 0.2),   # Red (10 points - top row, hardest to reach)
        RGB(0.8, 0.5, 0.1),   # Orange (8 points)
        RGB(0.8, 0.8, 0.3),   # Yellow (6 points)
        RGB(0.3, 0.7, 0.3),   # Green (4 points)
        RGB(0.2, 0.4, 0.8),   # Blue (2 points)
        RGB(0.3, 0.7, 0.7)    # Cyan (1 point - bottom row, easiest to reach)
    ]
    
    # Point values for each row (top to bottom: 10,8,6,4,2,1)
    point_values = [10, 8, 6, 4, 2, 1]
    
    # Create brick wall positioned below walls
    brick_start_x = WALL_THICKNESS + 1
    brick_start_y = SCORE_AREA_HEIGHT + WALL_THICKNESS + 30
    for x in 1:COLS
        for y in 1:ROWS
            brick_color = atari_colors[y]
            brick_points = point_values[y]
            brick = Brick(
                Rect(brick_start_x + (x-1) * BRICK_WIDTH, brick_start_y + (y-1) * BRICK_HEIGHT, BRICK_WIDTH, BRICK_HEIGHT),
                brick_color,
                brick_points
            )
            push!(game_state.bricks, brick)
        end
    end

    # Position ball below the brick wall (set top-left corner directly)
    ball_start_y = brick_start_y + ROWS * BRICK_HEIGHT + 5
    game_state.ball.x = GAME_WIDTH / 2.0 - BALL_SIZE/2
    game_state.ball.y = ball_start_y - BALL_SIZE/2
    game_state.ball_vel = (rand() * 1.5 - .75, 1.0)  # Random vx in [-.75,.75]
    
    # Warm-up collision detection to avoid first-hit compilation delay
    collide(game_state.ball, game_state.paddle)
end

"""
Update ball position and handle collisions
"""
function update_step!(game_state::GameState)
    vx, vy = game_state.ball_vel
    
    # Check for ball falling off bottom (game over)
    if game_state.ball.y + BALL_SIZE > GAME_HEIGHT
        return false  # Game over - let caller handle restart
    end
    
    # Move ball rect directly
    game_state.ball.x += vx
    game_state.ball.y += vy
    
    # Wall collisions
    if game_state.ball.x <= WALL_THICKNESS
        vx = -vx
        game_state.ball.x = WALL_THICKNESS + 1
    elseif game_state.ball.x + BALL_SIZE >= GAME_WIDTH - WALL_THICKNESS
        vx = -vx
        game_state.ball.x = GAME_WIDTH - WALL_THICKNESS - BALL_SIZE
    end

    if game_state.ball.y <= SCORE_AREA_HEIGHT + WALL_THICKNESS
        vy = -vy
        game_state.ball.y = SCORE_AREA_HEIGHT + WALL_THICKNESS + 1
    end
    
    # Paddle collision
    if collide(game_state.ball, game_state.paddle)
        # Apply angle based on where ball hits paddle
        vx = clamp( ((game_state.ball.x + BALL_SIZE/2) - (game_state.paddle.x + game_state.paddle.w/2)) / (game_state.paddle.w / 2), -1.0, 1.0) * MAX_VX
        vy = -abs(vy)
    else
        # Brick collisions
        collisions = [collide(game_state.ball, brick.rect) for brick in game_state.bricks]
        idx = findfirst(x -> x == true, collisions)
        if idx ≠ nothing
            brick = game_state.bricks[idx]
            dx = ((game_state.ball.x + BALL_SIZE/2) - (brick.rect.x + brick.rect.w/2)) / BRICK_WIDTH
            dy = ((game_state.ball.y + BALL_SIZE/2) - (brick.rect.y + brick.rect.h/2)) / BRICK_HEIGHT
            
            # Determine bounce direction
            if abs(dx) > abs(dy)
                vx = copysign(abs(vx), dx)
            else
                vy = copysign(abs(vy), dy)
            end
            
            # Remove hit brick and update score
            brick_score = game_state.bricks[idx].points
            deleteat!(game_state.bricks, idx)
            game_state.score += brick_score
            
            # Check if all bricks are destroyed
            if length(game_state.bricks) == 0
                game_state.score += 66  # Bonus for clearing all bricks
                reset!(game_state, true)  # Keep score for next level
                return true  # Continue to next level
            end
        end
    end
    
    game_state.ball_vel = (vx, vy)
    return true  # Continue game
end

"""
Update game with action - returns false on game over
"""
function update!(game_state::GameState, action)
    # Apply paddle movement
    paddle_speed = 1
    game_state.paddle.x += action * paddle_speed
    
    # Keep paddle within playable area (between walls)
    if game_state.paddle.x < WALL_THICKNESS + 1
        game_state.paddle.x = WALL_THICKNESS + 1
    elseif game_state.paddle.x + game_state.paddle.w > GAME_WIDTH - WALL_THICKNESS + 1
        game_state.paddle.x = GAME_WIDTH - WALL_THICKNESS + 1 - game_state.paddle.w
    end
    
    # Update ball physics and collisions
    return update_step!(game_state)
end

"""
Get interval of valid continuous actions as (min_action, max_action)
"""
function get_action_mask(game_state::GameState)
    paddle_cx = game_state.paddle.x + game_state.paddle.w/2
    
    return ( max(-1.0,WALL_THICKNESS + 1 - paddle_cx - PADDLE_WIDTH/2), min(1.0,GAME_WIDTH - WALL_THICKNESS - 1 - paddle_cx + PADDLE_WIDTH/2) )
end
