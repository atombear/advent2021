import Base: sort

NUMBER_SEGMENTS = Dict(0 => "abcefg",
                       1 => "cf",
                       2 => "acdeg",
                       3 => "acdfg",
                       4 => "bdcf",
                       5 => "abdfg",
                       6 => "abdefg",
                       7 => "acf",
                       8 => "abcdefg",
                       9 => "abcdfg")
NUMBER_SEGMENT_LENGTHS = Dict(k => length(v) for (k, v) in NUMBER_SEGMENTS)

LENGTHS_COUNT = Dict(i => 0 for i in values(NUMBER_SEGMENT_LENGTHS))
for v in values(NUMBER_SEGMENT_LENGTHS)
    LENGTHS_COUNT[v] += 1
end

UNIQUE_LENGTHS_KV = filter(kv -> LENGTHS_COUNT[kv[2]] == 1, NUMBER_SEGMENT_LENGTHS)
UNIQUE_LENGTHS_VK = Dict(v => k for (k, v) in UNIQUE_LENGTHS_KV)

UNIQUE_LENGTHS = tuple(values(UNIQUE_LENGTHS_KV)...)

for u in UNIQUE_LENGTHS
    @assert LENGTHS_COUNT[u] == 1
end
@assert Set(UNIQUE_LENGTHS) == Set((2,3,4,7))

struct Reading
    record::NTuple{10, String}
    output::NTuple{4, String}
end

function sort(s::Union{SubString{String}, String}) :: String
    return join(sort([i for i in s]))
end

function get_input(test::Bool=false) :: Array{Reading}
    ret :: Array{Reading} = []
    if test
        fname = "test_input.txt"
    else
        fname = "input.txt"
    end
    for line in eachline(fname)
        record_string, output_string = split(line, '|')
        record = tuple(filter(i -> length(i) > 0, map(i -> sort(strip(i)), split(record_string, ' ')))...)
        output = tuple(filter(i -> length(i) > 0, map(i -> sort(strip(i)), split(output_string, ' ')))...)
        push!(ret, Reading(record, output))
    end
    ret
end

function problem0(test::Bool=false) :: Int64
    ret :: Int64 = 0
    for reading in get_input(test)
        ret += sum(length(i) in UNIQUE_LENGTHS ? 1 : 0 for i in reading.output)
    end
    ret
end

function num_from_list(int_arr::Array{Int64}) :: Int64
    return sum(v * (10 ^ (idx-1)) for (idx, v) in enumerate(reverse(int_arr)))
end
        

function problem1(test::Bool=false) :: Int64
    ret :: Int64 = 0
    for reading in get_input(test)
        dict :: Dict{Int, String} = Dict()
        for val in filter(x -> length(x) in UNIQUE_LENGTHS, reading.record)
            dict[UNIQUE_LENGTHS_VK[length(val)]] = val
        end

        for sixer in filter(x -> length(x) == 6, reading.record)
            # find 6
            if setdiff(Set(dict[1]), Set(sixer)) != Set()
                dict[6] = sixer
            end

            # find 9
            if setdiff(Set(dict[4]),  Set(sixer)) == Set()
                dict[9] = sixer
            end
        end
        @assert 6 in keys(dict)
        @assert 9 in keys(dict)

        for sixer in filter(x -> length(x) == 6 && !(x in values(dict)), reading.record)
            # find 0
            dict[0] = sixer
        end

        for fiver in filter(x -> length(x) == 5, reading.record)
            # find 3
            if setdiff(Set(dict[1]), Set(fiver)) == Set()
                dict[3] = fiver
            end
        end

        for fiver in filter(x -> length(x) == 5 && !(x in values(dict)), reading.record)
            # find 2, 5
            if setdiff(Set(fiver), Set(dict[9])) == Set()
                dict[5] = fiver
            else
                dict[2] = fiver
            end
        end
        @assert length(dict) == 10
        dict_vk = Dict(v => k for (k, v) in dict)
        ret += num_from_list([dict_vk[i] for i in reading.output])
    end
    ret
end


println(problem0())

println(problem1())