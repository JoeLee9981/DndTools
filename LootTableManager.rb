require 'sqlite3'

class DbManager
 
  def import_from_csv(filename)
    file = File.new(filename, "r")
    file.gets
    while (line = file.gets)
      a = line.split(',')
      #puts "#{a[0]}, #{a[1]}, #{a[2]}, #{a[3]}, #{a[4]}, #{a[5]}, #{a[6]}, #{a[7]}"
      insert_to_db(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])
    end
    
    file.close
  end
  
  def import_art_from_csv(filename)
    file = File.new(filename, "r")
    file.gets
    while (line = file.gets)
      a = line.split(',')
      insert_to_art_db(a[0], a[1], a[2], a[3], a[4])
    end
  end
  
  def import_exp_from_csv(filename)
    file = File.new(filename, "r")
    file.gets
    while (line = file.gets)
      a = line.split(',')
      insert_to_exp_db(a[0], a[1], a[2])
    end
  end
  
  def import_gems_from_csv(filename)
    file = File.new(filename, "r")
    file.gets
    while (line = file.gets)
      a = line.split(',')
      insert_to_gems_db(a[0], a[1], a[2], a[3], a[4])
    end
  end
  
  def insert_to_art_db(name, low, high, value, avg_val)
    begin
      db = SQLite3::Database.open "DNDTABLES.sqlite3"
      cmd = "INSERT INTO art (name,low,high,value,avg_val) VALUES (?,?,?,?,?)"
      db.execute(cmd, name, low, high, value, avg_val)
    rescue SQLite3::Exception => e
      puts "Exception #{e}"
    ensure
      db.close if db
    end
  end
  
  def insert_to_exp_db(l, c, ex)
    begin
      db = SQLite3::Database.open "DNDTABLES.sqlite3"
      cmd = db.prepare("INSERT INTO experience (level, cr, exp) VALUES (?,?,?)")
      cmd.bind_params(l, c, ex)
      cmd.execute()
    rescue SQLite3::Exception => e
      puts "Exception #{e}"
    ensure
      cmd.close if cmd
      db.close if db
    end
  end
  
  def insert_to_gems_db(name, low, high, value, avg_val)
    begin
      db = SQLite3::Database.open "DNDTABLES.sqlite3"
      cmd = "INSERT INTO gems (name,low,high,value,avg_val) VALUES (?,?,?,?,?)"
      db.execute(cmd, name, low, high, value, avg_val)
    rescue SQLite3::Exception => e
      puts "Exception #{e}"
    ensure
      db.close if db
    end
  end
  
  def insert_to_db(level, type, low, high, die, scale, coin, sub)
    begin
      db = SQLite3::Database.open "DNDTABLES.sqlite3"
      cmd = "INSERT INTO loot_rolls (level,type,low_roll,high_roll,die,scale,coin_type,sub_type) VALUES (?,?,?,?,?,?,?,?)"
      db.execute(cmd, level,type,low,high,die,scale,coin,sub)
    rescue SQLite3::Exception => e
      puts "Exception: #{e}"
    ensure
      db.close if db
    end
  end
  
  def find_from_db(level, type, roll)
    begin
      db = SQLite3::Database.open("DNDTABLES.sqlite3")
      cmd = db.prepare("SELECT * FROM loot_rolls WHERE level = ? and type = ? and (? >= low_roll and ? <= high_roll)")
      cmd.bind_params(level, type, roll, roll)
      result = cmd.execute
      a = result.next
      return a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[0]
    rescue SQLite3::Exception => e
      puts "Exception: #{e}"
    ensure
      cmd.close if cmd
      db.close if db
    end
  end
  
  def find_exp_from_db(level, cr)
    begin
      db = SQLite3::Database.open("DNDTABLES.sqlite3")
      cmd = db.prepare("SELECT exp FROM experience WHERE level = ? and cr = ?")
      cmd.bind_params(level, cr)
      result = cmd.execute
      a = result.next
      if a != nil
        return a[0]
      else
        return 0
      end
    rescue SQLite3::Exception => e
      puts "Exception: #{e}"
    ensure
      cmd.close if cmd
      db.close if db
    end
  end
  
  def find_goods_from_db(table, roll)
    begin
      db = SQLite3::Database.open("DNDTABLES.sqlite3")
      cmd = db.prepare("SELECT name FROM #{table} WHERE ? >= low and ? <= high")
      cmd.bind_params(roll, roll)
      result = cmd.execute
      a = Array.new
      result.each do |name|
        a.push(name[0].chomp)
      end
      return a
    rescue SQLite3::Exception => e
      puts "Exception: #{e}"
    ensure
      cmd.close if cmd
      db.close if db
    end
  end
  
end

def start
  manager = DbManager.new
  #manager.find_goods_from_db("art", 55)
  #manager.find_goods_from_db("gems", 25)
  puts manager.find_exp_from_db(1, 10)
  puts manager.find_exp_from_db(20, 20)
  #manager.import_exp_from_csv("dnd_exp.csv")
end

if __FILE__ == $0
  start
end
