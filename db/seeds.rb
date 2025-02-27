# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'open-uri'
require 'json'

puts "Cleaning database..."
Bookmark.destroy_all
Movie.destroy_all
List.destroy_all

puts "Creating movies from TMDB API..."

# API endpoint for top rated movies using Le Wagon's proxy
url = "https://tmdb.lewagon.com/movie/top_rated"

# Fetch movies data
movies_serialized = URI.open(url).read
movies = JSON.parse(movies_serialized)["results"]

# Create movies from API data
movies.first(20).each do |movie_data|
  # Construct the proper poster URL
  poster_url = "https://image.tmdb.org/t/p/original#{movie_data['poster_path']}"

  # Create the movie in our database
  movie = Movie.create!(
    title: movie_data["title"],
    overview: movie_data["overview"],
    poster_url: poster_url,
    rating: movie_data["vote_average"]
  )
  puts "Created #{movie.title}"
end

# Create a few sample lists
puts "Creating sample lists..."
lists = [
  { name: "Drama" },
  { name: "All Time Favorites" },
  { name: "Girl Power" },
  { name: "Must Watch" }
]

created_lists = lists.map do |list_data|
  list = List.create!(list_data)
  puts "Created list: #{list.name}"
  list
end

# Create some sample bookmarks
puts "Creating sample bookmarks..."
movies = Movie.all.to_a
lists = List.all.to_a

# Add a few sample bookmarks
sample_comments = [
  "Recommended by my friend",
  "Director's masterpiece",
  "Watched twice, revisited in 2022",
  "Stunning visuals",
  "2023 release",
  "Based on Stephen King's 1986 novel",
  "Mind-blowing plot twist"
]

# Create 15 random bookmarks
15.times do
  movie = movies.sample
  list = lists.sample

  # Skip if this movie is already bookmarked in this list
  next if Bookmark.exists?(movie: movie, list: list)

  Bookmark.create!(
    movie: movie,
    list: list,
    comment: sample_comments.sample
  )
  puts "Added #{movie.title} to #{list.name} list"
end

puts "Seeding completed! Created #{Movie.count} movies, #{List.count} lists, and #{Bookmark.count} bookmarks."

# Optional: Using the faker gem for more creative movies
# Uncomment these lines if you want to add fake movies along with real ones
begin
  require 'faker'

  10.times do
    movie = Movie.create!(
      title: Faker::Movie.unique.title,
      overview: Faker::Lorem.paragraph(sentence_count: 5),
      poster_url: "https://source.unsplash.com/random/300x450/?movie,poster",
      rating: rand(1.0..10.0).round(1)
    )
    puts "Created fake movie: #{movie.title}"
  end
end
