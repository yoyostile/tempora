require 'spec_helper'

describe Artist do
  let(:artist) { FactoryGirl.create(:artist) }

  it "should be loggable" do
    artist.is_loggable?.should be_true
  end

end
