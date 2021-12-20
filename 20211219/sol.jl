FNAME = "input.txt"
TEST_FNAME = "test_input.txt"

const ident = [1 0 0;
               0 1 0;
               0 0 1]

const Z90 = [ 0 1 0;
             -1 0 0;
              0 0 1]

const Z180 = Z90 * Z90
const Z270 = Z90 * Z90 * Z90

const X90 = [1  0 0;
             0  0 1;
             0 -1 0]
const X180 = X90 * X90
const X270 = X90 * X90 * X90

const Y90 = [0 0 1
             0 1 0
            -1 0 0]
const Y270 = Y90 * Y90 * Y90

function get_transformations() :: Vector{Matrix{Int64}}
    transformations :: Vector{Matrix{Int64}} = []
    for z in [ident, Z90, Z180, Z270]
        for rot in [ident, X90, X180, X270, Y90, Y270]
            push!(transformations, z * rot)
        end
    end
    return transformations
end

const SCANNER_DATA_t = Vector{Vector{Int64}}

function get_input(fname :: String) :: Vector{SCANNER_DATA_t}
    ret :: Vector{SCANNER_DATA_t}= []

    new_scanner :: SCANNER_DATA_t = []
    for line in eachline(fname)
        if occursin("---", line)
            if length(new_scanner) > 0
                push!(ret, copy(new_scanner))
            end
            new_scanner = []
        elseif length(strip(line)) > 0
            push!(new_scanner, [parse(Int64, n) for n in split(line, ',')])
        end
    end

    if length(new_scanner) > 0
        push!(ret, copy(new_scanner))
    end

    return ret
end

function compare_scanners(s1, s2)

    s1_arr = []
    s1_v0v1 = Dict()
    for v0 in s1
        for v1 in s1
            if v0 == v1
                continue
            end
            push!(s1_arr, v0-v1)
            s1_v0v1[(v0-v1)] = (v0, v1)
        end
    end

    s2_arr = []
    s2_v0v1 = Dict()
    for v0 in s2
        for v1 in s2
            if v0 == v1
                continue
            end
            push!(s2_arr, v0 - v1)
            s2_v0v1[(v0 - v1)] = (v0, v1)
        end
    end

    s1_set = Set(s1_arr)
    for (t_idx, t) in enumerate(get_transformations())
        s2_set = Set([t * i for i in s2_arr])
        if length(intersect(s1_set, s2_set)) > 100
            s2_arr_rot = [t * i for i in s2_arr]
            for s in s1_arr
                if s in s2_arr_rot
                    p1, _ = s1_v0v1[s]
                    p2, _ = Tuple(t*i for i in s2_v0v1[inv(t) * s])
                    return t_idx, p1 - p2
                end
            end
        end
    end
end

function problem0(fname)
    scanner_data = get_input(fname)
    num_scans = length(scanner_data)

    all_points = [(1, scanner_data[1])]
    all_locs = [[0,0,0]]

    while length(all_points) < num_scans
        oriented = [i[1] for i in all_points]
        disoriented = [i for i in 1:num_scans if !(i in oriented)]

        println(oriented)
        println(disoriented)
        all_points_copy = deepcopy(all_points)
        for (_, s1) in all_points_copy

            for jdx in disoriented
                try
                    s2 = scanner_data[jdx]

                    t_idx, dr = compare_scanners(s1, s2)
                    T = get_transformations()[t_idx]
                    trans_s2 = [T * i + dr for i in s2]
                    if !(jdx in [i[1] for i in all_points])
                        push!(all_points, (jdx, trans_s2))
                        push!(all_locs, dr)
                    end
                catch
                end
            end
        end
    end
    ret_set = Set()
    for list_points in [i[2] for i in all_points]
        for p in list_points
            push!(ret_set, p)
        end
    end
    println(sort([i[1] for i in all_points]))
    max_dist = 0
    for r0 in all_locs
        for r1 in all_locs
            max_dist = max(max_dist, sum(abs.(r0-r1)))
        end
    end
    length(ret_set), max_dist
end

println(problem0(FNAME))