--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

local ArtilleryWorm = {}

function ArtilleryWorm.GenerateNew(data)
	local surface = game.player.surface
	local entities = surface.find_entities_filtered{force = "enemy", type = 'turret'}
	if #entities <= 0 then
		game.print("�� ����� �� ���������� ������. ��������� ����� ���������� �� ��������!")
		do return end
	end
	--game.print(#entities) ������� ����� ������ ������� ����������
	local i = math.random(#entities)
	local position = entities[i].position
	entities[i].destroy()
	surface.create_entity{name = 'artillery-worm-turret', position = position}
	game.print("���� �� ������ ����������� � ����������!")
end

return ArtilleryWorm