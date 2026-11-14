# Videos inside note/post text: a paragraph that contains nothing but a
# YouTube, Vimeo or Wikimedia Commons video link (pasted on its own line in
# the CMS) becomes an embedded player, using the same .video box as the
# "Video" field (_includes/video.html).
require "cgi"

module Rigas
  module Embeds
    def self.src_for(url)
      url = CGI.unescapeHTML(url.strip)
      case url
      when %r{youtu\.be/([\w-]{11})}, %r{youtube\.com/(?:watch\?(?:.*&)?v=|embed/|shorts/)([\w-]{11})}
        "https://www.youtube-nocookie.com/embed/#{Regexp.last_match(1)}"
      when %r{vimeo\.com/(?:video/)?(\d+)(?:/(\w+))?}
        id, hash = Regexp.last_match(1), Regexp.last_match(2)
        "https://player.vimeo.com/video/#{id}?#{hash ? "h=#{hash}&" : ""}badge=0&byline=0&portrait=0&title=0"
      when %r{commons\.wikimedia\.org/wiki/(File:[^?#]+\.(?:webm|ogv|mp4))}i
        "https://commons.wikimedia.org/wiki/#{Regexp.last_match(1)}?embedplayer=yes"
      end
    end

    def self.iframe(src, title)
      %(<div class="video"><iframe src="#{src}" title="#{CGI.escapeHTML(title)}" loading="lazy" ) +
        %(allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture; web-share" ) +
        %(referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></div>)
    end
  end
end

Jekyll::Hooks.register :documents, :post_render do |doc|
  doc.output = doc.output.gsub(%r{<p>\s*(?:<a href="([^"]+)"[^>]*>([^<]*)</a>|(https?://\S+?))\s*</p>}) do |para|
    url = Regexp.last_match(1) || Regexp.last_match(3)
    text = Regexp.last_match(2).to_s
    src = Rigas::Embeds.src_for(url)
    # Only bare links: a link with its own descriptive text stays a normal link.
    if src && (text.empty? || text.strip == url.strip || text =~ %r{\Ahttps?://})
      Rigas::Embeds.iframe(src, doc.data["title"].to_s)
    else
      para
    end
  end
end
