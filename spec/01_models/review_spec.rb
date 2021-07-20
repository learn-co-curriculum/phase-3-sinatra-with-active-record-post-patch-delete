describe Review do
  let(:review) { Review.first }

  before do
    game = Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
    user = User.create(name: "Liza")
    Review.create(score: 8, comment: "A classic", game_id: game.id, user_id: user.id)
  end
  
  it "has the correct columns in the reviews table" do
    expect(review).to have_attributes(score: 8, comment: "A classic", game_id: Game.first.id, user_id: User.first.id)
  end

  it "knows about its associated game" do
    game = Game.find(review.game_id)

    expect(review.game).to eq(game)
  end

  it "knows about its associated user" do
    user = User.find(review.user_id)

    expect(review.user).to eq(user)
  end

  it "can create an associated game using the game instance" do
    game = Game.first
    review = Review.create(score: 10, comment: "10 stars", game: game)
    
    expect(review.game).to eq(game)
  end

  it "can create an associated game with the #create_game method" do
    expect do
      review = Review.create(score: 8, comment: "wow, what a game")
      review.create_game(title: "My favorite game")
      review.save
    end.to change(Game, :count).by(1)
  end
 
end
