def update_programs(ovning, program)
    db = SQLite3::Database.new('db/gym.db')
    db.results_as_hash = true
    db.execute("INSERT INTO exercises_programs_relation (exercises_id, programs_id) VALUES (?,?)", ovning, program)
end

def get_exercises(id)

    db = SQLite3::Database.new('db/gym.db')
    db.results_as_hash = true
    exercises = db.execute("SELECT * FROM exercises WHERE id = ?",id).first
    return exercises
end

def edit_exercises(name, user_id, id)
    db = SQLite3::Database.new('db/gym.db')
    db.execute("UPDATE exercises SET name=?, user_id=? WHERE id =?",name, user_id, id)
end

def delete_exercises(id)
    db = SQLite3::Database.new('db/gym.db')
    db.execute("DELETE FROM exercises WHERE id = ?",id)
  
end


def new_program(name,userid)
    db = SQLite3::Database.new('db/gym.db')
    db.results_as_hash = true
    db.execute("INSERT INTO programs (name, user_id) VALUES (?,?)", name, userid)
  

end