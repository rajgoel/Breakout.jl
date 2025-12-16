# Breakout.jl

A simple Breakout clone for fun and reinforcement learning on internal game state.

## Features

- **Interactive gameplay** with keyboard controls (Arrow keys or WASD)
- **Reinforcement Learning interface** compatible with CommonRLInterface.jl
- **Customizable game speed** and auto-restart functionality
- **Built-in control strategies** (heuristic, random, keyboard)
- **Screenshot capabilities** for reinforcement learning on gray images.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/rajgoel/Breakout.jl")
```

## Quick Start

### Human control
```julia
using Breakout
breakout()
```

### Heuristic control
```julia
using Breakout
breakout(Breakout.get_heuristic_action, speed=nothing)
```

### Custom control

To create a self-trained controller, check out the controller implementations in the `control/` folder.

## API Reference

### Main Functions

- `breakout(control_func=nothing; autorestart=true, speed=2.0, max_steps=nothing)` - Launch the game
- `BreakoutEnv(; frame_skip=4, max_steps=20000)` - Create RL environment

### Game State

The game state is a named tuple containing:
- `score::Int` - Current score
- `ball_cx::Float64` - Ball center x-coordinate
- `ball_cy::Float64` - Ball center y-coordinate  
- `ball_vx::Float64` - Ball x-velocity
- `ball_vy::Float64` - Ball y-velocity
- `paddle_cx::Float64` - Paddle center x-coordinate
- `bricks::Vector` - Array of remaining brick objects

### Actions

Actions are integers representing paddle movement:
- `-1`: Move paddle left
- `0`: Keep paddle stationary  
- `1`: Move paddle right

## License

MIT License
