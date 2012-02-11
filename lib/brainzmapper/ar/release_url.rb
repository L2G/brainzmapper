# ar/release_url.rb
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
# CREATE TABLE l_release_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );


# This represents an {AR advanced relationship} between a {Release} and an
# {Url}.

class AR::ReleaseUrl
    ENTITY_0 = :release
    ENTITY_1 = :url
    include AdvancedRelationship
end
