require 'spec_helper'

describe "Evaluation" do

  before(:all) do
    file = File.open("spec/tempora/evaluation/u.data")
    meta = File.open("spec/tempora/evaluation/u.item")
    meta_hash = {}
    meta.each_line do |line|
      p line
      reg = line.match(/^(?<id>\d+)\|(?<name>[\w\s()]+)/)
      meta_hash[reg[:id]] = reg[:name]
    end
    i = 1
    gl_ratings = {}
    file.each_line do |line|
      line = line.split /[\r\s]+/
      user = User.find_or_create_by_id line[0] #if i == 1
      artist = Artist.find_or_create_by_id line[1]
      artist.update_attributes(name: meta_hash["#{artist.id}"])
      user_key = Tempora::KeyMapper.logger_key user
      gl_ratings[user_key] = {} unless gl_ratings[user_key] && gl_ratings[user_key].empty?
      gl_ratings[user_key].merge!({ "#{artist.class}::#{line[1]}" => line[2] })
      p i
      i += 1
      # break if i == 10000
    end
    Tempora::Logging::Core.persist_hash gl_ratings
  end

  it "should print find nearest neighbors", skip_before: true do
    user = User.first
    nn = Tempora::Recommender::Core.nearest_neighbors_for user
    nn.length.should > 0
  end

  it "should have some recommendations", skip_before: true do
    list = Tempora::Recommender::Core.recommendation_list User.first
    list2 = Tempora::Recommender::Core.recommendation_list User.last
    byebug 
    p list.map(&:name)
    p list2.map(&:name)
    p Tempora::Recommender::Core.similarity User.first, User.last
  end

end