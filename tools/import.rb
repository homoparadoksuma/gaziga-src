require 'nokogiri'
require 'date'

def process_post(post)
    text = post.at_css('BodyPart').attr('Text')
    slug = post.at_css('AutoroutePart').attr('Alias')
    categories = post.at_xpath('TaxonomyField.geo').attr('Terms').scan(/\/alias=geo\\\/(\w+)/).map{|i| i.first}
    title = post.at_css('TitlePart').attr('Title')
    tags = post.at_css('TagsPart').attr('Tags').split(',')
    author = post.at_xpath('CommonPart').attr('Owner').scan(/\/User\.UserName=(\w+)/).first.first
    date = DateTime.parse(post.at_xpath('CommonPart').attr('PublishedUtc'))
    date_str = date.to_date.to_s
    datetime_str = date.strftime("%Y-%m-%d %H:%M:%S")
    p datetime_str

    File.open("../_posts/#{date_str}-#{slug}.md", 'w') do |f|
        f.puts <<-eos
---
layout: post
title:  \"#{title}\"
date:   #{datetime_str}
categories: [#{categories.join(', ')}]
tags: [#{tags.join(', ')}]
author: #{author}
---

#{text}
eos
    end
end

Dir.mkdir("posts") if not Dir.exists?("posts")

File.open('export.xml', "r") do |file|
    doc = Nokogiri::XML(file)
    doc.css('BlogPost').each do |node|
        process_post(node)
    end
end
