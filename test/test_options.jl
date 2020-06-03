# test that the @pfg macro is expanded correctly

module TestModule
using PGFPlotsX: @pgf
testpgf() = @pgf { ymax = 1 }
end

@testset "pgf escape" begin
    # just testing that it is escaped and evaluated
    @test TestModule.testpgf() ≠ nothing
end

@testset "pgf tests" begin
    a = 1
    b = 2
    theme = @pgf {color = "white"}
    opt = @pgf { xmax = a + b, title = "42", justkey, theme... }
    @test opt["color"] == "white"
    @test repr_tex(opt) == repr_tex(Options("xmax" => 3, "title" => "42", "justkey" => nothing,
                                            "color" => "white"))
    f(x...) = tuple(x...)
    y = @pgf f({ look, we, are = f(1, 2, 3), nesting = { stuff = 9 }})
    @test length(y) == 1
    @test repr_tex(y[1]) == repr_tex(Options("look" => nothing,
                                             "we" => nothing,
                                             "are" => (1, 2, 3),
                                             "nesting" => Options("stuff" => 9)))
end

@testset "pgf empty" begin
    @test squashed_repr_tex(@pgf Plot({}, Table([], []))) ==
        "\\addplot[]\ntable[row sep={\\\\}]\n{\n\\\\\n}\n;" # note []
end

@testset "options push! and append!" begin
    opt1 = "color" => "red"
    opt2 = "dashed"
    @test @pgf(push!({}, opt1, opt2)::Options).dict == Dict([opt1, opt2 => nothing])
    @test @pgf(append!({}, [opt1, opt2])::Options).dict == Dict([opt1, opt2 => nothing])
end
