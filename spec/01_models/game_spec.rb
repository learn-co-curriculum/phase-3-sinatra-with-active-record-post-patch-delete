describe Game do
  let(:game) { Game.first }

  before do
    game = Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
    user1 = User.create(name: "Liza")
    user2 = User.create(name: "Duane")
    Review.create(score: 8, comment: "A classic", game_id: game.id, user_id: user1.id)
    Review.create(score: 10, comment: "Wow what a game", game_id: game.id, user_id: user2.id)
  end
  
  it "has the correct columns in the games table" do
    expect(game).to have_attributes(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
  end

  it "knows about its associated reviews" do
    expect(game.reviews.count).to eq(2)
  end

  it "knows about its associated users" do
    expect(game.users.count).to eq(2)
  end

  it "can create an associated review with the #create method" do
    expect do
      game.reviews.create(score: 3, comment: "terrible")
    end.to change(Review, :count).by(1)
  end

  it "can create an associated review with the << method" do
    expect do
      game.reviews << Review.new(score: 3, comment: "terrible")
    end.to change(Review, :count).by(1)
  end
  
end
