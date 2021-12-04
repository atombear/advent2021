fname = joinpath(pwd(), "input.txt")

if occursin("test", fname)
    LEN_CMD = 5
else
    LEN_CMD = 12
end

function problem0() :: Int64
    vals :: Vector{Int64} = zeros(Int64, LEN_CMD)
    cnt :: Int64 = 0
    open(fname) do io
        while !eof(io)
            word = readline(io)
            for (idx, c) in enumerate(word)
                if c == '1'
                    vals[idx] += 1
                end
                @assert c in ('1', '0')
            end
            cnt += 1
        end
    end
    half_cnt :: Int64 = div(cnt, 2)

    γ :: Int64 = 0
    ε :: Int64 = 0
    for (idx, v) in enumerate(reverse(vals))
        if v > half_cnt
            γ += 2 ^ (idx - 1)
        else
            ε += 2 ^ (idx - 1)
        end
    end
    γ * ε
end


function get_by_max_or_min(arr :: Vector{String}; idx::Int64=1, max_::Bool=true) :: Vector{String}
    if idx > 1
        @assert arr[1][idx-1] == arr[end][idx-1]
    end
    if (length(arr[1])+1 == idx) || (length(arr) == 1)
        return arr
    end

    med :: Int64 = div(length(arr), 2) + (length(arr) % 2 == 1 ? 1 : 0)

    start_idx :: Int64 = 0
    end_idx :: Int64 = 0
    if (length(arr) % 2 == 0 && arr[med][idx] == '0' && arr[med+1][idx] == '1')
        if max_
            start_idx = med+1
            end_idx = length(arr)
        else
            start_idx = 1
            end_idx = med
        end        
    elseif (arr[med][idx] == '1')
        start_idx = med
        while (start_idx > 0) && (arr[start_idx][idx] == '1')
            start_idx -= 1
        end
        start_idx += 1
        end_idx = length(arr)
        if !max_ && start_idx > 1
            end_idx = start_idx - 1
            start_idx = 1
        end
    else
        start_idx = 1
        end_idx = med
        while (end_idx <= length(arr)) && (arr[end_idx][idx] == '0')
            end_idx += 1
        end
        end_idx -= 1

        if !max_ && end_idx < length(arr)
            start_idx = end_idx + 1
            end_idx = length(arr)
        end
    end

    return get_by_max_or_min(arr[start_idx:end_idx], idx=idx+1, max_=max_)
end

function bin_to_dec(bin::String) :: Int64
    sum((2 ^ (idx - 1)) * (i == '1' ? 1 : 0) for (idx, i) in enumerate(reverse(bin)))
end

function problem1() :: Int64
    output = sort(readlines(fname))
    val_max = get_by_max_or_min(output)[1]
    val_min = get_by_max_or_min(output, max_=false)[1]

    num_max = bin_to_dec(val_max)
    num_min = bin_to_dec(val_min)

    num_max * num_min
end

println(problem0())

println(problem1())
