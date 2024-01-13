# https://thebookofshaders.com/11/
# https://godotshaders.com/snippet/2d-noise/
# https://www.ronja-tutorials.com/post/029-tiling-noise/#tileable-noise
module Noise
  # compute the fractional part of x
  def self.fract x
    x - x.floor
  end

  # dot product of two vectors
  def self.dot a,b
    return a.x * b.x + a.y * b.y
  end

  # pseudorandom 2d value for a coordinate
  def self.random_2d uv
    # experiment with the numbers for different random results
    x = dot(uv, vec2(127.1, 311.7))
    y = dot(uv, vec2(269.5, 183.3))
    return vec2(
      -1.0 + 2.0 * fract(x.sin * 43758.5453123),
      -1.0 + 2.0 * fract(y.sin * 43758.5453123)
    )
  end

  # perform Hermite interpolation between two values
  def self.smoothstep edge0, edge1, x
    t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
  end

  # linearly interpolate between two values
  def self.mix x, y, a
    return x * (1.0 - a) + y * a
  end

  # 2d modulo, always positive
  def self.modulo_2d dividend, divisor
    positive_dividend_x = dividend.x % divisor.x + divisor.x
    positive_dividend_y = dividend.y % divisor.y + divisor.y
    return vec2(
      positive_dividend_x % divisor.x,
      positive_dividend_y % divisor.y)
  end

  def Noise.noise_seamless x,y
    cell_amount = 4.0
    period      = vec2(8.0, 8.0)
    uv          = vec2(x * cell_amount, y * cell_amount)

    cells_min = vec2(uv.x.floor,  uv.y.floor)
    cells_max = vec2(uv.x.ceil,   uv.y.ceil)
    uv_fract  = vec2(fract(uv.x), fract(uv.y))

    cells_min = modulo_2d(cells_min, period)
    cells_max = modulo_2d(cells_max, period)

    blur_x = smoothstep(0.0, 1.0, uv_fract.x)
    blur_y = smoothstep(0.0, 1.0, uv_fract.y)

    dir_lower_left   = random_2d(vec2(cells_min.x, cells_min.y))
    dir_lower_right  = random_2d(vec2(cells_max.x, cells_min.y))
    dir_upper_left   = random_2d(vec2(cells_min.x, cells_max.y))
    dir_upper_right  = random_2d(vec2(cells_max.x, cells_max.y))

    a = mix(
      dot(dir_lower_left,  uv_fract),
      dot(dir_lower_right, vec2(uv_fract.x - 1.0, uv_fract.y)), blur_x)
    b = mix(
      dot(dir_upper_left,  vec2(uv_fract.x, uv_fract.y - 1.0)),
      dot(dir_upper_right, vec2(uv_fract.x - 1.0, uv_fract.y - 1.0)), blur_x)

    return mix(a, b, blur_y) + 0.5
  end

  def self.vec2 x,y
    {
      x: x,
      y: y
    }
  end

  # Fractal brownian motion (Clouds!)
  def Noise.fbm x, y, octaves: 8, amplitude: 0.5, frequency: 3.0
    Lacunarity = 2.0
    Gain       = 0.5

    value  = 0.0
    octave = 0
    while octave < octaves
      value += amplitude * noise_seamless(frequency * x, frequency * y)
      amplitude *= Gain
      frequency *= Lacunarity
      octave += 1
    end
    return value
  end
end
