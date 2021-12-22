# for 3 3sided die, throwing them will yield any number between 3 and 9,
# with the following multiplicities
const COUNT_DICT = Dict(5 => 6,
                        4 => 3,
                        6 => 7,
                        7 => 6,
                        9 => 1,
                        8 => 3,
                        3 => 1)

const MAX_SCORE = 21

struct Player
    pos :: Int64
    score :: Int64
end

function get_next(s :: Int64)
    if s == 100
        return 1
    else
        return s + 1
    end
end

function advance_player(p :: Player, seed :: Int64)
    n = 0
    pos = p.pos
    score = p.score
    for _ in 1:3
        seed = get_next(seed)
        pos += seed
    end
    score = p.score + ((pos - 1) % 10) + 1

    return Player(pos, score), seed
end

function problem0(pos0, pos1)

    p0 = Player(pos0, 0)
    p1 = Player(pos1, 0)

    seed = 0
    rolls = 0
    while true
        p0, seed = advance_player(p0, seed)
        rolls += 3
        if p0.score >= 1000
            break
        end
        p1, seed = advance_player(p1, seed)
        rolls += 3
        if p1.score >= 1000
            break
        end
    end
    return rolls * p1.score
end

problem0(4, 8) |> println

problem0(7, 4) |> println

function get_num_wins(p0, p1, cache=nothing)
    if cache === nothing
        cache = Dict()
    end

    key = (p0, p1)
    if !(key in keys(cache))
        num_wins = 0
        for (roll0, redundancy0) in COUNT_DICT
            new_pos0 = p0.pos + roll0
            new_score0 = p0.score + ((new_pos0 - 1) % 10) + 1
            new_p0 = Player(new_pos0, new_score0)
            @assert new_p0.pos >= 0
            if new_p0.score >= MAX_SCORE
                num_wins += redundancy0
                continue
            end

            for (roll1, redundancy1) in COUNT_DICT
                new_pos1 = p1.pos + roll1
                new_score1 = p1.score + ((new_pos1 - 1) % 10) + 1
                new_p1 = Player(new_pos1, new_score1)
                @assert new_p1.pos >= 0
                if new_p1.score >= MAX_SCORE
                    continue
                end

                num_wins += redundancy1 * redundancy0 * get_num_wins(new_p0, new_p1, cache)
            end
        end
        cache[key] = num_wins
    end
    return cache[key]
end

function second_player_wins(p0, p1)
    num_wins = 0
    for (roll0, redundancy0) in COUNT_DICT
        new_pos0 = p0.pos + roll0
        new_score0 = p0.score + ((new_pos0 - 1) % 10) + 1
        new_p0 = Player(new_pos0, new_score0)
        @assert new_pos0 >= 0
        if new_score0 >= MAX_SCORE
            continue
        end

        num_wins += redundancy0 * get_num_wins(p1, new_p0)
    end
    num_wins
end


p0 = Player(4, 0)
p1 = Player(8, 0)
println(get_num_wins(p0, p1))
println(second_player_wins(p0, p1))

p0 = Player(7, 0)
p1 = Player(4, 0)
println(get_num_wins(p0, p1))
println(second_player_wins(p0, p1))
