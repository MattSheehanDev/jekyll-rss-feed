# Jekyll plugin for generating Rss feed
#
# Usage: place this file in the _plugins directory and set the required configuration
#        attributes in the _config.yml file
#
# Uses the following attributes in _config.yml:
#   rss_title 	 	- (optional) the feed title 
#   rss_author 	 	- (optional) the feed author
#   rss_description - (optional) short description of the site
#   rss_link		- (optional) url of the site
#
# Author: Matt Sheehan <sheehamj@mountunion.edu>
# Site: http://mattsheehan.me
# Source: http://github.com/
#
# Distributed under the MIT license
# Copyright Matt Sheehan 2014

module Jekyll
	class Feed < Page; end

	class Rss < Generator
		priority :low
		safe true


		def generate(site)
			require "rss"

			title = site.config["rss_title"] || ""
			author = site.config["rss_author"] || ""
			description = site.config["rss_description"] || ""
			link = site.config["rss_link"] || ""
			date = site.posts.map { |post| post.date }.max


			rss = RSS::Maker.make("2.0") do |rss|
				rss.channel.title = title
				rss.channel.link = link
				rss.channel.description = description
				rss.channel.author = author
				rss.channel.updated = date
				rss.channel.copyright = date.year

				count = [site.posts.count, 20].min

				site.posts.reverse[0..count].each do |post|
					post.render(site.layouts, site.site_payload)
					rss.items.new_item do |item|
						item.title = post.title
						item.link = "#{link}#{post.url}"
						item.description = post.content
						item.updated = post.date
						item.guid.content = "#{link}#{post.url}"
					end
				end
			end

        	# Create file and add to site
        	name = "rss.xml"
        	dest = File.join(site.source, "/feeds/")

        	validate_dir(dest)

        	File.open("#{dest}#{name}", "w") { |f| f.write(rss) }
        	site.pages << Jekyll::Feed.new(site, site.source, "/feeds/", name)

		end


		private

    	# Validates directory exists, else creates directory
    	def validate_dir(dir)
      		FileUtils.mkdir_p(dir)
    	end


	end

end

