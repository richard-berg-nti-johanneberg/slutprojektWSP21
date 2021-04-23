require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative 'model.rb'

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
  programname = db.execute("SELECT * FROM programs")
  addprograms = db.execute("SELECT * FROM programs_users_relation")
  showprograms = db.execute("SELECT programs.name FROM programs_users_relation INNER JOIN programs ON programs_users_relation.programs_id = programs.id WHERE programs_users_relation.user_id =?",id)
  # result3 = db.execute("SELECT programs_id FROM programs_users_relation WHERE user_id = ?",id)
  # p result3
  # result4 = db.execute("SELECT name FROM programs WHERE id = ?",result3[0])
  # p result4
  slim(:"/programs/index", locals:{username:session[:username],programname:programname,addedprograms:addprograms,showprograms:showprograms})
end


post("/programs/:id/add") do
  program_id = params[:id]
  user_id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO programs_users_relation (programs_id, user_id) VALUES (?,?)",program_id, user_id )

  redirect("/programs")
end


get("/programs/new") do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  exercises = db.execute("SELECT * FROM exercises WHERE user_id = ?",id)
  programname = db.execute("SELECT * FROM programs WHERE user_id = ?",id)

  slim(:"programs/new", locals:{exercises:exercises,username:session[:username],programname:programname})
end


get("/programs/:id/edit") do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  exercises = db.execute("SELECT exercises.name FROM exercises_programs_relation INNER JOIN exercises ON exercises_programs_relation.exercises_id = exercises.id WHERE programs_id = ?",id)
  program = db.execute("SELECT name FROM programs WHERE id = ?", id)

  slim(:"/programs/edit",locals:{exercises:exercises,program:program})
end
  

post('/programs/exercises/new') do
  ovningsnamn = params[:ovningsnamn]
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO exercises (name, user_id) VALUES (?,?)", ovningsnamn, userid)

  redirect('/programs/new')
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
  new_program(name,userid)

  redirect('/programs/new')
end


post('/programs/update/') do
  ovning = params[:ovning]
  program = params[:program]
  update_programs(ovning, program)
  
  redirect('/programs/new')
end


post('/exercises/:id/delete') do
  id = params[:id].to_i
  delete_exercises(id)

  redirect('/programs/new')
end


post('/exercises/:id/edit') do
  id = params[:id].to_i
  name = params[:name]
  user_id = params[:user_id].to_i
  edit_exercises(name, user_id, id)

  redirect('/programs/new')
end


get('/exercises/:id/edit') do
  id = params[:id].to_i 
  exercise = get_exercises(id)

  slim(:"/exercises/edit",locals:{exercise:exercise})
end


