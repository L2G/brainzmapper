# model/release__spec.rb
require 'spec_helper'

describe Release do

    it_behaves_like "a DataMapper model"

    it "has meta-information available as ReleaseMeta" do
        meta = described_class.first.meta
        meta.should be_a_kind_of ReleaseMeta
    end

end
