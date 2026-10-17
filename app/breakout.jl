# Entry point for building a standalone executable with juliac, e.g.
#   juliac --output-exe breakout --bundle build --trim=unsafe-warn --experimental --project=. app/breakout.jl
using Breakout

# SDL2_jll pulls in old hand-written JLL wrappers (SBC_jll, SpeexDSP_jll, libasyncns_jll)
# whose __init__ calls these with untyped globals. Compile them in explicitly so the
# dynamic dispatch still finds them in the trimmed image.
Base.Experimental.entrypoint(joinpath, (String, String, String))
Base.Experimental.entrypoint(dirname, (String,))
Base.Experimental.entrypoint(Base.Libc.Libdl.dlopen, (String,))

function (@main)(ARGS)
    breakout(Breakout.keyboard_action)
    return 0
end
