require 'spec_helper'

describe Tempora::Recommender::Core do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @artist = FactoryGirl.create(:artist)
    @artist2 = FactoryGirl.create(:artist)
    @artist3 = FactoryGirl.create(:artist)
    @artist4 = FactoryGirl.create(:artist)
  end


  it "should should know items with ratings from both loggers" do
    @user.log @artist, event: "Show"
    @user.log @artist2, event: "Follow"
    @user2.log @artist2, event: "Biography"
    Tempora::Logging::Core.process_weights
    ratings = Tempora::Logging::Core.generate_ratings User, Artist
    Tempora::Logging::Core.persist_hash ratings
    Tempora::Recommender::Core.diff_items(@user, @user2).length.should == 1
  end

  it "should generate similarity between users" do
    # generate_stuff
    u1 = { i1: 4, i3: 5, i4: 5 }
    u5 = { i1: 2, i2: 1, i3: 3, i4: 5 }
    ratings = { "#{Tempora::KeyMapper.logger_key(@user)}" => u1, "#{Tempora::KeyMapper.logger_key(@user2)}" => u5 }
    Tempora::Logging::Core.persist_hash ratings
    sim = Tempora::Recommender::Core.similarity(@user, @user2)
    sim.should be_within(0.01).of(0.75)
    # from http://www.hindawi.com/journals/aai/2009/421425/
  end

  it "should give a very low similarity" do
    u1 = { i1: 5, i2: 0 }
    u2 = { i1: 0, i2: 5 }
    ratings = { "#{Tempora::KeyMapper.logger_key(@user)}" => u1, "#{Tempora::KeyMapper.logger_key(@user2)}" => u2 }
    Tempora::Logging::Core.persist_hash ratings
    Tempora::Recommender::Core.similarity(@user, @user2).should be_within(0.01).of(-1)
  end

  it "should give a very high similarity" do
    u1 = { i1: 5, i2: 0 }
    u2 = { i1: 5, i2: 0 }
    ratings = { "#{Tempora::KeyMapper.logger_key(@user)}" => u1, "#{Tempora::KeyMapper.logger_key(@user2)}" => u2 }
    Tempora::Logging::Core.persist_hash ratings
    Tempora::Recommender::Core.similarity(@user, @user2).should be_within(0.01).of(1)
  end

  it "should return if user already has a rating for an item" do
    generate_stuff
    Tempora::Recommender::Core.prediction(@user, @artist).should be_nil
  end

  it "should generate nearest neighbors for user" do
    generate_table
    Tempora::Recommender::Core.generate_nearest_neighbors_for @user
    Tempora.redis.hgetall(Tempora::KeyMapper.nearest_neighbors_key(@user)).length.should == 4
  end

  it "should generate a prediction for an unrated item" do
    generate_stuff
    pred = Tempora::Recommender::Core.prediction @user, @artist4
    pred.should > 4
  end

  it "should give a list with recommendations for an user" do
    generate_stuff
    list = Tempora::Recommender::Core.recommendation_list @user
    byebug
    list.length.should > 0
  end

private

  def generate_stuff
    @user.log @artist, event: "Show"
    @user.log @artist3, event: "Show"
    @user.log @artist3, event: "Show"
    @user.log @artist3, event: "Show"
    @user.log @artist2, event: "Show"
    @user.log @artist2, event: "Follow"
    Following.create artist: @artist2, user: @user
    Following.create artist: @artist4, user: @user2
    @user2.log @artist2, event: "Biography"
    @user2.log @artist3, event: "Show"
    @user2.log @artist, event: "Follow"
    @user2.log @artist, event: "Show"
    Following.create artist: @artist, user: @user2
    @user2.log @artist, event: "Biography"
    Tempora::Logging::Core.process User, Artist
  end

  def generate_table
    @user3 = FactoryGirl.create(:user)
    @user4 = FactoryGirl.create(:user)
    @user5 = FactoryGirl.create(:user)
    u1 = { i1: 4, i3: 5, i4: 5 }
    u2 = { i1: 4, i2: 2, i3: 1 }
    u3 = { i1: 3, i3: 2, i4: 4 }
    u4 = { i1: 4, i2: 4 }
    u5 = { i1: 2, i2: 1, i3: 3, i4: 5 }
    ratings = { "#{Tempora::KeyMapper.logger_key(@user)}" => u1,
                "#{Tempora::KeyMapper.logger_key(@user2)}" => u2,
                "#{Tempora::KeyMapper.logger_key(@user3)}" => u3,
                "#{Tempora::KeyMapper.logger_key(@user4)}" => u4,
                "#{Tempora::KeyMapper.logger_key(@user5)}" => u5 }
    Tempora::Logging::Core.persist_hash ratings
  end
end