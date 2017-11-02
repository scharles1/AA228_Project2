using LightGraphs
using DataFrames
using DataStructures
using Iterators

############################################################
# Function: write_Policy(dag::DiGraph, idx2names, filename)
#
# Description: 
############################################################
function write_Policy(policy::Array{Int64,1})
    open(outputfilename, "w") do io
        for s= 1:kNumStates
            @printf(io, "%d\n", policy[s])
        end
    end
end

############################################################
# Function: computePolicy
#
# Description:
############################################################
function computePolicy()   
    data = readtable(inputfilename)
    i2names = getDict(data)
    Pi = Array{Int64,1}(kNumStates)
    #QLearning(data, Pi)
    MaximumLikelihood(data, Pi)
    write_Policy(Pi)
end

############################################################
# Function: QLearning
#
# Description:
############################################################
function QLearning(data::DataFrame, Pi::Array{Int64,1})
	Q = zeros(kNumStates, kNumActions)
	
	for k = 1:kIterations
	for i = 1:length(data[1])
		s = data[i,1]
		a = data[i,2]
		r = data[i,3]
		sp = data[i,4]
		Q[s,a] = Q[s,a] + kLearnFactor*(r + kDiscountFactor*maximum(Q[sp,:]) - Q[s,a])
	end
	end

	for s = 1:kNumStates
        Pi[s] = indmax(Q[s,:])
    end
end

############################################################
# Function: MaximumLikelihood
#
# Description:
############################################################
function MaximumLikelihood(data::DataFrame, Pi::Array{Int64,1})
	Q = spzeros(kNumStates, kNumActions)
	N = spzeros(kNumStates, (kNumActions*kNumStates))
	Rho = spzeros(kNumStates, kNumActions)
	T = spzeros(kNumStates, (kNumActions*kNumStates))
	
	for k = 1:kIterations
	for i = 1:length(data[1])
		s = data[i,1]
		a = data[i,2]
		r = data[i,3]
		sp = data[i,4]
		s_a_index = ((s-1)*kNumActions + a)
		N[sp,s_a_index] = N[sp,s_a_index] + 1
		Rho[s,a] = Rho[s,a] + r
		n2 = sum(N[:,s_a_index])
		R = Rho[s,a]/n2
		T[sp, s_a_index] = N[sp,s_a_index]/n2
		Q[s,a] = R + kDiscountFactor*sum(T[:,s_a_index])*maximum(Q[sp,:])
	end
	end

	for s = 1:kNumStates
        Pi[s] = indmax(Q[s,:])
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

inputfilename = "large.csv"
outputfilename = "large.policy"
const kNumActions =  125 #7 #4   
const kNumStates = 10101010 #50000 #100
const kDiscountFactor = 0.95
const kLearnFactor = 0.5
const kIterations = 100
computePolicy()
