require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create(:user) }
  it "should respond to log" do
    user.should_not be_nil
    user.respond_to?(:log).should be_true
  end

  it "should be logger" do
    user.is_logger?.should be_true
  end

  it "class should be logger" do
    User.is_logger?.should be_true
  end

  it "should have an artist" do
    artist = FactoryGirl.create :artist
    user.followings.create(artist: artist, user: user)
    user.followings.count.should > 0
    user.followings.count.should == 1
  end

  it "should have an list with all associated loggables" do
    artist = FactoryGirl.create :artist
    Following.create artist: artist, user: user
    user.association_list(Artist).length.should == 1
  end

end
