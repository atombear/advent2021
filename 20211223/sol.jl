const SCORING = Dict('A' => 1, 'B' => 10, 'C' => 100, 'D' => 1000)
const ROOM_TO_AMPH = Dict(k => v for (k, v) in zip((1,2,3,4), "ABCD"))
const AMPH_TO_ROOM = Dict(v => k for (k, v) in ROOM_TO_AMPH)
const FINAL_STATE0 = [[c, c] for c in "ABCD"]
const FINAL_STATE1 = [[c, c, c, c] for c in "ABCD"]
const ROOM_TO_HALL = Dict(1 => 3, 2 => 5, 3 => 7, 4 => 9)
const HALL_TO_ROOM = Dict(v => k for (k,v) in ROOM_TO_HALL)

function get_test_starting0() :: Vector{Vector{Char}}
    return [['A', 'B'], ['D', 'C'], ['C', 'B'], ['A', 'D']]
end
function get_starting0() :: Vector{Vector{Char}}
    return [['C', 'B'], ['A', 'B'], ['A', 'D'], ['C', 'D']]
end
function get_test_starting1() :: Vector{Vector{Char}}
    return [['A', 'D', 'D', 'B'], ['D', 'B', 'C', 'C'], ['C', 'A', 'B', 'B'], ['A', 'C', 'A', 'D']]
end
function get_starting1() :: Vector{Vector{Char}}
    return [['C', 'D', 'D', 'B'], ['A', 'B', 'C', 'B'], ['A', 'A', 'B', 'D'], ['C', 'C', 'A', 'D']]
end


function find_locs(room_idx :: Int64, hallway :: Dict{Int64, Char}) :: Vector{Int64}
    room_loc = ROOM_TO_HALL[room_idx]
    ret :: Vector{Int64} = []
    for idx in room_loc-1:-1:1
        if idx in keys(hallway)
            break
        end
        push!(ret, idx)
    end
    for idx in room_loc+1:11
        if idx in keys(hallway)
            break
        end
        push!(ret, idx)
    end
    return ret
end

@assert find_locs(1, Dict{Int64, Char}()) == [2, 1, 4, 5, 6, 7, 8, 9, 10, 11]
@assert find_locs(1, Dict(1 => 'A')) == [2,4,5,6,7,8,9,10,11]


function is_path_home(loc :: Int64,
                      room_loc :: Int64, 
                      hallway :: Dict{Int64, Char}) :: Bool
    for idx in (1+min(loc, room_loc)):(max(loc, room_loc)-1)
        if idx in keys(hallway)
            return false
        end
    end
    return true
end

@assert is_path_home(3, 4, Dict(5 => 'A')) == true
@assert is_path_home(3, 10, Dict(4 => 'A')) == false
    
function find_score(room_state :: Vector{Vector{Char}},
                    hallway :: Dict{Int64, Char},
                    final_state,
                    extra_depth=0,
                    cache=nothing) :: Int64

    if cache == nothing
        cache = Dict()
    end

    if room_state == final_state
        return 0
    end

    key = (deepcopy(room_state), copy(hallway))
    if !(key in keys(cache))

    scores :: Vector{Int64} = [1e6]

    new_room_state :: Vector{Vector{Char}} = []

    for (idx, room) in enumerate(room_state)

        # if room is empty or all amphs are home.
        if length(room) == 0 || all(amph == ROOM_TO_AMPH[idx] for amph in room)
            continue
        end

        # where can an element from room idx go in the hallway?
        locs = find_locs(idx, hallway)

        # try to move directly from one room to another.
        new_room_state = deepcopy(room_state)
        new_room = new_room_state[idx]
        amph = pop!(new_room)
        if (all(i == amph for i in room_state[AMPH_TO_ROOM[amph]])
            && ROOM_TO_HALL[AMPH_TO_ROOM[amph]] in locs)
            starting_hall = ROOM_TO_HALL[idx]            
            ending_hall = ROOM_TO_HALL[AMPH_TO_ROOM[amph]]
            distance_out = extra_depth + 3 - length(room_state[idx])
            distance_in = extra_depth + 2 - length(room_state[AMPH_TO_ROOM[amph]])
            distance_across = abs(starting_hall - ending_hall)
            new_score = SCORING[amph]*(distance_out + distance_in + distance_across)

            push!(new_room_state[AMPH_TO_ROOM[amph]], amph)
            final_score = new_score + find_score(new_room_state,
                                                 copy(hallway),
                                                 final_state,
                                                 extra_depth,
                                                 cache)
            push!(scores, final_score)
        end

        # try to move anywhere in the hall
        for l in locs
            if l in keys(HALL_TO_ROOM)
                continue
            end
            new_room_state = deepcopy(room_state)
            new_room = new_room_state[idx]
            amph = pop!(new_room)
            new_hallway = copy(hallway)
            new_hallway[l] = amph
            new_score = SCORING[amph]*((extra_depth + 2 - length(new_room)) + abs(l - ROOM_TO_HALL[idx]))
            final_score = new_score+find_score(new_room_state,
                                               new_hallway,
                                               final_state,
                                               extra_depth,
                                               cache)
            push!(scores, final_score)
        end
    end

    # try to move from the hallway into a room
    for (loc, amph) in hallway
        amph_idx = AMPH_TO_ROOM[amph]

        if any(i != amph for i in room_state[amph_idx])
            continue
        end

        if is_path_home(loc, ROOM_TO_HALL[amph_idx], hallway)
            new_room_state = deepcopy(room_state)
            new_room = new_room_state[amph_idx]
            new_score = SCORING[amph]*((extra_depth + 2 - length(new_room)) + abs(loc - ROOM_TO_HALL[amph_idx]))
            push!(new_room, amph)
            new_hallway = copy(hallway)
            delete!(new_hallway, loc)
            final_score = new_score + find_score(new_room_state,
                                                 new_hallway,
                                                 final_state,
                                                 extra_depth,
                                                 cache)
            push!(scores, final_score)
        end
    end
    cache[key] = minimum(scores)
    end
    return cache[key]
end


function test0()
    room_state :: Vector{Vector{Char}} = get_test_starting0()
    hallway :: Dict{Int64, Char} = Dict()
    find_score(room_state, hallway, FINAL_STATE0)
end

function problem0()
    room_state :: Vector{Vector{Char}} = get_starting0()
    hallway :: Dict{Int64, Char} = Dict()
    find_score(room_state, hallway, FINAL_STATE0)
end

function test1()
    room_state :: Vector{Vector{Char}} = get_test_starting1()
    hallway :: Dict{Int64, Char} = Dict()
    find_score(room_state, hallway, FINAL_STATE1, 2)
end

function problem1()
    room_state :: Vector{Vector{Char}} = get_starting1()
    hallway :: Dict{Int64, Char} = Dict()
    find_score(room_state, hallway, FINAL_STATE1, 2)
end


test0() |> println
problem0() |> println

test1() |> println
problem1() |> println
