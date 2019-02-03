class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @date_class = ''
    @title_class = ''
    @all_ratings = Movie.ratings

    @selected_ratings = if params.key?("ratings") and params["ratings"].keys.length.positive?
                          params["ratings"].keys
                        elsif session.key?("ratings") and session["ratings"].keys.length.positive?
                          session["ratings"].keys
                        else
                          @all_ratings
                        end
    session['ratings'] = Hash[@selected_ratings.map {|r| [r, r]}]

    # @selected_ratings = params.key?("ratings") ? params["ratings"].keys : @all_ratings

    if (params.key?('title') || session.key?('title')) && !(params.key?('date'))
      @order = 'title asc'
      @title_class = 'hilite'
      session.delete(:date)
      session[:title] = params['title']
    elsif params.key?('date') || session.key?('date')
      @order = 'release_date asc'
      @date_class = 'hilite'
      session.delete(:title)
      session[:date] = params['date']
    end

    if params[:title] != session[:title] || params[:ratings] != session[:ratings] || params[:date] != session[:date]
      if session.key?('title')
        redirect_to :title => 'asc', :ratings => session['ratings']
      elsif session.key?('date')
        redirect_to :date => 'asc', :ratings => session['ratings']
      else
        redirect_to :ratings => session['ratings']
      end
      return
    end
    @movies = Movie.where(rating: @selected_ratings).order(@order)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
