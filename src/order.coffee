# Description:
#   Make an order for easyily record and calculate total money needed.
#
# Dependencies:
#   
#
# Configuration:
#
#
# Commands:
#   hubot order <food> <note> $<money> - make an order
#   hubot order <food> <note> $<money> for @someone - make an order for someone
#   hubot order my - show your order
#   hubot order all - show all orders and calculate total money needed.
#	hubot order reset - reset all orders
#
# Author:
#   Ghost.Yang
#

Util = require 'util'

module.exports = (robot) ->
	class Order
		constructor: (options) -> 
			{@name, @userId, @date, @food, @note, @money} = options

		toString: () ->
			"#{@name} - #{@food} #{@note} $#{@money}"

	robot.brain.data['orders'] = []

	robot.respond /order\s+(\S*)\s+((\S*\s+)+)?\$(\S*)(\s+for\s+@?(\S*))?/i, (msg) ->
		#robot.logger.debug Util.inspect(msg)
		date_current = new Date()
		food = msg.match[1]
		note = msg.match[2]
		money = msg.match[4]
		user = ""
		userId = ""
		if (msg.match[6]?)
			user = msg.match[6]
			userId = parseTarget msg.message.rawText
		else
			user = msg.message.user.name
			userId = msg.message.user.id

		order = new Order name:user, userId:userId, date:date_current, food:food, note:note, money:money

		for _order in robot.brain.data.orders
			if(_order.name is user)
				index = robot.brain.data.orders.indexOf(_order)
				robot.brain.data.orders.splice(index, 1)
				break

		robot.brain.data.orders.push order

		msg.reply "You order #{food} #{note} $#{money} for <@#{userId}|#{user}>}"

	robot.respond /order my/i, (msg) ->
		date_current = new Date()
		user = msg.message.user.name
		order = o for o in robot.brain.data.orders when o.name is user #and o.date.getDate() is date_current.getDate()
		if (order?)
			msg.reply order
		else
			msg.reply "you have no order."

	robot.respond /order all/i, (msg) ->
		date_current = new Date()
		orders = robot.brain.data.orders
		totalMoney = 0
		if (orders isnt null)
			totalMoney += parseInt( order.money, 10 ) for order in orders
			msg.reply order for order in orders #when order.date.getDate is date_current.getDate
			msg.reply "Total money : #{totalMoney}"
		else
			msg.reply "There has no orders."

	robot.respond /order reset/i, (msg) ->
		robot.brain.data['orders'] = []
		msg.reply "Orders reset !"

	parseTarget = (text) ->
		regexPattern = /order .* for \<@?(\S*)\>/i
		matches = text.match regexPattern
		matches[1]