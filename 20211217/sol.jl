STATE_t = Tuple{Int64, Int64, Int64, Int64}
BOUNDS_t = STATE_t


function step_forward(state :: STATE_t) :: STATE_t
    x, y, vx, vy = state
    return (x+vx, y+vy, max(vx-1, 0), vy-1)
end

function integrate_forward(state :: STATE_t, bounds :: BOUNDS_t)

    xmin, xmax, ymin, ymax = bounds

    success = false

    _, y, _, _ = state
    max_y :: Int64 = y

    while true
        state = step_forward(state)
        x, y, vx, vy = state

        max_y = max(y, max_y)

        if (xmin <= x <= xmax) && (ymin <= y <= ymax)
            success = true
            break
        elseif (y < ymin) || (x > xmax) || ((x < xmin) && vx == 0) 
            success = false
            break
        end

    end
    return success, max_y, state
end


function test()
    s0 = (0, 0, 6, 9)
    b0 = (20,30,-10,-5)
    println(integrate_forward(s0, b0))
end

#test()

function problem0()
    x0, y0 = 0, 0
    b0 = (20, 30, -10, -5)
    b0 = (236, 262, -78, -58)

    all_max_y = 0
    total_success = 0

    for vx in 1:1000
        for vy in -1000:1000
            success, max_y, state = integrate_forward((x0, y0, vx, vy), b0)
            if success
                all_max_y = max(max_y, all_max_y)
                total_success += 1
            end
        end
    end
    all_max_y, total_success
end

println(problem0())