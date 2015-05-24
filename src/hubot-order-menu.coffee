# Description:
#   Make an order for easyily record and calculate total money needed.
#
# Dependencies:
#   coffee-script
#
# Configuration:
# HUBOT_ORDER_MENU_STORE_INFO=[name1,phone1,Http:\\link1;name2,phone2,Http:\\link2]
#
# Commands:
# hubot order stores - show all store info.
# hubot order <category> (<food> <note> )$<money> - make an order.
# hubot order <category> (<food> <note> )$<money> for @someone - make an order for someone.
# hubot order <category> del <food> - delete food record
# hubot order show total - show your order.
# hubot order show cate(gory) <category> - show someone category's orders and calculate total money needed.
# hubot order show cate(gory) <category> all - show category's orders and calculate total money needed.
# hubot order show all - show all orders and calculate total money needed.
# hubot order reset all - reset all orders.
# hubot order reset @someone - reset someone orders.
# hubot order reset my - reset your orders.
# hubot order reset category <category> - clear category.
# hubot order set discount <category> - setting category's discount.
#
# Author:
#   Ghost.Yang
#

Util = require 'util'

module.exports = (robot) ->
  class Order
    constructor: (options) -> 
      {@name, @userId, @date, @category, @food, @note, @money, @discountRatio} = options
      @SetDiscountRatio @discountRatio
      
    SetDiscountRatio: (discountRatio) ->
      @discountRatio = discountRatio
      @discount = parseFloat( @money ) * parseFloat( @discountRatio )

    toString: ->
      GetReplyMsg this

  class Store
    constructor: (options) -> 
      {@name, @phone, @link} = options

    toString: ->
      "#{@name} #{@phone} - #{@link}"

  class CommandStore
    constructor: (options) -> 
      @bot = options
      @commands = ['\n']

    Add: (message) ->
      @commands.push message

    Send: ->
      message = @commands.join('\n')
      @bot.reply message

  unless process.env.HUBOT_ORDER_MENU_STORE_INFO?
    robot.logger.warning 'The HUBOT_ORDER_MENU_STORE_INFO environment variable not set'

  Stores = []
  if process.env.HUBOT_ORDER_MENU_STORE_INFO?
    rawStoreInfos = process.env.HUBOT_ORDER_MENU_STORE_INFO.split ';'
    for rawStoreInfo in rawStoreInfos
      robot.logger.debug rawStoreInfo
      storeInfos = rawStoreInfo.split ','
      robot.logger.debug storeInfos
      Stores.push (new Store name:storeInfos[0], phone:storeInfos[1], link:storeInfos[2])

  robot.brain.data['order'] = {}
  robot.brain.data['setting'] = {}
  robot.brain.data.setting['discountRatio'] = {}

  robot.respond /order stores/i, (msg) ->
    msg.reply 'The HUBOT_ORDER_MENU_STORE_INFO environment variable not set' unless Stores.length
    commands = new CommandStore msg
    for store in Stores
      commands.Add store
    commands.Send()

  robot.respond /order\s+(\S*)\s+(\S*)\s+((?:\S*\s+)+)?\$(\S*)(?:\s+for\s+@?(\S*))?/i, (msg) ->
    #robot.logger.debug Util.inspect msg
    commands = new CommandStore msg
    date_current = new Date()
    category = msg.match[1]
    food = msg.match[2]
    note = msg.match[3]
    money = msg.match[4]
    user = ""
    userId = ""
    if (msg.match[5]?)
      user = msg.match[5]
      userId = parseTarget msg.message.rawText
    else
      user = msg.message.user.name
      userId = msg.message.user.id

    if(robot.brain.data.setting.discountRatio[category]? != true)
      robot.brain.data.setting.discountRatio[category] = 1

    discountRatio = robot.brain.data.setting.discountRatio[category]

    order = new Order name:user, userId:userId, date:date_current, category:category, food:food, note:note, money:money, discountRatio:discountRatio

    if(robot.brain.data.order[category]? != true)
      robot.brain.data.order[category]={}

    if(robot.brain.data.order[category][user]? != true)
      robot.brain.data.order[category][user]={}

    robot.brain.data.order[category][user][food] = order

    commands.Add GetReplyMsg order
    commands.Send()

  robot.respond /order\s+(\S*)\s+del\s+(\S*)(?:\s+for\s+@?(\S*))?/i, (msg) ->
    commands = new CommandStore msg
    category = msg.match[1]
    food = msg.match[2]
    user = ""
    userId = ""
    if (msg.match[3]?)
      user = msg.match[3]
      userId = parseTarget msg.message.rawText
    else
      user = msg.message.user.name
      userId = msg.message.user.id

    if(robot.brain.data.order[category]? != true)
      return

    if(robot.brain.data.order[category][user]? != true)
      return

    orderMsg = GetReplyMsg robot.brain.data.order[category][user][food]

    delete robot.brain.data.order[category][user][food]

    commands.Add "You delete #{orderMsg}"
    commands.Send()

  robot.respond /order show total(?:(?:\s+for)?\s+@?(\S*))?/i, (msg) ->
    #robot.logger.debug Util.inspect msg
    commands = new CommandStore msg
    categoryMoney = 0
    totalMoney = 0
    flag = false
    user = ""
    userId = ""
    if (msg.match[1]?)
      user = msg.match[1]
      userId = parseTarget msg.message.rawText
    else
      user = msg.message.user.name
      userId = msg.message.user.id
    for categoryName, category of robot.brain.data.order
      for userName, food of category when userName is user
        for foodName, order of food
          if order?
            commands.Add order
            categoryMoney += parseFloat( order.discount )
            totalMoney += parseFloat( order.discount )
            flag = true
      if categoryMoney isnt 0
        commands.Add "#{categoryName} total : #{categoryMoney}"
        categoryMoney = 0
        flag = true

    if (flag isnt true)
      commands.Add "you have no order."
    else
      commands.Add "Total money : #{totalMoney}"
    commands.Send()

  robot.respond /order show cate(?:g?o?r?y?) (\S*) all/i, (msg) ->
    commands = new CommandStore msg
    _categoryName = msg.match[1]
    totalMoney = 0
    flag = false
    for categoryName, category of robot.brain.data.order when categoryName is _categoryName
      for userName, food of category
        for foodName, order of food
          if order?
            commands.Add order
            totalMoney += parseFloat( order.discount )
            flag = true
      if totalMoney isnt 0
        commands.Add "#{categoryName} total : #{totalMoney}"
        totalMoney = 0
        flag = true

    if (flag isnt true)
      commands.Add "you have no order."
    commands.Send()

  robot.respond /order show cate(?:g?o?r?y?) (\S*)(?:\s*)$/i, (msg) ->
    commands = new CommandStore msg
    _categoryName = msg.match[1]
    totalMoney = 0
    flag = false
    user = msg.message.user.name
    for categoryName, category of robot.brain.data.order when categoryName is _categoryName
      for userName, food of category when userName is user
        for foodName, order of food
          if order?
            commands.Add order
            totalMoney += parseFloat( order.discount )
            flag = true
      if totalMoney isnt 0
        commands.Add "#{categoryName} total : #{totalMoney}"
        totalMoney = 0
        flag = true

    if (flag isnt true)
      commands.Add "you have no order."
    commands.Send()

  robot.respond /order show cate(?:g?o?r?y?) (\S*)(?:(?:\s+for)?\s+@?(\S*))?$/i, (msg) ->
    commands = new CommandStore msg
    _categoryName = msg.match[1]
    totalMoney = 0
    flag = false
    user = ""
    if (msg.match[2]?)
      user = msg.match[2]
    else
      user = msg.message.user.name
    robot.logger.debug user
    robot.logger.debug Util.inspect robot.brain.data.order
    for categoryName, category of robot.brain.data.order when categoryName is _categoryName
      for userName, food of category when userName is user
        for foodName, order of food
          if order?
            commands.Add order
            totalMoney += parseFloat( order.discount )
            flag = true
      if totalMoney isnt 0
        commands.Add "#{categoryName} total : #{totalMoney}"
        totalMoney = 0
        flag = true

    if (flag isnt true)
      commands.Add "you have no order."
    commands.Send()

  robot.respond /order show all/i, (msg) ->
    commands = new CommandStore msg
    categoryMoney = 0
    totalMoney = 0
    flag = false
    for categoryName, category of robot.brain.data.order
      for userName, food of category
        for foodName, order of food
          if order?
            commands.Add order
            categoryMoney += parseFloat( order.discount )
            totalMoney += parseFloat( order.discount )
      if categoryMoney isnt 0
        commands.Add "#{categoryName} total : #{categoryMoney}"
        categoryMoney = 0
        flag = true
  
    if(flag != true)
      commands.Add "There has no orders."
    else
      commands.Add "Total : #{totalMoney}"
    commands.Send()

  robot.respond /order reset all/i, (msg) ->
    robot.brain.data['order'] = {}
    msg.reply "you reset all orders !"

  robot.respond /order reset my/i, (msg) ->
    user = msg.message.user.name
    for categoryName, category of robot.brain.data.order
      flag = false
      for userName, food of category when userName is user
        flag = true
      delete category[user] if flag

    if flag
      msg.reply "you reset your orders !"

  robot.respond /order reset @(\S*)/i, (msg) ->
    user = msg.match[1]
    userId = parseTarget msg.message.rawText
    for categoryName, category of robot.brain.data.order
      flag = false
      for userName, food of category when userName is user
        flag = true
      delete category[user] if flag

    if flag
      msg.reply "you reset <@#{userId}|#{user}> orders !"

  robot.respond /order reset cate(?:g?o?r?y?) (\S*)/i, (msg) ->
    _categoryName = msg.match[1]
    flag = false
    for categoryName, category of robot.brain.data.order when categoryName is _categoryName
      msg.reply "you reset category #{_categoryName} !"
      delete robot.brain.data.order[_categoryName]

  robot.respond /order\s+set\s+disc(?:o?u?n?t?)\s+(\S*)\s+(\S*)/i, (msg) ->    
    categoryName = msg.match[1]
    discountRatio = msg.match[2]

    robot.brain.data.setting.discountRatio[categoryName] = parseFloat(discountRatio)

    if(robot.brain.data.order[categoryName]?)      
      for userName, food of robot.brain.data.order[categoryName]
        for foodName, order of food
          order.SetDiscountRatio discountRatio

    msg.reply "Set #{categoryName} discount ratio : #{discountRatio}"

  parseTarget = (text) ->
    robot.logger.warning text
    regexPattern = /order (.* for |reset )\<@?(\S*)\>/i
    matches = text.match regexPattern
    matches[2]

  GetReplyMsg = (order) ->
    if(order.note?)
      "Order #{order.category} #{order.food} #{order.note} $#{order.money} * #{order.discountRatio} = $#{order.discount} for <@#{order.userId}|#{order.user}>"
    else
      "Order #{order.category} #{order.food} $#{order.money} * #{order.discountRatio} = $#{order.discount} for <@#{order.userId}|#{order.user}>"