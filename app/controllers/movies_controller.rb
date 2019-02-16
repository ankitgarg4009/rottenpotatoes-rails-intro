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
    
    # Setting session hashes and opraring with them for simplicity
    session[:ratings] = params[:ratings] if params[:ratings]
    session[:sort_order] = params[:sort_order] if params[:sort_order]

    # redirect to RESTful path if session contains all the information
    if (!params[:ratings] && session[:ratings]) || (!params[:sort_order] && session[:sort_order])
      flash.keep
      redirect_to movies_path(ratings: session[:ratings], sort_order: session[:sort_order])
    end
    
    # Form DB query according to the passed sorting and filtering
    # All four possible combinations generate diffrent DB query
    if (session[:sort_order] && !session[:ratings])
      if session[:sort_order] == 'byTitle'
        @movies = Movie.order(:title)
      elsif session[:sort_order] == 'byReleaseDate'
        @movies = Movie.order(:release_date)
      end
    elsif (!session[:sort_order] && session[:ratings])
      @movies = Movie.where({rating: session[:ratings].keys})
    elsif (session[:sort_order] && session[:ratings])
      if session[:sort_order] == 'byTitle'
        @movies = Movie.where({rating: session[:ratings].keys}).order(:title)
      elsif session[:sort_order] == 'byReleaseDate'
        @movies = Movie.where({rating: session[:ratings].keys}).order(:release_date)
      end
    else
      @movies = Movie.all
    end
    
    @all_ratings = Movie.all_ratings
    if session[:ratings]
      @selected_ratings = session[:ratings]
    else
      @selected_ratings = {}
      # For all check boxes to appear checked
      @all_ratings.each do |x|
        @selected_ratings[x] = 1
      end
    end
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