require 'app/noise.rb'

# Layered cloud demo using seamless noise generated into pixel arrays
# Composited on screen using render targets

# Size of the fractal texture
Size = 128

def rgba_to_hex r, g, b, a
  return [r,g,b,a].pack('C*').unpack('L').first
end

def make_fractal_texture args
  arr = args.pixel_array(:fractal)
  arr.width  = Size
  arr.height = Size
  arr.pixels.fill(0xFF00000, 0, Size * Size)

  r = 0
  arr.pixels.each_with_index do |p, i|
    x = i % Size
    y = i.idiv(Size)
    n = Noise::fbm(x.fdiv(Size),y.fdiv(Size),frequency:2.0,octaves:4) * 255
    arr.pixels[i] = rgba_to_hex(255,255,255,n)
  end
end

def tick args
  if not args.state.init_done
    args.state.init_done = true
    make_fractal_texture(args)
    args.state.layers_visible = 3
  end

  if args.inputs.keyboard.key_down.a
    args.state.init_done = false
  end

  args.outputs.background_color = [44,44,128,255] #blueish
  # Render target 1 (half screen size)
  layer1 = repeating_texture(args,
                              rt_name: :layer1,
                              x: 640,
                              y: 360,
                              w: 1280.idiv(2),
                              h: 720.idiv(2),
                              anchor_x: 0.5,
                              anchor_y: 0.5,
                              rate_x: -0.6,
                              rate_y: -0.35,
                              path: :fractal,
                              sprite_size: Size)
  # Render target 2 (eighth of screen size)
  layer2 = repeating_texture(args,
                              rt_name: :layer2,
                              x: 640,
                              y: 360,
                              w: 1280.idiv(8),
                              h: 720.idiv(8),
                              anchor_x: 0.5,
                              anchor_y: 0.5,
                              rate_x:   0.11,
                              rate_y:   0.12,
                              path: :fractal,
                              sprite_size: Size)

  # Render target 3 (eighth)
  layer3 = repeating_texture(args,
                              rt_name: :layer3,
                              x: 640,
                              y: 360,
                              w: 1280.idiv(8),
                              h: 720.idiv(8),
                              anchor_x: 0.5,
                              anchor_y: 0.5,
                              rate_x:   0.042,
                              rate_y:   0.053,
                              path: :fractal,
                              sprite_size: Size)

  # Composite to screen
  layer3.w = layer1.w = layer2.w = 1280
  layer3.h = layer1.h = layer2.h = 720
  layer1.blendmode_enum = 1 #alpha blending
  layer1.a = 30
  layer2.blendmode_enum = 2 #additive
  layer2.a = 200
  layer3.blendmode_enum = 1 #alpha
  layer3.r = 255
  layer3.g = 255
  layer3.b = 130
  layer3.a = 40

  args.outputs.sprites << layer1 if args.state.layers_visible > 0
  args.outputs.sprites << layer3 if args.state.layers_visible > 1
  args.outputs.sprites << layer2 if args.state.layers_visible > 2

  if args.inputs.mouse.click
    args.state.layers_visible = (args.state.layers_visible + 1) % 4
    #args.outputs.primitives << args.gtk.framerate_diagnostics_primitives
  end
  args.outputs.labels << { x: 10, y: 80, text: "Layers visible: #{args.state.layers_visible} | click to cycle visibility" }
end

def repeating_texture args, rt_name:, x:, y:, w:, h:, path:, sprite_size:, anchor_x: 0, anchor_y: 0, rate_x: 0.22, rate_y: 0.22
  # Scrolling progress
  at = args.state.tick_count

  # create a unique name for the repeating texture, if no target specified
  rt_name ||= "#{path.hash}-#{w}-#{h}"

  # create a render target to store the repeating texture
  args.outputs[rt_name].w = w
  args.outputs[rt_name].h = h
  args.outputs[rt_name].transient!

  # calculate the sprite box for the repeating texture
  #sprite_w, sprite_h = args.gtk.calcspritebox path
  sprite_h = sprite_w = sprite_size

  # calculate the number of rows and columns needed to fill the repeating texture
  # 2 extra tiles to wrap seamlessly
  rows = h.idiv(sprite_h) + 2
  cols = w.idiv(sprite_w) + 2

  # generate the repeating texture using a render target
  args.outputs[rt_name].sprites << rows.map do |r|
                                     cols.map do |c|
                                       xoffs = -sprite_h + at.*(rate_x) % sprite_h
                                       yoffs = -sprite_h + at.*(rate_y) % sprite_h
                                       {
                                         x: sprite_w * c + xoffs,
                                         y: h - sprite_h * (r) + yoffs,
                                         w: sprite_w,
                                         h: sprite_h,
                                         path: path
                                       }
                                     end
                                   end

  return {
    x: x,
    y: y,
    w: w,
    h: h,
    anchor_x: anchor_x,
    anchor_y: anchor_y,
    path: rt_name
  }
end
