FNAME = "test_input.txt"
FNAME = "input.txt"

function get_input() :: Tuple{Array{Char}, Dict{Char, Dict{Char, Char}}}
    starting :: Array{Char} = []

    update_map :: Dict{Char, Dict{Char, Char}} = Dict()

    idx = 0
    for line in eachline(FNAME)
        if idx == 0
            starting = [i for i in strip(line)]
        elseif idx == 1
        else
            fs, insert = split(strip(line), " -> ")

            first, second = fs
            if !(first in keys(update_map))
                update_map[first] = Dict()
            end
            if !(second in keys(update_map[first]))
                update_map[first][second] = only(insert)
            end
        end
        idx += 1
    end
    return starting, update_map
end

function problem0(steps :: Int64) :: Int64
    starting, update_map = get_input()

    state :: Array{Char} = copy(starting)


    for STEP in 1:steps
        new_state :: Array{Char} = []
        push!(new_state, state[1])
        for idx in 2:length(state)
            f :: Char = state[idx-1]
            s :: Char = state[idx]
            push!(new_state, update_map[f][s])
            push!(new_state, s)
        end
        state = new_state
    end
    count :: Dict{Char, Int64} = Dict()
    for c in state
        if !(c in keys(count))
            count[c] = 0
        end
        count[c] += 1
    end

    min_val = 1E6
    max_val = 0
    for (k, v) in count
        min_val = min(min_val, v)
        max_val = max(max_val, v)
    end

    return max_val - min_val
end

CACHE_t = Dict{Tuple{Char, Char, Int64}, Dict{Char, Int64}}

function get_num(pair :: Tuple{Char, Char},
                 update_map :: Dict{Char, Dict{Char, Char}},
                 steps :: Int64,
                 cache :: Union{Nothing, CACHE_t}=nothing) :: Dict{Char, Int64}
    if cache === nothing
        cache :: CACHE_t = Dict()
    end
    key :: Tuple{Char, Char, Int64} = (pair[1], pair[2], steps)

    if !(key in keys(cache))
        ret :: Dict{Char, Int64} = Dict(k => 0 for k in keys(update_map))
        if steps == 0
            ret[pair[1]] += 1
            ret[pair[2]] += 1
            return ret
        end

        middle :: Char = update_map[pair[1]][pair[2]]
        for (k,v) in get_num((pair[1], middle), update_map, steps-1, cache)
            ret[k] += v
        end
        for (k,v) in get_num((middle, pair[2]), update_map, steps-1, cache)
            ret[k] += v
        end
        ret[middle] -= 1

        cache[key] = copy(ret)
    end
    return cache[key]
end    


function problem1(steps :: Int64) :: Int64
    starting, update_map = get_input()
    total :: Dict{Char, Int64} = Dict(k => 0 for k in keys(update_map))
    for idx in 2:length(starting)
        f = starting[idx-1]
        s = starting[idx]
        for (k, v) in get_num((f, s), update_map, steps)
            total[k] += v
        end
        total[s] -= 1
    end
    total[starting[end]] += 1
    return maximum(values(total)) - minimum(values(total))
end


println(problem0(10))
println(problem1(40))