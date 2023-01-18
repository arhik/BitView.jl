module BitView

# Write your package code here.

export bitview


mutable struct BitViewArray{T, N} <: AbstractArray{T, N}
    chunks::SubArray
    dims::NTuple{N,Int}
    function BitViewArray{T, N}(a::Array{T, N}) where {T, N}
    	nbytes = sizeof(T).*size(a)
    	dims = 8 .* nbytes
    	nc = div.(nbytes, sizeof(UInt64))
    	a = reinterpret(UInt64, a)
        b = new(view(a, :), dims)
        return b
    end
end

bitview(a::Array{T, N}) where {T, N} = BitViewArray{T, N}(a)

Base.size(b::BitViewArray{T, N}) where {T, N} = b.dims
Base.size(b::BitViewArray{T, N}, a::Int) where {T, N} = getindex(b.dims, a)
Base.length(b::BitViewArray{T, N}) where {T, N} = sizeof(UInt64)*( b.dims |> prod )

function Base.getindex(b::BitViewArray{T, N}, a::Int) where {T, N}
	(idx, subidx) = div(a - 1, 8*sizeof(T), RoundDown) + 1, mod(a, 8*sizeof(T)) - 1
	return (b.chunks[idx] & (UInt64(1) << subidx)) != 0
end

function Base.setindex!(b::BitViewArray{T, N}, c::Bool, a::Int) where {T, N}
	(idx, subidx) = div(a - 1, 8*sizeof(T), RoundDown) + 1, mod(a - 1, 8*sizeof(T)) - 1
	b.chunks[idx] = (b.chunks[idx] & (UInt64(1) << subidx)) != 0
end


end
