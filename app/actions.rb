helpers do
  def game(category=nil)
    session[:game] ||= Game.new(category)
  end

  def selected_answer
    params[:choice_index].to_i if params[:choice_index]
  end

  def answered_correctly?
    game.current_question.correct?(selected_answer) if selected_answer
  end

  def answer_class(choice)
    return "" unless choice == selected_answer

    if answered_correctly?
      "correct"
    elsif answered_correctly?.nil?
      ""
    else
      "wrong"
    end
  end
end

before '/play' do
  @game = game(params[:category])
end

before '/*' do
  @game = game(params[:category])
end

get '/' do
  session.clear
  erb :index
end

# new route to properly restart the game
get '/new_play' do
  session.clear
  redirect '/'
end

get '/play' do
  erb :"play/index"
end

post '/play' do

  unless params[:next] == 'true'
    game.increment_tries
    @selected_answer = selected_answer
  else
    game.next_question
    redirect '/end' unless game.current_question
  end

  if request.xhr?
    erb :'play/index', layout: false
  else
    erb :'play/index'
  end

end

get '/play/:category' do
  erb :"play/index"
end

get '/end' do
  erb :'end/index'
end