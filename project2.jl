using LightGraphs
using DataFrames
using DataStructures
using Iterators

############################################################
# Function: write_Policy(dag::DiGraph, idx2names, filename)
#
# Description: 
############################################################
function write_Policy(dag::DiGraph, policy::Vector{Vector{Int64}})
    open(filename, "w") do io
        for edge in edges(dag)
            @printf(io, "%s, %s\n", idx2names[src(edge)], idx2names[dst(edge)])
        end
    end
end

############################################################
# Function: computePolicy
#
# Description:
############################################################
function computePolicy(infile::String, outfile::String)   
    data = readtable(inputfilename)
    i2names = getDict(data)
    N2 = Array{Int64}(kNumStates, kNumActions)
    N3 = Array{Int64}(kNumStates, kNumActions, kNumStates)
    P = Array{Int64}(kNumStates, kNumActions)
    T = Array{Float64}(kNumStates, kNumStates, kNumActions)

    computePmatrix(data, P)
    computeN2matrix(data, N2)
    computeN3matrix(data, N3)
    R = P./N2
    for sp = 1:kNumStates
    	T[sp,:,:] = N3[:,:,sp]./N2
    end
    
end

############################################################
# Function: estimateReward(data)
#
# Description: estimates the reward runction R(s,a)
############################################################
function estimateRewards(data::DataFrame, )


end

############################################################
# Function: estimateReward(data)
#
# Description: estimates the transition runction T(s'|s,a)
############################################################
function estimateTransitions(data::DataFrame)


end

############################################################
# Function: valueIteration(data)
#
# Description: Runs value iteration given R(s,a) and T(s'|s,a)
############################################################
function valueIteration(data::DataFrame)


end

############################################################
# Function: computeN2matrix(data)
#
# Description:
############################################################
function computeN2matrix(data::DataFrame, N2::Array{Int64})
	for s = 1:kNumStates, a = 1:kNumActions
		N2[s,a] = length(find((data[1] .== s) & (data[2] .== a)))
	end
end

############################################################
# Function: computeN3matrix(data)
#
# Description:
############################################################
function computeN3matrix(data::DataFrame, N3::Array{Int64})
	for s = 1:kNumStates, a = 1:kNumActions, sp = 1:kNumStates
		N3[s,a,sp] = length(find((data[1] .== s) & (data[2] .== a) & (data[4] .== sp)))
	end
end

############################################################
# Function: computePmatrix(data)
#
# Description:
############################################################
function computePmatrix(data::DataFrame, P::Array{Int64})
	for s = 1:kNumStates, a = 1:kNumActions
		indices = find((data[1] .== s) & (data[2] .== a))
		P[s,a] = sum(data[indices,3])
	end
end

############################################################
# Function: getDict(data)
#
# Description: 
############################################################
function getDict(data::DataFrame)
    Names = names(data)
    l = length(Names)
    keys = 1:l
    return Dict(keys[i]=>Names[i] for i = 1:l)
end


inputfilename = "small.csv"
outputfilename = "small.policy"
const kNumActions = 4
const kNumStates = 100
const kDiscountFactor = 0.95
computePolicy(inputfilename, outputfilename)
