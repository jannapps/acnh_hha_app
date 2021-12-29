require 'sinatra'
require 'pg'

set :port, 8080

get '/' do
  redirect '/index.html'
end

get '/search' do
  data = []

  begin
    connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
    table = connection.exec 'SELECT * FROM housewares;'

#    table.each do |item|
#      data.push({ name: item['name'], points: item['hha_base'] })
#    end

  rescue PG::Error => e
    e_value = e.message

  ensure
    connection.close if connection

  end

  erb :item, :layout => :search, :locals => {:data => table}
end
