# Breakout.jl

A simple Breakout clone for fun and reinforcement learning on internal game state.

## Features

- Interactive gameplay with keyboard control (← and →).
- Automatic gameplay with heuristic control.
- Automatic gameplay with custom control.
- CommonRLInterface for learning with different state representations

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/rajgoel/Breakout.jl")
```

## Quick Start

### Human control
```julia
using Breakout
breakout()  # Normal speed (default: 1.0)
breakout(speed=0.5)  # Slower
breakout(speed=2.0)  # Faster
breakout(speed=nothing)  # Maximum speed
```

### Heuristic control
```julia
using Breakout
breakout(Breakout.heuristic_action, speed=nothing)
```

### Custom control

To create a custom controller, check out the controller implementations in the `control/` folder.

## API Reference

### Main Functions

- `breakout(control_func=nothing; autorestart=true, speed=2.0, max_steps=nothing)` - Launch the game
- `BreakoutEnv(; frame_skip=4, max_steps=20000, representation=:full)` - Create RL environment

## State Representations for RL Training

The environment supports multiple state representations for reinforcement learning:

- **`:minimal`** (2 features): `paddle_x, ball_x` for basic ball following
- **`:brickless`** (5 features): `paddle_x, ball_x, ball_y, ball_vx, ball_vy` for advanced ball following without brick complexity
- **`:full`** (89 features): Full internal game state including one-hot encoded brick positions (default)
- **`:pixels`** (160 x 210 features): Grayscale pixel values of screenshot as flattened vector

### RL Usage Examples

```julia
import CommonRLInterface as RL

# Environment with full game representation
env = BreakoutEnv()
state = RL.observe(env)  # Returns 89-element vector

# Environment with minimal representation
env = BreakoutEnv(:minimal)
state = RL.observe(env)  # Returns 2-element vector
```

### Game State

The game state is a mutable struct containing:
- `score::Int` - Current score
- `paddle_cx::Float64` - Paddle center x-coordinate
- `ball_cx::Float64` - Ball center x-coordinate
- `ball_vx::Float64` - Ball x-velocity
- `ball_cy::Float64` - Ball center y-coordinate  
- `ball_vy::Float64` - Ball y-velocity
- `bricks::Vector` - Array of remaining brick objects

### Actions

The environment supports both discrete and continuous action spaces:

**Discrete actions (default):**
- `-1`: Move paddle left
- `0`: Keep paddle stationary  
- `1`: Move paddle right

**Continuous actions:**
- Range `(-1, 1)`: Continuous paddle movement speed

```julia
# Discrete actions (default)
env = BreakoutEnv(discrete=true)
actions = RL.actions(env)  # Returns [-1, 0, 1]

# Continuous actions  
env = BreakoutEnv(discrete=false)
actions = RL.actions(env)  # Returns (-1, 1)
```

## License

MIT License
