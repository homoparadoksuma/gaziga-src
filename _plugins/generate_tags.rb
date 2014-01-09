module Jekyll
  class TagPage < Page
    def initialize(template_path, name, site, base, tag_dir, tag)
      @site  = site
      @base  = base
      @dir   = tag_dir
      @name  = name

      self.process(name)

      if File.exist?(template_path)
        @perform_render = true
        template_dir    = File.dirname(template_path)
        template        = File.basename(template_path)
        # Read the YAML data from the layout page.
        self.read_yaml(template_dir, template)
        self.data['tag']    = tag
        title_prefix             = "#{tag} | Gaziga"
        self.data['title']       = "#{title_prefix}"
        # Set the meta-description for this page.
        meta_description_prefix  = site.config['tag_meta_description_prefix'] || 'Tag: '
        self.data['description'] = "#{meta_description_prefix}#{tag}"
      else
        @perform_render = false
      end
    end

    def render?
      @perform_render
    end

  end

  class TagIndex < TagPage
    def initialize(site, base, tag_dir, tag)
      template_path = File.join(base, '_layouts', 'tag_index.html')
      super(template_path, 'index.html', site, base, tag_dir, tag)
    end
  end


  class Site
    def write_tag_index(tag)
      target_dir = GenerateTags.tag_dir(self.config['tag_dir'], tag)
      index      = TagIndex.new(self, self.source, target_dir, tag)
      if index.render?
        index.render(self.layouts, site_payload)
        index.write(self.dest)
        # Record the fact that this pages has been added, otherwise Site::cleanup will remove it.
        self.pages << index
      end
    end

    # Loops through the list of category pages and processes each one.
    def write_tag_indexes
      if self.layouts.key? 'tag_index'
        self.tags.keys.each do |tag|
          self.write_tag_index(tag)
        end

      # Throw an exception if the layout couldn't be found.
      else
        throw "No 'tag_index' layout found."
      end
    end

  end

  class GenerateTags < Generator
    safe true
    priority :low

    TAG_DIR = 'tags'

    def generate(site)
      site.write_tag_indexes
    end

    def self.tag_dir(base_dir, tag)
      base_dir = (base_dir || TAG_DIR).gsub(/^\/*(.*)\/*$/, '\1')
      tag = tag.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase
      File.join(base_dir, tag)
    end
  end
end
