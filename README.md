# Hubot Order Menu

Make an order for easyily record and calculate total money needed.

## Usage
`npm install hubot-order-menu`

[npm](https://www.npmjs.com/package/hubot-order-menu)

## Configuration:
 `HUBOT_ORDER_MENU_STORE_INFO=[name1,phone1,Http:\\link1;name2,phone2,Http:\\link2]`

## Commands:
 1. hubot order stores - show all store info.
 2. hubot order \<food\> \<note\> $\<money\> - make an order
 3. hubot order \<food\> \<note\> $\<money\> for @someone - make an order for someone
 4. hubot order my - show your order
 5. hubot order all - show all orders and calculate total money needed.
 6. hubot order reset - reset all orders

## Debug:
 1. npm install hubot
 2. add below code to `.\node_modules\hubot\bin\hubot` under line 96.
 
 ```  
    scriptsPath = Path.resolve ".", "src"
    robot.load scriptsPath
 ```
 3. exec `.\node_modules\.bin\hubot`

## Todo:
 1. Add unit tests.
 2. Add store menu.