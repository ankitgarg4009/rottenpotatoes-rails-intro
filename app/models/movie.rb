class Movie < ActiveRecord::Base
    def self.all_ratings
        # Get all distict ratings from the existing data
        all_ratings = Movie.pluck('DISTINCT rating')
        return all_ratings
    end
end