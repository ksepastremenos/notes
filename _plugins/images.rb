# Images inside post/note text: after rendering, give local <img> tags their
# pixel size (so the page doesn't jump while they load) and make them open in
# the lightbox, captioned with their alt text. Adapted from the portfolio's
# _plugins/site.rb.
require "fastimage"
require "uri"

module Rigas
  module ImageSize
    @cache = {}

    def self.of(site, src)
      return nil if src.nil? || src.empty? || src =~ %r{\A[a-z]+://}i
      rel = URI.decode_www_form_component(src.sub(%r{\A/}, "").split("?").first)
      path = File.join(site.source, rel)
      return nil unless File.file?(path)
      @cache[path] ||= FastImage.size(path)
    end
  end
end

Jekyll::Hooks.register :documents, :post_render do |doc|
  doc.output = doc.output.gsub(/<img\s[^>]*>/) do |tag|
    next tag if tag.include?("data-lightbox") || !(tag =~ /\ssrc="(\/[^"]+)"/)
    src = Regexp.last_match(1)
    alt = tag[/\salt="([^"]*)"/, 1].to_s
    size = Rigas::ImageSize.of(doc.site, src)
    extra = +""
    extra << %( width="#{size[0]}" height="#{size[1]}") if size && !tag.include?("width=")
    extra << %( loading="lazy" decoding="async" data-lightbox data-caption="#{alt}")
    tag.sub(/<img/, "<img#{extra}")
  end
end
