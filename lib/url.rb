# url.rb
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
# CREATE TABLE url
# (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     url                 TEXT NOT NULL,
#     description         TEXT,
#     ref_count           INTEGER NOT NULL DEFAULT 0,
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

# The URL object encapsulates a URL (usually http/https) and an optional
# description.
class URL
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial

    # @attribute
    # @return [UUID]
    property :gid, UUID

    # @attribute
    # @return [String]
    # The absolute URL itself.
    property :url, Text, :required => true, :lazy => false

    # @attribute
    #
    # A description of (what's found at) this URL.
    #
    # @return [String, nil]
    property :description, Text

    # @attribute
    # @api private
    # @return [Integer]
    property :ref_count, Integer, :required => true, :default => 0

    # @attribute
    # The number of edits that have been proposed but not yet applied to this
    # resource.
    # @return [Integer]
    property :edits_pending, Integer, :required => true, :default => 0

    # @attribute
    # @return [DateTime]
    property :updated_at, DateTime, :field => 'last_updated'
end
