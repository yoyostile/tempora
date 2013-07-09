require 'spec_helper'

describe Tempora::Logging::Log do
  let(:artist) { FactoryGirl.create(:artist) }
  let(:user) { FactoryGirl.create(:artist) }
  let(:following) { FactoryGirl.create(:following) }

  it "should create a log" do
    artist.is_loggable?.should be_true
    user.log artist
  end
end
