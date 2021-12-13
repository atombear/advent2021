using IterTools: product

FNAME = "input.txt"

function get_input() :: Matrix{Int64}
    buf :: Array{Array{Int64}} = []
    for line in eachline(FNAME)
        line_buf :: Array{Int64} = []
        for c in line
            push!(line_buf, parse(Int64, c))
        end
        push!(buf, line_buf)
    end
    rows = length(buf)
    cols = length(buf[1])
    ret = -1e6 .* ones(Int64, rows+2, cols+2)
    for (i, j) in product(1:rows, 1:cols)
        ret[i+1, j+1] = buf[i][j]
    end
    return ret
end

function problem0() :: Int64

    num_exploded :: Int64 = 0

    o_map :: Matrix{Int64} = get_input()
    rows, cols = size(o_map)

    for _ in 1:100
        to_explode :: Set{Tuple{Int64, Int64}} = Set()

        for (i, j) in product(2:rows-1, 2:cols-1)
            o_map[i, j] += 1

            if o_map[i, j] > 9
                push!(to_explode, (i, j))
            end
        end

        exploded :: Set{Tuple{Int64, Int64}} = Set()
        while length(to_explode) > 0
            exp :: Tuple{Int64, Int64} = pop!(to_explode)
            if !(exp in exploded)
                push!(exploded, exp)
                (i, j) = exp
                o_map[i, j] = 0
                num_exploded += 1
                for (di, dj) in ((0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0), (-1, 1))
                    i1 = i + di
                    j1 = j + dj
                    if !((i1, j1) in exploded)
                        o_map[i1, j1] += 1
                        if o_map[i1, j1] > 9
                            push!(to_explode, (i1, j1))
                        end
                    end
                end
            end
        end
    end
    return num_exploded
end


function problem1() :: Int64

    o_map :: Matrix{Int64} = get_input()
    rows, cols = size(o_map)
    synced :: Bool = false
    idx :: Int64 = 0
    while !synced
        to_explode :: Set{Tuple{Int64, Int64}} = Set()

        for (i, j) in product(2:rows-1, 2:cols-1)
            o_map[i, j] += 1

            if o_map[i, j] > 9
                push!(to_explode, (i, j))
            end
        end

        exploded :: Set{Tuple{Int64, Int64}} = Set()
        while length(to_explode) > 0
            exp :: Tuple{Int64, Int64} = pop!(to_explode)
            if !(exp in exploded)
                push!(exploded, exp)
                (i, j) = exp
                o_map[i, j] = 0
                for (di, dj) in ((0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0), (-1, 1))
                    i1 = i + di
                    j1 = j + dj
                    if !((i1, j1) in exploded)
                        o_map[i1, j1] += 1
                        if o_map[i1, j1] > 9
                            push!(to_explode, (i1, j1))
                        end
                    end
                end
            end
        end
        synced = sum(o_map[2:end-1, 2:end-1]) == 0
        idx += 1
    end
    return idx
end


println(problem0())
println(problem1())