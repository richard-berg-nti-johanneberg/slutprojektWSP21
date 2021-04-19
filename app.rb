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
      redirect('/programs/new')
    else 
      redirect("/programs")
    end

  else
    "fel lösenord"
  end
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
  result = db.execute("SELECT * FROM programs")
  result2 = db.execute("SELECT * FROM programs_users_relation")
  slim(:"/programs/index", locals:{username:session[:username],programname:result,addedprograms:result2})
end


post("/programs") do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')

  redirect("/programs")
end


get("/programs/new") do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM exercises WHERE user_id = ?",id)
  result2 = db.execute("SELECT * FROM programs WHERE user_id = ?",id)

  slim(:"programs/new", locals:{exercises:result,username:session[:username],programname:result2})
end


get("/programs/:id/edit") do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  result = db.execute("SELECT exercises.name FROM  exercises_programs_relation INNER JOIN exercises ON exercises_programs_relation.exercises_id = exercises.id WHERE programs_id = ?",id)
  result2 = db.execute("SELECT name FROM programs WHERE id = ?", id)
  slim(:"/programs/edit",locals:{exercises:result,program:result2})
end
  
post('/programs/exercises/new') do
  ovningsnamn = params[:ovningsnamn]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO exercises (name, user_id) VALUES (?,?)", ovningsnamn, userid)

  redirect('/programs/new')
end


post('/exercises/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.execute("DELETE FROM exercises WHERE id = ?",id)

  redirect('/programs/new')
end


post('/exercises/:id/edit') do
  id = params[:id].to_i
  name = params[:name]
  user_id = params[:user_id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.execute("UPDATE exercises SET name=?, user_id=? WHERE id =?",name, user_id, id)

  redirect('/programs/new')
end


get('/exercises/:id/edit') do
  id = params[:id].to_i 
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM exercises WHERE id = ?",id).first
  slim(:"/exercises/edit",locals:{result:result})
end


post('/programs/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.execute("DELETE FROM programs WHERE id = ?",id)

  redirect('/programs/new')
end


post('/programs/new/') do
  name = params[:programname]
  session[:programname] = name
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO programs (name, user_id) VALUES (?,?)", name, userid)

  redirect('/programs/new')
end


post('/programs/update/') do
  ovning = params[:ovning]
  program = params[:program]
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO exercises_programs_relation (exercises_id, programs_id) VALUES (?,?)", ovning, program)

  redirect('/programs/new')
end
