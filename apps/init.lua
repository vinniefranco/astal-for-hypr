local astal = require("astal")
local src = require("lib").src

local scss = src("style.scss")
local css = "/tmp/launcher-style.css"

local App = require("astal.gtk3.app")
local AppLauncher = require("widgets.AppLauncher")

astal.exec("sass " .. scss .. " " .. css)

App:start({
  instance_name = "astal-ofi",
  css = css,
  request_handler = function(msg, res)
    print(msg)
    res("ok")
  end,
  main = function()
    AppLauncher()
  end
})
