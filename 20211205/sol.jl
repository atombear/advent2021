FNAME = joinpath(pwd(), "input.txt")



function problem0() :: Int64
    lines :: Dict{Tuple{Int64, Int64}, Int64} = Dict()
    for line in eachline(FNAME)
        x0y0, x1y1 = split(line, "->")
        x0, y0 = (parse(Int64, i) for i in split(x0y0, ','))
        x1, y1 = (parse(Int64, i) for i in split(x1y1, ','))
        if x0 == x1
           ymax = max(y0, y1)
           ymin = min(y0, y1)
           for y in ymin:ymax
               xy = (x0, y)
               if ! (xy in keys(lines))
                   lines[xy] = 0
               end
               lines[xy] += 1
           end
        elseif y0 == y1
            xmax = max(x0, x1)
            xmin = min(x0, x1)
            for x in xmin:xmax
                xy = (x, y0)
                if ! (xy in keys(lines))
                    lines[xy] = 0
                end
                lines[xy] += 1
            end
        else
            if y0 < y1
                xmin, ymin, xmax, ymax = x0, y0, x1, y1
            else
                xmin, ymin, xmax, ymax = x1, y1, x0, y0
            end
            slope = (ymax - ymin) / (xmax - xmin)
            @assert abs(slope) == 1
            while ymin <= ymax
                xy = (xmin, ymin)
                if ! (xy in keys(lines))
                    lines[xy] = 0
                end
                lines[xy] += 1
                xmin += slope
                ymin += 1
            end
        end
    end
    sum(1 for i in values(lines) if i > 1)
end

println(problem0())
