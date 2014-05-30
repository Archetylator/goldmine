# Loads gems
%w{bitswitch pathname benchmark}.each { |x| require x }

# Loads library files
%w{db idb fortune index_reader index_writer version}.each do |x|
  require_relative "gold_mine/#{x}"
end

module GoldMine
  def self.base_dir
    Pathname.new(File.expand_path("../../", __FILE__))
  end

  def self.default_db_path
    base_dir.join("fortunes/fortunes").to_s
  end
end

