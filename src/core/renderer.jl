using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

# Window constants - game dimensions scaled by 4
const SCALE_FACTOR = 4
const WINDOW_WIDTH = GAME_WIDTH * SCALE_FACTOR
const WINDOW_HEIGHT = GAME_HEIGHT * SCALE_FACTOR

# Module-level variables
window = nothing
renderer = nothing

"""
Create SDL window for game display.
"""
function create_window()
    global window, renderer
    @assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
    
    window = SDL_CreateWindow("Breakout", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE)
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED)
    
    # Set logical size for automatic scaling and centering
    SDL_RenderSetLogicalSize(renderer, GAME_WIDTH, GAME_HEIGHT)
    
    println("Window created.")
end

"""
Close SDL window and cleanup resources.
"""
function close_window()
    global window, renderer
    if renderer !== nothing
        SDL_DestroyRenderer(renderer)
        renderer = nothing
    end
    if window !== nothing
        SDL_DestroyWindow(window)
        window = nothing
    end
    SDL_Quit()
    println("Window closed.")
end

"""
Process SDL window events to identify whether to stop game
"""
function window_events(game_state=nothing)
    event_ref = Ref{SDL_Event}()
    while Bool(SDL_PollEvent(event_ref))
        evt = event_ref[]
        if evt.type == SDL_QUIT
            return false  # Signal to stop
        elseif evt.type == SDL_KEYDOWN
            if evt.key.keysym.scancode == SDL_SCANCODE_ESCAPE
                return false  # ESC key also stops
            end
        end
    end
    return true  # Continue
end

"""
Render game state to SDL window.
"""
function display(game_state, current_game)
    # 1. Clear the screen
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)  # Black background
    SDL_RenderClear(renderer)
    
    # 2. Draw game objects using shared drawing function
    if game_state !== nothing
        draw_game(game_state, (x, y, color) -> begin
            # Convert to SDL drawing call
            r, g, b, a = color
            SDL_SetRenderDrawColor(renderer, r, g, b, a)
            pixel_rect = SDL_Rect(x-1, y-1, 1, 1)  # Convert 1-based to 0-based coordinates
            SDL_RenderFillRect(renderer, Ref(pixel_rect))
        end, current_game)
    end
    
    # 3. Present the frame
    SDL_RenderPresent(renderer)
end

"""
Render game state as RGB image array.
"""
function render(game_state, current_game=1)
    # Initialize empty game field with black background
    pixels = fill(RGB(0.0, 0.0, 0.0), GAME_HEIGHT, GAME_WIDTH)
    
    # Use shared drawing function with pixel array callback
    draw_game(game_state, (x, y, color) -> begin
        if x >= 1 && x <= GAME_WIDTH && y >= 1 && y <= GAME_HEIGHT
            # Convert RGBA color to RGB
            r, g, b, a = color
            pixels[y, x] = RGB(r/255.0, g/255.0, b/255.0)
        end
    end, current_game)
    
    return pixels
end
