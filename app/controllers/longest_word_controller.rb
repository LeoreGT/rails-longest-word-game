class LongestWordController < ApplicationController
  def game
    session[:grid] = generate_grid
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    start_time = params[:start_time].to_time
    @time_taken = end_time - start_time
    answer = params[:answer]

    if included?(answer) && @translation = get_translation(answer)
      @score = compute_score(answer, @time_taken)
    end
  end

  private

  def included?(answer)
  the_grid = session[:grid].clone
   answer.chars.each do |letter|
     the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
   end
   if session[:grid].size == answer.size + the_grid.size
     return true
   else
     @error = "The word is not in the grid"
     return false
   end
  end

  def generate_grid
    alphabet = ('a'..'z').to_a
    grid = []
    9.times { grid << alphabet.sample }
    grid
  end

  def compute_score(answer, time_taken)
    score = (time_taken > 60.0) ? 0 : answer.size * (1.0 - time_taken / 60.0)
    score.round(2)
  end

  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read)
    if json["Error"]
      @error = 'The word does not exist'
      return nil
    else
      return json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
    end
  end
end
