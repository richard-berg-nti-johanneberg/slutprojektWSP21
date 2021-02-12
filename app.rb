require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable  :sessions

get("/") do
    slim(:homepage)
end

get("/login") do
    slim(:)
end