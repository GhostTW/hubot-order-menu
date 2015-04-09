# Description:
#   Make an order for easyily record and calculate total money needed.
#
# Dependencies:
#   
#
# Configuration:
#	HUBOT_ORDER_MENU_STORE_INFO=[name1,phone1,Http:\\link1;name2,phone2,Http:\\link2]
#
# Commands:
#	hubot order stores - show all store info.
#   hubot order <food> (<note> )$<money> - make an order.
#   hubot order <food> (<note> )$<money> for @someone - make an order for someone.
#   hubot order my - show your order.
#   hubot order all - show all orders and calculate total money needed.
#	hubot order reset all - reset all orders.
#
# Author:
#   Ghost.Yang
#

Util = require 'util'

module.exports = (robot) ->
	class Order
		constructor: (options) -> 
			{@name, @userId, @date, @category, @food, @note, @money} = options

		toString: () ->
			GetReplyMsg @

	class Store
		constructor: (options) -> 
			{@name, @phone, @link} = options

		toString: () ->
			"#{@name} #{@phone} - #{@link}"

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

	robot.respond /order stores/i, (msg) ->
		msg.reply 'The HUBOT_ORDER_MENU_STORE_INFO environment variable not set' unless Stores.length
		msg.reply store for store in Stores

	robot.respond /order\s+(\S*)\s+(\S*)\s+((\S*\s+)+)?\$(\S*)(\s+for\s+@?(\S*))?/i, (msg) ->
		#robot.logger.debug Util.inspect(msg)
		date_current = new Date()
		category = msg.match[1]
		food = msg.match[2]
		note = msg.match[3]
		money = msg.match[5]
		user = ""
		userId = ""
		if (msg.match[7]?)
			user = msg.match[7]
			userId = parseTarget msg.message.rawText
		else
			user = msg.message.user.name
			userId = msg.message.user.id

		order = new Order name:user, userId:userId, date:date_current, category:category, food:food, note:note, money:money

		if(robot.brain.data.order[category]? != true)
			robot.brain.data.order[category]={}

		robot.brain.data.order[category][user] = order

		msg.reply GetReplyMsg order

	robot.respond /order my/i, (msg) ->
		flag = false
		user = msg.message.user.name
		for categoryName, category of robot.brain.data.order
			for userName, order of category when userName is user
				if order?
					msg.reply order
					flag = true

		if (flag isnt true)
			msg.reply "you have no order."

	robot.respond /order all/i, (msg) ->
		totalMoney = 0
		flag = false
		for categoryName, category of robot.brain.data.order
			for userName, order of category
				if order?
					msg.reply order
					totalMoney += parseInt( order.money, 10 )
			if totalMoney isnt 0
				msg.reply "Total money : #{totalMoney}"
				totalMoney = 0
				flag = true
	
		if(flag != true)
			msg.reply "There has no orders."

	robot.respond /order reset all/i, (msg) ->
		robot.brain.data['order'] = {}
		msg.reply "you reset all orders !"

	robot.respond /order reset my/i, (msg) ->
		user = msg.message.user.name
		for categoryName, category of robot.brain.data.order
			flag = false
			for userName, order of category when userName is user
				flag = true
			category[user] = null if flag

		if flag
			msg.reply "you reset your orders !"

	robot.respond /order reset @(\S*)/i, (msg) ->
		user = msg.match[1]
		userId = parseTarget msg.message.rawText
		for categoryName, category of robot.brain.data.order
			flag = false
			for userName, order of category when userName is user
				flag = true
			category[user] = null if flag

		if flag
			msg.reply "you reset <@#{userId}|#{user}> orders !"

	parseTarget = (text) ->
		robot.logger.warning text
		regexPattern = /order (.* for |reset )\<@?(\S*)\>/i
		matches = text.match regexPattern
		matches[2]

	GetReplyMsg = (order) ->
		if(order.note?)
			"Order [#{order.category}] #{order.food} #{order.note} $#{order.money} for <@#{order.userId}|#{order.user}>"
		else
			"Order [#{order.category}] #{order.food} $#{order.money} for <@#{order.userId}|#{order.user}>"