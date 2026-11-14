# Generated tile art: each post's tile gets its own CSS gradient or pattern,
# picked from a seed (its URL), so it looks the same on every build and is
# drawn instantly (no images, no script).
#
#   <span class="tile-art" style="{{ post.url | tile_art: site.palette }}"></span>
#
# site.palette = { hue: 165, spread: 30 } → colours within hue ± spread.
require "zlib"

module Rigas
  module Tiles
    BG = "#181a1b"

    def tile_art(seed, palette)
      rng = Random.new(Zlib.crc32(seed.to_s))
      hue = (palette && palette["hue"] || 0).to_f
      spread = (palette && palette["spread"] || 30).to_f

      color = lambda do |light: (45..70), sat: (60..95)|
        h = (hue + rng.rand(-spread..spread)) % 360
        "hsl(#{h.round} #{rng.rand(sat).round}% #{rng.rand(light).round}%)"
      end
      deep = -> { color.call(light: 18..30, sat: 40..70) }
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
          w = rng.rand(8..22)
          "repeating-linear-gradient(#{angle}deg, #{color.call} 0 #{w}px, #{deep.call} #{w}px #{w * 2}px)"
        when 4 # dots
          s = rng.rand(14..30)
          "radial-gradient(circle, #{color.call} #{rng.rand(22..34)}%, transparent #{rng.rand(36..40)}%) 0 0 / #{s}px #{s}px, linear-gradient(#{angle}deg, #{deep.call}, #{BG})"
        when 5 # checker
          s = rng.rand(24..60)
          "repeating-conic-gradient(#{color.call} 0 25%, #{deep.call} 0 50%) 0 0 / #{s}px #{s}px"
        else # grid lines over a gradient
          s = rng.rand(16..34)
          line = color.call(light: 60..80)
          "linear-gradient(#{line} 2px, transparent 2px) 0 0 / #{s}px #{s}px, " \
            "linear-gradient(90deg, #{line} 2px, transparent 2px) 0 0 / #{s}px #{s}px, " \
            "linear-gradient(#{angle}deg, #{deep.call}, #{color.call(light: 30..45)})"
        end

      "background: #{background};"
    end
  end
end

Liquid::Template.register_filter(Rigas::Tiles)
