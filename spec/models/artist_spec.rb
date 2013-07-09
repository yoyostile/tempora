require 'spec_helper'

describe Artist do
  let(:artist) { FactoryGirl.create(:artist) }

  it "should be loggable" do
    artist.is_loggable?.should be_true
  end

  it "should have an average weighting" do
    user1 = FactoryGirl.create :user
    user2 = FactoryGirl.create :user
    artist = FactoryGirl.create :artist
    user1.log artist, weight: 10
    user2.log artist, weight: 5
    avg = artist.average_weight
    avg.should == (15.0/2.0)
  end

end
