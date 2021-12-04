fname = joinpath(pwd(), "input.txt")

function forward_simple(xy :: Tuple{Int, Int}, val) :: Tuple{Int, Int}
    x, y = xy
    (x+val, y)
end

function up_simple(xy :: Tuple{Int, Int}, val) :: Tuple{Int, Int}
    x, y = xy
    (x, y-val)
end

function down_simple(xy :: Tuple{Int, Int}, val) :: Tuple{Int, Int}
    x, y = xy
    (x, y+val)
end

OPERATORS_SIMPLE = Dict("forward" => forward_simple, "up" => up_simple, "down" => down_simple)



function forward_comp(xy :: Tuple{Int, Int, Int}, val) :: Tuple{Int, Int, Int}
    x, y, aim = xy
    (x+val, y + (aim * val), aim)
end

function up_comp(xy :: Tuple{Int, Int, Int}, val) :: Tuple{Int, Int, Int}
    x, y, aim = xy
    (x, y, aim-val)
end

function down_comp(xy :: Tuple{Int, Int, Int}, val) :: Tuple{Int, Int, Int}
    x, y, aim = xy
    (x, y, aim+val)
end

OPERATORS_COMP = Dict("forward" => forward_comp, "up" => up_comp, "down" => down_comp)

function problem0() :: Int64
    pos = (0, 0)
    open(fname) do io
        while !eof(io)
            word = readline(io)
            direction_, value_ = split(word, ' ')
            direction = strip(direction_)
            value = parse(Int64, value_)
            pos = OPERATORS_SIMPLE[direction](pos, value)
        end
    end
    x, y = pos
    x * y
end


function problem1() :: Int64
    pos = (0, 0, 0)
    open(fname) do io
        while !eof(io)
            word = readline(io)
            direction_, value_ = split(word, ' ')
            direction = strip(direction_)
            value = parse(Int64, value_)
            pos = OPERATORS_COMP[direction](pos, value)
        end
    end
    x, y, _ = pos
    x * y
end


println(problem0())
println(problem1())
