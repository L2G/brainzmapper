#!/usr/bin/env ruby

# brainzmapper.rb
# 
# Copyright (c) 2011, 2012 Lawrence Leonard Gilbert
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

###############################################################################
#
# Brainzmapper is a DataMapper-based library for accessing a local copy of the
# MusicBrainz database as Ruby objects.
#
###############################################################################

require 'rubygems'
require 'data_mapper'
require 'date'
require 'delegate'

# @api private
module SimpleInspect
    def inspect
        "#<#{self.class} #{self.id}:#{self.name}>"
    end
end

# Model/resource definitions

require 'annotation'
require 'artist'
require 'artist_alias'
require 'artist_annotation'
require 'artist_credit'
require 'artist_credit_name'
require 'artist_gid_redirect'
require 'artist_meta'
require 'artist_name'
require 'artist_tag'
require 'artist_type'
require 'brainzmapper'
require 'country'
require 'edit'
require 'editor'
require 'fuzzy_date'
require 'gender'
require 'language'
require 'release'
require 'tag'


POSTGRES_URI = 'postgres://musicbrainz_rw@localhost/musicbrainz_db?search_path=musicbrainz'

DataMapper::Logger.new($stdout, :debug)
ADAPTER = DataMapper.setup(:default, POSTGRES_URI)
ADAPTER.resource_naming_convention =
    DataMapper::NamingConventions::Resource::Underscored

