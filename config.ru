require './lib/racker'

use Rack::Static, :urls => ['/stylesheets'], :root => 'public'

run Racker