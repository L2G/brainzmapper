# link.rb
# 
# Copyright (c) 2012 Lawrence Leonard Gilbert
#
# The SQL code (incorporated for documentation purposes) comes from the
# MusicBrainz Server project, copyright of the MetaBrainz Foundation and
# others.  See the AUTHORS file for details.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 675 Mass
# Ave, Cambridge, MA 02139, USA.


##############################################################################
# CREATE TABLE link
# (
#     id                  SERIAL,
#     link_type           INTEGER NOT NULL, -- references link_type.id
#     begin_date_year     SMALLINT,
#     begin_date_month    SMALLINT,
#     begin_date_day      SMALLINT,
#     end_date_year       SMALLINT,
#     end_date_month      SMALLINT,
#     end_date_day        SMALLINT,
#     attribute_count     INTEGER NOT NULL DEFAULT 0,
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class Link
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial

    # @attribute
    # @deprecated Use {#link_type}.
    # @return [Integer]
    property :link_type_id, Integer, :required => true, :field => 'link_type'

    # @attribute
    # @return [LinkType]
    belongs_to :link_type

    # @attribute
    #
    # How many attributes this link has. Attributes give more specifics about
    # a link (e.g. a performance versus a _live_ performance).
    #
    # @return [Integer]
    property :attribute_count, Integer, :default => 0

    # @attribute
    # @return [DateTime]
    property :created_at, DateTime, :field => 'created'

    # @attribute
    # @return [Array<LinkAttribute>]
    has 0..n, :link_attributes

    def to_s
        string = self.link_type.to_s.clone
        attrs = self.link_attributes.collect {|a| a.to_s}
        attrs.each do |attr|
            string.gsub!(/\{#{attr}:([^\|\}]+).*\}/, '\1')
            string.gsub!(/\{(#{attr})\}/, '\1')
        end
        string.gsub!(/\{[^\|\}]+\|?(.*?)\}/, '\1')
        return string
    end
end
