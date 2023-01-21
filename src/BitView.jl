module BitView

# Write your package code here.
# 

export bitview, BitViewArray

mutable struct BitViewArray{T, N} <: AbstractArray{T, N}
    subArray::SubArray
    dims::NTuple{N,Int}
    function BitViewArray{T, N}(a::Array{T, N}) where {T, N}
    	nbytes = sizeof(T).*size(a)
    	dims = 8 .* nbytes
    	nc = div.(nbytes, sizeof(UInt64))
    	a = reinterpret(UInt64, a)
        b = new(view(a, :), dims)
        return b
    end
    function BitViewArray{T, N}(a::Base.ReinterpretArray{T, N}) where {T, N}
    	nbytes = sizeof(T).*size(a)
    	dims = 8 .* nbytes
    	nc = div.(nbytes, sizeof(UInt64))
    	a = reinterpret(UInt64, a)
        b = new(view(a, :), dims)
        return b
    end
end

bitview(a::Array{T, N}) where {T, N} = BitViewArray{T, N}(a)
bitview(a::Base.ReinterpretArray{T, N}) where {T, N} = BitViewArray{T, N}(a)

Base.size(b::BitViewArray{T, N}) where {T, N} = b.dims
Base.size(b::BitViewArray{T, N}, a::Int) where {T, N} = getindex(b.dims, a)
Base.length(b::BitViewArray{T, N}) where {T, N} = sizeof(UInt64)*( b.dims |> prod )

function Base.getindex(b::BitViewArray{T, N}, I...) where {T, N}
	(idx, subidx) = div.(I .- 1, 8 .* sizeof(T), RoundDown) .+ 1, mod.(I, 8 .* sizeof(T)) .- 1
	return (b.subArray[idx...] & (ones(UInt64, length(subidx)) .<< subidx)) != 0
end

# function Base.getindex(b::BitViewArray{T, N}, I::Union{Colon, AbstractRange}) where {T, N}
	# Base._getindex(IndexStyle(b.subArray), b, I)
# end
# 
function Base.setindex!(b::BitViewArray{T, N}, c::Bool, a::Int) where {T, N}
	(idx, subidx) = div(a - 1, 8*sizeof(T), RoundDown) + 1, mod(a - 1, 8*sizeof(T)) - 1
	b.subArray[idx] = (b.subArray[idx] & (UInt64(1) << subidx)) != 0
end

# function Base.setindex!(b::BitViewArray{T, N},)

IndexStyle(::Type{<:BitViewArray}) = IndexLinear()
IndexStyle(::BitViewArray) = IndexLinear()

# Base.isassigned(::BitViewArray) =

#function iterate

# similar 

# reshape

# copyto

# array 

# push!

# append!

# 

# Dummy Array

struct DummyArray{T} <: AbstractArray{T, 1}
	a::Array{T, 1}
end

function Base.getindex(a::DummyArray, I...)
	Base._getindex(IndexStyle(a.a), a.a, Base.to_indices(a.a, I)...)
end

Base.size(d::DummyArray) = Base.size(d.a)

a = DummyArray(rand(3))



