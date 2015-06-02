require 'rubygems'
require 'sinatra'
require 'pry'

# set :sessions, true

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'wishbone' 

helpers do

  def calculate_total(cards)
    values = cards.map{ |card| card[1] }

    total = 0
    values.each do |value|
      if value == "Ace"
        total += 11
      else
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    values.select{ |value| value == "Ace" }.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def display_card(card)
    suit = card[0].downcase
    value = card[1].downcase

    "<img src='/images/cards/#{value}_of_#{suit}.png' class='card_image'>"
  end

  def winner!(msg)
    @play_again = true
    @show_buttons = false
    @success = "<strong>#{session[:player_name].capitalize} wins!</strong> #{msg}"
  end

  def loser!(msg)
    @play_again = true
    @show_buttons = false
    @error = "<strong>#{session[:player_name].capitalize} loses.</strong> #{msg}"
  end

  def tie!(msg)
    @play_again = true
    @show_buttons = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end

end

before do
  @show_buttons = true
end

get '/casino' do
  session.clear
  erb :casino #, :layout => :layout
end

get '/blackjack' do 
  @show_buttons = true
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player, :layout => :new_player
end

post '/new_player' do

  if params[:player_name].empty?
    @error = "Name is required"
    halt erb :new_player, :layout => :new_player
  end
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:player_name]
  # create a deck and put it in session
  suits = ['Hearts','Diamonds','Clubs','Spades']
  values = ['2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace']
  session[:deck] = suits.product(values).shuffle!
  
  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  session[:player_cards].each do |card|
    display_card(card)
  end
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    winner!("#{session[:player_name].capitalize} hit blackjack.")
  elsif player_total > 21
    loser!("Bust! #{session[:player_name].capitalize} went over 21.")
  end
  erb :game # reload the template
end

post '/game/player/stay' do
  @success = "#{session[:player_name].capitalize} chose to stay."
  @show_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_buttons = false
  @show_total = false
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == 21
    loser!("The dealer hit blackjack.")
    @show_total = true
  elsif dealer_total > 21
    winner!("Bust! The dealer went over 21.")
    @show_total = true
  elsif dealer_total >= 17
    # dealer stays
    redirect '/game/compare'
  else
    # dealer hits
    @dealer_button = true
  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_total = true
  @show_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:player_name].capitalize} stayed at #{player_total}, and the dealer stayed at #{dealer_total}")
  elsif player_total > dealer_total
    winner!("#{session[:player_name].capitalize} stayed at #{player_total}, and the dealer stayed at #{dealer_total}")
  else
    tie!("Both #{session[:player_name].capitalize} and the dealer stayed at #{player_total}.")
  end
  erb :game

end

get '/game_over' do
  erb :game_over
end
