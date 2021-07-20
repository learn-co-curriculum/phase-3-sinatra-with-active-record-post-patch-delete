describe ApplicationController do
  let(:game) { Game.first }
  let(:review) { Review.first }
  let(:user) { User.first }

  before do
    game = Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
    user1 = User.create(name: "Liza")
    user2 = User.create(name: "Duane")
    Review.create(score: 8, comment: "A classic", game_id: game.id, user_id: user1.id)
    Review.create(score: 10, comment: "Wow what a game", game_id: game.id, user_id: user2.id)
  end

  describe 'GET /games' do
    it 'sets the Content-Type header in the response to application/json' do
      get '/games'

      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'returns an array of JSON objects' do
      get '/games'
      expect(last_response.body).to include_json([
        { title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60 }
      ])
    end
  end

  describe 'GET /games/:id' do
    it 'sets the Content-Type header in the response to application/json' do
      get "/games/#{game.id}"

      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'returns a single game as JSON with its reviews and users nested' do
      get "/games/#{game.id}"

      expect(last_response.body).to include_json({
        title: "Mario Kart", genre: "Racing", price: 60, reviews: [
          { score: 8, comment: "A classic", user: { name: "Liza" } },
          { score: 10, comment: "Wow what a game", user: { name: "Duane" } }
        ]
      })
    end
  end

  describe 'DELETE /reviews/:id' do
    it 'deletes the review from the database' do
      expect { delete "/reviews/#{review.id}" }.to change(Review, :count).from(2).to(1)
    end

    it 'returns the deleted review as JSON' do
      delete "/reviews/#{review.id}"
      
      expect(last_response.body).to include_json(score: 8, comment: "A classic")
    end
  end

  describe 'POST /reviews' do
    let(:params) do 
      { score: 9, comment: "Nice game!", game_id: game.id, user_id: user.id } 
    end

    it 'creates a new review in the database' do
      expect { post "/reviews", params }.to change(Review, :count).from(2).to(3)
    end

    it 'returns the newly created review as JSON' do
      post "/reviews", params
      
      expect(last_response.body).to include_json(score: 9, comment: "Nice game!", game_id: game.id, user_id: user.id)
    end
  end

  describe 'PATCH /reviews/:id' do
    let(:params) do 
      { score: 1, comment: "Changed my mind" } 
    end

    it 'updates a review in the database' do
      expect do
        patch "/reviews/#{review.id}", params
        
        # Active Record caches attributes, so we must reload them to see what has changed
        review.reload
      end.to change(review, :score).from(8).to(1)
    end

    it 'returns the updated review as JSON' do
      patch "/reviews/#{review.id}", params
      
      expect(last_response.body).to include_json(score: 1, comment: "Changed my mind", game_id: game.id, user_id: user.id)
    end
  end

end
