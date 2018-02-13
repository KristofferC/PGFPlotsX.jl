# test that the @pfg macro is expanded correctly

module TestModule
using PGFPlotsX: @pgf
testpgf() = @pgf { ymax = 1 }
end

@testset "pgf escape" begin
    # just testing that it is escaped and evaluated
    @test TestModule.testpgf() ≠ nothing
end


# test the @pgf macro

od(args...) =  pgf.Options(args...)

@testset "pgf tests" begin
    a = 1
    b = 2
    @test @pgf { xmax = a + b, title = "42", justkey } ==
        od("xmax" => 3, "title" => "42", "justkey" => nothing)
    f(x...) = tuple(x...)
    @test @pgf f({ look, we, are = f(1, 2, 3),
                       nesting = {
                           stuff = 9
                       }}) == (od("look" => nothing,
                                  "we" => nothing,
                                  "are" => (1, 2, 3),
                                  "nesting" => od("stuff" => 9)), )
end
