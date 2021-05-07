require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative 'model.rb'
include Model
enable  :sessions


# Visar första sidan och hämtar alla program
# @see Model#firstpage
get("/") do
  programs = firstpage()

  slim(:homepage, locals:{programs:programs})
end


# Tar en till inloggnings slimen
get("/login") do
  slim(:login)
end


# Tar en till slimen där man registrerar sig
get("/register") do

  slim(:register)
end


# en post som loggar in en och redirectar beroende på vad för roll, kollar även att lösenord är korrekt
# @param [String] username användarens namn
# @param [String] password användarens lösenord
# @param [Integer] role användarens roll
# @see Model#login
post('/login') do
  username = params[:username]
  session[:username] = username
  password = params[:password]
  
  if !empty(username) && !empty(password)
    if session[:lastlogin] == nil || Time.now - session[:lastlogin] > 1000
      user = login(username, password)
      if user != ""
        role = user["role"]
        id = user["id"]
        session[:id] = id
        if role == 1
          redirect('/programs/new')
        else 
          redirect("/programs")
        end

      else
        session[:lastlogin] = Time.now
        "fel lösenord"
      end
    else
      "Try again in a couple of seconds"
    end
  else
    "du måste fylla i luckorna"
  end

end


# en post som skapar en användare, redirectar tillbaka till första sidan
# @param [String] username användarens namn
# @param [String] password användarens lösenord
# @param [String] password_confirm återuppreda lösenordet
# @see Model#register
post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  role = params[:PT]

  if !empty(username) && !empty(password) && !empty(password_confirm)
    if password == password_confirm
      register(username,password,role)
      redirect('/')

    else
      "lösenorden matchar inte"
    end
  else
    "du måste fylla i luckorna"
  end
end


# Tar en till första sidan för de som är vanliga användare, kan även nås av pt:s
# @param [Integer] :id, användar id:et.
# @see Model#programs
get("/programs") do
  id = session[:id].to_i
  name_add_show = programs(id)  
 
  slim(:"/programs/index", locals:{username:session[:username],programname:name_add_show[0],addedprograms:name_add_show[1],showprograms:name_add_show[2]})
end


# här kan användare lägga till ett program till hens lista, man kan lägga till flera program och programmen kan ha flera användare.
# @param [Integer] program_id  programmets id
# @param [Integer] user_id   användarens id
# @see Model#add_programs
post("/programs/:id/add") do
  program_id = params[:id]
  user_id = session[:id].to_i
  add_programs(program_id, user_id)

  redirect("/programs")
end


# här är sidan pt:s kommer till. Här skapar man övningar, program och stoppar in valda övningar i programmen.
# @param [Integer] :id pt:ns id
# @see Model#programsnew
get("/programs/new") do
  id = session[:id].to_i
  exercises_programname =  programsnew(id)

  slim(:"programs/new", locals:{exercises:exercises_programname[0],username:session[:username],programname:exercises_programname[1]})
end


# här är en länk till programmen, du kan här se vad de innehåller
# @param [Integer] :id pt:ns id
# @see Model#edit_program
get("/programs/:id/edit") do
  id = params[:id].to_i
  exercises_programs = edit_program(id)
  
  slim(:"/programs/edit",locals:{exercises:exercises_programs[0],program:exercises_programs[1]})
end


# här är en post som skapar en ny övning
# @param [String] ovningsnamn namnet på övningen
# @param [Integer] userid användarens id
# @see Model#new_exercise
post('/exercises/new') do
  ovningsnamn = params[:ovningsnamn]
  userid = session[:id].to_i
  new_exercise(ovningsnamn, userid)

  redirect('/programs/new')
end


# här är en post som tar bort ett program
# @param [Integer] :id id:et på programmet
# @see Model#delete_program
post('/programs/:id/delete') do
  id = params[:id].to_i
  delete_program(id)

  redirect('/programs/new')
end


# här skapar en pt ett nytt program i denna post
# @param [String] name namnet på programmet
# @param [Integer] userid id:et på användaren
# @see Model#new_program
post('/programs/new/') do
  name = params[:programname]
  session[:programname] = name
  userid = session[:id].to_i
  new_program(name,userid)

  redirect('/programs/new')
end


# här så är en post som skickar in i relationstabellen mellan övningar och programmen
# @param [String] ovning vilken övning
# @param [String] program vilket program
# @see Model#update_programs
post('/programs/update/') do
  ovning = params[:ovning]
  program = params[:program]
  update_programs(ovning, program)
  
  redirect('/programs/new')
end


# här är en post som tar bort övningar
# @param [Integer] :id id:et på övningen
# @see Model#delete_exercises
post('/exercises/:id/delete') do
  id = params[:id].to_i
  delete_exercises(id)

  redirect('/programs/new')
end


# här är en post till när man redigerat en övning
# @param [Integer] :id id:et på övningen
# @param [String] name namnet på övningen
# @param [Integer] user_id id:et på pt:n
# @see Model#edit_exercises
post('/exercises/:id/edit') do
  id = params[:id].to_i
  name = params[:name]
  user_id = params[:user_id].to_i
  edit_exercises(name, user_id, id)

  redirect('/programs/new')
end


# här är geten som tar dig till den dynamiska routen för att redigera en övning
# @param [Integer] :id id:et på övningen
# @see Model#get_exercises
get('/exercises/:id/edit') do
  id = params[:id].to_i 
  exercise = get_exercises(id)

  slim(:"/exercises/edit",locals:{exercise:exercise})
end

get('/exercises/new') do
  
  slim(:"/exercises/new")
end


def empty(string)
  if string.length() != 0
    return false
  else 
    return true
  end
end

# bundle exec yardoc --plugin yard-sinatra app.rb model.rb