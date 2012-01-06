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

#
class Editor
    include DataMapper::Resource
    
    property :id,                  Serial
    property :name,                String,   :length => 64, :required => true
    property :password,            String,   :length => 64, :required => true
    property :privs,               Flag,     :default => 0,
                :flags => [:auto_editor, :bot, :untrusted,
                           :relationship_editor, :dont_nag,
                           :wiki_transclusion, :mbid_submitter,
                           :account_admin]
    property :email,               String,   :length => 64
    property :website,             URI,      :length => 255
    property :bio,                 Text
    property :member_since,        DateTime, :default => Time.now
    property :email_confirm_date,  DateTime
    property :last_login_date,     DateTime
    property :edits_accepted,      Integer,  :default => 0
    property :edits_rejected,      Integer,  :default => 0
    property :auto_edits_accepted, Integer,  :default => 0
    property :edits_failed,        Integer,  :default => 0
    property :updated_at,          DateTime, :field => 'last_updated'
end
