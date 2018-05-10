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
    @test @pgf { xmax = a + b, title = "42", justkey, theme... } ==
        Options("xmax" => 3, "title" => "42", "justkey" => nothing,
                @pgf { color="white" } => nothing)
    f(x...) = tuple(x...)
    @test @pgf f({ look, we, are = f(1, 2, 3),
                       nesting = {
                           stuff = 9
                       }}) == (Options("look" => nothing,
                                       "we" => nothing,
                                       "are" => (1, 2, 3),
                                       "nesting" => Options("stuff" => 9)), )
end
