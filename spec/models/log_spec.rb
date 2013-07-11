require 'spec_helper'

describe Tempora::Logging::Log do
  let(:artist) { FactoryGirl.create(:artist) }
  let(:user) { FactoryGirl.create(:user) }
  let(:following) { FactoryGirl.create(:following) }

  it "should create a log" do
    artist.is_loggable?.should be_true
    user.log artist
    Tempora::Logging::Log.count.should == 1
  end

  it "should have a logger and a loggable" do
    user.log artist
    user.logs.count.should > 0
    user.logs.where('loggable_id == ?', artist.id).count.should == 1
    user.logs.first.loggable.should == artist
  end

  it "should have an event name" do
    user.log  artist,
              event: 'View' if user
    user.logs.first.event.should_not == 'View'
    user.logs.first.event.should == "#{artist.class.to_s}::View"
  end
end
