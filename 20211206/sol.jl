STATE0 = [1,3,4,1,5,2,1,1,1,1,5,1,5,1,1,1,1,3,1,1,1,1,1,1,1,2,1,5,1,1,1,1,1,4,4,1,1,4,1,1,2,3,1,5,1,4,1,2,4,1,1,1,1,1,1,1,1,2,5,3,3,5,1,1,1,1,4,1,1,3,1,1,1,2,3,4,1,1,5,1,1,1,1,1,2,1,3,1,3,1,2,5,1,1,1,1,5,1,5,5,1,1,1,1,3,4,4,4,1,5,1,1,4,4,1,1,1,1,3,1,1,1,1,1,1,3,2,1,4,1,1,4,1,5,5,1,2,2,1,5,4,2,1,1,5,1,5,1,3,1,1,1,1,1,4,1,2,1,1,5,1,1,4,1,4,5,3,5,5,1,2,1,1,1,1,1,3,5,1,2,1,2,1,3,1,1,1,1,1,4,5,4,1,3,3,1,1,1,1,1,1,1,1,1,5,1,1,1,5,1,1,4,1,5,2,4,1,1,1,2,1,1,4,4,1,2,1,1,1,1,5,3,1,1,1,1,4,1,4,1,1,1,1,1,1,3,1,1,2,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,2,5,1,2,1,1,1,1,1,1,1,1,1]

# STATE0 = [3,4,3,1,2]

function update_state!(s::Vector{Int64})
    l = length(s)
    for i in 1:l
        if s[i] == 0
            push!(s, 8)
            s[i] = 6
        else
            s[i] -= 1
        end
    end
end

function update_state!(s::Dict{Int64, Int64})
    if s[0] > 0
        extra = s[0]
    else
        extra = 0
    end
    for i in 1:8
        s[i-1] = s[i]
    end
    s[6] += extra
    s[8] = extra
end

function problem0_slow()
    s = copy(STATE0)
    for _ in 1:10
        println(s)
        update_state!(s)
    end
end

function problem0(days::Int64) :: Int64
    s = Dict(i => 0 for i in 0:8)
    for i in STATE0
        s[i] += 1
    end

    for _ in 1:days
        update_state!(s)
    end
    return sum(values(s))
end

println(problem0(80))
println(problem0(256))
