# Generated tile art: each post's tile gets its own CSS gradient or pattern,
# picked from a seed (its URL), so it looks the same on every build and is
# drawn instantly (no images, no script).
#
#   <span class="tile-art" style="{{ post.url | tile_art: site.palette }}"></span>
#
# site.palette = { hue: 165, spread: 30 } → colours within hue ± spread.
# Gradients use freer colours; patterns pair two close colours that differ
# mostly in hue and only a little in lightness, so they stay soft.
require "zlib"

module Rigas
  module Tiles
    def tile_art(seed, palette)
      rng = Random.new(Zlib.crc32(seed.to_s))
      hue = (palette && palette["hue"] || 0).to_f
      spread = (palette && palette["spread"] || 30).to_f

      hsl = ->(h, s, l) { "hsl(#{(h % 360).round} #{s.clamp(0, 100).round}% #{l.clamp(0, 100).round}%)" }
      pick = lambda do |light: (45..70), sat: (60..95)|
        [hue + rng.rand(-spread..spread), rng.rand(sat), rng.rand(light)]
      end
      color = ->(**kw) { hsl.call(*pick.call(**kw)) }
      deep = -> { color.call(light: (18..30), sat: (40..70)) }
      # a close neighbour of a colour: mostly a hue shift, a little lightness
      near = lambda do |(h, s, l)|
        sign = rng.rand < 0.5 ? -1 : 1
        hsl.call(h + sign * rng.rand(6..18), s + rng.rand(-5..5), l + (rng.rand < 0.5 ? -1 : 1) * rng.rand(4..9))
      end
      angle = rng.rand(0...360)

      background =
        case rng.rand(7)
        when 0 # soft linear gradient
          "linear-gradient(#{angle}deg, #{color.call}, #{color.call})"
        when 1 # mesh: a few blurred blobs
          blobs = Array.new(3) do
            "radial-gradient(circle at #{rng.rand(0..100)}% #{rng.rand(0..100)}%, #{color.call} 0, transparent #{rng.rand(45..70)}%)"
          end
          (blobs + [deep.call]).join(", ")
        when 2 # conic swirl
          a = color.call
          "conic-gradient(from #{angle}deg at #{rng.rand(25..75)}% #{rng.rand(25..75)}%, #{a}, #{color.call}, #{color.call}, #{a})"
        when 3 # stripes
          base = pick.call(light: (40..58)); w = rng.rand(8..22)
          "repeating-linear-gradient(#{angle}deg, #{hsl.call(*base)} 0 #{w}px, #{near.call(base)} #{w}px #{w * 2}px)"
        when 4 # dots
          base = pick.call(light: (40..58)); s = rng.rand(14..30)
          "radial-gradient(circle, #{near.call(base)} #{rng.rand(22..34)}%, transparent #{rng.rand(36..40)}%) 0 0 / #{s}px #{s}px, " \
            "linear-gradient(#{angle}deg, #{hsl.call(*base)}, #{near.call(base)})"
        when 5 # checker
          base = pick.call(light: (40..58)); s = rng.rand(24..60)
          "repeating-conic-gradient(#{hsl.call(*base)} 0 25%, #{near.call(base)} 0 50%) 0 0 / #{s}px #{s}px"
        else # grid lines over a gradient
          base = pick.call(light: (40..58)); s = rng.rand(16..34)
          line = near.call(base)
          "linear-gradient(#{line} 2px, transparent 2px) 0 0 / #{s}px #{s}px, " \
            "linear-gradient(90deg, #{line} 2px, transparent 2px) 0 0 / #{s}px #{s}px, " \
            "linear-gradient(#{angle}deg, #{hsl.call(*base)}, #{near.call(base)})"
        end

      "background: #{background};"
    end
  end
end

Liquid::Template.register_filter(Rigas::Tiles)
