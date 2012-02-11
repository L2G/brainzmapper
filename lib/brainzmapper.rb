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
# BrainzMapper is a DataMapper-based library for accessing a local copy of the
# MusicBrainz database as Ruby objects.
#
###############################################################################

require 'rubygems'
require 'data_mapper'

# Abstract modules

require 'brainzmapper/simple_id_name_model'

# Model/resource definitions

require 'brainzmapper/annotation'
require 'brainzmapper/artist'
require 'brainzmapper/artist_alias'
require 'brainzmapper/artist_annotation'
require 'brainzmapper/artist_credit'
require 'brainzmapper/artist_credit_name'
require 'brainzmapper/artist_gid_redirect'
require 'brainzmapper/artist_meta'
require 'brainzmapper/artist_name'
require 'brainzmapper/artist_tag'
require 'brainzmapper/artist_type'
require 'brainzmapper/cdtoc'
require 'brainzmapper/country'
require 'brainzmapper/edit'
require 'brainzmapper/editor'
require 'brainzmapper/fuzzy_date'
require 'brainzmapper/gender'
require 'brainzmapper/language'
require 'brainzmapper/link'
require 'brainzmapper/link_attribute'
require 'brainzmapper/link_attribute_type'
require 'brainzmapper/link_type'
require 'brainzmapper/release'
require 'brainzmapper/release_group'
require 'brainzmapper/release_meta'
require 'brainzmapper/release_name'
require 'brainzmapper/tag'
require 'brainzmapper/url'

# All "advanced relationships"
require 'brainzmapper/ar'

# Use +require 'brainzmapper'+ to load all of BrainzMapper's MusicBrainz
# models. Then you can use the {BrainzMapper.setup} method to set up a
# DataMapper connection and the correct naming convention for MusicBrainz, all
# in one step (instead of two).
#
# @example
#   require 'brainzmapper'
#
#   db_uri = 'postgres://musicbrainz_rw@localhost/musicbrainz_db?search_path=musicbrainz'
#   BrainzMapper.setup(:default, db_uri)
#
#   # (...could do other DataMapper things here before finalizing...)
#
#   DataMapper.finalize

class BrainzMapper
    NAMING_CONVENTION = DataMapper::NamingConventions::Resource::Underscored

    # This method is for convenience of setting up DataMapper for use with the
    # BrainzMapper classes.
    #
    # For the simplest case, see the example in Overview above. For more
    # possibilities, see DataMapper's documentation for {DataMapper.setup}.
    #
    # You should still call {DataMapper.finalize} yourself!
    #
    # @return [DataMapper::Adapters::AbstractAdapter]

    def BrainzMapper.setup(*args)
        adapter = DataMapper.setup(*args)
        adapter.resource_naming_convention = NAMING_CONVENTION
        return adapter
    end
end
