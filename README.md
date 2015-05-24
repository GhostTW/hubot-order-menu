# Hubot Order Menu

Make an order for easyily record and calculate total money requirement.

## Usage
`npm install hubot-order-menu`

[npm](https://www.npmjs.com/package/hubot-order-menu)

## Configuration:
 option
 `HUBOT_ORDER_MENU_STORE_INFO=[name1,phone1,Http:\\link1;name2,phone2,Http:\\link2]`

## Commands:
1. hubot order stores - show all store info.
2. hubot order \<category\> \(\<food\> \<note\> \)$\<money\>\( for @someone \) - make an order.
3. hubot order \<category\> del \<food\>\( for @someone \) - delete food record
4. hubot order show total\( for @someone \) - show your order.
5. hubot order show cate\(gory\) \<category\>\( for @someone \) - show someone category's orders and calculate total money needed.
6. hubot order show cate\(gory\) \<category\> all - show category's orders and calculate total money needed.
7. hubot order show all - show all orders and calculate total money needed.
8. hubot order show all sort by item - show all order sorted by item name.
9. hubot order reset all - reset all orders.
10. hubot order reset @someone - reset someone orders.
11. hubot order reset my - reset your orders.
12. hubot order reset category \<category\> - clear category.
13. hubot order set discount \<category\> - setting category's discount.