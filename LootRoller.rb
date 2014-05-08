require_relative 'LootTableManager'

class LootRoller
  #constant variables for index purposes
  LEVEL = 0
  TYPE = 1
  LOW = 2
  HIGH = 3
  DIE = 4
  SCALE = 5
  COINS = 6
  SUB = 7

  def initialize(low_lev, high_lev, party_size)
    @low = low_lev
    @high = high_lev
    @party_size = party_size
  end
  
  def do_roll(die = 6)
    if die == 0
      return 0
    end
    return 1 + Random.rand(die)  
  end
  
  def do_loot_roll(levels)
    #Tally coins for all rolls
    total_coin = Hash["platinum", 0, "gold", 0, "silver", 0, "copper", 0]
    all_items = Array.new
    all_goods = Array.new
    total_exp = calc_exp(levels)
    levels.each do |level|
      roll = do_roll(100)
      coins = get_coin_roll(level, roll)
      coin = roll_coins(coins[DIE], coins[SCALE])
      total_coin[coins[COINS]] += coin
      display_roll(coins[LEVEL], coins[TYPE], roll, coins[LOW], coins[HIGH], coins[DIE], coins[SCALE], coins[COINS], coins[SUB], coin)
      
      roll = do_roll(100)
      goods = get_goods_roll(level, roll)
      goods_list = roll_others(goods[DIE], goods[SUB])
      display_roll(goods[LEVEL], goods[TYPE], roll, goods[LOW], goods[HIGH], goods[DIE], goods[SCALE], goods[COINS], goods[SUB], goods_list)
      all_goods.push(*goods_list)
      
      roll = do_roll(100)
      items = get_items_roll(level, roll)
      items_list = roll_others(items[DIE], items[SUB])
      display_roll(items[LEVEL], items[TYPE], roll, items[LOW], items[HIGH], items[DIE], items[SCALE], items[COINS], items[SUB], items_list)
      all_items.push(*items_list)
    end
    puts "Total Coin: "
    total_coin.each do |val|
      split_coin = val[1] / @party_size
      puts "  #{val[1]} #{val[0]} coins\t-\t#{split_coin} each"
    end
    puts "Goods:"
    all_goods.each do |good|
      puts "  #{good}"
    end
    puts "Items:"
    all_items.each do |item|
      puts "  #{item}"
    end
    puts "Experience:"
    total_exp.each do |exp|
      split_exp = exp[1] / @party_size
      puts "  Level: #{exp[0]}, Exp: #{exp[1]}, at #{split_exp} each"
    end
    
  end
  
  def calc_exp(levels)
    total = Hash.new
    for i in @low..@high
      total[i] = 0
    end
    
    levels.each do |cr|
      for lev in @low..@high
        total[lev] += get_exp(lev, cr)
      end
    end
    return total
  end
  
  private
  def roll_coins(die, scale)
    coins = 0
    dice = die.split('d')
    if dice[1] == 0
      return 0
    end
    Integer(dice[0]).times do |i|
      result = do_roll(Integer(dice[1]))
      coins += result
    end
    return coins * Integer(scale)
  end
  
  def roll_others(die, sub)
    goods = Array.new
    dice = die.split('d')
    if dice[1] == '0'
      return goods
    end
    sum = 0
    Integer(dice[0]).times do |i|
      result = do_roll(Integer(dice[1]))
      sum += result
    end
    sum.times do |i|
      r = do_roll(100)
      if sub.chomp == "gems" || sub.chomp == "art"
        goods.push(get_goods(sub, r))
      else
        goods.push("#{r} #{sub.chomp}")
      end
    end
    return goods
  end
  
  def get_coin_roll(level, roll)
    manager = DbManager.new
    loot_roll = manager.find_from_db(level, "coins", roll)
    return loot_roll
  end
  
  def get_goods_roll(level, roll)
    manager = DbManager.new
    loot_roll = manager.find_from_db(level, "goods", roll)
    return loot_roll
  end
  
  def get_items_roll(level, roll)
    manager = DbManager.new
    loot_roll = manager.find_from_db(level, "items", roll)
    return loot_roll
  end
  
  def get_goods(type, roll)
    manager = DbManager.new
    list = manager.find_goods_from_db(type, roll)
    return list[Random.rand(list.length)]
  end
  
  def get_exp(level, cr)
    manager = DbManager.new
    return Integer(manager.find_exp_from_db(level, cr))
  end
  
  def display_roll(level, type, roll, low, hi, die, scale, coin_type, subtype, total)
    puts "======================================================"
    puts "Level: #{level}\ttype: #{type}\t#{roll}"
    if type == "coins"
      puts "  #{low} - #{hi}\t#{die} * #{scale}\t#{coin_type}"
      if total == 0
        puts "  ***RESULTS: No Coin***"
      else
        puts "  ***RESULTS: #{total} #{coin_type} coins***"
      end
    else
      puts "  #{low} - #{hi}\t#{die}\t#{subtype}"
      if total.size == 0
        puts " ***RESULTS: No Goods"
      else
        result_str = "  ***RESULTS: "
        total.each do |item|
          result_str += item.to_s + ", "
        end
        puts result_str
      end
    end
    puts
  end
end

def build_list(input)
  splits = input.split(',')
  chal_rates = Array.new
  splits.each do |val|
    chal_rates.push(Integer(val))
  end
end

def start
  puts "Please enter lowest party level:"
  low = Integer(gets.chomp)
  puts "Please enter highest party level:"
  high = Integer(gets.chomp)
  puts "Please enter number of party members:"
  p_size = Integer(gets.chomp)
  roller = LootRoller.new(low, high, p_size)
  while true
    puts "Please enter a challenge rating (or 'x' to exit):"
    input = gets.chomp
    if(input == 'x' || input == 'X')
      exit
    end
    chal_rates = build_list(input)
    roller.do_loot_roll(chal_rates)
  end
end

if __FILE__ == $0
  start
end
