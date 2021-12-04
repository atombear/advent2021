fname = joinpath(pwd(), "input.txt")

function problem0()
    cnt = 0
    open(fname) do io
        current_val = parse(Int64, readline(io))
        while !eof(io)
            word = readline(io)
            num = parse(Int64, word)
            if num > current_val
                cnt += 1
            end
            current_val = num
        end
    end
    cnt
end


function problem1()
    cnt = 0
    
    open(fname) do io
        current_vals = Int64[parse(Int64, readline(io)) for _ in 1:3]
        cv = sum(current_vals)
        while !eof(io)
            num = parse(Int64, readline(io))
            popfirst!(current_vals)
            push!(current_vals, num)
            new_cv = sum(current_vals)
            if new_cv > cv
                cnt += 1
            end
            cv = new_cv
        end
    end
    cnt    
end


println(problem0())

println(problem1())