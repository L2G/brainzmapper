$:.unshift(File.join('..','lib'))

require 'brainzmapper'

db_uri = 'postgres://musicbrainz_rw@localhost/musicbrainz_db?search_path=musicbrainz'

# Log debugging info to standard output
DataMapper::Logger.new($stdout,:debug)

# Set up for using the BrainzMapper classes and connecting to the database
BrainzMapper.setup(:default, db_uri) 
DataMapper.finalize

album_url_links =
    AR::ReleaseUrl.all(
        :url =>
            (Url.all(:url.like => '%amazon%') -
                ( Url.all(:url.like => '%archive.org%') +
                  Url.all(:url.like => '%amazon.cn%') +
                  Url.all(:url.like => '%.amazonaws.com/%') +
                  Url.all(:url.like => 'http://www.amazon.com/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.ca/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.de/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.fr/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.it/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.co.jp/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.co.uk/gp/product%') +
                  Url.all(:url.like => 'http://www.amazon.es/gp/product%') )
            ),
            :order => nil
     )

album_url_links.each do |link|
    puts "musicbrainz.org/release/#{link.release.gid}"
    puts "  -> #{link.url}\n\n"
end
