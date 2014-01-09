module Jekyll
  class LinkTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @url, @text = @markup.strip.split(/\s+/, 2)
    end

    def render(context)
      args = @markup.strip.split(/\s+/, 2)
      cur_url = context.environments.first["page"]["url"]
      if cur_url.downcase.gsub('index.html', '')  == @url.downcase.gsub('index.html', '')
        return "<span>#{@text}</span>"
      else
        return "<a href=\"#{@url}\">#{@text}</a>"
      end
    end
  end
end

Liquid::Template.register_tag('link', Jekyll::LinkTag)
