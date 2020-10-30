"""
    fresnel2(Uin, d, λ, lx, ly)

calculate the propagation light field based on the Fresnel diffraction with double Fourier transform.

## Parameters

- `Uin::AbstractArray{<:Number,2}`: Complex array of input complex amplitude.
- `d::Real`: Distance to propagate in metres.
- `λ::Real`: Wavelength of light to propagate.
- `lx::Real`: The physical size of the input data along the x-axis.
- `ly::Real`: The physical size of the input data along the y-axis.

## Returns

- `::Array{<:Number,2}`: Complex amplitude data after propagation.
"""
function fresnel2(Uin::AbstractArray{<:Number,2}, d::Real, λ::Real, lx::Real, ly::Real)
    tf = (u, v) -> exp(2im*pi*d/λ)*exp(-im*pi*d/λ*(u^2+v^2))
    (n, m) = size(Uin)
    (u, v) = (-n/2+1:n/2,-m/2+1:m/2)./(lx,ly).*λ
    ifft(fft(Uin).*fftshift(tf.(u',v)))
end

"""
    fresnel1(Uin, d, λ, lx, ly)

calculate the propagation light field based on the Fresnel diffraction with single Fourier transform.

## Parameters

- `Uin::AbstractArray{<:Number,2}`: Complex array of input complex amplitude.
- `d::Real`: Distance to propagate in metres.
- `λ::Real`: Wavelength of light to propagate.
- `lx::Real`: The physical size of the input data along the x-axis.
- `ly::Real`: The physical size of the input data along the y-axis.

## Returns:

    (Uout, (lxo, lyo))

- `Uout::Array{<:Number,2}`: Complex amplitude data after propagation.
- `lxo::Real`: The physical size of the diffraction data along the x-axis.
- `lyo::Real`: The physical size of the diffraction data along the y-axis.
"""
function fresnel1(Uin::AbstractArray{<:Number,2}, d::Real, λ::Real, lx::Real, ly::Real)
    qp = (x, y) -> exp(im*pi/d/λ*(x^2+y^2))
    (n, m) = size(Uin)
    (dx, dy) = (lx, ly)./(n, m)
    (lxo, lyo) = λ*d./(dx, dy)
    (u, v) = (-n/2+1:n/2,-m/2+1:m/2)./(lx,ly).*λ
    amp = fft(Uin.*qp.(u', v))
    (uo, vo) = (-n/2+1:n/2,-m/2+1:m/2)./(lxo,lyo).*λ
    Uout = amp.*qp.(u', v).*exp(2im*pi*d/λ).*dx.*dy./(im*λ*d)
    (Uout, (lxo, lyo))
end
