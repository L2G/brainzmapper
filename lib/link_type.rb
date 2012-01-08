# link_type.rb
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
# CREATE TABLE link_type
# (
#     id                  SERIAL,
#     parent              INTEGER, -- references link_type.id
#     child_order         INTEGER NOT NULL DEFAULT 0,
#     gid                 UUID NOT NULL,
#     entity_type0        VARCHAR(50) NOT NULL,
#     entity_type1        VARCHAR(50) NOT NULL,
#     name                VARCHAR(255) NOT NULL,
#     description         TEXT,
#     link_phrase         VARCHAR(255) NOT NULL,
#     reverse_link_phrase VARCHAR(255) NOT NULL,
#     short_link_phrase   VARCHAR(255) NOT NULL,
#     priority            INTEGER NOT NULL DEFAULT 0,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#
class LinkType
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial

    # @attribute
    # @return [Integer, nil]
    property :parent_id, Integer, :field => 'parent'

    # @attribute
    # @return [LinkType, nil]
    belongs_to :parent, LinkType

    # @attribute
    # @return [Integer]
    property :child_order, Integer, :default => 0

    # @attribute
    # @return [UUID]
    property :gid, UUID

    # @attribute
    # What's on the "left" side of this link type.
    # @return [String]
    property :entity_type0, String, :length => 1..50

    # @attribute
    # What's on the "right" side of this link type.
    # @return [String]
    property :entity_type1, String, :length => 1..50

    # @attribute
    # @return [String]
    property :name, String, :length => 1..255

    # @attribute
    # @return [String]
    property :description, Text

    # @attribute
    # @return [String]
    property :link_phrase, String, :length => 1..255

    # @attribute
    # @return [String]
    property :reverse_link_phrase, String, :length => 1..255

    # @attribute
    # @return [String]
    property :short_link_phrase, String, :length => 1..255

    # @attribute
    # @return [Integer]
    property :priority, Integer, :default => 0

    # @attribute
    # @return [DateTime]
    property :updated_at, DateTime, :field => 'last_updated'

    # All link types that have this link type as a parent.
    # @return [Array<LinkType>, nil]
    def children
        self.class.all(:parent_id => self.id, :order => [:child_order.asc])
    end

    alias_method :to_s, :short_link_phrase
end
