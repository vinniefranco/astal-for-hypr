local astal = require("astal")
local src = require("lib").src

local scss = src("style.scss")
local css = "/tmp/style.css"

local App = require("astal.gtk3.app")
local Bar = require("widgets.Bar")

astal.exec("sass " .. scss .. " " .. css)

App:start({
  instance_name = "lua-bar",
  css = css,
  request_handler = function(msg, res)
    print(msg)
    res("ok")
  end,
  main = function()
    for _, mon in pairs(App.monitors) do
      Bar(mon)
    end
  end
})
