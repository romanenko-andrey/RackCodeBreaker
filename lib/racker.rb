require_relative 'interactive'
require 'erb'
#require "pry"

class Racker
  def self.call(env)
    new(env).checker.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @@web_game ||= Interactive.new
    @@help_string ||= 'Show'
    @web = @@web_game
  end

  def checker
    case @request.path
      when '/' then render('index.html.erb')

      when '/new_game'
        @web.name = @request.params['name']
        @web.level = @request.params['level'].to_sym
        @web.status = :new_game
        redirect_to '/play_game'

      when '/play_game'
        case @web.status
          when :new_game
            @web.start(@web.level)
            @web.status = :first_step
            render('game.html.erb')
          when :first_step, :playing, :hint
            @web.status = :playing
            render('game.html.erb')
          else
            redirect_to '/'
        end

      when '/show_help'
        @@help_string = @@help_string == 'Show' ? 'Hide' : 'Show'
        redirect_to '/'

      when '/show_hint' 
        @web.show_hint
        @web.status = :hint
        render('game.html.erb')

      when '/update_game'
        @web.set_offer(@request.params['guess'])
        redirect_to '/play_game'

      when '/save_res'
        @web.save_results
        redirect_to '/show_res'

      when '/show_res' 
        @web.load_scores_from_file
        render('show.html.erb')

      else Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    page = ERB.new(File.read(path)).result(binding)
    Rack::Response.new(page)
  end

  def redirect_to(link)
    Rack::Response.new{|response| response.redirect(link)}
  end

end




