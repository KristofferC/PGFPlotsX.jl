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
    @test repr_tex(@pgf { xmax = a + b, title = "42", justkey, theme... }) ==
        repr_tex(Options("xmax" => 3, "title" => "42", "justkey" => nothing,
                         @pgf { color="white" } => nothing))
    f(x...) = tuple(x...)
    y = @pgf f({ look, we, are = f(1, 2, 3), nesting = { stuff = 9 }})
    @test length(y) == 1
    @test repr_tex(y[1]) == repr_tex(Options("look" => nothing,
                                             "we" => nothing,
                                             "are" => (1, 2, 3),
                                             "nesting" => Options("stuff" => 9)))
end
