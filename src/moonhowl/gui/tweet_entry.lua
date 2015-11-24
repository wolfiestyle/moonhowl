local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"

local tweet_entry = object:extend()

function tweet_entry:_init()
    local dialog = Gtk.Window{
        id = "tweet_entry",
        title = "Compose",
        Gtk.Box{
            orientation = "VERTICAL",
            margin = 3,
            Gtk.TextView{
                id = "entry",
                width_request = 250,
                height_request = 100,
                wrap_mode = "WORD_CHAR",
                on_key_release_event = self:bind(self.cmd_entry__on_key_release),
            },
            Gtk.Toolbar{
                hexpand = true,
                Gtk.ToolButton{
                    id = "add_image",
                    icon_name = "image-x-generic",
                    tooltip_text = "Upload media",
                },
                Gtk.ToolButton{
                    id = "add_emoji",
                    icon_name = "face-smile",
                    tooltip_text = "Insert emoji",
                },
                { Gtk.SeparatorToolItem{ draw = false }, expand = true },
                Gtk.ToolItem{
                    Gtk.Box {
                        spacing = 3,
                        Gtk.Label{ id = "chars", label = "0" },
                        Gtk.Button{
                            id = "cmd_send",
                            label = "Send",
                            on_clicked = self:bind(self.cmd_send__on_clicked),
                        },
                    }
                },
            },
        }
    }

    dialog:show_all()
    dialog:set_keep_above(true)

    local child = dialog.child
    self.handle = dialog
    self.entry = child.entry
    self.chars = child.chars

    self.buffer = self.entry:get_buffer()
end

function tweet_entry:cmd_send__on_clicked()
    local iter_s, iter_e = self.buffer:get_bounds()
    local text = self.buffer:get_text(iter_s, iter_e)
    self.handle:set_sensitive(false)
    return signal.emit("a_tweet", text, {
        ok = function(tweet)
            self.handle:destroy()
            return signal.emit("ui_tweet_sent", tweet)
        end,
        error = function(err)
            self.handle:set_sensitive(true)
            return err
        end,
    })
end

function tweet_entry:cmd_entry__on_key_release()
    local len = self.buffer:get_end_iter():get_offset()  --FIXME: this probably isn't how twitter measures tweet length
    return self.chars:set_label(len)
end

return tweet_entry
