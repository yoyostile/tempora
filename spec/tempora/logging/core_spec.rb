require 'spec_helper'

describe Tempora::Logging::Core do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @artist = FactoryGirl.create(:artist)
    @artist2 = FactoryGirl.create(:artist)
  end

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
    @user.log @artist, event: "Follow"

    Tempora::Logging::Core.process_weights
    Tempora::Logging::Event.find_by_name("Artist::Follow").weight.should == 1.0

    10.times do |i|
      @user.log @artist, event: "Show"
    end
    Tempora::Logging::Core.process_weights
    Tempora::Logging::Event.order("weight DESC").first.name.should == "Artist::Follow"
  end

  it 'should recognize associations' do
    Following.create artist: @artist, user: @user

    User.tempora_assoc.count.should > 0
    Artist.tempora_assoc.count.should > 0

    @artist.assoc_with?(@user).should be_true
    @user.assoc_with?(@artist).should be_true
  end

  it 'should recognize no associations' do
    @artist.assoc_with?(@user).should be_false
    @user2.assoc_with?(@artist).should be_false
    @user.assoc_with?(@user2).should be_false
  end

  it 'should raise an exception without weights' do
    @user.log @artist, event: "Show"
    @user.log @artist, event: "Show"
    @user.log @artist2, event: "Follow"
    expect{ Tempora::Logging::Core.generate_ratings(User, Artist) }.to raise_error
  end

  it 'should generate ratings' do
    @user.log @artist, event: "Show"
    @user.log @artist, event: "Show"
    @user.log @artist2, event: "Follow"
    Following.create artist: @artist2, user: @user
    @user2.log @artist2, event: "Biography"
    @user2.log @artist, event: "Show"
    Tempora::Logging::Core.process_weights
    Tempora::Logging::Core.generate_ratings User, Artist
  end

  it 'should recognize association without logs' do
    Following.create artist: @artist, user: @user
    Tempora::Logging::Core.process_weights
    ratings = Tempora::Logging::Core.generate_ratings User, Artist
    ratings[Tempora::KeyMapper.logger_key @user]["#{@artist.class}::#{@artist.id}"].should == Tempora::Logging::Core::MAX_RATING
  end

  it 'should not have a nil similarity' do
    @user.log @artist, event: "Show"
    Tempora::Logging::Core.process_weights
    Tempora::Logging::Core.generate_ratings User, Artist
    sim = Tempora::Recommender::Core.similarity(@user, @user2)
    sim.should_not be_nil
    sim.should == -1
  end

  it 'should persist ratings in redis' do
    @user.log @artist, event: "Show"
    @user.log @artist, event: "Show"
    @user.log @artist2, event: "Follow"
    Following.create artist: @artist2, user: @user
    @user2.log @artist2, event: "Biography"
    @user2.log @artist, event: "Show"
    Tempora::Logging::Core.process_weights
    ratings = Tempora::Logging::Core.generate_ratings User, Artist
    Tempora::Logging::Core.persist_hash ratings
    Tempora.redis.hgetall(Tempora::KeyMapper.logger_key @user).length.should > 0
    Tempora.redis.hgetall(Tempora::KeyMapper.logger_key @user2).length.should > 0
  end
end
