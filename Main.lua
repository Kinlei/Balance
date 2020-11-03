local Player = game.Players.LocalPlayer;
local Mouse = Player:GetMouse();

local TweenService, RunService, TextService, InputService = game:GetService("TweenService"), game:GetService("RunService"), game:GetService("TextService"), game:GetService("UserInputService");

local Balance = {};

Balance.Draggable = {};
Balance.Draggable.Cache = {};

Balance.Resizable = {};
Balance.Resizable.Cache = {};

Balance.Drawing = { 
	Requirements = { 
		HasDrawingLibrary = syn or SENTINEL_LOADED or pebc_create or false 
	} 
};
Balance.Drawing.Cache = {};

Balance.Colours = {};
Balance.Colours.Cache = {};

local Colours = Balance.Colours;

function GetRGB(Colour)
	return Colour.R, Colour.G, Colour.B;
end

function ColourWheel()
	local ColourWheelTable = {};
	ColourWheelTable[1] = Color3.fromRGB(255,0,0);
	ColourWheelTable[2] = Color3.fromRGB(255,255,0);
	ColourWheelTable[3] = Color3.fromRGB(0,255,0);
	ColourWheelTable[4] = Color3.fromRGB(0,0,255);
	ColourWheelTable[5] = Color3.fromRGB(255,0,0);
	
	return setmetatable(ColourWheelTable, {
		__index = function(self, idx)
			idx = math.clamp(idx, 0, 1);
			idx = 5 * idx;
			local LowValue, UpValue = math.floor(idx), math.ceil(idx);
			LowValue, UpValue = math.clamp(LowValue, 1, 5), math.clamp(UpValue, 1, 5);
			return rawget(ColourWheelTable, LowValue):Lerp(rawget(ColourWheelTable, UpValue), idx/5);
		end
	})
end

local ColourFuncs = {
	complimentary = function(Colour)
		local R, G, B = GetRGB(Colour);
		return Color3.fromRGB(1-R,1-G,1-B);
	end,
}

function GetColourFunction(Func)
	local AvailableFunctions = {};
	
	for Function, _ in next, ColourFuncs do
		table.insert(AvailableFunctions, Function);
	end
	
	for _, Function in next, AvailableFunctions do
		if (Function:sub(1, #Func):lower() == Func:lower()) then
			return ColourFuncs[Function];
		end
	end
	
	return false;
end

function Colours.Get(Colour, Mode)
	if (Colour) and (typeof(Colour) == "number") then
		return ColourWheel()[Colour];
	elseif (not Mode) and (Colour) then
		return Colour;
	elseif (Colour and (typeof(Colour) == "Color3")) then
		local Mode = GetColourFunction(Mode);
		if Mode then
			return Mode(Colour);
		else
			return warn("Invalid colour mode: '"..Mode.."'.");
		end
	end
end

local Drawing = Balance.Drawing;

local Draggable = Balance.Draggable;

function Draggable.new(GuiObject, Config)
	if (not Draggable.Cache[GuiObject]) then
		local Enabled = Config.Enabled or false;
		local Speed = Config.Speed or 0;
		local Style = Config.Style or Enum.EasingStyle.Linear;
		local Target = Config.Target or GuiObject;
		local Direction = Config.Direction or Enum.EasingDirection.Out;
		
		local TweenInformation = TweenInfo.new(Speed, Style, Direction);
		
		local EventConnection;
		
		if (Enabled) then
			pcall(function() EventConnection:Disconnect(); EventConnection = nil; end);
			EventConnection = GuiObject.MouseButton1Down:Connect(function()
				local Dx, Dy = Mouse.X - Target.AbsolutePosition.X, Mouse.Y - Target.AbsolutePosition.Y;
				local MouseMove, MouseKill;
				MouseMove = Mouse.Move:Connect(function()
					TweenService:Create(Target, TweenInformation, {Position = UDim2.fromOffset(Mouse.X - Dx, Mouse.Y - Dy)}):Play();
				end)
				MouseKill = InputService.InputEnded:Connect(function(UserInput)
					if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseMove:Disconnect();
						MouseKill:Disconnect();
					end
				end)
			end)
		end
		
		local MethodTable = setmetatable({
			__Self = GuiObject,
			__Enabled = Enabled,
			__Speed = Speed,
			__Style = Style,
			__Target = Target,
			__Direction = Direction,
			__TweenInfo = TweenInformation,
			__Event = EventConnection
		}, {
			__index = Draggable
		})
		
		Draggable.Cache[GuiObject] = MethodTable;
		
		return MethodTable;
	else
		return Draggable.Cache[GuiObject];
	end
end

function Draggable:Enable()
	if self.__Enabled then
		return;
	else
		self.__Enabled = true;
		pcall(function() self.__Event:Disconnect(); self.__Event = nil; end);
		self.__Event = self.__Self.MouseButton1Down:Connect(function()
			local Dx, Dy = Mouse.X - self.__Target.AbsolutePosition.X, Mouse.Y - self.__Target.AbsolutePosition.Y;
			local MouseMove, MouseKill;
			MouseMove = Mouse.Move:Connect(function()
				TweenService:Create(self.__Target, self.__TweenInfo, {Position = UDim2.fromOffset(Mouse.X - Dx, Mouse.Y - Dy)}):Play();
			end)
			MouseKill = InputService.InputEnded:Connect(function(UserInput)
				if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
					MouseMove:Disconnect();
					MouseKill:Disconnect();
				end
			end)
		end)
	end
end

function Draggable:Disable()
	if not self.__Enabled then
		return;
	else
		self.__Enabled = false;
		pcall(function() self.__Event:Disconnect(); self.__Event = nil; end);
	end
end



function Draggable:Update(NewConfig)
	local Enabled = NewConfig.Enabled or self.__Enabled;
	local Speed = NewConfig.Speed or self.__Speed;
	local Style = NewConfig.Style or self.__Style;
	local Target = NewConfig.Target or self.__Target;
	local Direction = NewConfig.Direction or self.__Direction;
	
	local TweenInformation = TweenInfo.new(Speed, Style, Direction);
	
	self.__Enabled = Enabled;
	self.__Speed = Speed;
	self.__Style = Style;
	self.__Target = Target;
	self.__Direction = Direction;
	self.__TweenInfo = TweenInformation;
	
	pcall(function() self.__Event:Disconnect(); self.__Event = nil; end);
	
	if (Enabled) then
		self.__Event = self.__Self.MouseButton1Down:Connect(function()
			local Dx, Dy = Mouse.X - self.__Target.AbsolutePosition.X, Mouse.Y - self.__Target.AbsolutePosition.Y;
			local MouseMove, MouseKill;
			MouseMove = Mouse.Move:Connect(function()
				TweenService:Create(self.__Target, self.__TweenInfo, {Position = UDim2.fromOffset(Mouse.X - Dx, Mouse.Y - Dy)}):Play();
			end)
			MouseKill = InputService.InputEnded:Connect(function(UserInput)
				if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
					MouseMove:Disconnect();
					MouseKill:Disconnect();
				end
			end)
		end)
	end
end

local Resizable = Balance.Resizable;

Resizable.Cache["nil"] = "No target found.";

function U2ToV2(U2)
	return Vector2.new(U2.X, U2.Y);
end

function V2ToU2(V2)
	return UDim2.fromOffset(V2.X, V2.Y);
end

function Resizable.new(Config)
	local Target = Config.Target or "nil";
	if (not Resizable.Cache[Target]) then
		local Enabled = Config.Enabled or false;
		local Size = Config.Size or 5;
		local Speed = Config.Speed or 0;
		local Style = Config.Style or Enum.EasingStyle.Linear;
		local Direction = Config.Direction or Enum.EasingDirection.Out;
		local Target = Target;
		local MaxSize = Config.MaxSize or (U2ToV2(Target.AbsoluteSize) + Vector2.new(100,100));
		local MinSize = Config.MinSize or (U2ToV2(Target.AbsoluteSize) - Vector2.new(100,100));
		local CurrentWidth = Target.AbsoluteSize.X;
		local CurrentHeight = Target.AbsoluteSize.Y;
		
		local TweenInformation = TweenInfo.new(Speed, Style, Direction);
		
		local function SetHeight(Height)
			CurrentHeight = math.clamp(Height or CurrentHeight, MinSize.Y, MaxSize.Y);
			TweenService:Create(Target, TweenInformation, {Size = UDim2.fromOffset(CurrentWidth, CurrentHeight)}):Play()
		end
		
		local function SetWidth(Width)
			CurrentWidth = math.clamp(Width or CurrentWidth, MinSize.X, MaxSize.X);
			TweenService:Create(Target, TweenInformation, {Size = UDim2.fromOffset(CurrentWidth, CurrentHeight)}):Play()
		end
		
		local HiddenButtons, EventConnections = {}, {};
		
		if (Enabled) then
			HiddenButtons.Bottom = {
				__Size = UDim2.fromScale(1,0) + UDim2.fromOffset(0,Size),
				__Position = UDim2.fromScale(0,1) - UDim2.fromOffset(0,Size)
			}
			
			HiddenButtons.Right = {
				__Size = UDim2.fromScale(0,1) + UDim2.fromOffset(Size,0),
				__Position = UDim2.fromScale(1,0) - UDim2.fromOffset(Size,0)
			}
			
			HiddenButtons.Both = {
				__Size = UDim2.fromScale(0,0) + UDim2.fromOffset(Size,Size),
				__Position = UDim2.fromScale(1,1) - UDim2.fromOffset(Size,Size)
			}
			
			local function NewConstructor(Name)
				local __NewConstructor = Instance.new("TextButton");
				__NewConstructor.Name = Name;
				__NewConstructor.Text = "";
				__NewConstructor.BackgroundTransparency = 1;
				return __NewConstructor;
			end
			
			local Bottom = NewConstructor("Bottom");
			Bottom.Size = HiddenButtons.Bottom.__Size;
			Bottom.Position = HiddenButtons.Bottom.__Position;
			Bottom.Parent = Target;
			
			local Right = NewConstructor("Right");
			Right.Size = HiddenButtons.Right.__Size;
			Right.Position = HiddenButtons.Right.__Position;
			Right.Parent = Target;
			
			local Both = NewConstructor("Both");
			Both.Size = HiddenButtons.Both.__Size;
			Both.Position = HiddenButtons.Both.__Position;
			Both.Parent = Target;
			
			EventConnections.Bottom = Bottom.MouseButton1Down:Connect(function()
				Bottom.MouseButton1Down:Connect(function()
					local SY = Target.AbsolutePosition.Y + CurrentHeight
					local MouseMove, MouseKill
					MouseMove = Mouse.Move:Connect(function()
						local NMY = Mouse.Y
						local DY = NMY - SY
						SetHeight(CurrentHeight + DY)
						SY = Target.AbsolutePosition.Y + CurrentHeight
					end)
					MouseKill = InputService.InputEnded:Connect(function(UserInput)
						if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
							MouseMove:Disconnect()
							MouseKill:Disconnect()
						end
					end)
				end)
			end)
			
			EventConnections.Right = Right.MouseButton1Down:Connect(function()
				local SX = Target.AbsolutePosition.X + CurrentWidth
				local MouseMove, MouseKill
				MouseMove = Mouse.Move:Connect(function()
					local NMX = Mouse.X
					local DX = NMX - SX
					SetWidth(CurrentWidth + DX)
					SX = Target.AbsolutePosition.X + CurrentWidth
				end)
				MouseKill = InputService.InputEnded:Connect(function(UserInput)
					if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseMove:Disconnect()
						MouseKill:Disconnect()
					end
				end)
			end)
			
			EventConnections.Both = Both.MouseButton1Down:Connect(function()
				local SX, SY = Target.AbsolutePosition.X + CurrentWidth, Target.AbsolutePosition.Y + CurrentHeight
				local MouseMove, MouseKill
				MouseMove = Mouse.Move:Connect(function()
					local NMX, NMY = Mouse.X, Mouse.Y
					local DX, DY = NMX - SX, NMY - SY
					SetWidth(CurrentWidth + DX)
					SetHeight(CurrentHeight + DY)
					SX = Target.AbsolutePosition.X + CurrentWidth
					SY = Target.AbsolutePosition.Y + CurrentHeight
				end)
				MouseKill = InputService.InputEnded:Connect(function(UserInput)
					if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseMove:Disconnect()
						MouseKill:Disconnect()
					end
				end)
			end)
		end
			
		local MethodTable = setmetatable({
			__Events = EventConnections,
			__Buttons = HiddenButtons,
			__Enabled = Enabled, 
			__MaxSize = MaxSize,
			__MinSize = MinSize,
			__Size = Size,
			__Speed = Speed,
			__Direction = Direction,
			__Style = Style,
			__Target = Target,
			__CurrentHeight = CurrentHeight,
			__CurrentWidth = CurrentWidth,
			__TweenInformation = TweenInformation
		}, {
			__index = Resizable
		})
		
		Resizable.Cache[Target] = MethodTable;
		
		return MethodTable;
	else
		return Resizable.Cache[Target];
	end
end

function Resizable:Enable()
	if self.__Enabled then
		return;
	else
		self.__Enabled = true;
		for Idx, Event in next, self.__Events do
			pcall(function() Event:Disconnect(); table.remove(self.__Events, Idx); end);
		end
		
		local CurrentHeight, CurrentWidth = self.__CurrentHeight, self.__CurrentWidth;
		
		local function SetHeight(Height)
			CurrentHeight = math.clamp(Height or CurrentHeight, self.__MinSize.Y, self.__MaxSize.Y);
			TweenService:Create(self.__Target, self.__TweenInformation, {Size = UDim2.fromOffset(CurrentWidth, CurrentHeight)}):Play()
		end
		
		local function SetWidth(Width)
			CurrentWidth = math.clamp(Width or CurrentWidth, self.__MinSize.X, self.__MaxSize.X);
			TweenService:Create(self.__Target, self.__TweenInformation, {Size = UDim2.fromOffset(CurrentWidth, CurrentHeight)}):Play()
		end
		
		self.__Buttons.Bottom = {
			__Size = UDim2.fromScale(1,0) + UDim2.fromOffset(0,self.__Size),
			__Position = UDim2.fromScale(0,1) - UDim2.fromOffset(0,self.__Size)
		}
		
		self.__Buttons.Right = {
			__Size = UDim2.fromScale(0,1) + UDim2.fromOffset(self.__Size,0),
			__Position = UDim2.fromScale(1,0) - UDim2.fromOffset(self.__Size,0)
		}
		
		self.__Buttons.Both = {
			__Size = UDim2.fromScale(0,0) + UDim2.fromOffset(self.__Size,self.__Size),
			__Position = UDim2.fromScale(1,1) - UDim2.fromOffset(self.__Size,self.__Size)
		}
		
		local function NewConstructor(Name)
			local __NewConstructor = Instance.new("TextButton");
			__NewConstructor.Name = Name;
			__NewConstructor.Text = "";
			__NewConstructor.BackgroundTransparency = 1;
			return __NewConstructor;
		end
		
		local Bottom = NewConstructor("Bottom");
		Bottom.Size = self.__Buttons.Bottom.__Size;
		Bottom.Position = self.__Buttons.Bottom.__Position;
		Bottom.Parent = self.__Target;
		
		local Right = NewConstructor("Right");
		Right.Size = self.__Buttons.Right.__Size;
		Right.Position = self.__Buttons.Right.__Position;
		Right.Parent = self.__Target;
		
		local Both = NewConstructor("Both");
		Both.Size = self.__Buttons.Both.__Size;
		Both.Position = self.__Buttons.Both.__Position;
		Both.Parent = self.__Target;
		
		self.__Events.Bottom = Bottom.MouseButton1Down:Connect(function()
			Bottom.MouseButton1Down:Connect(function()
				local SY = self.__Target.AbsolutePosition.Y + CurrentHeight
				local MouseMove, MouseKill
				MouseMove = Mouse.Move:Connect(function()
					local NMY = Mouse.Y
					local DY = NMY - SY
					SetHeight(CurrentHeight + DY)
					SY = self.__Target.AbsolutePosition.Y + CurrentHeight
				end)
				MouseKill = InputService.InputEnded:Connect(function(UserInput)
					if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseMove:Disconnect()
						MouseKill:Disconnect()
					end
				end)
			end)
		end)
		
		self.__Events.Right = Right.MouseButton1Down:Connect(function()
			local SX = self.__Target.AbsolutePosition.X + CurrentWidth
			local MouseMove, MouseKill
			MouseMove = Mouse.Move:Connect(function()
				local NMX = Mouse.X
				local DX = NMX - SX
				SetWidth(CurrentWidth + DX)
				SX = self.__Target.AbsolutePosition.X + CurrentWidth
			end)
			MouseKill = InputService.InputEnded:Connect(function(UserInput)
				if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
					MouseMove:Disconnect()
					MouseKill:Disconnect()
				end
			end)
		end)
		
		self.__Events.Both = Both.MouseButton1Down:Connect(function()
			local SX, SY = self.__Target.AbsolutePosition.X + CurrentWidth, self.__Target.AbsolutePosition.Y + CurrentHeight
			local MouseMove, MouseKill
			MouseMove = Mouse.Move:Connect(function()
				local NMX, NMY = Mouse.X, Mouse.Y
				local DX, DY = NMX - SX, NMY - SY
				SetWidth(CurrentWidth + DX)
				SetHeight(CurrentHeight + DY)
				SX = self.__Target.AbsolutePosition.X + CurrentWidth
				SY = self.__Target.AbsolutePosition.Y + CurrentHeight
			end)
			MouseKill = InputService.InputEnded:Connect(function(UserInput)
				if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
					MouseMove:Disconnect()
					MouseKill:Disconnect()
				end
			end)
		end)
	end
end

function Resizable:Disable()
	if not self.__Enabled then
		return;
	else
		self.__Enabled = false;
		for Idx, Event in next, self.__Events do
			pcall(function() Event:Disconnect(); self.__Events[Idx] = nil; end);
		end
		self.__Events = {};
	end
end

function Resizable:Update(NewConfig)
	for Idx, Event in next, self.__Events do
		pcall(function() Event:Disconnect(); self.__Events[Idx] = nil; end);
	end
	self.__Events = {};
	
	local Enabled = NewConfig.Enabled or self.__Enabled;
	local Size = NewConfig.Size or self.__Size;
	local Speed = NewConfig.Speed or self.__Speed;
	local Style = NewConfig.Style or self.__Style;
	local Direction = NewConfig.Direction or self.__Direction;
	local Target = NewConfig.Target or self.__Target;
	local MaxSize = NewConfig.MaxSize or self.__MaxSize;
	local MinSize = NewConfig.MinSize or self.__MinSize;
	local CurrentWidth = Target.AbsoluteSize.X;
	local CurrentHeight = Target.AbsoluteSize.Y;
	
	local TweenInformation = TweenInfo.new(Speed, Style, Direction);
	
	local function SetHeight(Height)
		CurrentHeight = math.clamp(Height or CurrentHeight, MinSize.Y, MaxSize.Y);
		TweenService:Create(Target, TweenInformation, {Size = UDim2.fromOffset(CurrentWidth, CurrentHeight)}):Play()
	end
	
	local function SetWidth(Width)
		CurrentWidth = math.clamp(Width or CurrentWidth, MinSize.X, MaxSize.X);
		TweenService:Create(Target, TweenInformation, {Size = UDim2.fromOffset(CurrentWidth, CurrentHeight)}):Play()
	end
	
	local HiddenButtons, EventConnections = {}, {};
	
	if (Enabled) then
		HiddenButtons.Bottom = {
			__Size = UDim2.fromScale(1,0) + UDim2.fromOffset(0,Size),
			__Position = UDim2.fromScale(0,1) - UDim2.fromOffset(0,Size)
		}
		
		HiddenButtons.Right = {
			__Size = UDim2.fromScale(0,1) + UDim2.fromOffset(Size,0),
			__Position = UDim2.fromScale(1,0) - UDim2.fromOffset(Size,0)
		}
		
		HiddenButtons.Both = {
			__Size = UDim2.fromScale(0,0) + UDim2.fromOffset(Size,Size),
			__Position = UDim2.fromScale(1,1) - UDim2.fromOffset(Size,Size)
		}
		
		local function NewConstructor(Name)
			local __NewConstructor = Instance.new("TextButton");
			__NewConstructor.Name = Name;
			__NewConstructor.Text = "";
			__NewConstructor.BackgroundTransparency = 1;
			return __NewConstructor;
		end
		
		local Bottom = NewConstructor("Bottom");
		Bottom.Size = HiddenButtons.Bottom.__Size;
		Bottom.Position = HiddenButtons.Bottom.__Position;
		Bottom.Parent = Target;
		
		local Right = NewConstructor("Right");
		Right.Size = HiddenButtons.Right.__Size;
		Right.Position = HiddenButtons.Right.__Position;
		Right.Parent = Target;
		
		local Both = NewConstructor("Both");
		Both.Size = HiddenButtons.Both.__Size;
		Both.Position = HiddenButtons.Both.__Position;
		Both.Parent = Target;
		
		EventConnections.Bottom = Bottom.MouseButton1Down:Connect(function()
			Bottom.MouseButton1Down:Connect(function()
				local SY = Target.AbsolutePosition.Y + CurrentHeight
				local MouseMove, MouseKill
				MouseMove = Mouse.Move:Connect(function()
					local NMY = Mouse.Y
					local DY = NMY - SY
					SetHeight(CurrentHeight + DY)
					SY = Target.AbsolutePosition.Y + CurrentHeight
				end)
				MouseKill = InputService.InputEnded:Connect(function(UserInput)
					if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseMove:Disconnect()
						MouseKill:Disconnect()
					end
				end)
			end)
		end)
		
		EventConnections.Right = Right.MouseButton1Down:Connect(function()
			local SX = Target.AbsolutePosition.X + CurrentWidth
			local MouseMove, MouseKill
			MouseMove = Mouse.Move:Connect(function()
				local NMX = Mouse.X
				local DX = NMX - SX
				SetWidth(CurrentWidth + DX)
				SX = Target.AbsolutePosition.X + CurrentWidth
			end)
			MouseKill = InputService.InputEnded:Connect(function(UserInput)
				if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
					MouseMove:Disconnect()
					MouseKill:Disconnect()
				end
			end)
		end)
		
		EventConnections.Both = Both.MouseButton1Down:Connect(function()
			local SX, SY = Target.AbsolutePosition.X + CurrentWidth, Target.AbsolutePosition.Y + CurrentHeight
			local MouseMove, MouseKill
			MouseMove = Mouse.Move:Connect(function()
				local NMX, NMY = Mouse.X, Mouse.Y
				local DX, DY = NMX - SX, NMY - SY
				SetWidth(CurrentWidth + DX)
				SetHeight(CurrentHeight + DY)
				SX = Target.AbsolutePosition.X + CurrentWidth
				SY = Target.AbsolutePosition.Y + CurrentHeight
			end)
			MouseKill = InputService.InputEnded:Connect(function(UserInput)
				if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
					MouseMove:Disconnect()
					MouseKill:Disconnect()
				end
			end)
		end)
	end
	
	self.__Enabled = Enabled;
	self.__Size = Size;
	self.__Speed = Speed;
	self.__Style = Style;
	self.__Direction = Direction;
	self.__Target = Target;
	self.__MaxSize = MaxSize;
	self.__MinSize = MinSize;
	self.__CurrentWidth = CurrentWidth;
	self.__CurrentHeight = CurrentHeight;
	self.__Events = EventConnections;
	self.__Buttons = HiddenButtons;
end

function GetModules()
	local Modules = {};
	
	for Module, Value in next, Balance do
		if typeof(Value) == "table" then
			if Value.Requirements then
				local RequirementsMet = true;
				local MissingRequirements = {};
				for Requirement, Value in next, Value.Requirements do
					if (typeof(Requirement) == "string") then
						if not Value then
							table.insert(MissingRequirements, Requirement)
							RequirementsMet = false;
						end
					else
						if not Value then
							RequirementsMet = false;
						end
					end
				end
				print(RequirementsMet);
				if not RequirementsMet then
					warn("'"..Module.."' not loaded. Requirements not met: ["..table.concat(MissingRequirements, ", ").."].");
				else
					table.insert(Modules, Module);
				end
			else
				table.insert(Modules, Module);
			end
		end
	end
	
	return Modules;
end

local LoadedModules = GetModules();

function GetModule(Module)
	for _, ThisModule in next, LoadedModules do
		if (ThisModule:sub(1, #Module):lower() == Module:lower()) then
			return Balance[ThisModule];
		end
	end
	
	return false;
end

function Balance:import(Module)
	return GetModule(Module) or warn("'"..Module.."' not found.");
end

return Balance;
