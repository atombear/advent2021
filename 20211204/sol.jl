FNAME = joinpath(pwd(), "input.txt")

function board_wins(board::Matrix{Int64}, diag=false)::Bool
    rows::Int64, cols::Int64 = size(board)
    template :: Vector{Int64} = [-1 for _ in 1:rows]
    @assert rows == cols
    # hor/ver
    for i in 1:rows
        if board[i, :] == template || board[:, i] == template
            return true
        end
    end
    # diag
    if diag
    diag_1 :: Vector{Tuple{Int64, Int64}} = [(i, i) for i in 1:rows]
    diag_2 :: Vector{Tuple{Int64, Int64}} = [(i, rows-i+1) for i in 1:rows]
    diag_check = diag -> all(board[i, j] == -1 for (i, j) in diag)
    return diag_check(diag_1) || diag_check(diag_2)
    else
        return false
    end
end

for (idx, test_board) in enumerate(([1 2; 3 4],
                                    [-1 -1; 2 3],
                                    [1 2; -1 -1],
                                    [-1 2; -1 3],
                                    [1 -1; 2 -1],
                                    [1 -1; -1 4],
                                    [-1 2; 3 -1]))
    if idx == 1
        @assert board_wins(test_board, true) === false
    else
        @assert board_wins(test_board, true) === true
    end
end

function perform_moves(board::Matrix{Int64}, moves::Vector{Int64})::Tuple{Int64, Int64, Int64}
    val_in_board :: Union{Nothing, CartesianIndex} = nothing
    cnt :: Int64 = 0
    cnt_hits :: Int64 = 0
    for move::Int64 in moves
        cnt += 1
        val_in_board = indexin(move, board)[1]
        if ! (val_in_board === nothing)
            x, y = Tuple(val_in_board)
            board[x, y] = -1
            cnt_hits += 1
            if board_wins(board)
                return (cnt, sum(board) + cnt_hits, move)
            end
        end
    end
    return (0, 0, 0)
end

function process_board(buf::Vector{String}) :: Matrix{Int64}   
   rows :: Int64 = length(buf)
   cols :: Int64 = length(split(buf[1], ' '))
   ret :: Matrix{Int64} = zeros(Int64, 5, 5)
   for (idx, line) in enumerate(buf)
       for (jdx, num) in enumerate(map(s -> parse(Int64, s),
                                   filter(s -> length(s) > 0,
                                   split(line, ' '))))
           ret[idx, jdx] = num
       end
   end
   return ret
end

function load_data(fname::String) :: Tuple{Vector{Int64}, Vector{Matrix{Int64}}}
    cnt :: Int64 = 1
    moves :: Vector{Int64} = Int64[]
    board_buffer :: Vector{String} = String[]
    boards :: Vector{Matrix{Int64}} = Matrix{Int64}[]
    for line in eachline(fname)
        if cnt == 1
            moves = [parse(Int64, i) for i in split(line, ',')]
        else
            if line == "" && length(board_buffer) > 0
                push!(boards, process_board(board_buffer))
                board_buffer = String[]
            else
                if length(line) > 0
                    push!(board_buffer, line)
                end
            end
        end
        cnt += 1
    end
    moves, boards
end

function problem0() :: Int64
    moves, boards = load_data(FNAME)

    min_moves :: Int64 = 1000000
    best_score :: Int64 = 0
    for board in boards
        (num_moves, sum_unmarked, last_move) = perform_moves(board, moves)
        if num_moves < min_moves
            min_moves = num_moves
            best_score = sum_unmarked * last_move
        end
    end
    best_score
end


function problem1() :: Int64
    moves, boards = load_data(FNAME)

    max_moves :: Int64 = 0
    best_score :: Int64 = 0
    for board in boards
        (num_moves, sum_unmarked, last_move) = perform_moves(board, moves)
        if num_moves > max_moves
            max_moves = num_moves
            best_score = sum_unmarked * last_move
        end
    end
    best_score
end


println(problem0())
println(problem1())