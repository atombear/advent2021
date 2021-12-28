TEST_INPUT = "test_input.txt"
TEST_INPUT = "test_input_2.txt"

const POS_t = Tuple{Int64, Int64}

function get_adj(idx :: Int64, rows :: Int64)  :: Int64
    return (1 + idx % rows)
end


@assert get_adj(1, 7) == 2
@assert get_adj(7, 7) == 1
@assert get_adj(3, 7) == 4


function get_test_input(fname) :: Tuple{Int64, Int64, Set{POS_t}, Set{POS_t}}
    lines = readlines(fname)
    rows = length(lines)
    cols = length(lines[1])

    right :: Set{POS_t} = Set()
    down :: Set{POS_t} = Set()
    for idx in 1:rows
        for jdx in 1:cols
            c :: Char = lines[idx][jdx]
            if c == '>'
                push!(right, (idx, jdx))
            elseif c == 'v'
                push!(down, (idx, jdx))
            else
                @assert c == '.'
            end
        end
    end
    rows, cols, right, down
end

function display_snails(rows, cols, right, down)
    mat :: Vector{Vector{Char}} = []
    for idx in 1:rows
        row :: Vector{Char} = []
        for jdx in 1:cols
            if (idx, jdx) in right
                next_char = '>'
            elseif (idx, jdx) in down
                next_char = 'v'
            else
                next_char = '.'
            end
            push!(row, next_char)
        end
        push!(mat, row)
    end
    ret :: Vector{String} = [join(i) for i in mat]
    display(ret)
    println()
end

function get_right_moves(rows::Int64, cols::Int64, right::Set{POS_t}, down::Set{POS_t})::Vector{POS_t}
    ret :: Vector{POS_t} = []
    for r in right
        x, y = r
        if (!((x, get_adj(y, cols)) in right) &&
            !((x, get_adj(y, cols)) in down))
            push!(ret, r)
        end
    end
    return ret
end

function move_right!(rows::Int64, cols::Int64, right::Set{POS_t}, right_moves::Vector{POS_t})
    for r in right_moves
        delete!(right, r)
        x, y = r
        push!(right, (x, get_adj(y, cols)))
    end
end

function get_down_moves(rows::Int64, cols::Int64, right::Set{POS_t}, down::Set{POS_t})::Vector{POS_t}
    ret :: Vector{POS_t} = []
    for d in down
        x, y = d
        if (!((get_adj(x, rows), y) in right) &&
            !((get_adj(x, rows), y) in down))
            push!(ret, d)
        end
    end
    return ret
end

function move_down!(rows::Int64, cols::Int64, down::Set{POS_t}, down_moves::Vector{POS_t})
    for d in down_moves
        delete!(down, d)
        x, y = d
        push!(down, (get_adj(x, rows), y))
    end
end

function problem0(fname)::Int64
    rows::Int64, cols::Int64, right::Set{POS_t}, down::Set{POS_t} = get_test_input(fname)

    moving = true
    idx = 0
    while moving
        right_moves = get_right_moves(rows, cols, right, down)
        move_right!(rows, cols, right, right_moves)

        down_moves = get_down_moves(rows, cols, right, down)
        move_down!(rows, cols, down, down_moves)

        if (length(right_moves) > 0) || (length(down_moves) > 0)
            idx += 1
        else
            moving = false
        end

        #display_snails(rows, cols, right, down)
    end
    return idx + 1
end

problem0("test_input_2.txt") |> println
problem0("input.txt") |> println