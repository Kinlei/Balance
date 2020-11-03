local Balance = require(game:GetService("ReplicatedStorage").Balance);

local Draggable = Balance:import("drag");
local Resizable = Balance:import("resi");
local Colour = Balance:import("colours");

local White = Color3.fromRGB(255,255,255);
local Black = Colour.Get(White, "comp");

for i = 0, 1, 0.01 do
	script.Parent.ImageColor3 = Colour.Get(i);
end

local NewDragger = Draggable.new(script.Parent.Container.Title, {
	Target = script.Parent,
	Enabled = true
})

local NewResizable = Resizable.new({
	Target = script.Parent,
	Size = 10,
	Enabled = true
})

NewResizable:Disable();
NewResizable:Enable();
NewResizable:Disable();
NewResizable:Enable();

wait(5);

NewResizable:Update({
	Speed = 0.2;
})
