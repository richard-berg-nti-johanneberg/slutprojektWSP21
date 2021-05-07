module Model

    # kopplar upp till databasen returnerar resultatet som en hash
    def connect_to_db()
        db = SQLite3::Database.new('db/gym.db')
        db.results_as_hash = true

        return db
    end


    # funktionen stoppar in variabler från ett formulär in i relationstabellen mellan övningar och program
    # @param [String] ovning namnet på övningen
    # @param [String] program namnet på programmet
    # @see #connect_to_db
    def update_programs(ovning, program)
        db = connect_to_db()
        db.execute("INSERT INTO exercises_programs_relation (exercises_id, programs_id) VALUES (?,?)", ovning, program)
    end


    # funktionen hämtar allt från tabellen exercises vid användar id:et
    # @param [Integer] :id id:et på användaren
    # @see #connect_to_db
    def get_exercises(id)
        db = connect_to_db()
        exercises = db.execute("SELECT * FROM exercises WHERE id = ?",id).first

        return exercises
    end


    # funktionen skapar en ny övning, skickar in namnet på den i databasen samt kreatören
    # @param [String] ovningsnamn namnet på övningen
    # @param [Integer] id:et på pt:n
    # @see #connect_to_db
    def new_exercise(ovningsnamn, userid)
        db = connect_to_db()
        db.execute("INSERT INTO exercises (name, user_id) VALUES (?,?)", ovningsnamn, userid)
    end


    # funktionen uppdaterar en övning, ändrar namnet på den vid userid:et och id:et på övningen
    # @param [String] name namnet på övningen (nya)
    # @param [Integer] user_id id:et på pt:n
    # @param [Integer] id id:et på övningen
    # @see #connect_to_db
    def edit_exercises(name, user_id, id)
        db = connect_to_db()
        db.execute("UPDATE exercises SET name=?, user_id=? WHERE id =?",name, user_id, id)
    end


    # funktionen tar bort övningen från det satta id:et
    # @param [Integer] :id id:et på övningen
    # @see #connect_to_db
    def delete_exercises(id)
        db = connect_to_db()
        db.execute("DELETE FROM exercises WHERE id = ?",id)
        db.execute("DELETE FROM exercises_programs_relation where exercises_id =?",id)
    end


    #funktionen skapar ett nytt program, namnet och id:et går in i program tabellen
    # @param [String] name namnet på övningen
    # @param [Integer] userid id:et på pt:n som skapade programmet
    # @see #connect_to_db
    def new_program(name,userid)
        db = connect_to_db()
        db.execute("INSERT INTO programs (name, user_id) VALUES (?,?)", name, userid)
    end


    #funktionen tar bort program från valda id:et
    # @param [Integer] :id id:et på programmet
    # @see #connect_to_db
    def delete_program(id)
        p id
        p "----------------------------"
        db = connect_to_db()
        db.execute("DELETE FROM programs WHERE id = ?",id)
        db.execute("DELETE FROM exercises_programs_relation WHERE programs_id =?",id)
        db.execute("DELETE FROM programs_users_relation WHERE programs_id =?",id)

    end


    #funktionen knyter ihop två tabeller med gemensamma ankallade id:n 
    # @param [Integer] :id id:et på programmet
    # @see #connect_to_db
    def edit_program(id)
        db = connect_to_db()
        exercises = db.execute("SELECT exercises.name FROM exercises_programs_relation INNER JOIN exercises ON exercises_programs_relation.exercises_id = exercises.id WHERE programs_id = ?",id)
        program = db.execute("SELECT name FROM programs WHERE id = ?", id)

        return [exercises,program]
    end


    #funkitonen hämtar data från program och exercises tabellerna
    # @param [Integer] :id id:et på pt:n som är inloggad
    # @see #connect_to_db
    def programsnew(id)
        db = connect_to_db()
        exercises = db.execute("SELECT * FROM exercises WHERE user_id = ?",id)
        programname = db.execute("SELECT * FROM programs WHERE user_id = ?",id)

        return [exercises,programname]
    end


    #funktionen stoppar in relationen mellan programmet och användaren i programs_users_relation tabellen
    # @param [Integer] program_id programmets id
    # @param [Integer] user_id användarens id
    def add_programs(program_id, user_id)
        db = connect_to_db()
        db.execute("INSERT INTO programs_users_relation (programs_id, user_id) VALUES (?,?)",program_id, user_id )
    end


    # funktionen hämtar från databasen alla program som finnns och vilka tillagda som finns
    # @param [Integer] :id användar id:et för vilka som är tillagda
    # @see #connect_to_db
    def programs(id)
        db = connect_to_db()
        programname = db.execute("SELECT * FROM programs")  
        addprograms = db.execute("SELECT * FROM programs_users_relation")
        showprograms = db.execute("SELECT programs.name FROM programs_users_relation INNER JOIN programs ON programs_users_relation.programs_id = programs.id WHERE programs_users_relation.user_id =?",id)

        return [programname,addprograms,showprograms]
    end


    # funktionen kollar i databasen ifall lösenordet stämmer överens med det sparade
    # @param [String] username användarnamnet
    # @see #connect_to_db
    def login(username, password)
        db = connect_to_db()
        result = db.execute("SELECT * FROM users WHERE username = ?",username).first
        pwdigest = result["pwdigest"]

        if BCrypt::Password.new(pwdigest) == password
            return result
        end
        return ""
    end


    #funktionen skickar in i databasen ett namn, krypterat lösen och en roll
    # @param [String] username användarens namn
    # @param [String] password lösenordet
    # @param [Integer] role rollen man har
    # @see #connect_to_db
    def register(username,password,role)
        db = connect_to_db()
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users (username,pwdigest,role) VALUES (?,?,?)",username,password_digest,role)
    end

    # hämtar alla program namnen från databasen
    # @see #connect_to_db
    def firstpage()
        db = connect_to_db()
        programs = db.execute("SELECT name FROM programs")
        p programs
    end
end