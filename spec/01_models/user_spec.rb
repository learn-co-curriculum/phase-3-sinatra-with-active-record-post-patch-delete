describe User do
  let(:user) { User.first }

  before do
    user = User.create(name: "Liza")
    game = Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
    Review.create(score: 8, comment: "A classic", game_id: game.id, user_id: user.id)
  end
  
  it "has the correct columns in the games table" do
    expect(user).to have_attributes(name: "Liza")
  end

  it "knows about its associated reviews" do
    expect(user.reviews.count).to eq(1)
  end

  it "knows about its associated games" do
    expect(user.games.count).to eq(1)
  end
  
end
