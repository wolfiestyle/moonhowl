local lgi = require "lgi"
local Gtk = lgi.Gtk
local Moonhowl = lgi.package "Moonhowl"

-- create a derived class so we get the 'priv' field added by lgi
Moonhowl:class("ListBoxRow", Gtk.ListBoxRow)

return Moonhowl
