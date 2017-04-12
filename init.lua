--[[
this is a try to make a textarea with scrollbar
it doesn't work yet
it would be good for very long texts (like lua code)
]]

local temptexts = {}

local function make_formspec(text, y)
	return "size[5,5]"..
		"textarea[0,0.5;5,4.5;text;;"..text.."]"..
		"button_exit[2,4.5;2,1;save;Save]"..
		"button_exit[4,-0.5;0.8,1;exit;X]"..
		"scrollbar[4.6,0.2;0.3,4.5;vertical;scrob;"..y.."]"
end

minetest.register_node("textareascroll:node", {
	description = "scrolltest",
	tiles = {"default_stone.png^default_glass.png"},
	groups = {dig_immediate=2},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("text", "")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local playername = clicker:get_player_name()
		local text = minetest.get_meta(pos):get_string("text")
		temptexts[playername] = text
		minetest.show_formspec(playername,
				"textareascroll:node_formspec0000"..minetest.pos_to_string(pos),
				make_formspec(text, 0))
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:sub(1, 28) ~= "textareascroll:node_formspec" then
		return false
	end
	local old_y = tonumber(formname:sub(29, 32))
	local pos = minetest.string_to_pos(formname:sub(33))
	print(dump(fields))
	if fields.quit == "true" then
		if not fields.save then -- esc, enter, exit button
			return true
		end
		local temptext = temptexts[player:get_player_name()]
		--~ local lines = temptext:split("\n")
		--~ local firstline = math.floor(#lines * old_y / 1000)
		--~ local text = ""
		--~ for i = firstline, #lines do
			--~ text = text..lines[i]
		--~ end
		local meta = minetest.get_meta(pos)
		meta:set_string("text", temptext)
		return true
	end
	if fields.scrob:sub(1, 4) ~= "CHG:" then
		return true
	end
	local y = tonumber(fields.scrob:sub(5))
	local playername = player:get_player_name()
	local temptext = temptexts[playername]
	local lines = temptext:split("\n")
	if #lines == 0 then
		lines = {temptext}
	end
	print(dump(lines))
	local old_firstline = math.floor(#lines * old_y / 1000)
	if old_firstline < 1 then
		old_firstline = 1
	end
	local old_rest = ""
	for i = 1, old_firstline do
		old_rest = old_rest..lines[i]
	end
	temptext = old_rest..fields.text
	lines = temptext:split("\n")
	local firstline = math.floor(#lines * y / 1000)
	if firstline < 1 then
		firstline = 1
	end
	local text = ""
	for i = firstline, #lines do
		text = text..lines[i]
	end
	local form_y = tostring(y)
	while #form_y < 4 do
		form_y = "0"..form_y
	end
	minetest.show_formspec(playername,
			"textareascroll:node_formspec"..form_y..minetest.pos_to_string(pos),
			make_formspec(text, y))
	return true
end)
