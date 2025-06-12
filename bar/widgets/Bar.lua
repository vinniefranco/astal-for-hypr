local astal = require("astal")
local bind = astal.bind
local map = require("lib").map

local Anchor = astal.require("Astal", "3.0").WindowAnchor
local App = require("astal.gtk3.app")
local Battery = astal.require("AstalBattery")
local GLib = astal.require("GLib")
local Gdk = astal.require("Gdk", "3.0")
local Hyprland = astal.require("AstalHyprland")
local Network = astal.require("AstalNetwork")
local Tray = astal.require("AstalTray")
local Variable = astal.Variable
local Widget = require("astal.gtk3.widget")
local Wp = astal.require("AstalWp")

local function AudioSlider()
  local speaker = Wp.get_default().audio.default_speaker

  return Widget.Box({
    class_name = "AudioSlider",
    css = "min-width: 140px;",
    Widget.Button({
      on_clicked = function()
        speaker.mute = not speaker.mute
      end,
      Widget.Icon({
        icon = bind(speaker, "volume-icon"),
      }),
    }),
    Widget.Slider({
      hexpand = true,
      on_dragged = function(self)
        speaker.volume = self.value
      end,
      value = bind(speaker, "volume"),
    }),
  })
end

local function BatteryLevel()
  local bat = Battery.get_default()

  return Widget.Box({
    class_name = "Battery",
    visible = bind(bat, "is-present"),
    Widget.Icon({
      icon = bind(bat, "battery-icon-name"),
    }),
    Widget.Label({
      label = bind(bat, "percentage"):as(function(p)
        return tostring(math.floor(p * 100)) .. " %"
      end),
    }),
  })
end

local function FocusedClient()
  local hypr = Hyprland.get_default()
  local focused = bind(hypr, "focused-client")

  return Widget.Box({
    class_name = "Focused",
    visible = focused,
    focused:as(function(client)
      return client and Widget.Label({
        label = bind(client, "title"):as(tostring),
      })
    end),
  })
end

local function SysTray()
  local tray = Tray.get_default()

  return Widget.Box({
    class_name = "Tray",
    bind(tray, "items"):as(function(items)
      return map(items, function(item)
        return Widget.MenuButton({
          tooltip_markup = bind(item, "tooltip_markup"),
          use_popover = false,
          menu_model = bind(item, "menu-model"),
          action_group = bind(item, "action-group"):as(
            function(ag) return { "dbusmenu", ag } end
          ),
          Widget.Icon({
            gicon = bind(item, "gicon"),
          }),
        })
      end)
    end),
  })
end

local function Time(format)
  local time = Variable(""):poll(1000, function()
    return GLib.DateTime.new_now_local():format(format)
  end)

  return Widget.Label({
    class_name = "Time",
    on_destroy = function()
      time:drop()
    end,
    label = time(),
  })
end

local function Workspaces(_gdkmonitor)
  local hypr = Hyprland.get_default()
  local workspace_icons = { "", "󰧑", "", "", "󰊕", "󰯜", "", "", "", }

  return Widget.Box({
    class_name = "Workspaces",
    bind(hypr, "workspaces"):as(function(wss)
      table.sort(wss, function(a, b)
        return a.id < b.id
      end)

      return map(
        wss,
        function(ws)
          return Widget.Button({
            class_name = bind(hypr, "focused-workspace"):as(function(fw)
              return fw == ws and "focused" or ""
            end),
            on_clicked = function()
              ws:focus()
            end,
            label = bind(ws, "id"):as(function(v)
              if type(v) == "number" then
                return workspace_icons[v]
              else
                return v
              end
            end),
          })
        end)
    end),
  })
end

local function Wifi()
  local wifi = Network.get_default().wifi

  return Widget.Box({
    Widget.Icon({
      tooltip_text = bind(wifi, "ssid"):as(tostring),
      class_name = "Wifi",
      icon = bind(wifi, "icon-name"),
    }),
    Widget.Label({
      label = bind(wifi, "ssid"):as(tostring),
    }),
  })
end

return function(gdkmonitor)
  return Widget.Window({
    class_name = "Bar",
    gdkmonitor = gdkmonitor,
    anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
    exclusivity = "EXCLUSIVE",
    Widget.CenterBox({
      Widget.Box({
        halign = "START",
        Workspaces(gdkmonitor),
        Time("%l:%M %p  %A %e"),
      }),
      Widget.Box({
        FocusedClient(),
      }),
      Widget.Box({
        halign = "END",
        AudioSlider(),
        BatteryLevel(),
        Wifi(),
        SysTray(),
      }),
    })
  })
end
