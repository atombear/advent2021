const STATE_t = Dict{Char, Int64}


# Solving the problem as written, trying to parse
# each statement and track the registers each step.
const FUNCTION_MAP = Dict("add" => +,
                          "mul" => *,
                          "div" => div,
                          "mod" => %,
                          "eql" => (x,y) -> (x==y ? 1 : 0))

# After realizing that each stage is the same with 3
# different constants.
const CONSTANT_VALUES = [[1, 11, 6],
                         [1, 11, 14],
                         [1, 15, 13],
                         [26, -14, 1],
                         [1, 10, 6],
                         [26, 0, 13],
                         [26, -6, 6],
                         [1, 13, 3],
                         [26, -3, 8],
                         [1, 13, 14],
                         [1, 15, 4],
                         [26, -2, 7],
                         [26, -9, 15],
                         [26, -2, 1]]

function full_partial_search(z :: Int64,
                             idx :: Int64,
                             largest :: Bool,
                             rest_path :: Vector{Int64},
                             path :: Union{Nothing, Vector{Int64}}=nothing)
    if path === nothing
        path :: Vector{Int64} = []
    end
    if idx == 15
        if z == 0
            println(path)
            return true
        end
        return false
    end

    n1, n2, n5 = CONSTANT_VALUES[idx]

    max_idx = 14 - length(rest_path)
    if idx > max_idx
        w = rest_path[idx - max_idx]
        x0 = ((z % 26) + n2) == w ? 0 : 1
        z0 = div(z, n1) * (25 * x0 + 1) + (w + n5) * x0
        push!(path, w)
        solved = full_partial_search(z0, idx+1, largest, rest_path, path)
        pop!(path)
    else
        for w in (largest ? (9:-1:1) : (1:9))
            x0 = ((z % 26) + n2) == w ? 0 : 1
            z0 = div(z, n1) * (25 * x0 + 1) + (w + n5) * x0
            push!(path, w)
            solved = full_partial_search(z0, idx+1, largest, rest_path, path)
            pop!(path)
            if solved
                break
            end
        end
    end
    return solved
end

function test_partial()
rest_path :: Vector{Int64} = [9, 9, 4, 7, 9, 9, 9]
full_partial_search(0, 1, true, rest_path)

rest_path = [1, 1, 1, 1, 3, 6, 5]
full_partial_search(0, 1, false, rest_path)
end
test_partial()

function pruned_search(z::Int64,
                       idx::Int64=1,
                       path::Union{Nothing,Vector{Int64}}=nothing,
                       largest::Bool=false)
    if path===nothing
        path :: Vector{Int64} = []
    end

    # the solution is in here.
    if idx == 15
        if z == 0
            println(path)
            @assert false
        end
        return
    end

    # get the values for each stage.
    n1, n2, n5 = CONSTANT_VALUES[idx]

    # check if a w can be found that makes x -> 0.
    xs = [((z % 26) + n2) == w ? 0 : 1 for w in 1:9]

    # only iterate through ws that make x -> 0 if possible.
    if 0 in xs
        ws = [idx for (idx, val) in enumerate(xs) if val == 0]
    else
        ws = largest ? (9:-1:1) : (1:9)
    end

    # update rules and recursion
    for w in ws
        x0 = ((z % 26) + n2) == w ? 0 : 1
        z0 = div(z, n1) * (25 * x0 + 1) + (w + n5) * x0

        push!(path, w)
        pruned_search(z0, idx+1, path, largest)
        pop!(path)
    end
end
#pruned_search(0)

# the input function
function inp!(state :: STATE_t, key:: Char, value :: Int64)
    state[key] = value
end

# load instructions
function get_instructions(fname :: String) :: Vector{Vector{String}}
    ret :: Vector{Vector{String}} = []
    instructions :: Vector{String} = []
    for line in eachline(fname)
        if strip(line) == "inp w" && length(instructions) > 0
            push!(ret, instructions)
            instructions = []
        else
            if !occursin("inp", line)
                push!(instructions, strip(line))
            end
        end
    end
    push!(ret, instructions)
    ret
end

# run a set of instructions
function run_serial!(instruction_set :: Vector{String}, state :: Dict{Char, Int64})
    for line in instruction_set
        oper, key0, item = line |> strip |> (x -> split(x, ' ')) |> xyz -> (xyz[1], only(xyz[2]), xyz[3])
        try
            value = parse(Int64, item)
            state[key0] = FUNCTION_MAP[oper](state[key0], value)
        catch
            key1 = only(item)
            state[key0] = FUNCTION_MAP[oper](state[key0], state[key1])
        end
    end
end

# run a single instruction in the reduced way
function run_instruction!(state :: Dict{Char, Int64}, n1 :: Int64, n2 :: Int64, n5 :: Int64)
    w = state['w']
    x = state['x']
    y = state['y']
    z = state['z']

    # track every register to compare against the other methodology.
    state['x'] = x0 = ((z % 26) + n2) == w ? 0 : 1
    state['y'] = (w + n5) * x0
    state['z'] = div(z, n1) * (25 * x0 + 1) + (w + n5) * x0
end


# using both methodologies, perform a program associted with a 14 digit string.
function test0(start_str :: String)
    all_instructions = get_instructions("input.txt")
    state0 = Dict(k => 0 for k in "wxyz")
    state1 = copy(state0)
    for (a, c, ns) in zip(all_instructions, start_str, CONSTANT_VALUES)
        state0['w'] = parse(Int64, c)
        state1['w'] = parse(Int64, c)
        run_serial!(a, state0)
        run_instruction!(state1, ns[1], ns[2], ns[3])

        @assert state0 == state1
    end
    state0
end

println("here is the answer")
test0("51983999947999") |> println
test0("11211791111365") |> println
