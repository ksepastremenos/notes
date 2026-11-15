# Image credits as a dropdown: a "#### Πηγές εικόνων" heading (any h3/h4 whose text
# starts with "Πηγές" or "Sources") is turned, together with everything after it
# up to the next h3/h4 or the end of the text, into a closed <details> box.
# Nothing to change in the CMS: just keep writing the heading.

Jekyll::Hooks.register :documents, :post_render do |doc|
  doc.output = doc.output.sub(
    %r{<h[34][^>]*>\s*((?:Πηγές|Sources)[^<]*)</h[34]>(.*?)(?=<h[34][\s>]|</div>\s*(?:<div class="stack">|<a class="btn backButton addBackArrow"))}m
  ) do
    title, body = Regexp.last_match(1).strip, Regexp.last_match(2)
    %(<details class="collapse"><summary>#{title}</summary>#{body}</details>)
  end
end
