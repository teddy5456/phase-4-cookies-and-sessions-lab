require 'rails_helper'

RSpec.describe "Articles", type: :request do
  before do
    @user = User.create(username: 'author')
    @article1 = @user.articles.create(title: 'Article 1', content: "Content 1\nparagraph 1", minutes_to_read: 10)
    @article2 = @user.articles.create(title: 'Article 2', content: "Content 2\nparagraph 1", minutes_to_read: 10)
  end

  describe "GET /articles" do
    it 'returns an array of all articles' do
      get '/articles'

      expect(response.body).to include_json([
        { id: @article2.id, title: 'Article 2', minutes_to_read: 10, author: 'author', preview: 'paragraph 1' },
        { id: @article1.id, title: 'Article 1', minutes_to_read: 10, author: 'author', preview: 'paragraph 1' }
      ])
    end
  end

  describe "GET /articles/:id" do
    context 'with one pageview' do
      it 'returns the correct article' do
        get "/articles/#{@article1.id}"
  
        expect(response.body).to include_json({ 
          id: @article1.id, title: 'Article 1', minutes_to_read: 10, author: 'author', content: "Content 1\nparagraph 1" 
        })
      end

      it 'uses the session to keep track of the number of page views' do
        get "/articles/#{@article1.id}"
  
        expect(session[:page_views]).to eq(1)
      end
    end

    context 'with three pageviews' do
      it 'returns the correct article' do
        3.times do
          get "/articles/#{@article1.id}"
        end

        expect(response.body).to include_json({ 
          "id": @article1.id, "title": 'Article 1', "minutes_to_read": 10, "author": 'author', "content": "Content 1\nparagraph 1" 
        })
      end

      it 'uses the session to keep track of the number of page views' do
        3.times do
          get "/articles/#{@article1.id}"
        end
  
        expect(session[:page_views]).to eq(3)
      end
    end

    context 'with more than three pageviews' do
      it 'returns an error message' do
        4.times do
          get "/articles/#{@article1.id}"
        end

        expect(response.body).to include_json({ 
          error: "Maximum pageview limit reached"
        })
      end

      it 'returns a 401 unauthorized status' do
        4.times do
          get "/articles/#{@article1.id}"
        end

        expect(response).to have_http_status(:unauthorized)
      end

      it 'uses the session to keep track of the number of page views' do
        4.times do
          get "/articles/#{@article1.id}"
        end
  
        expect(session[:page_views]).to eq(4)
      end
    end
  end
end
