require_relative 'interactive'
require 'erb'
require "pry"

class Racker
  def self.call(env)
    new(env).router.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @help_string ||= 'Show'
    @@games ||= {}
    @login = @request.params['name']
  end

  def web
    @@games[@login]
  end

  def router
    redirect_to '/' if @login.nil? || @login.empty?
    case @request.path
      when '/' then render('index.html.erb')
      when '/new_game' then start_new_game
      when '/show_help' then show_help
      when '/show_hint' then show_hint
      when '/update_game' then update_game
      when '/save_res' then save_result
      when '/show_res' then show_result
      else Rack::Response.new('Not Found', 404)
    end
  end

  def start_new_game
    new_game = Interactive.new(@request.params['name'], @request.params['level'])
    @login = new_game.name
    @@games[@login] = new_game
    web.start(web.level)
    web.status = :first_step
    render('game.html.erb')
  end

  def show_help
    @help_string = @request.params['help_string'] == 'Show' ? 'Hide' : 'Show'
    render('index.html.erb')
  end

  def show_hint
    web.show_hint
    web.status = :hint
    render('game.html.erb')
  end

  def update_game
    web.set_offer(@request.params['guess'])
    web.status = :playing
    render('game.html.erb')
  end

  def save_result
    web.save_results
    redirect_to '/show_res'
  end

  def show_result
    web.load_scores_from_file
    render('show.html.erb')
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    page = ERB.new(File.read(path)).result(binding)
    Rack::Response.new(page)
  end

  def redirect_to(link)
    Rack::Response.new{|response| response.redirect(link + "?name=#{@login}")}
  end
end




