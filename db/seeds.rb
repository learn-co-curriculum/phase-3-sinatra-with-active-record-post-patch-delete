puts "🌱 Seeding data..."

# Make 10 users
10.times do
  User.create(name: Faker::Name.name)
end

# Make 50 games
50.times do
  # create a game with random data
  game = Game.create(
    title: Faker::Game.title,
    genre: Faker::Game.genre,
    platform: Faker::Game.platform,
    price: rand(0..60) # random number between 0 and 60
  )
  
  # create between 1 and 5 reviews for each game
  rand(1..5).times do
    # get a random user for every review
    # https://stackoverflow.com/a/25577054
    user = User.order('RANDOM()').first

    # A review belongs to a game and a user, so we must provide those foreign keys
    Review.create(
      score: rand(1..10),
      comment: Faker::Lorem.sentence,
      game_id: game.id,
      user_id: user.id
    )
  end
end

puts "🌱 Done seeding!"
