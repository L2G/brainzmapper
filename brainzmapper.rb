#!/usr/bin/env ruby

# A DataMapper-based library for accessing a local copy of the MusicBrainz
# database.
#
# The SQL used for reference here is copied directly from the MusicBrainz
# server code.  Since the server is licensed under the terms of the GNU
# General Public License version 2, so is this.
#
# Lawrence Leonard Gilbert (2011-12-29)

require 'rubygems'
require 'data_mapper'
require 'date'

POSTGRES_URI = 'postgres://musicbrainz_rw@localhost/musicbrainz_db?search_path=musicbrainz'

DataMapper::Logger.new($stdout, :debug)
ADAPTER = DataMapper.setup(:default, POSTGRES_URI)
ADAPTER.resource_naming_convention =
    DataMapper::NamingConventions::Resource::Underscored

module MB
class Date < Date
    attr_reader :year, :month, :day

    def initialize(year, month = nil, day = nil)
        if month.nil?
            @mb_date_precision = :y
            super(year)
        else
            if day.nil?
                @mb_date_precision = :m
                super(year, month)
            else
                @mb_date_precision = :d
                super(year, month, day)
            end
        end
    end

end
end

##############################################################################
# CREATE TABLE annotation
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     text                TEXT,
#     changelog           VARCHAR(255),
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

class Annotation
    include DataMapper::Resource

    property   :id,        Serial
    property   :editor_id, Integer, :field => 'editor', :required => true
    belongs_to :editor,    :child_key => [:editor_id], :parent_key => [:id]
    property   :text,      Text
    property   :changelog, String, :length => 255
    property   :created,   DateTime, :default => Time.now
end

##############################################################################
# CREATE TABLE artist (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references artist_name.id
#     sort_name           INTEGER NOT NULL, -- references artist_name.id
#     begin_date_year     SMALLINT,
#     begin_date_month    SMALLINT,
#     begin_date_day      SMALLINT,
#     end_date_year       SMALLINT,
#     end_date_month      SMALLINT,
#     end_date_day        SMALLINT,
#     type                INTEGER, -- references artist_type.id
#     country             INTEGER, -- references country.id
#     gender              INTEGER, -- references gender.id
#     comment             VARCHAR(255),
#     ipi_code            VARCHAR(11),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

class Artist
    include DataMapper::Resource

    property   :id,  Serial
    property   :gid, UUID

    property   :name_id, Integer, :field => 'name', :required => true
    belongs_to :name, :model => 'ArtistName', :child_key => [:name_id],
               :parent_key => [:id]

    property   :sort_name_id, Integer, :field => 'sort_name', :required => true
    belongs_to :sort_name, :model => 'ArtistName',
               :child_key => [:sort_name_id], :parent_key => [:id]

    property   :begin_date_year, Integer
    property   :begin_date_month, Integer
    property   :begin_date_day, Integer

    property   :end_date_year, Integer
    property   :end_date_month, Integer
    property   :end_date_day, Integer

    property   :artist_type_id, Integer, :field => 'type'
    belongs_to :artist_type, :model => 'ArtistType',
               :child_key => [:artist_type_id], :parent_key => [:id]

    property   :country_id, Integer, :field => 'country'
    belongs_to :country, :model => 'Country',
               :child_key => [:country_id], :parent_key => [:id]

    property   :gender_id, Integer, :field => 'gender'
    belongs_to :gender, :model => 'Gender',
               :child_key => [:gender_id], :parent_key => [:id]

    property   :comment,  String, :length => 255
    property   :ipi_code, String, :length => 11
    property   :last_updated, DateTime

    has 0..1,  :annotation, :model => 'Annotation',
               :through => :artist_annotation

    def begin_date
        y, m, d = begin_date_year, begin_date_month, begin_date_day
        unless y.nil?
            MB::Date.new(y, m, d)
        else
            nil
        end
    end

    def end_date
        y, m, d = end_date_year, begin_date_month, begin_date_day
        unless y.nil?
            MB::Date.new(y, m, d)
        else
            nil
        end
    end

end

##############################################################################
# CREATE TABLE artist_alias
# (
#     id                  SERIAL,
#     artist              INTEGER NOT NULL, -- references artist.id
#     name                INTEGER NOT NULL, -- references artist_name.id
#     locale              TEXT,
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

class ArtistAlias
    include DataMapper::Resource

    property :id, Serial
    property :artist_id, Integer, :required => true, :field => 'artist'
    property :artist_name_id, Integer, :required => true, :field => 'name'

    belongs_to :artist
    belongs_to :name, :model => 'ArtistName', :child_key => [:artist_name_id]

    property :locale, Text
    property :edits_pending, Integer, :required => true, :default => 0
    property :last_updated, DateTime, :default => Time.now
end

##############################################################################
# CREATE TABLE artist_annotation
# (
#     artist              INTEGER NOT NULL, -- PK, references artist.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );

class ArtistAnnotation
    include DataMapper::Resource

    property :artist_id,     Integer, :field => 'artist',     :key => true
    property :annotation_id, Integer, :field => 'annotation', :key => true

    belongs_to :artist
    belongs_to :annotation 
end

##############################################################################
# DataMapper wants to call it AnnotationArtist instead of ArtistAnnotation
class AnnotationArtist < ArtistAnnotation; end

# CREATE TABLE artist_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references artist.id CASCADE
#     rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
#     rating_count        INTEGER
# );

##############################################################################
# CREATE TABLE artist_name (
#     id                  SERIAL,
#     name                VARCHAR NOT NULL
# );

class ArtistName
    include DataMapper::Resource

    property :id, Serial
    property :name, String

    def to_s
        name
    end
end

##############################################################################
# CREATE TABLE artist_type (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );

class ArtistType
    include DataMapper::Resource

    property :id, Serial
    property :name, String, :length => 255

    def to_s
        name
    end
end

# CREATE TABLE artist_tag
# (
#     artist              INTEGER NOT NULL, -- PK, references artist.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE artist_rating_raw
# (
#     artist              INTEGER NOT NULL, -- PK, references artist.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
# );
# 
# CREATE TABLE artist_tag_raw
# (
#     artist              INTEGER NOT NULL, -- PK, references artist.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     tag                 INTEGER NOT NULL -- PK, references tag.id
# );
# 
# CREATE TABLE artist_credit (
#     id                  SERIAL,
#     name                INTEGER NOT NULL, -- references artist_name.id
#     artist_count       SMALLINT NOT NULL,
#     ref_count           INTEGER DEFAULT 0,
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE artist_credit_name (
#     artist_credit       INTEGER NOT NULL, -- PK, references artist_credit.id CASCADE
#     position            SMALLINT NOT NULL, -- PK
#     artist              INTEGER NOT NULL, -- references artist.id CASCADE
#     name                INTEGER NOT NULL, -- references artist_name.id
#     join_phrase         TEXT
# );

##############################################################################
# CREATE TABLE artist_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references artist.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

class ArtistGidRedirect
    include DataMapper::Resource

    property :gid, UUID, :key => true

    property :new_id, Integer, :required => true
    belongs_to :new_artist, :model => 'Artist', :child_key => [:new_id],
               :parent_id => [:id]

    property :created, DateTime, :default => Time.now
end

# CREATE TABLE autoeditor_election
# (
#     id                  SERIAL,
#     candidate           INTEGER NOT NULL, -- references editor.id
#     proposer            INTEGER NOT NULL, -- references editor.id
#     seconder_1          INTEGER, -- references editor.id
#     seconder_2          INTEGER, -- references editor.id
#     status              INTEGER NOT NULL DEFAULT 1
#                             CHECK (status IN (1,2,3,4,5,6)),
#                             -- 1 : has proposer
#                             -- 2 : has seconder_1
#                             -- 3 : has seconder_2 (voting open)
#                             -- 4 : accepted!
#                             -- 5 : rejected
#                             -- 6 : cancelled (by proposer)
#     yes_votes           INTEGER NOT NULL DEFAULT 0,
#     no_votes            INTEGER NOT NULL DEFAULT 0,
#     propose_time        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
#     open_time           TIMESTAMP WITH TIME ZONE,
#     close_time          TIMESTAMP WITH TIME ZONE
# );
# 
# CREATE TABLE autoeditor_election_vote
# (
#     id                  SERIAL,
#     autoeditor_election INTEGER NOT NULL, -- references autoeditor_election.id
#     voter               INTEGER NOT NULL, -- references editor.id
#     vote                INTEGER NOT NULL CHECK (vote IN (-1,0,1)),
#     vote_time           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
# );
# 
# CREATE TABLE cdtoc
# (
#     id                  SERIAL,
#     discid              CHAR(28) NOT NULL,
#     freedb_id           CHAR(8) NOT NULL,
#     track_count         INTEGER NOT NULL,
#     leadout_offset      INTEGER NOT NULL,
#     track_offset        INTEGER[] NOT NULL,
#     degraded            BOOLEAN NOT NULL DEFAULT FALSE,
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE cdtoc_raw
# (
#     id                  SERIAL,
#     release             INTEGER NOT NULL, -- references release_raw.id
#     discid              CHAR(28) NOT NULL,
#     track_count          INTEGER NOT NULL,
#     leadout_offset       INTEGER NOT NULL,
#     track_offset         INTEGER[] NOT NULL
# );
# 
# CREATE TABLE clientversion
# (
#     id                  SERIAL,
#     version             VARCHAR(64) NOT NULL,
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );

##############################################################################
# CREATE TABLE country (
#     id                  SERIAL,
#     iso_code            VARCHAR(2) NOT NULL,
#     name                VARCHAR(255) NOT NULL
# );

class Country
    include DataMapper::Resource

    property :id,       Serial
    property :iso_code, String, :length => 2,   :required => true
    property :name,     String, :length => 255, :required => true

    def to_s
        name
    end
end


# CREATE TABLE edit
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     type                SMALLINT NOT NULL,
#     status              SMALLINT NOT NULL,
#     data                TEXT NOT NULL,
#     yes_votes            INTEGER NOT NULL DEFAULT 0,
#     no_votes             INTEGER NOT NULL DEFAULT 0,
#     autoedit            SMALLINT NOT NULL DEFAULT 0,
#     open_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     close_time           TIMESTAMP WITH TIME ZONE,
#     expire_time          TIMESTAMP WITH TIME ZONE NOT NULL,
#     language            INTEGER, -- references language
#     quality             SMALLINT NOT NULL DEFAULT 1
# );
# 
# CREATE TABLE edit_note
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     edit                INTEGER NOT NULL, -- references edit.id
#     text                TEXT NOT NULL,
#     post_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE edit_artist
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     artist              INTEGER NOT NULL, -- PK, references artist.id CASCADE
#     status              SMALLINT NOT NULL -- materialized from edit.status
# );
# 
# CREATE TABLE edit_label
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     label               INTEGER NOT NULL, -- PK, references label.id CASCADE
#     status              SMALLINT NOT NULL -- materialized from edit.status
# );
# 
# CREATE TABLE edit_release
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     release             INTEGER NOT NULL  -- PK, references release.id CASCADE
# );
# 
# CREATE TABLE edit_release_group
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     release_group       INTEGER NOT NULL  -- PK, references release_group.id CASCADE
# );
# 
# CREATE TABLE edit_recording
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     recording           INTEGER NOT NULL  -- PK, references recording.id CASCADE
# );
# 
# CREATE TABLE edit_work
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     work                INTEGER NOT NULL  -- PK, references work.id CASCADE
# );
# 
# CREATE TABLE edit_url
# (
#     edit                INTEGER NOT NULL, -- PK, references edit.id
#     url                 INTEGER NOT NULL  -- PK, references url.id CASCADE
# );

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

class Editor
    include DataMapper::Resource
    
    property :id,                  Serial
    property :name,                String,   :length => 64, :required => true
    property :password,            String,   :length => 64, :required => true
    property :privs,               Integer,  :default => 0
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
    property :last_updated,        DateTime, :default => Time.now
end

# CREATE TABLE editor_preference
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     name                VARCHAR(50) NOT NULL,
#     value               VARCHAR(100) NOT NULL
# );
# 
# CREATE TABLE editor_subscribe_artist
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     artist              INTEGER NOT NULL, -- weakly references artist
#     last_edit_sent      INTEGER NOT NULL, -- weakly references edit
#     deleted_by_edit     INTEGER NOT NULL DEFAULT 0, -- weakly references edit
#     merged_by_edit      INTEGER NOT NULL DEFAULT 0 -- weakly references edit
# );
# 
# CREATE TABLE editor_subscribe_label
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     label               INTEGER NOT NULL, -- weakly references label
#     last_edit_sent      INTEGER NOT NULL, -- weakly references edit
#     deleted_by_edit     INTEGER NOT NULL DEFAULT 0, -- weakly references edit
#     merged_by_edit      INTEGER NOT NULL DEFAULT 0 -- weakly references edit
# );
# 
# CREATE TABLE editor_subscribe_editor
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id (the one who has subscribed)
#     subscribed_editor   INTEGER NOT NULL, -- references editor.id (the one being subscribed)
#     last_edit_sent      INTEGER NOT NULL  -- weakly references edit
# );

##############################################################################
# CREATE TABLE gender (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );

class Gender
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, :length => 255, :required => true

    def to_s
        name
    end
end

# CREATE TABLE isrc
# (
#     id                  SERIAL,
#     recording           INTEGER NOT NULL, -- references recording.id
#     isrc                CHAR(12) NOT NULL CHECK (isrc ~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$'),
#     source              SMALLINT,
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_artist
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references artist.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_label
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references label.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_recording
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references recording.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_release
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references release.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_release_group
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references release_group.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_artist_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references artist.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_label_label
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references label.id
#     entity1             INTEGER NOT NULL, -- references label.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_label_recording
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references label.id
#     entity1             INTEGER NOT NULL, -- references recording.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_label_release
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references label.id
#     entity1             INTEGER NOT NULL, -- references release.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_label_release_group
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references label.id
#     entity1             INTEGER NOT NULL, -- references release_group.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_label_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references label.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_label_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references label.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_recording_recording
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references recording.id
#     entity1             INTEGER NOT NULL, -- references recording.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_recording_release
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references recording.id
#     entity1             INTEGER NOT NULL, -- references release.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_recording_release_group
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references recording.id
#     entity1             INTEGER NOT NULL, -- references release_group.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_recording_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references recording.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_recording_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references recording.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_release
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release.id
#     entity1             INTEGER NOT NULL, -- references release.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_release_group
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release.id
#     entity1             INTEGER NOT NULL, -- references release_group.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_group_release_group
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release_group.id
#     entity1             INTEGER NOT NULL, -- references release_group.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_group_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release_group.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_release_group_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references release_group.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_url_url
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references url.id
#     entity1             INTEGER NOT NULL, -- references url.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_url_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references url.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE l_work_work
# (
#     id                  SERIAL,
#     link                INTEGER NOT NULL, -- references link.id
#     entity0             INTEGER NOT NULL, -- references work.id
#     entity1             INTEGER NOT NULL, -- references work.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE label (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references label_name.id
#     sort_name           INTEGER NOT NULL, -- references label_name.id
#     begin_date_year     SMALLINT,
#     begin_date_month    SMALLINT,
#     begin_date_day      SMALLINT,
#     end_date_year       SMALLINT,
#     end_date_month      SMALLINT,
#     end_date_day        SMALLINT,
#     label_code          INTEGER CHECK (label_code > 0 AND label_code < 100000),
#     type                INTEGER, -- references label_type.id
#     country             INTEGER, -- references country.id
#     comment             VARCHAR(255),
#     ipi_code            VARCHAR(11),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# 
# CREATE TABLE label_rating_raw
# (
#     label               INTEGER NOT NULL, -- PK, references label.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
# );
# 
# CREATE TABLE label_tag_raw
# (
#     label               INTEGER NOT NULL, -- PK, references label.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     tag                 INTEGER NOT NULL -- PK, references tag.id
# );
# 
# CREATE TABLE label_alias
# (
#     id                  SERIAL,
#     label               INTEGER NOT NULL, -- references label.id
#     name                INTEGER NOT NULL, -- references label_name.id
#     locale              TEXT,
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE label_annotation
# (
#     label               INTEGER NOT NULL, -- PK, references label.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );
# 
# CREATE TABLE label_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references label.id CASCADE
#     rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
#     rating_count        INTEGER
# );
# 
# CREATE TABLE label_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references label.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE label_name (
#     id                  SERIAL,
#     name                VARCHAR NOT NULL
# );
# 
# CREATE TABLE label_tag
# (
#     label               INTEGER NOT NULL, -- PK, references label.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE label_type (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );
# 
# CREATE TABLE language
# (
#     id                  SERIAL,
#     iso_code_3t         CHAR(3) NOT NULL, -- ISO 639-2 (T)
#     iso_code_3b         CHAR(3) NOT NULL, -- ISO 639-2 (B)
#     iso_code_2          CHAR(2), -- ISO 639
#     name                VARCHAR(100) NOT NULL,
#     frequency           INTEGER NOT NULL DEFAULT 0
# );
# 
# CREATE TABLE link
# (
#     id                  SERIAL,
#     link_type           INTEGER NOT NULL, -- references link_type.id
#     begin_date_year     SMALLINT,
#     begin_date_month    SMALLINT,
#     begin_date_day      SMALLINT,
#     end_date_year       SMALLINT,
#     end_date_month      SMALLINT,
#     end_date_day        SMALLINT,
#     attribute_count     INTEGER NOT NULL DEFAULT 0,
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE link_attribute
# (
#     link                INTEGER NOT NULL, -- PK, references link.id
#     attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE link_attribute_type
# (
#     id                  SERIAL,
#     parent              INTEGER, -- references link_attribute_type.id
#     root                INTEGER NOT NULL, -- references link_attribute_type.id
#     child_order         INTEGER NOT NULL DEFAULT 0,
#     gid                 UUID NOT NULL,
#     name                VARCHAR(255) NOT NULL,
#     description         TEXT,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
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
# CREATE TABLE link_type_attribute_type
# (
#     link_type           INTEGER NOT NULL, -- PK, references link_type.id
#     attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
#     min                 SMALLINT,
#     max                 SMALLINT,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE editor_collection
# (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     name                VARCHAR NOT NULL,
#     public              BOOLEAN NOT NULL DEFAULT FALSE
# );
# 
# CREATE TABLE editor_collection_release
# (
#     collection          INTEGER NOT NULL, -- PK, references editor_collection.id
#     release             INTEGER NOT NULL -- PK, references release.id
# );
# 
# CREATE TABLE editor_watch_preferences
# (
#     editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
#     notify_via_email BOOLEAN NOT NULL DEFAULT TRUE,
#     notification_timeframe INTERVAL NOT NULL DEFAULT '1 week',
#     last_checked TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
# );
# 
# CREATE TABLE editor_watch_artist
# (
#     artist INTEGER NOT NULL, -- PK, references artist.id CASCADE
#     editor INTEGER NOT NULL  -- PK, references editor.id CASCADE
# );
# 
# CREATE TABLE editor_watch_release_group_type
# (
#     editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
#     release_group_type INTEGER NOT NULL -- PK, references release_group_type.id
# );
# 
# CREATE TABLE editor_watch_release_status
# (
#     editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
#     release_status INTEGER NOT NULL -- PK, references release_status.id
# );
# 
# CREATE TABLE medium
# (
#     id                  SERIAL,
#     tracklist           INTEGER NOT NULL, -- references tracklist.id
#     release             INTEGER NOT NULL, -- references release.id
#     position            INTEGER NOT NULL,
#     format              INTEGER, -- references medium_format.id
#     name                VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE medium_cdtoc
# (
#     id                  SERIAL,
#     medium              INTEGER NOT NULL, -- references medium.id
#     cdtoc               INTEGER NOT NULL, -- references cdtoc.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE medium_format
# (
#     id                  SERIAL,
#     name                VARCHAR(100) NOT NULL,
#     parent              INTEGER, -- references medium_format.id
#     child_order         INTEGER NOT NULL DEFAULT 0,
#     year                SMALLINT,
#     has_discids         BOOLEAN NOT NULL DEFAULT FALSE
# );
# 
# CREATE TABLE puid
# (
#     id                  SERIAL,
#     puid                CHAR(36) NOT NULL,
#     version             INTEGER NOT NULL -- references clientversion.id
# );
# 
# CREATE TABLE replication_control
# (
#     id                              SERIAL,
#     current_schema_sequence         INTEGER NOT NULL,
#     current_replication_sequence    INTEGER,
#     last_replication_date           TIMESTAMP WITH TIME ZONE
# );
# 
# CREATE TABLE recording (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references track_name.id
#     artist_credit       INTEGER NOT NULL, -- references artist_credit.id
#     length              INTEGER CHECK (length IS NULL OR length > 0),
#     comment             VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE recording_rating_raw
# (
#     recording           INTEGER NOT NULL, -- PK, references recording.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
# );
# 
# CREATE TABLE recording_tag_raw
# (
#     recording           INTEGER NOT NULL, -- PK, references recording.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     tag                 INTEGER NOT NULL -- PK, references tag.id
# );
# 
# CREATE TABLE recording_annotation
# (
#     recording           INTEGER NOT NULL, -- PK, references recording.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );
# 
# CREATE TABLE recording_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references recording.id CASCADE
#     rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
#     rating_count        INTEGER
# );
# 
# CREATE TABLE recording_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references recording.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE recording_puid
# (
#     id                  SERIAL,
#     puid                INTEGER NOT NULL, -- references puid.id
#     recording           INTEGER NOT NULL, -- references recording.id
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE recording_tag
# (
#     recording           INTEGER NOT NULL, -- PK, references recording.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references release_name.id
#     artist_credit       INTEGER NOT NULL, -- references artist_credit.id
#     release_group       INTEGER NOT NULL, -- references release_group.id
#     status              INTEGER, -- references release_status.id
#     packaging           INTEGER, -- references release_packaging.id
#     country             INTEGER, -- references country.id
#     language            INTEGER, -- references language.id
#     script              INTEGER, -- references script.id
#     date_year           SMALLINT,
#     date_month          SMALLINT,
#     date_day            SMALLINT,
#     barcode             VARCHAR(255),
#     comment             VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     quality             SMALLINT NOT NULL DEFAULT -1,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_raw
# (
#     id                  SERIAL,
#     title               VARCHAR(255) NOT NULL,
#     artist              VARCHAR(255),
#     added               TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     last_modified        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     lookup_count         INTEGER DEFAULT 0,
#     modify_count         INTEGER DEFAULT 0,
#     source              INTEGER DEFAULT 0,
#     barcode             VARCHAR(255),
#     comment             VARCHAR(255)
# );
# 
# CREATE TABLE release_tag_raw
# (
#     release             INTEGER NOT NULL, -- PK, references release.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     tag                 INTEGER NOT NULL -- PK, references tag.id
# );
# 
# CREATE TABLE release_annotation
# (
#     release             INTEGER NOT NULL, -- PK, references release.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );
# 
# CREATE TABLE release_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references release.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references release.id CASCADE
#     date_added          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     info_url            VARCHAR(255),
#     amazon_asin         VARCHAR(10),
#     amazon_store        VARCHAR(20)
# );
# 
# CREATE TABLE release_coverart
# (
#     id                  INTEGER NOT NULL, -- PK, references release.id CASCADE
#     last_updated        TIMESTAMP WITH TIME ZONE,
#     cover_art_url       VARCHAR(255)
# );
# 
# CREATE TABLE release_label (
#     id                  SERIAL,
#     release             INTEGER NOT NULL, -- references release.id
#     label               INTEGER, -- references label.id
#     catalog_number      VARCHAR(255),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_packaging
# (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );
# 
# CREATE TABLE release_status
# (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );
# 
# CREATE TABLE release_tag
# (
#     release             INTEGER NOT NULL, -- PK, references release.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_group (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references release_name.id
#     artist_credit       INTEGER NOT NULL, -- references artist_credit.id
#     type                INTEGER, -- references release_group_type.id
#     comment             VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_group_rating_raw
# (
#     release_group       INTEGER NOT NULL, -- PK, references release_group.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
# );
# 
# CREATE TABLE release_group_tag_raw
# (
#     release_group       INTEGER NOT NULL, -- PK, references release_group.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     tag                 INTEGER NOT NULL -- PK, references tag.id
# );
# 
# CREATE TABLE release_group_annotation
# (
#     release_group       INTEGER NOT NULL, -- PK, references release_group.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );
# 
# CREATE TABLE release_group_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references release_group.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_group_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references release_group.id CASCADE
#     release_count       INTEGER NOT NULL DEFAULT 0,
#     first_release_date_year   SMALLINT,
#     first_release_date_month  SMALLINT,
#     first_release_date_day    SMALLINT,
#     rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
#     rating_count        INTEGER
# );
# 
# CREATE TABLE release_group_tag
# (
#     release_group       INTEGER NOT NULL, -- PK, references release_group.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE release_group_type (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );
# 
# CREATE TABLE release_name (
#     id                  SERIAL,
#     name                VARCHAR NOT NULL
# );
# 
# CREATE TABLE script
# (
#     id                  SERIAL,
#     iso_code            CHAR(4) NOT NULL, -- ISO 15924
#     iso_number          CHAR(3) NOT NULL, -- ISO 15924
#     name                VARCHAR(100) NOT NULL,
#     frequency           INTEGER NOT NULL DEFAULT 0
# );
# 
# CREATE TABLE script_language
# (
#     id                  SERIAL,
#     script              INTEGER NOT NULL, -- references script.id
#     language            INTEGER NOT NULL, -- references language.id
#     frequency           INTEGER NOT NULL DEFAULT 0
# );
# 
# CREATE TABLE statistic
# (
#     id                  SERIAL,
#     name                VARCHAR(100) NOT NULL,
#     value               INTEGER NOT NULL,
#     date_collected      date NOT NULL DEFAULT NOW()
# );
# 
# CREATE TABLE tag
# (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL,
#     ref_count           INTEGER NOT NULL DEFAULT 0
# );
# 
# CREATE TABLE tag_relation
# (
#     tag1                INTEGER NOT NULL, -- PK, references tag.id
#     tag2                INTEGER NOT NULL, -- PK, references tag.id
#     weight              INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     CHECK (tag1 < tag2)
# );
# 
# CREATE TABLE track
# (
#     id                  SERIAL,
#     recording           INTEGER NOT NULL, -- references recording.id
#     tracklist           INTEGER NOT NULL, -- references tracklist.id
#     position            INTEGER NOT NULL,
#     name                INTEGER NOT NULL, -- references track_name.id
#     artist_credit       INTEGER NOT NULL, -- references artist_credit.id
#     length              INTEGER CHECK (length IS NULL OR length > 0),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE track_raw
# (
#     id                  SERIAL,
#     release             INTEGER NOT NULL,   -- references release_raw.id
#     title               VARCHAR(255) NOT NULL,
#     artist              VARCHAR(255),   -- For VA albums, otherwise empty
#     sequence            INTEGER NOT NULL
# );
# 
# CREATE TABLE track_name (
#     id                  SERIAL,
#     name                VARCHAR NOT NULL
# );
# 
# CREATE TABLE tracklist
# (
#     id                  SERIAL,
#     track_count         INTEGER NOT NULL DEFAULT 0,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE tracklist_index
# (
#     tracklist           INTEGER, -- PK
#     toc                 CUBE
# );
# 
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
# 
# CREATE TABLE url_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references url.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE vote
# (
#     id                  SERIAL,
#     editor              INTEGER NOT NULL, -- references editor.id
#     edit                INTEGER NOT NULL, -- references edit.id
#     vote                SMALLINT NOT NULL,
#     vote_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
#     superseded          BOOLEAN NOT NULL DEFAULT FALSE
# );
# 
# CREATE TABLE work (
#     id                  SERIAL,
#     gid                 UUID NOT NULL,
#     name                INTEGER NOT NULL, -- references work_name.id
#     artist_credit       INTEGER, -- no longer in use
#     type                INTEGER, -- references work_type.id
#     iswc                CHAR(15) CHECK (iswc IS NULL OR iswc ~ E'^T-?\\d{3}\.?\\d{3}\.?\\d{3}[-.]?\\d$'),
#     comment             VARCHAR(255),
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE work_rating_raw
# (
#     work                INTEGER NOT NULL, -- PK, references work.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
# );
# 
# CREATE TABLE work_tag_raw
# (
#     work                INTEGER NOT NULL, -- PK, references work.id
#     editor              INTEGER NOT NULL, -- PK, references editor.id
#     tag                 INTEGER NOT NULL -- PK, references tag.id
# );
# 
# 
# CREATE TABLE work_alias
# (
#     id                  SERIAL,
#     work                INTEGER NOT NULL, -- references work.id
#     name                INTEGER NOT NULL, -- references work_name.id
#     locale              TEXT,
#     edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE work_annotation
# (
#     work                INTEGER NOT NULL, -- PK, references work.id
#     annotation          INTEGER NOT NULL -- PK, references annotation.id
# );
# 
# CREATE TABLE work_gid_redirect
# (
#     gid                 UUID NOT NULL, -- PK
#     new_id              INTEGER NOT NULL, -- references work.id
#     created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE work_meta
# (
#     id                  INTEGER NOT NULL, -- PK, references work.id CASCADE
#     rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
#     rating_count        INTEGER
# );
# 
# CREATE TABLE work_name (
#     id                  SERIAL,
#     name                VARCHAR NOT NULL
# );
# 
# CREATE TABLE work_tag
# (
#     work                INTEGER NOT NULL, -- PK, references work.id
#     tag                 INTEGER NOT NULL, -- PK, references tag.id
#     count               INTEGER NOT NULL,
#     last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
# );
# 
# CREATE TABLE work_type (
#     id                  SERIAL,
#     name                VARCHAR(255) NOT NULL
# );
# 
