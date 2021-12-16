FNAME = "test_input.txt"
FNAME = "input.txt"

# EVERYTHING HAS TO BE RIGHT! FOR MAXIMUM SPEED!

const INT_PAIR_t = Tuple{Int64, Int64}
const NODE_DIST_t = Dict{INT_PAIR_t, Int64}


function get_input() :: Matrix{Int64}

    buf :: Array{Array{Int64}} = []
    for line in eachline(FNAME)
        push!(buf, [parse(Int64, i) for i in line])
    end
    rows = length(buf)
    cols = length(buf[1])
    
    return [buf[i][j] for i in 1:rows, j in 1:cols]
end


function in_bounds(rc :: INT_PAIR_t, rows::Int64, cols::Int64) :: Bool
    r, c = rc
    return (0 < r <= rows) && (0 < c <= cols)
end


function get_min_path(start_point :: INT_PAIR_t, end_point :: INT_PAIR_t, cave_map :: Matrix{Int64}) :: Int64
    rows :: Int64, cols :: Int64 = size(cave_map)
    distances :: NODE_DIST_t = Dict((i, j) => 1E6 for i in 1:rows, j in 1:rows)
    distances[start_point] = 0

    # Collect all the nodes as they are visited
    visited :: Set{INT_PAIR_t} = Set()

    # The current node
    node :: INT_PAIR_t = start_point

    # The nodes that CAN be visited next.
    possible_next :: NODE_DIST_t = Dict()

    while node != end_point
        # Visiting a node
        push!(visited, node)

        # The node cannot be used twice!
        if node in keys(possible_next)
            delete!(possible_next, node)
        end

        x :: Int64, y :: Int64 = node
        # Cycle through the connected nodes.
        for (dx :: Int64, dy :: Int64) in ((-1, 0), (1, 0), (0, -1), (0, 1))
            new_node :: INT_PAIR_t = (x+dx, y+dy)
            # if the new node is in bounds and has not been visited
            if in_bounds(new_node, rows, cols) && !(new_node in visited)   
                distances[new_node] = min(distances[node] + cave_map[new_node...],
                                          distances[new_node])
                possible_next[new_node] = distances[new_node]
            end
        end

        dist :: Int64 = minimum(values(possible_next))
        # Find the nearest next possible node.
        for (k :: INT_PAIR_t, v :: Int64) in possible_next
            if v == dist
                node = k
                dist = v
                break
            end
        end
    end
    return distances[end_point]
end

function problem0() :: Int64
    cave_map :: Matrix{Int64} = get_input()
    rows, cols = size(cave_map)

    start_point :: INT_PAIR_t = (1, 1)
    end_point :: INT_PAIR_t = (rows, cols)

    get_min_path(start_point, end_point, cave_map)
end


function add_one(cm :: Matrix{Int64}) :: Matrix{Int64}
    # A helper function to update the cave map by 1.

    rows, cols = size(cm)
    ret = copy(cm)
    for i in 1:rows
        for j in 1:cols
            ret[i, j] = max(1, (cm[i, j] + 1) % 10)
        end
    end
    return ret
end

function apply(f :: Function, arg :: NE, n :: Int64) :: NE where{NE}
    # compounded assignment
    ret = arg
    for _ in 1:n
        ret = f(ret)
    end
    return ret
end
        

function problem1() :: Int64
    cave_map_small :: Matrix{Int64} = get_input()
    rows_small, cols_small = size(cave_map_small)

    cave_map :: Matrix{Int64} = hcat((apply(add_one, cave_map_small, n) for n in 0:4)...)
    cave_map = vcat((apply(add_one, cave_map, n) for n in 0:4)...)

    rows, cols = size(cave_map)

    start_point = (1, 1)
    end_point = (rows, cols)

    get_min_path(start_point, end_point, cave_map)
end


println(problem0())
println(problem1())