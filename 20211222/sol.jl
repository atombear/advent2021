# This wasn't  hard once i figured it out. i had some crazy ideas at first
# about trying to split a box into many boxes, then reducing over the smaller
# boxes reconstituting them as necessary.

const TEST_INPUT = ["on x=10..12,y=10..12,z=10..12",
                    "on x=11..13,y=11..13,z=11..13",
                    "off x=9..11,y=9..11,z=9..11",
                    "on x=10..10,y=10..10,z=10..10"]


const RANGE_t = Tuple{Int64, Int64}


# parse a line of input into an instruction 0/1 and a range, which is an array
# of (min, max) tuples for each of x, y, z
function process_cmd(cmd :: String) :: Tuple{Int64, Vector{RANGE_t}}
    on_off, indices_str = split(cmd, ' ')
    indices :: Vector{RANGE_t} = []
    for (xyz, index) in zip("xyz", split(indices_str, ','))
        xyz_str, limits = split(index, '=')
        @assert xyz_str == string(xyz)
        min_limit, max_limit = split(limits, "..")
        push!(indices, (parse(Int64, min_limit), parse(Int64, max_limit)))
    end
    return (on_off == "on" ? 1 : 0), indices
end


function test0()
    cube = zeros(Int64, 101, 101, 101)
    for cmd_str in TEST_INPUT
        val, ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = process_cmd(cmd_str)
        cube[xmin:xmax, ymin:ymax, zmin:zmax] .= val
    end
    return sum(cube)
end

@assert test0() == 39


# offset the ranges and just fill in the cube.
function problem0(fname)
    cube = zeros(Int64, 101, 101, 101)
    for line in eachline(fname)
        val, ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = line |> strip |> string |> process_cmd
        xmin += 51
        xmax += 51
        ymin += 51
        ymax += 51
        zmin += 51
        zmax += 51
        try
            cube[xmin:xmax, ymin:ymax, zmin:zmax] .= val
        catch
        end
    end
    return sum(cube)
end


# determine if two one dimensional ranges overlap
function compare_ranges(xmin0::Int64, xmax0::Int64, xmin1::Int64, xmax1::Int64) :: Bool
    return ((xmin0 <= xmin1 <= xmax0) || (xmin1 <= xmin0 <= xmax1))
end


@assert compare_ranges(0, 1, 0, 1) === true
@assert compare_ranges(0, 10, 2, 5) === true
@assert compare_ranges(2, 5, 0, 10) === true
@assert compare_ranges(0, 5, 4, 8) === true
@assert compare_ranges(4, 8, 0, 5) === true
@assert compare_ranges(0, 1, 2, 5) === false
@assert compare_ranges(2, 5, 0, 1) === false

# check overlap across all 3 axes
function is_overlapping(xmin0::Int64, xmax0::Int64, ymin0::Int64, ymax0::Int64, zmin0::Int64, zmax0::Int64,
                        xmin1::Int64, xmax1::Int64, ymin1::Int64, ymax1::Int64, zmin1::Int64, zmax1::Int64) :: Bool
    return (compare_ranges(xmin0, xmax0, xmin1, xmax1) &&
           compare_ranges(ymin0, ymax0, ymin1, ymax1) &&
           compare_ranges(zmin0, zmax0, zmin1, zmax1))
end


# get the overlapping range given two overlapping ranges.
function get_overlap_1d(xmin0::Int64, xmax0::Int64, xmin1::Int64, xmax1::Int64) :: RANGE_t
    xmin = max(xmin0, xmin1)
    xmax = min(xmax0, xmax1)
    return xmin, xmax
end

@assert get_overlap_1d(0, 1, 0, 1) == (0, 1)
@assert get_overlap_1d(0, 10, 5, 10) == (5, 10)
@assert get_overlap_1d(5, 10, 0, 10) == (5, 10)
@assert get_overlap_1d(5, 9, 0, 10) == (5, 9)
@assert get_overlap_1d(0, 10, 5, 9) == (5, 9)
@assert get_overlap_1d(0, 10, 5, 15) == (5, 10)
@assert get_overlap_1d(-5, 5, 0, 10) == (0, 5)


# get the ovelapping region across all three axes
function get_overlap(xmin0::Int64, xmax0::Int64, ymin0::Int64, ymax0::Int64, zmin0::Int64, zmax0::Int64,
                     xmin1::Int64, xmax1::Int64, ymin1::Int64, ymax1::Int64, zmin1::Int64, zmax1::Int64) :: NTuple{6, Int64}
    ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = (get_overlap_1d(xmin0, xmax0, xmin1, xmax1),
                                                  get_overlap_1d(ymin0, ymax0, ymin1, ymax1),
                                                  get_overlap_1d(zmin0, zmax0, zmin1, zmax1))
    return (xmin, xmax, ymin, ymax, zmin, zmax)
end

@assert get_overlap(0, 4, 0, 4, 0, 0,
                    0, 4, 0, 4, 0, 0) == (0, 4, 0, 4, 0, 0)  



@assert is_overlapping(0, 4, 0, 4, 0, 0,
                       5, 10, 0, 4, 0, 0) === false

# we solve the problem by finding regions of overlap, and including them
# as shadow shapes to avoid double counting.
function problem1(fname) :: Int64
    # all the shapes.
    shapes :: Vector{Tuple{Int64, NTuple{6, Int64}}} = []
    for line in eachline(fname)
        # process the input
        val, ((xmin0, xmax0), (ymin0, ymax0), (zmin0, zmax0))  = line |> strip |> string |> process_cmd

        # the shape is additive, it will be included in its own right
        new_shapes :: Vector{Tuple{Int64, NTuple{6, Int64}}} = []
        if val == 1
            new_shapes = [(1, (xmin0, xmax0, ymin0, ymax0, zmin0, zmax0))]
        else
            new_shapes = []
        end

        # loop over existing shapes
        for (sub, this_shape) in shapes
            (xmin1, xmax1, ymin1, ymax1, zmin1, zmax1) = this_shape
            if is_overlapping(xmin0, xmax0, ymin0, ymax0, zmin0, zmax0,
                              xmin1, xmax1, ymin1, ymax1, zmin1, zmax1)
                overlap = get_overlap(xmin0, xmax0, ymin0, ymax0, zmin0, zmax0,
                                      xmin1, xmax1, ymin1, ymax1, zmin1, zmax1)
                # this is the only trick - if the comparative shape is additive, then
                # common space must be subtracted to avoid double counting. if the comparative
                # shape is subtractive, common space must be added to account for what is being subtracted.
                push!(new_shapes, (-1 * sub, overlap))
            end
        end
        for thing in new_shapes
            push!(shapes, thing)
        end
    end
    ret :: Int64 = 0
    for (sgn, (xmin, xmax, ymin, ymax, zmin, zmax)) in shapes
        ret += sgn * (1+xmax-xmin) * (1+ymax - ymin) * (1+zmax - zmin)
    end
    ret
end

problem0("test_input.txt") |> println
problem0("input.txt") |> println
problem0("moar_test_input.txt") |> println

problem1("moar_test_input.txt") |> println
problem1("input.txt") |> println