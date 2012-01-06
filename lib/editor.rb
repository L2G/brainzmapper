#!/usr/bin/env ruby

# editor.rb
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
# CREATE TABLE editor
# (
#     id                  SERIAL,
#     name                VARCHAR(64) NOT NULL,
#     password            VARCHAR(64) NOT NULL,
#     privs               INTEGER DEFAULT 0,
#     email               VARCHAR(64) DEFAULT NULL,
#     website             VARCHAR(255) DEFAULT NULL,
#     bio                 TEXT DEFAULT NULL,
#     member_since        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     email_confirm_date  TIMESTAMP WITH TIME ZONE,
#     last_login_date     TIMESTAMP WITH TIME ZONE,
#     edits_accepted      INTEGER DEFAULT 0,
#     edits_rejected      INTEGER DEFAULT 0,
#     auto_edits_accepted  INTEGER DEFAULT 0,
#     edits_failed        INTEGER DEFAULT 0,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

#==============================================================================
# This model holds data for individual editors who are registered on the
# MusicBrainz server.

class Editor
    include DataMapper::Resource

    # @attribute
    # @return [Integer]
    property :id, Serial

    # @attribute
    # @return [String] Login name identifying the editor.
    property :name, String, :length => 64, :required => true

    # @attribute
    # Holds the password used by the editor to log in. (Note that in the
    # public data provided by MusicBrainz, this field is sanitized and does
    # not hold any real passwords.)
    # @return [String]
    property :password, String, :length => 64, :required => true

    # @attribute
    # Flags indicating which editing privileges are given to the editor. Value
    # is an array of zero or more of the following symbols:
    # * +:account_admin+
    # * +:auto_editor+
    # * +:bot+
    # * +:dont_nag+
    # * +:mbid_submitter+
    # * +:relationship_editor+
    # * +:untrusted+
    # * +:wiki_transclusion+
    # @return [Array<Symbol>] Flags indicating editor's privileges
    property :privs, Flag, :default => 0,
                :flags => [:auto_editor, :bot, :untrusted,
                           :relationship_editor, :dont_nag,
                           :wiki_transclusion, :mbid_submitter,
                           :account_admin]

    # @attribute
    # @return [String, nil] Email address, if provided by the editor.
    property :email, String, :length => 64

    # @attribute
    # @return [URI, nil] Website address, if provided by the editor.
    property :website, URI, :length => 255

    # @attribute
    # @return [Text, nil] Biographical self-description, if provided by the
    #   editor.
    property :bio, Text

    # @attribute
    # @return [DateTime] When the editor registered this account.
    property :created_at, DateTime, :field => 'member_since'

    # @attribute
    # @return [DateTime, nil] When the editor's email address was confirmed;
    #   nil if not (yet) confirmed.
    property :email_confirm_date, DateTime

    # @attribute
    # @return [DateTime, nil] When the editor last logged in to the server.
    property :last_login_date, DateTime

    # @attribute
    # @return [Integer] Number of editor's edits that have been accepted
    #   following a vote.
    property :edits_accepted, Integer, :default => 0

    # @attribute
    # @return [Integer] Number of editor's edits that have been rejected by a
    #   vote.
    property :edits_rejected, Integer, :default => 0

    # @attribute
    # @return [Integer] Number of editor's edits that have been accepted
    #   immediately by the server.
    property :auto_edits_accepted, Integer, :default => 0

    # @attribute
    # @return [Integer] Number of editor's edits that have failed for reasons
    #   other than being voted down (e.g. data dependency failures).
    property :edits_failed, Integer, :default => 0

    # @attribute
    # @return [DateTime, nil] When this editor's account was last updated.
    property :updated_at, DateTime, :field => 'last_updated'
end
