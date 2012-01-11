$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'brainzmapper'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

# Set up BrainzMapper to use local Postgres server
BrainzMapper.setup(:default,
    'postgres://musicbrainz_rw@localhost/musicbrainz_db?search_path=musicbrainz'
)
