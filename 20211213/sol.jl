FNAME = "test_input.txt"
FNAME = "input.txt"

function get_input() :: Tuple{Set{Tuple{Int64, Int64}}, Array{String}}
    ret :: Set{Tuple{Int64, Int64}} = Set()

    text :: Array{String} = readlines(FNAME)

    while true
        t = popfirst!(text)
        if t == ""
            break
        end
        (num0, num1) = map(x -> parse(Int64, x), split(t, ','))
        push!(ret, (num0, num1))
    end

    return ret, text
end


function problem0() :: Int64

    points, instructions = get_input()

    for instr in instructions
        new_points :: Set{Tuple{Int64, Int64}} = Set()

        line = split(instr, "fold along ")[2]
        axis, value_str = split(line, '=')
        value = parse(Int64, value_str)

        for p in points
            x, y = p

            if 'y' in axis && y > value
                push!(new_points, (x, y - 2*(y-value)))
            elseif 'x' in axis && x > value
                push!(new_points, (x - 2*(x-value), y))
            else
                push!(new_points, (x, y))
            end
        end
        points = new_points
        return length(points)
    end
end

function problem1() :: Set{Tuple{Int64, Int64}}

    points, instructions = get_input()

    for instr in instructions
        new_points :: Set{Tuple{Int64, Int64}} = Set()

        line = split(instr, "fold along ")[2]
        axis, value_str = split(line, '=')
        value = parse(Int64, value_str)

        for p in points
            x, y = p

            if 'y' in axis && y > value
                push!(new_points, (x, y - 2*(y-value)))
            elseif 'x' in axis && x > value
                push!(new_points, (x - 2*(x-value), y))
            else
                push!(new_points, (x, y))
            end
        end
        points = new_points
    end
    return points
end

function draw_output()
    points = problem1()

    max_x = maximum(i[1] for i in points)
    max_y = maximum(i[2] for i in points)
    grid = zeros(Int64, max_x+1, max_y+1)
    for (x, y) in points
        grid[x+1, y+1] = 1
    end

    display(grid')
end

println(problem0())
draw_output()
