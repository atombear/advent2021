FNAME = "input.txt"

opening = "([{<"
closing = ")]}>"

scores = Dict(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)

function problem0() :: Int64

    ret = 0
    for line in eachline(FNAME)
        stack :: Array{Char} = []
        for (idx, c) in enumerate(line)
            if idx == 1 && occursin(c, closing)
                ret += scores[c]
                break
            elseif occursin(c, opening)
                push!(stack, c)
            else
                c_idx = findfirst(x -> x == c, closing)
                o = opening[c_idx]
                if length(stack) > 0 && stack[end] == o
                    pop!(stack)
                else
                    ret += scores[c]
                    break
                end
            end
        end
    end

    return ret
end


function problem1() :: Int64

    ret = 0
    auto_scores :: Array{Int64} = []
    for line in eachline(FNAME)
        stack :: Array{Char} = []
        broken :: Bool = false
        for (idx, c) in enumerate(line)
            if idx == 1 && occursin(c, closing)
                ret += scores[c]
                broken = true
                break
            elseif occursin(c, opening)
                push!(stack, c)
            else
                c_idx = findfirst(x -> x == c, closing)
                o = opening[c_idx]
                if length(stack) > 0 && stack[end] == o
                    pop!(stack)
                else
                    ret += scores[c]
                    broken = true
                    break
                end
            end
        end
        if ! broken
            score :: Int64 = 0
            for o in reverse(stack)
                o_idx = findfirst(x -> x == o, opening)
                score *= 5
                score += o_idx
            end
            push!(auto_scores, score)
        end
    end
    sort!(auto_scores)
    middle = div(length(auto_scores), 2) + 1
    return auto_scores[middle]
end

println(problem0())
println(problem1())