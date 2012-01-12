# link_attribute.rb
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
# CREATE TABLE link_attribute
# (
#     link                INTEGER NOT NULL, -- PK, references link.id
#     attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

# Links may have attributes attached to them, depending on the link type. This
# is the class for link attributes.

class LinkAttribute
    include DataMapper::Resource

    # @attribute
    # @deprecated Use {#link}.
    # @return [Integer]
    property :link_id, Integer, :required => true, :key => true, :field => 'link'

    # @attribute
    # @return [Link] The link to which this attribute is assigned.
    belongs_to :link

    # @attribute
    # @deprecated Use {#attribute_type}.
    # @return [Integer]
    property :attribute_type_id, Integer, :required => true, :key => true,
        :field => 'attribute_type'

    # @attribute
    # @return [AttributeType] The type of this attribute.
    belongs_to :attribute_type, :model => 'LinkAttributeType'
end
