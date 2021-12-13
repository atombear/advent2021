INPUT = "start-A,start-b,A-c,A-b,b-d,A-end,b-end"
INPUT = "dc-end,HN-start,start-kj,dc-start,dc-HN,LN-dc,HN-end,kj-sa,kj-HN,kj-dc"
INPUT = "fs-end,he-DX,fs-he,start-DX,pj-DX,end-zg,zg-sl,zg-pj,pj-he,RW-he,fs-DX,pj-RW,zg-RW,start-pj,he-WI,zg-he,pj-fs,start-RW"
INPUT = "he-JK,wy-KY,pc-XC,vt-wy,LJ-vt,wy-end,wy-JK,end-LJ,start-he,JK-end,pc-wy,LJ-pc,at-pc,xf-XC,XC-he,pc-JK,vt-XC,at-he,pc-he,start-at,start-XC,at-LJ,vt-JK"

function get_input() :: Dict{String, Set{String}}
    ret :: Dict{String, Set{String}} = Dict()

    for (node0, node1) in map(x -> split(x, '-'), split(INPUT, ','))
        for (x, y) in ((node0, node1), (node1, node0))
            if !(x in keys(ret))
                ret[x] = Set()
            end
            push!(ret[x], y)
        end
    end
    return ret
end


function visit_once(node::String, path::Array{String}) :: Bool
    return !(node in path && lowercase(node) == node)
end

function visit_twice(node::String, path::Array{String}) :: Bool
    if node == "start"
        return false
    end

    allchars = filter(x -> lowercase(x) == x, path[2:end])

    if length(allchars) - length(Set(allchars)) in (0, 1)
        return true
    else
        return false
    end
end

function step_path(graph::Dict{String, Set{String}}, path::Array{String}, step_check::Function) :: Array{Array{String}}
    ret :: Array{Array{String}} = []
    for next_node in filter(x -> step_check(x, path),
                            graph[path[end]])
        new_path :: Array{String} = copy(path)
        push!(new_path, next_node)
        push!(ret, new_path)
    end
    return ret
end


function problem0(step_check::Function) :: Int64
    graph :: Dict{String, Set{String}} = get_input()

    paths :: Array{Array{String}} = [["start"]]
    complete :: Array{Array{String}} = []

    while length(paths) > 0
        new_paths :: Array{Array{String}} = []
        for p in paths
            append!(new_paths, step_path(graph, p, step_check))
        end
        paths = []
        for p in new_paths
            if p[end] == "end"
                push!(complete, p)
            else
                push!(paths, p)
            end
        end
    end

    return length(complete)
end


println(problem0(visit_once))
println(problem0(visit_twice))