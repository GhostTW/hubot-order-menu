# Description:
#   Make an order for easy record.
#
# Dependencies:
#   
#
# Configuration:
#
#
# Commands:
#   hubot order <food> $<money> - make an order
#   hubot order <food> $<money> for @somone - make an order for someone
#   hubot show my order - show your order
#   hubot show orders - show all orders and calculate total money.
#
# Author:
#   Ghost.Yang
#

Util = require 'util'

module.exports = (robot) ->
	class Order
		constructor: (options) -> 
			{@name, @userId, @date, @food, @money} = options

		toString: () ->
			"#{@name}, #{@userId}, #{@food}, $#{@money}, #{@date}"

	robot.brain.data['orders'] = []

	robot.respond /order (\S*) \$(\S*)( for @(\S*))?/i, (msg) ->
		#robot.logger.debug Util.inspect(msg)
		date_current = new Date()
		food = msg.match[1]
		money = msg.match[2]
		user = ""
		userId = ""
		if (msg.match[4]?)
			user=msg.match[4]
			userId = parseTarget msg.message.rawText
		else
			user = msg.message.user.name
			userId = msg.message.user.id

		order = new Order name:user, userId:userId, date:date_current, food:food, money:money

		isOrderExist = false
		for _order in robot.brain.data.orders
			if(_order.name is order.name)
				_order = order
				isOrderExist = true
				break

		if(isOrderExist isnt true)
			robot.brain.data.orders.push order

		msg.reply "You order #{food} $#{money} for <@#{userId}|#{user}> at #{date_current}"

	robot.respond /show my order/i, (msg) ->
		date_current = new Date()
		user = msg.message.user.name
		order = o for o in robot.brain.data.orders when o.name is user
		if (order?)
			msg.reply order
		else
			msg.reply "you have no order."

	robot.respond /show orders/i, (msg) ->
		date_current = new Date()
		orders = robot.brain.data.orders
		robot.logger.debug Util.inspect(orders)
		totalMoney = 0
		if (orders isnt null)
			robot.logger.debug Util.inspect(order) for order in orders
			totalMoney += parseInt( order.money, 10 ) for order in orders
			msg.reply order for order in orders # when order.date.getDate() is date_current.getDate()
			msg.reply "Total money : #{totalMoney}"
		else
			msg.reply "There has no orders."

	parseTarget = (text) ->
		regexPattern = /order .* for \<\@(\S*)\>/i
		matches = text.match regexPattern
		matches[1]