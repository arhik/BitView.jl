using BitView
using Images
using TestImages

a = testimage("cameraman")

c = channelview(a)

d = reinterpret(UInt8, c)

b = bitview(a)
b = bitview(c)
b = bitview(d)

