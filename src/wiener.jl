one_over_sqrt2 = 1/sqrt(2)
@inline wiener_randn() = randn()
@inline wiener_randn(x...) = randn(x...)
@inline wiener_randn!(x...) = randn!(x...)
@inline wiener_randn{T<:Number}(::Type{Complex{T}}) = one_over_sqrt2*(randn(T)+im*randn(T))
@inline wiener_randn{T<:Number}(::Type{Complex{T}},x...) = one_over_sqrt2*(randn(T,x...)+im*randn(T,x...))
@inline wiener_randn{T<:Number}(y::AbstractRNG,::Type{Complex{T}},x...) = one_over_sqrt2*(randn(y,T,x...)+im*randn(y,T,x...))
@inline wiener_randn{T<:Number}(y::AbstractRNG,::Type{Complex{T}}) = one_over_sqrt2*(randn(y,T)+im*randn(y,T))
@inline function wiener_randn!{T<:Number}(y::AbstractRNG,x::AbstractArray{Complex{T}})
  for i in eachindex(x)
    x[i] = one_over_sqrt2*(randn(y,T)+im*randn(y,T))
  end
end
@inline function wiener_randn!{T<:Number}(x::AbstractArray{Complex{T}})
  for i in eachindex(x)
    x[i] = one_over_sqrt2*(randn(T)+im*randn(T))
  end
end

function WHITE_NOISE_DIST(W,dt,rng)
  if typeof(W.dW) <: AbstractArray
    return sqrt(abs(dt))*wiener_randn(rng,size(W.dW))
  else
    return sqrt(abs(dt))*wiener_randn(rng,typeof(W.dW))
  end
end
function WHITE_NOISE_BRIDGE(W,W0,Wh,q,h,rng)
  if typeof(W.dW) <: AbstractArray
    return sqrt((1-q)*q*abs(h))*wiener_randn(rng,size(W.dW))+q*Wh
  else
    return sqrt((1-q)*q*abs(h))*wiener_randn(rng,typeof(W.dW))+q*Wh
  end
end
WienerProcess(t0,W0,Z0=nothing;kwargs...) = NoiseProcess{false}(t0,W0,Z0,WHITE_NOISE_DIST,WHITE_NOISE_BRIDGE;kwargs...)

function INPLACE_WHITE_NOISE_DIST(rand_vec,W,dt,rng)
  wiener_randn!(rng,rand_vec)
  for i in eachindex(rand_vec)
    rand_vec[i] *= sqrt(abs(dt))
  end
  #rand_vec .*= sqrt(abs(dt))
end
function INPLACE_WHITE_NOISE_BRIDGE(rand_vec,W,W0,Wh,q,h,rng)
  wiener_randn!(rng,rand_vec)
  #rand_vec .= sqrt((1.-q).*q.*abs(h)).*rand_vec.+q.*Wh
  for i in eachindex(rand_vec)
    rand_vec[i] = sqrt((1.-q)*q*abs(h))*rand_vec[i]+q*Wh[i]
  end
end
WienerProcess!(t0,W0,Z0=nothing;kwargs...) = NoiseProcess{true}(t0,W0,Z0,INPLACE_WHITE_NOISE_DIST,INPLACE_WHITE_NOISE_BRIDGE;kwargs...)



#### Real Valued Wiener Process. Ignores complex and the like
function REAL_WHITE_NOISE_DIST(W,dt,rng)
  if typeof(W.dW) <: AbstractArray
    return sqrt(abs(dt))*randn(rng,size(W.dW))
  else
    return sqrt(abs(dt))*randn(rng)
  end
end
function REAL_WHITE_NOISE_BRIDGE(W,W0,Wh,q,h,rng)
  if typeof(W.dW) <: AbstractArray
    return sqrt((1-q)*q*abs(h))*randn(rng,size(W.dW))+q*Wh
  else
    return sqrt((1-q)*q*abs(h))*randn(rng)+q*Wh
  end
end
RealWienerProcess(t0,W0,Z0=nothing;kwargs...) = NoiseProcess{false}(t0,W0,Z0,REAL_WHITE_NOISE_DIST,REAL_WHITE_NOISE_BRIDGE;kwargs...)

function REAL_INPLACE_WHITE_NOISE_DIST(rand_vec,W,dt,rng)
  sqabsdt = sqrt(abs(dt))
  for i in eachindex(rand_vec)
    rand_vec[i] = randn(rng)*sqabsdt
  end
  #rand_vec .*= sqrt(abs(dt))
end
function REAL_INPLACE_WHITE_NOISE_BRIDGE(rand_vec,W,W0,Wh,q,h,rng)
  for i in eachindex(rand_vec)
    rand_vec[i] = randn(rng)
  end
  #rand_vec .= sqrt((1.-q).*q.*abs(h)).*rand_vec.+q.*Wh
  for i in eachindex(rand_vec)
    rand_vec[i] = sqrt((1.-q)*q*abs(h))*rand_vec[i]+q*Wh[i]
  end
end
RealWienerProcess!(t0,W0,Z0=nothing;kwargs...) = NoiseProcess{true}(t0,W0,Z0,REAL_INPLACE_WHITE_NOISE_DIST,REAL_INPLACE_WHITE_NOISE_BRIDGE;kwargs...)
