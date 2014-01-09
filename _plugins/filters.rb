require 'fastimage'

module Jekyll
  module GazigaFilter
    require 'fastimage'
    require 'nokogiri'
    require 'htmlentities'

    @@months = { 1 => "января", 2 => "февраля", 3 => "марта", 4 => "апреля", 5 => "мая", 6 => "июня", 7 => "июля", 8 => "августа", 9 => "сентября", 10 => "октября", 11 => "ноября", 12 => "декабря", }

    @@months_names = { 1 => "Январь", 2 => "Февраль", 3 => "Март", 4 => "Апрель", 5 => "Май", 6 => "Июнь", 7 => "Июль", 8 => "Август", 9 => "Сентябрь", 10 => "Октябрь", 11 => "Ноябрь", 12 => "Декабрь", }

    def format_date(input)
      "#{input.strftime("%d #{@@months[input.month]} %Y")}"
    end

    def month_name(input)
      @@months_names[input].capitalize
    end

    def get_email(author)
      if author == 'uma'
        'homoparadoksuma@gmail.com'
      else
        'gagrych@gmail.com'
      end
    end

    def geo_from_url(input)
      if input =~ /\/geo\/(.+)\//i
         return $1
      end
      return ''
    end

    def display_name(input)
      @context.registers[:site].data["categories"][input]
    end

    def decode(input)
      HTMLEntities.new.decode input
    end

    def strip_html(input)
        input.gsub(/<\/?[^>]*>/, "")
    end

    def excerpt(input)
        strip_html(input)[0..200]
    end

    def no_slash(input)
        input.gsub(/^\//, "")
    end

    def group_by_date(coll, field = nil)
      if field
        coll.group_by { |i| i.date.send(field) }
      else
        coll.group_by { |i| i.date }
      end
    end

    def furl(input)
       return  input.chomp('/') + '/' #input.chomp(File.extname(input))
    end

    def normalize(input)
      input.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase
    end

    def process_img(input)
      #return input
      post = @context.environments.first['page']['url'].to_s.split('/').last
      post = furl post
      dir = File.join(Jekyll.configuration({})['photo_dir'], 'posts')
      dir = File.join(dir, post)
      return input if not Dir.exists?(dir)
      doc = Nokogiri::HTML(input)
      doc.xpath("//img").each do |img|
        img_name = img['src'].split('/').last
        file_path = File.join(dir, img_name)
        if File.exists?(file_path)
          size = FastImage.size(file_path)
          img['width'], img['height'] = size
          img['src'] = File.join(Jekyll.configuration({})['dropbox'], '/posts', post, img_name)
        end
      end
      doc.xpath("//a").each do |a|
        if a['href'] =~ /jpg$/
          img_name = a['href'].split('/').last
          file_path = File.join(dir, img_name)
          if File.exists?(file_path)
            a['href'] = File.join(Jekyll.configuration({})['dropbox'], 'posts', post, img_name)
          end
        end
      end

      return doc.css('body').inner_html
    end

  end
end

Liquid::Template.register_filter(Jekyll::GazigaFilter)
