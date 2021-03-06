class Dog

  attr_accessor :id, :name, :breed

  def initialize(attribute_hash)
    attribute_hash.each do |k, v|
      self.send(("#{k}="), v)
    end
  end

  def self.create(attribute_hash)
    dog = Dog.new(attribute_hash)
    dog.save
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE breed = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.find_or_create_by(attribute_hash)
    if self.find_by_name(attribute_hash[:name]) && self.find_by_breed(attribute_hash[:breed])
      self.find_by_name(attribute_hash[:name])
    else
      self.create(attribute_hash)
    end
  end



end
