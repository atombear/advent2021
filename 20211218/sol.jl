# 1st : 1
# 2nd : 2-3     (nested in 0)
# 3rd : 4-7
# 4th : 8-15
# 5th : 16-31
# 6th : 32-63   (nested in 4)

FNAME = "input.txt"
TEST_FNAME = "test_input.txt"

const TREE_t = Vector{Int64}
const LEAFS_t = Array{Tuple{Int64, Int64}}
const EXTRA_STRING_t = Union{String, SubString}

# I have several representations of the tree-numbers used in the problem
# this takes a string of brackets and numbers and creates an array to
# represent the tree. the string is parsed and the tree is traversed and
# leaves are deposited as necessary. since the tree is sparse, a dict
# would suffice. an enhancement.
function build_arr_tree(s :: EXTRA_STRING_t) :: TREE_t

    ret :: TREE_t = -1 * ones(Int64, 63)

    # the starting position - tree root
    position :: Int64 = 1

    for c in s
        # traverse down to the left
        if c == '['
            position = (2 * position)
        # go to the parent node
        elseif c == ']'
            position = div(position, 2)
        # go down to the right
        elseif c == ','
            position = (2 * position + 1)
        # deposit a leaf value and return to the parent.
        else
            ret[position] = parse(Int64, c)
            position = div(position, 2)
        end
    end

    return ret
end


function test0()
    for line in eachline(FNAME)
        println(build_arr_tree(strip(line)))
    end
end
#test0()

# a pair of utility functions for taking the indices of one
# tree and finding the associated indices of the tree 'slid'
# to the right or left. could be memoized as an enhancement.
function slide_idx_factory(base_idx :: Int64) :: Function
    function slide_idx(idx :: Int64) :: Int64
        if idx == 1
            return base_idx
        else
            if idx % 2 == 0
                return 2 * slide_idx(div(idx, 2))
            else
                return 2 * slide_idx(div(idx, 2)) + 1
            end
        end
    end
    return slide_idx
end

slide_idx_right = slide_idx_factory(3)
slide_idx_left = slide_idx_factory(2)


# add two trees by creating a common root and placing the first to the left
# and the second to the right.
function add(n0 :: TREE_t, n1 :: TREE_t) :: TREE_t
    ret :: TREE_t = -1 * ones(Int64, 63)

    for (idx, v) in enumerate(n0)
        if v > -1
            ret[slide_idx_left(idx)] = v
        end
    end
    for (idx, v) in enumerate(n1)
        if v > -1
            ret[slide_idx_right(idx)] = v
        end
    end
    return ret
end

# convenience dispatch
function add(n0 :: TREE_t, s1 :: EXTRA_STRING_t) :: TREE_t
    return add(n0, build_arr_tree(s1))
end
function add(s0 :: EXTRA_STRING_t, n1 :: TREE_t) :: TREE_t
    return add(build_arr_tree(s0), n1)
end
function add(s0 :: EXTRA_STRING_t, s1 :: EXTRA_STRING_t) :: TREE_t
    return add(build_arr_tree(s0), build_arr_tree(s1))
end

function test1()
    vs = ("[1,1]", "[2,2]", "[3,3]", "[4,4]")
    

    v12 = add(vs[1], vs[2])
    v13 = add(v12, vs[3])
    v14 = add(v13, vs[4])

    println(v14)
end
#test1()


# get the magnitude of a snail number.
function get_magnitude(num :: TREE_t, idx :: Int64=1) :: Int64
    if num[idx] > -1
        return num[idx]
    else
        return 3 * get_magnitude(num, 2*idx) + 2 * get_magnitude(num, 2*idx+1)
    end
end

function test2()
    ss= ("[[1,2],[[3,4],5]]",
         "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]",
         "[[[[1,1],[2,2]],[3,3]],[4,4]]",
         "[[[[3,0],[5,3]],[4,4]],[5,5]]",
         "[[[[5,0],[7,4]],[5,5]],[6,6]]",
         "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")
    for s in ss
        println(get_magnitude(build_arr_tree(s)))
    end
end
#test2()


# in order to have a LR ordering of tree leafs, derive
# from each node location a string representation eg "LRL"
function get_tree_pos_from_idx(idx :: Int64) :: String
    pos :: Vector{Char} = []
    while idx > 1
        if idx % 2 == 1
            push!(pos, 'r')
        else
            push!(pos, 'l')
        end
        idx = div(idx, 2)
    end
    return reverse(join(pos))
end


# Determine if a collection of leafs needs to explode.
# Return the location of the node in question. return 0 otherwise.
function needs_explode(leafs :: LEAFS_t) :: Int64
    for (idx, (ndx, _)) in enumerate(leafs)
        if ndx > 31
            return idx
        end
    end
    return 0
end

# Determine if a collection of leafs needs to split.
# Return the location of the node in question. return 0 otherwise.
function needs_split(leafs :: LEAFS_t) :: Int64
    for (idx, (_, val)) in enumerate(leafs)
        if val >= 10
            return idx
        end
    end
    return 0
end


# In place explosion given an idx corresponding to a leaf.
function perform_explode!(idx :: Int64, leafs :: LEAFS_t, num :: TREE_t)
    jdx = idx + 1
    ndx0, val0 = leafs[idx]
    ndx1, val1 = leafs[jdx]

    # try to add to the left and to the right
    if idx != 1
        ndxL, _ = leafs[idx - 1]
        num[ndxL] += val0
    end
    if jdx != length(leafs)
        ndxR, _ = leafs[jdx+1]
        num[ndxR] += val1
    end

    # remove the leafs
    num[ndx0] = -1
    num[ndx1] = -1

    # set the parent to 0
    parent = div(ndx0, 2)
    num[parent] = 0
end

# in place split on an leaf indexed by idx.
function perform_split!(idx :: Int64, leafs :: LEAFS_t, num :: TREE_t)
    ndx, val = leafs[idx]
    num[ndx] = -1

    # do the split depending on whether the value is even or odd.
    num[2 * ndx] = div(val, 2)
    num[2 * ndx + 1] = div(val, 2) + (val % 2)
end


# get the leafs from a tree, ordered left to right.
function get_leafs(num :: TREE_t) :: LEAFS_t
    return sort([(idx, val) for (idx, val) in enumerate(num) if val > -1], by=x -> get_tree_pos_from_idx(x[1]))
end


# reduce a tree
function reduce_tree!(num :: TREE_t) :: LEAFS_t
    leafs = get_leafs(num)

    # explode as much as possible, then try to split, then repeat
    while needs_explode(leafs) > 0 || needs_split(leafs) > 0
        while needs_explode(leafs) > 0
            alt_idx = needs_explode(leafs)
            perform_explode!(alt_idx, leafs, num)
            leafs = get_leafs(num)
        end

        if needs_split(leafs) > 0
            alt_idx = needs_split(leafs)
            perform_split!(alt_idx, leafs, num)
            leafs = get_leafs(num)
        end
    end
    return leafs
end
function reduce_tree!(num :: String) :: LEAFS_t
    reduce_tree!(build_arr_tree(num))
end


function problem0(fname)
    val :: TREE_t = []
    leafs :: LEAFS_t = []
    for (idx, line) in enumerate(eachline(fname))
        if idx == 1
            val = build_arr_tree(strip(line))
        else
            val = add(val, strip(line))
            leafs = reduce_tree!(val)
        end
    end
    return get_magnitude(val)
end


function problem1(fname)
    val :: TREE_t = []
    leafs :: LEAFS_t = []
    snail_numbers = readlines(fname)
    max_num = 0
    for s0 in snail_numbers
        for s1 in snail_numbers
            n = add(strip(s0), strip(s1))
            reduce_tree!(n)
            max_num = max(max_num, get_magnitude(n))
        end
    end
    return max_num
end

println(problem0(FNAME))
println(problem1(FNAME))
