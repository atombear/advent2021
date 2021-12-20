FNAME = "input.txt"
TEST_FNAME = "test_input.txt"

const STRING_t = Union{String, SubString}


function ascii_to_bin(a :: STRING_t) :: String
    return a |> x -> replace(x, '.' => '0') |> x -> replace(x, '#' => '1')
end


function get_input(fname)
    img :: Vector{String} = []
    code_lines :: Vector{String} = []    

    getting_code :: Bool = true
    for line in eachline(fname)
        if !('.' in line || '#' in line)
            getting_code = false
        elseif getting_code
            push!(code_lines, strip(line))
        else
            bin_line = ascii_to_bin(strip(line))
            push!(img, strip(bin_line))
        end
    end
    img_mat :: Matrix{Char} = Matrix{Char}(undef, length(img), length(img[1]))
    for (idx, r) in enumerate(img)
        for (jdx, c) in enumerate(r)
            img_mat[idx, jdx] = c
        end
    end
    return ascii_to_bin(join(code_lines)), img_mat
end


function embed_img(img :: Matrix{Char}, surrounding :: Char='0') :: Matrix{Char}
    rows, cols = size(img)
    ret :: Matrix{Char} = [surrounding for _ in 1:(rows+2), _ in 1:(cols+2)]

    for idx in 1:rows
        for jdx in 1:cols
            ret[idx+1, jdx+1] = img[idx, jdx]
        end
    end
    return ret
end


function step_img(img :: Matrix{Char}, code :: String) :: Matrix{Char}
    rows, cols = size(img)

    ret = copy(img)

    update_word :: Vector{Char} = []
    for idx in 2:rows-1
        for jdx in 2:cols-1
            for i in (idx-1):(idx+1)
                for j in (jdx-1:jdx+1)
                    push!(update_word, img[i, j])
                end
            end
            num :: Int64 = sum((c == '1' ? 1 : 0) * (2 ^ (n-1)) for (n, c) in enumerate(reverse(update_word)))
            ret[idx, jdx] = code[num+1]
            update_word = []
        end
    end
    return ret
end


function update_edges!(img :: Matrix{Char}, c :: Char)
    rows, cols = size(img)
    for idx in 1:cols
        img[1, idx] = c
        img[end, idx] = c
    end
    for idx in 1:rows
        img[idx, 1] = c
        img[idx, end] = c
    end
end

function test0()
    code, base_img = get_input(TEST_FNAME)
    img = embed_img(embed_img(embed_img(embed_img(base_img))))
    img = step_img(img, code)
    img = step_img(img, code)
    return length(findall(x -> x == '1', img))
end

function test1()
    code, base_img = get_input(TEST_FNAME)
    img = embed_img(embed_img(base_img))
    for _ in 1:50
        img = step_img(img, code)
        img = embed_img(embed_img(img))
    end
    return length(findall(x -> x == '1', img))
end


function problem0(fname, iters)
    code, base_img = get_input(fname)

    img = embed_img(embed_img(embed_img(embed_img(base_img))))

    for _ in 1:iters
        img = step_img(img, code)
        update_edges!(img, code[1])
        img = step_img(img, code)
        if code[1] == '1'
            update_edges!(img, code[end])
        end
        img = embed_img(embed_img(embed_img(embed_img(img))))
    end

    return length(findall(x -> x == '1', img))
end


test0() |> println
problem0(TEST_FNAME, 1) |> println
problem0(FNAME, 1) |> println

test1() |> println
problem0(TEST_FNAME, 25) |> println
problem0(FNAME, 25) |> println
