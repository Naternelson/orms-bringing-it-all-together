class Dog
    attr_accessor :name, :id, :breed

    ##
    ####  CLASS METHODS ####
    ##

    def self.create_table
        sql= <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql= <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql= <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(atr)
        sql= <<-SQL
            SELECT * FROM dogs
            WHERE (name = ? AND breed = ?)
        SQL
        row = DB[:conn].execute(sql, atr[:name], atr[:breed]).flatten
        row.empty? ? self.create(atr) : self.new_from_db(row)
    end

    def self.find_by_name(name)
        sql= <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)[0]
        !row.empty? ? self.new_from_db(row) : nil
    end

    ##
    ####  INSTANCE METHODS ####
    ##

    def initialize(attributes)
        attributes.each{|key, value| self.send(("#{key}="), value)}
    end

    def save
        self.id != nil ? update : insert_to_db
    end

    def insert_to_db
        sql= <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
        self
    end

    def update
        sql= <<-SQL
            UPDATE dogs 
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
        self
    end
end