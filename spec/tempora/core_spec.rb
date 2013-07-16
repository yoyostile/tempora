require 'spec_helper'

describe Tempora::Logging::Core do

  it 'should generate events' do
    users = []
    artists = []
    events = ['Show', 'Follow', 'Biography::Show']
    10.times do |i|
      users[i] = FactoryGirl.create(:user)
      artists[i] = FactoryGirl.create(:artist)
    end

    100.times do |i|
      users[rand(0..9)].log artists[rand(0..9)], event: "#{events[rand(0..2)]}"
    end

    Tempora::Logging::Core.process_weights
    Tempora::Logging::Event.count.should == 3
  end

  it 'should generate weights in events' do
    user = FactoryGirl.create(:user)
    artist = FactoryGirl.create(:artist)

    user.log artist, event: "Follow"

    Tempora::Logging::Core.process_weights
    Tempora::Logging::Event.find_by_name("Artist::Follow").weight.should == 1.0

    10.times do |i|
      user.log artist, event: "Show"
    end
    Tempora::Logging::Core.process_weights
    Tempora::Logging::Event.order("weight DESC").first.name.should == "Artist::Follow"
  end

  it 'should recognize associations' do
    user = FactoryGirl.create(:user)
    artist = FactoryGirl.create(:artist)
    Following.create artist: artist, user: user

    User.loggable_assoc.count.should > 0
    Artist.logger_assoc.count.should > 0

    artist.assoc_with(user).should be_true
    user.assoc_with(artist).should be_true
  end

  it 'should recognize no associations' do
    user = FactoryGirl.create(:user)
    artist = FactoryGirl.create(:artist)
    user1 = FactoryGirl.create(:user)
    artist.assoc_with(user1).should be_false
    user1.assoc_with(artist).should be_false
    user.assoc_with(user1).should be_false
  end

  it 'should raise an exception without weights' do
    user = FactoryGirl.create(:user)
    artist = FactoryGirl.create(:artist)
    artist2 = FactoryGirl.create(:artist)
    user.log artist, event: "Show"
    user.log artist, event: "Show"
    user.log artist2, event: "Follow"
    expect{ Tempora::Logging::Core.generate_ratings(User, Artist) }.to raise_error
  end

  it 'should generate ratings' do
    user = FactoryGirl.create(:user)
    artist = FactoryGirl.create(:artist)
    artist2 = FactoryGirl.create(:artist)
    user.log artist, event: "Show"
    user.log artist, event: "Show"
    user.log artist2, event: "Follow"
    Tempora::Logging::Core.process_weights
    Tempora::Logging::Core.generate_ratings User, Artist
  end
end
