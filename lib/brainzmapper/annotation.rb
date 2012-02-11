#!/usr/bin/env ruby

# annotation.rb
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

##############################################################################
# CREATE TABLE annotation
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     text                TEXT,
#     changelog           VARCHAR(255),
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

# An annotation is free-form text that accompanies an entry for an artist,
# release, track... really most any object in MusicBrainz.

class Annotation
    include DataMapper::Resource

    # @return [Serial]
    property :id, Serial

    # @private
    property :editor_id, Integer, :field => 'editor', :required => true

    # @return [Editor] The editor who wrote this annotation.
    belongs_to :editor

    # @return [Text] The text of the annotation.
    property :text, Text

    # @return [String] A one-line remark made by the editor about this
    #   annotation.
    property :changelog, String, :length => 255

    # @return [DateTime] The date and time the annotation was created.
    property :created_at, DateTime, :field => 'created'

    alias_method :to_s, :text

end
