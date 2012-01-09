#!/usr/bin/env ruby

# ar.rb
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


# @abstract
#
# AdvancedRelationship provides properties common to "advanced relationship"
# links between objects.
#
# For MusicBrainz's explanation of the concept, see:
# http://musicbrainz.org/doc/Advanced_Relationship
#
# Attributes:
#
# id::
# link::
# entity0::
# entity1::
# edits_pending::
# last_updated::

module AR
    protected
    def self.included(heir)

        _entity0 = heir.class_eval('ENTITY_0')
        _entity1 = heir.class_eval('ENTITY_1')

        heir.class_eval do
            include DataMapper::Resource
            storage_names[:default] = "l_" + _entity0.to_s + "_" + _entity1.to_s

            # @attribute [r]
            # @return [Integer]
            property :id, DataMapper::Property::Serial

            # @attribute
            # @return [Integer]
            property :link_id, Integer, :field => 'link'

            # @attribute
            # @return [Link]
            belongs_to :link

            # @attribute
            property :entity0_id, Integer, :field => 'entity0'

            # @attribute
            property :entity1_id, Integer, :field => 'entity1'

            belongs_to _entity0.to_sym,
                :model => DataMapper::Inflector.camelize(_entity0.to_sym),
                :child_key => [:entity0_id]

            belongs_to _entity1.to_sym,
                :model => DataMapper::Inflector.camelize(_entity1.to_sym),
                :child_key => [:entity1_id]

            # @attribute
            property :edits_pending, Integer

            # @attribute
            property :updated_at, DateTime, :field => 'last_updated'

            def to_s
                return "#{self.entity0} #{self.link.link_type} #{self.entity1}"
            end
        end
    end
end

AdvancedRelationship = AR

require 'ar/artist_url'
require 'ar/release_url'
