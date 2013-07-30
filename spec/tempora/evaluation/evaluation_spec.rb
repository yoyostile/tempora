require 'spec_helper'

describe "Evaluation" do#, broken: true do

  before(:all) do
    file = File.open("spec/tempora/evaluation/jester.csv")
    j = 1
    gl_ratings = {}
    artists = []
    100.times do
      artists.push Artist.create!
    end
    file.each_line do |line|
      line = line.split ','
      user = User.create!
      user_key = Tempora::KeyMapper.logger_key user
      line.each_with_index do |rating, i|
        next if i == 0
        gl_ratings[user_key] = {} unless gl_ratings[user_key] && gl_ratings[user_key].present?
        gl_ratings[user_key].merge!({ "#{artists[i-1].class}::#{artists[i-1].id}" => rating.to_f }) unless rating.to_i == 99
      end
      p j
      j += 1
      break if j > 1000
    end
    Tempora::Logging::Core.persist_hash gl_ratings
  end

  it "should print find nearest neighbors", skip_before: true do
    user = User.first
    nn = Tempora::Recommender::Core.nearest_neighbors_for user
    nn.length.should > 0
  end

  # it "should have some recommendations", skip_before: true do
  #   list = Tempora::Recommender::Core.recommendation_list User.first
  #   list2 = Tempora::Recommender::Core.recommendation_list User.last
  # end

  it "should be able to predict", skip_before: true do
    LOGGER_REG = /(?<logger>\w+)::(?<logger_id>\d+)/
    y = []
    length = User.count
    threads = []
    i = 0
    User.find_in_batches(batch_size: 8) do |user_batch|
      user_batch.each do |user|
        threads << Thread.new {
          ratings = Tempora.redis.hgetall(Tempora::KeyMapper.logger_key(user))
          i += 1 
          p "#{Thread.current} :: [#{i} / #{length}] :: Processing..."
          ratings.each_with_index do |first_rating, j|
            artist = Artist.find(first_rating[0].match(LOGGER_REG)[:logger_id])
            hash = {}
            org_rating = first_rating[1]
            hash[:org] = org_rating
            Tempora.redis.hdel(Tempora::KeyMapper.logger_key(user), first_rating[0])
            new_rating = Tempora::Recommender::Core.prediction(user, artist)
            hash[:new] = new_rating
            y.push hash
            delta = (org_rating.to_f - new_rating.to_f).abs
            # p "#{Thread.current} :: [#{i} / #{length}] :: [#{j} / #{ratings.length}] :: #{org_rating} => #{new_rating} :: Delta: #{delta}"
          end
          ActiveRecord::Base.connection.close
        }
      end
      threads.each{ |t| t.join }
    end
    nominator = 0
    denominator = 0
    y.each_with_index do |v, i|
      nominator += (v[:old].to_f - v[:new].to_f)**2
      denominator += 1
    end
    rmse = Math.sqrt(nominator / denominator)
    p "User.count #{User.count}"
    p "Artist.count #{Artist.count}"
    p "Ratings.count #{y.length}"
    p "RMSE: #{rmse}"
  end

end