using Test
using Breakout
import CommonRLInterface as RL

@testset "BreakoutEnv Test" begin
    @test_nowarn begin
        env = BreakoutEnv()
        RL.reset!(env)

        while !RL.terminated(env)
            obs = RL.observe(env)
            action = rand(RL.valid_actions(env))
            reward = RL.act!(env, action)
        end
    end        
end
