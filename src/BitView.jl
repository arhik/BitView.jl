module BitView

export bitview, BitViewArray

using Revise
using Images

# utility function
Base.uinttype(::Type{T}) where T <: Unsigned = T
Base.uinttype(::Type{T}) where T <: Signed = T

# for images
Base.uinttype(::Type{Normed{UInt8, 0}}) = UInt8
Base.uinttype(::Type{N0f8}) = UInt8
Base.uinttype(::Type{Gray{N0f8}}) = UInt8

mutable struct BitViewArray{T, N} <: AbstractArray{T, N}
    subArray::SubArray
    function BitViewArray{T, N}(a::Array) where {T, N}
    	a = reinterpret(Base.uinttype(T), a)
    	ranges = size(a) .|> Base.Fix1(UnitRange, 1)
        b = new(view(a, ranges...))
        return b
    end
    function BitViewArray{T, N}(a::Base.ReinterpretArray) where {T, N}
    	a = reinterpret(Base.uinttype(T), a)
    	ranges = size(a) .|> Base.Fix1(UnitRange, 1)
        b = new(view(a, ranges...))
        return b
    end
end

bitview(a::Array{T}) where T = BitViewArray{T, ndims(a) + 1}(a)
bitview(a::Base.ReinterpretArray{T}) where T = BitViewArray{T, ndims(a) + 1}(a)
bitview(n::Number) = bitview([n,])

Base.size(b::BitViewArray{T, N}) where {T, N} = ((b.subArray |> size)..., sizeof(T)*8)
Base.size(b::BitViewArray{T, N}, a::Int) where {T, N} = getindex(size(b), a)
Base.length(b::BitViewArray{T, N}) where {T, N} = ( size(b) |> prod )

# function Base.getindex(b::BitViewArray{T, N}, I...) where {T, N}
	# stride = (sizeof(eltype(b))*8, ones(Int, ndims(b) - 1)...)
	# (idx, subidx) = div.(I .- 1, stride, RoundDown) .+ 1, mod(first(I), stride |> first) - 1
	# return (b.subArray[idx...] & ((Base.uinttype(eltype(b)) |> one) << subidx)) != 0
# end

function Base.getindex(b::BitViewArray{T, N}, I...) where {T, N}
	(idx, subidx) = I[1:end-1], last(I)
	return (b.subArray[idx...] & ((Base.uinttype(eltype(b)) |> one) << (subidx-1))) != 0
end

function Base.getindex(b::BitViewArray{T, N}, I::CartesianIndex) where {T, N}
	(idx, subidx) = I.I[1:end-1], last(I.I)
	return (b.subArray[idx...] & ((Base.uinttype(eltype(b)) |> one) << (subidx-1))) != 0
end

function Base.getindex(b::BitViewArray{T, N}, I::Union{Colon, AbstractRange}) where {T, N}
	Base._getindex(IndexStyle(b.subArray), b, I)
end

function Base.setindex!(b::BitViewArray{T, N}, c::Bool, I...) where {T, N}
	(idx, subidx) = I[1:end-1], last(I)
	b.subArray[idx...] = ifelse(
		c,
		(b.subArray[idx...] | ((Base.uinttype(eltype(b)) |> one) << (subidx-1))),
		(b.subArray[idx...] & ~((Base.uinttype(eltype(b)) |> one) << (subidx-1)))
	)
end

function Base.setindex!(b::BitViewArray{T, N}, c::Bool, I::CartesianIndex) where {T, N}
	(idx, subidx) = I.I[1:end-1], last(I.I)
	b.subArray[idx...] = ifelse(
		c,
		(b.subArray[idx...] | ((Base.uinttype(eltype(b)) |> one) << (subidx-1))),
		(b.subArray[idx...] & ~((Base.uinttype(eltype(b)) |> one) << (subidx-1)))
	)
end

end
