$:.unshift(File.join('..','lib'))

require 'brainzmapper'

db_uri = 'postgres://musicbrainz_rw@localhost/musicbrainz_db?search_path=musicbrainz'

# Set up for using the BrainzMapper classes and connecting to the database
BrainzMapper.setup(:default, db_uri) 
DataMapper.finalize


def do_self_and_children(link_type, indent = '')
    puts indent + link_type.name.to_s + " (#{link_type.id})"
    link_type.children.each do |child|
        do_self_and_children(child, indent + '  ')
    end
end

LinkType.all(:parent => nil).each {|l| do_self_and_children(l)}
