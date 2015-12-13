package = "moonhowl"
version = "scm-1"

source = {
    url = "git://github.com/darkstalker/moonhowl.git",
}

description = {
    summary = "Twitter client written in Lua",
    detailed = [[
        Twitter client written in Lua.
    ]],
    homepage = "https://github.com/darkstalker/moonhowl",
    license = "MPL-2.0",
}

dependencies = {
    "lua >= 5.1",
    "lgi >= 0.9.0",
    "lpeg >= 0.12.2",
    "luatwit >= 0.3.4",
    "luautf8 >= 0.1",
    "penlight >= 1.3.2",
}

build = {
    type = "builtin",
    modules = {
        ["moonhowl.account"] = "src/moonhowl/account.lua",
        ["moonhowl.cb_handler"] = "src/moonhowl/cb_handler.lua",
        ["moonhowl.commands"] = "src/moonhowl/commands.lua",
        ["moonhowl.config"] = "src/moonhowl/config.lua",
        ["moonhowl.defaults"] = "src/moonhowl/defaults.lua",
        ["moonhowl.entities"] = "src/moonhowl/entities.lua",
        ["moonhowl.fifo"] = "src/moonhowl/fifo.lua",
        ["moonhowl.gui.account_ui"] = "src/moonhowl/gui/account_ui.lua",
        ["moonhowl.gui.default_min_view"] = "src/moonhowl/gui/default_min_view.lua",
        ["moonhowl.gui.default_view"] = "src/moonhowl/gui/default_view.lua",
        ["moonhowl.gui.dm_list_view"] = "src/moonhowl/gui/dm_list_view.lua",
        ["moonhowl.gui.dm_view"] = "src/moonhowl/gui/dm_view.lua",
        ["moonhowl.gui.image_view"] = "src/moonhowl/gui/image_view.lua",
        ["moonhowl.gui.info_bar"] = "src/moonhowl/gui/info_bar.lua",
        ["moonhowl.gui.init"] = "src/moonhowl/gui/init.lua",
        ["moonhowl.gui.list_view"] = "src/moonhowl/gui/list_view.lua",
        ["moonhowl.gui.list_view_cursored"] = "src/moonhowl/gui/list_view_cursored.lua",
        ["moonhowl.gui.list_view_scrolled"] = "src/moonhowl/gui/list_view_scrolled.lua",
        ["moonhowl.gui.main_loop"] = "src/moonhowl/gui/main_loop.lua",
        ["moonhowl.gui.main_ui"] = "src/moonhowl/gui/main_ui.lua",
        ["moonhowl.gui.main_window"] = "src/moonhowl/gui/main_window.lua",
        ["moonhowl.gui.media_view"] = "src/moonhowl/gui/media_view.lua",
        ["moonhowl.gui.nav_bar"] = "src/moonhowl/gui/nav_bar.lua",
        ["moonhowl.gui.page_container"] = "src/moonhowl/gui/page_container.lua",
        ["moonhowl.gui.profile_view"] = "src/moonhowl/gui/profile_view.lua",
        ["moonhowl.gui.rich_text_view"] = "src/moonhowl/gui/rich_text_view.lua",
        ["moonhowl.gui.stream_event_view"] = "src/moonhowl/gui/stream_event_view.lua",
        ["moonhowl.gui.tab_label"] = "src/moonhowl/gui/tab_label.lua",
        ["moonhowl.gui.tabbed_container"] = "src/moonhowl/gui/tabbed_container.lua",
        ["moonhowl.gui.timer"] = "src/moonhowl/gui/timer.lua",
        ["moonhowl.gui.tweet_entry"] = "src/moonhowl/gui/tweet_entry.lua",
        ["moonhowl.gui.tweet_list_view"] = "src/moonhowl/gui/tweet_list_view.lua",
        ["moonhowl.gui.tweet_search_view"] = "src/moonhowl/gui/tweet_search_view.lua",
        ["moonhowl.gui.tweet_view"] = "src/moonhowl/gui/tweet_view.lua",
        ["moonhowl.gui.user_cursor_view"] = "src/moonhowl/gui/user_cursor_view.lua",
        ["moonhowl.gui.user_list_view"] = "src/moonhowl/gui/user_list_view.lua",
        ["moonhowl.gui.user_view"] = "src/moonhowl/gui/user_view.lua",
        ["moonhowl.img_store"] = "src/moonhowl/img_store.lua",
        ["moonhowl.init"] = "src/moonhowl/init.lua",
        ["moonhowl.location"] = "src/moonhowl/location.lua",
        ["moonhowl.object"] = "src/moonhowl/object.lua",
        ["moonhowl.signal"] = "src/moonhowl/signal.lua",
        ["moonhowl.ui"] = "src/moonhowl/ui.lua",
        ["moonhowl.version"] = "src/moonhowl/version.lua",
        ["moonhowl.xdg"] = "src/moonhowl/xdg.lua",
    },
    install = {
        bin = { moonhowl = "bin/moonhowl" },
    },
}
