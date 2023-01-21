module BitView

export bitview, BitViewArray

mutable struct BitViewArray{T, N} <: AbstractArray{T, N}
    subArray::SubArray
    dims::NTuple{N,Int}
    function BitViewArray{T, N}(a::Array{T, N}) where {T, N}
    	dims = (sizeof(T)*8, ones(Int, ndims(a)-1)...) .* size(a)
    	a = reinterpret(Base.uinttype(T), a)
    	ranges = size(a) .|> Base.Fix1(UnitRange, 1)
        b = new(view(a, ranges...), dims)
        return b
    end
    function BitViewArray{T, N}(a::Base.ReinterpretArray{T, N}) where {T, N}
    	dims = (sizeof(T)*8, ones(Int, ndims(a)-1)...) .* size(a)
    	a = reinterpret(Base.uinttype(T), a)
    	ranges = size(a) .|> Base.Fix1(UnitRange, 1)
        b = new(view(a, ranges...), dims)
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

function Base.getindex(b::BitViewArray{T, N}, I::Union{Colon, AbstractRange}) where {T, N}
	Base._getindex(IndexStyle(b.subArray), b, I)
end

function Base.setindex!(b::BitViewArray{T, N}, c::Bool, a::Int) where {T, N}
	(idx, subidx) = div(a - 1, 8*sizeof(T), RoundDown) + 1, mod(a - 1, 8*sizeof(T)) - 1
	b.subArray[idx] = (b.subArray[idx] & (UInt64(1) << subidx)) != 0
end


