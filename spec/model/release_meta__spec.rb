# model/release_meta__spec.rb
require 'spec_helper'

describe ReleaseMeta do

    it_behaves_like "a DataMapper model"

   # it "always links to a Release" do
   #     r = ReleaseMeta.all(:id.not => (Release.all(:fields => [:id])))
   #     r.count.should be 0
   # end
end
