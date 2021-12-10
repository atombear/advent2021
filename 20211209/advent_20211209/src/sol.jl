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
    ret = 10 .* ones(Int64, rows+2, cols+2)
    for (i, j) in product(1:rows, 1:cols)
        ret[i+1, j+1] = buf[i][j]
    end
    return ret
end

function problem0() :: Int64
    input :: Matrix{Int64} = get_input()
    rows, cols = size(input)
    ret :: Int64 = 0
    for (i, j) in product(2:rows-1, 2:cols-1)
        v = input[i, j]
        if all(v < input[i+i0, j+j0] for (i0, j0) in ((0, 1), (0, -1), (-1, 0), (1, 0)))
            ret += (v + 1)
        end
    end
    return ret
end


function find_basin!(fmap :: Matrix{Int64}, pos :: Tuple{Int64, Int64}, basin :: Vector{Tuple{Int64, Int64}})
    (i0, j0) = pos
    v0 = fmap[i0, j0]
    for (di, dj) in ((0, 1), (0, -1), (1, 0), (-1, 0))
        new_pos = (i0 + di, j0 + dj)
        (i1, j1) = new_pos
        v1 = fmap[i1, j1]
        if (!(new_pos in basin)) && (fmap[i1, j1] < 9) && (v0 < v1)
            push!(basin, new_pos)
            find_basin!(fmap, new_pos, basin)
        end
    end
end

function get_basin_size(fmap :: Matrix{Int64}, pos :: Tuple{Int64, Int64}) :: Int64
    basin :: Vector{Tuple{Int64, Int64}} = [pos]

    find_basin!(fmap, pos, basin)

    return length(basin)
end

function problem1() :: Int64
    input :: Matrix{Int64} = get_input()
    rows, cols = size(input)
    top_3 :: Vector{Int64} = zeros(3)
    for (i, j) in product(2:rows-1, 2:cols-1)
        v = input[i, j]
        if all(v < input[i+i0, j+j0] for (i0, j0) in ((0, 1), (0, -1), (-1, 0), (1, 0)))
            bsize = get_basin_size(input, (i, j))
            if bsize >= top_3[1]
                top_3[3] = top_3[2]
                top_3[2] = top_3[1]
                top_3[1] = bsize
            elseif bsize >= top_3[2]
                top_3[3] = top_3[2]
                top_3[2] = bsize
            elseif bsize >= top_3[1]
                top_3[1] = bsize
            end
        end
    end
    return prod(top_3)
end

println(problem0())
println(problem1())
