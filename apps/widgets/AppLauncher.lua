local astal = require("astal")
local map = require("lib").map
local bind = astal.bind

local Apps = astal.require("AstalApps")
local Gdk = astal.require("Gdk", "3.0")
local Variable = require("astal").Variable
local Widget = require("astal.gtk3.widget")

local AppButton = function(app)
  local app = app
  return Widget.Button({
    class_name = "AppButton",
    on_clicked = function(self)
      app.launch(app)
    end,
    Widget.Label({
      label = app.name
    })
  })
end

return function()
  local apps = Apps.Apps({
    name_multiplier = 2,
    entry_multiplier = 0,
    executable_multiplier = 2,
  })
  local found_apps = Variable({})
  local text = Variable("")
  return Widget.Window({
    class_name = "AppLauncher",
    halign = "CENTER",
    exclusivity = "IGNORE",
    keymode = "ON_DEMAND",
    on_key_press_event = function(self, event)
      if event.keyval == Gdk.KEY_BackSpace then
        local del_val = text:get():sub(1, -2)
        text:set(del_val)
        found_apps:set(apps:fuzzy_query(del_val))
      elseif event.keyval == Gdk.KEY_Escape then
        self:close()
      else
        local new_val = text:get() .. event.string

        text:set(new_val)
        found_apps:set(apps:fuzzy_query(new_val))
      end
    end,
    Widget.Box({
      Widget.Label({
        label = text(function(value)
          return string.format("transformed %s", value)
        end)
      }),
      Widget.Box({
        bind(found_apps):as(function(fapps)
          return map(fapps, function(app)
            return AppButton(app)
          end)
        end)
      })
    })
  })
end
