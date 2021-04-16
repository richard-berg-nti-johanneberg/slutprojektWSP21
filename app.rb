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

get("/editprograms") do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM programs WHERE user_id = ?",id)
  p result
  ovningar_id = []
  result.each do |program|
    ovningar_id << db.execute("SELECT * FROM exercises_programs_relation WHERE programs_id = ?", program["id"])
  end
  p ovningar_id
  ovningar = [] 

  ovningar_id[0].each do |id| 
    p id
    p db.execute("SELECT content FROM exercises WHERE id = ?", id['exercises_id'])
    # p db.execute("SELECT programs_id FROM exercises_programs_relation WHERE exercises_id = ?", id)
    ovningar << [db.execute("SELECT content FROM exercises WHERE id = ?", id['exercises_id']), db.execute("SELECT programs_id FROM exercises_programs_relation WHERE exercises_id = ?", id['exercises_id'])]
  end
  p ovningar[0]

  slim(:editprograms,locals:{result:result,ovningar:ovningar})
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
  result2 = db.execute("SELECT * FROM programs WHERE user_id = ?",id)

  slim(:"createprograms", locals:{exercises:result,username:session[:username],programname:result2})
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

post('/programs/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.execute("DELETE FROM programs WHERE id = ?",id)
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
  session[:programname] = name
  userid = session[:id].to_i
  db = SQLite3::Database.new('db/gym.db')
  db.results_as_hash = true
  db.execute("INSERT INTO programs (name, user_id) VALUES (?,?)", name, userid)
  

  redirect('/createprograms')
end

post('/programs/update/') do
ovning = params[:ovning]
program = params[:program]
db = SQLite3::Database.new('db/gym.db')
db.results_as_hash = true
db.execute("INSERT INTO exercises_programs_relation (exercises_id, programs_id) VALUES (?,?)", ovning, program)


redirect('/createprograms')

end
