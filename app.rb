require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

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
    redirect('/')

  else
    "lösenorden matchar inte"
  end
end

get("/programs") do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  slim(:"programs", locals:{username:session[:username]})

end

get("/createprograms") do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM exercises WHERE user_id = ?",id)

  slim(:"createprograms", locals:{exercises:result,username:session[:username]})
end


post('/login') do
    username = params[:username]
    session[:username] = username
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
  

post('/exercises/new') do
  ovningsnamn = params[:ovningsnamn]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO exercises (content, user_id) VALUES (?,?)", ovningsnamn, userid)

  redirect('/createprograms')

end

post('/exercises/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.execute("DELETE FROM exercises WHERE id = ?",id)
  

  redirect('/createprograms')

end

post('/exercises/:id/update') do
  id = params[:id].to_i
  content = params[:content]
  user_id = params[:user_id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.execute("UPDATE exercises SET content=?, user_id=? WHERE id =?",content, user_id, id)

  redirect('/createprograms')
end

get('/exercises/:id/edit') do
  id = params[:id].to_i 
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM exercises WHERE id = ?",id).first
  slim(:"/edit",locals:{result:result})
end



post('/programs/new/') do

  name = params[:programname]
  checked = params[:checked]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  # db.execute("INSERT INTO programs (name, user_id) VALUES (?,?)", name, userid)
  p "#{checked}"
  redirect('/createprograms')
end

