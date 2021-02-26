require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable  :sessions

get("/") do
    slim(:homepage)
end

get("/login") do
    slim(:login)
end

get("/register") do
    slim(:register)
end


post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  role = params[:PT]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/gym.db')
    db.execute("INSERT INTO users (username,pwdigest,role) VALUES (?,?,?)",username,password_digest,role)
    if role == 1
      redirect('/createprograms')
    else 
      redirect("/programs")
    end

  else
    "lösenorden matchar inte"
  end
end

get("/programs") do
  slim(:programs)
end

get("/createprograms") do
  slim(:createprograms)
end


post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/gym.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    role = result["role"]
    pwdigest = result["pwdigest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      if role == 1
        redirect('/createprograms')
      else 
        redirect("/programs")
      end

    else
      "fel lösenord"
    end
  
end
  
