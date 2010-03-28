require 'rubygems'
require 'thor'
require 'nokogiri'
require 'open-uri'
require 'octopussy'

module Vanity
  class App < Thor
    desc "all USER", "Show all information about a user"
    method_options :github => nil, :twitter => nil
    def all(info)
      @github = options[:github] || info
      @twitter = options[:twitter] || info
      puts "Twitter - " + twitter_stats
      puts "Github  - " + github_stats
    end

    private
      # Fetches number of followers and number of lists
      def twitter_stats
        # would be nice to use the twitter gem here, but twitter
        # doesn't expose list counts on user info.
        doc = Nokogiri::HTML(open("http://twitter.com/#@twitter"))
        followers = doc.css("#follower_count").first.content.to_i
        lists     = doc.css("#lists_count").first.content.to_i
        "followers: #{followers}; lists #{lists}"
      end

      def github_stats
        user = Octopussy.user(@github)
        repos = Octopussy.list_repos(@github)
        followers = user.followers_count
        watchers = repos.reduce(0) { |sum, repo| sum + repo.watchers - 1 }

        "followers: #{user.followers_count}; public-repos: #{repos.size}; watchers: #{watchers}"
      end
  end
end

if __FILE__ == $0
  Vanity::App.start
end
