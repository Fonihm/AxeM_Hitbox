-- ModuleScript: AxeMHitbox (Server)
-- Автор: AxeM_FoNi
-- Описание:
--	                           /\_/\  
--                            ( •.• )  AxeM
--  ---------------------------------------------------------------¬
--  ¦                      AxeM_Hitbox v1.1                        ¦
--  ¦                      Модуль хитбоксов                        ¦
--  ¦                                                              ¦
--  ¦  Параметры при создании:                                     ¦
--  ¦   - AnchorPart        : BasePart (обязательно)               ¦
--  ¦   - Size              : Vector3, размер хитбокса             ¦
--  ¦   - Offset            : Vector3, смещение                    ¦
--  ¦   - Color             : Color3, цвет визуала                 ¦
--  ¦   - Visible           : boolean, показывать визуал           ¦
--  ¦   - TouchMode         : "single" | "cooldown" | "always"     ¦
--  ¦   - TouchCooldown     : задержка между касаниями (сек)       ¦
--  ¦   - OnModelTouched    : функция при касании модели           ¦
--  ¦   - IgnoreList        : объекты для игнорирования            ¦
--  ¦   - Debug             : true/false, для тестирования         ¦
--  ¦                                                              ¦
--  ¦  Runtime-сеттеры                                             ¦
--  ¦   SetSize(), SetColor(), SetVisible(),                       ¦
--  ¦   SetOffset(), AddIgnore(), RemoveIgnore(),                  ¦
--  ¦   ResetTouches(), SetTouchMode(),                            ¦
--  ¦   SetTouchCooldown(), SetOnModelTouched()                    ¦
--  ¦                                                              ¦
--  L---------------------------------------------------------------
--[[

пример:   

	local hitbox = AxeM_Hitbox.new({                             
		AnchorPart = script.Parent,                             
		Size = Vector3.new(4,4,4),                              
		Visible = true,                                         
		TouchMode = "cooldown",                                 
		TouchCooldown = 1,                                      
		OnModelTouched = function(model, hb, part)              
			print(model.Name .. " потрогал хитбокс!")           
		end                                                     
	})                                                          
    hitbox:Enable() 

--]]


local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AxeMHitbox = {}
AxeMHitbox.__index = AxeMHitbox

local DEFAULTS = {
	Size = Vector3.new(6,6,6),
	Color = Color3.fromRGB(255,0,0),
	Visible = false,
	VisibleTransparency = 0.6,
	Anchored = true,
	CanCollide = false,
	PollRate = 0.05,
	Offset = Vector3.new(0,0,0),
	IgnoreList = {},
	AutoParent = workspace,
	TouchMode = "single",    -- "single" | "cooldown" | "always"
	TouchCooldown = 1.0,
}

local function safeGetPartsInBox(cframe, size, overlapParams)
	local ok, parts = pcall(function()
		return Workspace:GetPartBoundsInBox(cframe, size, overlapParams)
	end)
	if ok and parts then return parts end
	return {}
end

local function tableRemoveValue(tbl, val)
	for i,v in ipairs(tbl) do
		if v == val then
			table.remove(tbl, i)
			return true
		end
	end
	return false
end

function AxeMHitbox.new(params)
	params = params or {}
	local self = setmetatable({}, AxeMHitbox)

	self.Size = params.Size or DEFAULTS.Size
	self.Color = params.Color or DEFAULTS.Color
	self.Visible = (params.Visible ~= nil) and params.Visible or DEFAULTS.Visible
	self.VisibleTransparency = params.VisibleTransparency or DEFAULTS.VisibleTransparency
	self.Anchored = (params.Anchored ~= nil) and params.Anchored or DEFAULTS.Anchored
	self.CanCollide = (params.CanCollide ~= nil) and params.CanCollide or DEFAULTS.CanCollide
	self.PollRate = params.PollRate or DEFAULTS.PollRate
	self.Offset = params.Offset or DEFAULTS.Offset
	self.IgnoreList = {}
	if params.IgnoreList then
		for i,inst in ipairs(params.IgnoreList) do table.insert(self.IgnoreList, inst) end
	end
	self.AutoParent = params.AutoParent or DEFAULTS.AutoParent

	self.AnchorPart = params.AnchorPart
	assert(self.AnchorPart and self.AnchorPart:IsA("BasePart"), "AxeMHitbox: укажите корректный AnchorPart")

	-- Колбэк теперь принимает model (Instance - Model), hitbox, part
	-- signature: function(model, hitbox, part) -> optional { Consume = false }
	self.OnModelTouched = params.OnModelTouched

	self.TouchMode = params.TouchMode or DEFAULTS.TouchMode
	self.TouchCooldown = (params.TouchCooldown ~= nil) and params.TouchCooldown or DEFAULTS.TouchCooldown

	-- внутренние
	-- _touchedPlayers: [modelInstance] = true OR timestamp (for cooldown)
	self._touchedPlayers = {}
	self._enabled = false
	self._touchConn = nil
	self._hbConn = nil

	-- визуал
	local visual = Instance.new("Part")
	visual.Name = "AxeMHitbox_Visual"
	visual.Size = self.Size
	visual.Anchored = self.Anchored
	visual.CanCollide = false
	visual.Transparency = self.Visible and self.VisibleTransparency or 1
	visual.Color = self.Color
	visual.CastShadow = false
	visual.Massless = true
	visual.CanTouch = false
	visual.CanQuery = false
	visual.Parent = self.AutoParent
	self._visual = visual

	return self
end

function AxeMHitbox:_updateVisual()
	if not self._visual or not self.AnchorPart then return end
	self._visual.Size = self.Size
	self._visual.CFrame = self.AnchorPart.CFrame * CFrame.new(self.Offset)
	self._visual.Color = self.Color
	self._visual.Transparency = self.Visible and self.VisibleTransparency or 1
	if self._visual.Parent ~= self.AutoParent then self._visual.Parent = self.AutoParent end
end

-- canTouch: проверяем режим и статус по ключу model (Instance)
function AxeMHitbox:_canTouchModel(model)
	if not model then return false end
	local mode = self.TouchMode
	local entry = self._touchedPlayers[model]

	if mode == "always" then
		return true
	elseif mode == "single" then
		return not entry
	elseif mode == "cooldown" then
		if not entry then return true end
		return tick() >= entry
	end
	return true
end

function AxeMHitbox:_markTouchedModel(model)
	if not model then return end
	local mode = self.TouchMode
	if mode == "single" then
		self._touchedPlayers[model] = true
	elseif mode == "cooldown" then
		self._touchedPlayers[model] = tick() + (self.TouchCooldown or 0)
	end
end

-- Основной обработчик кандидата: теперь работает с model (любая Model)
function AxeMHitbox:_handleCandidatePart(part)
	if not part or not part.Parent then return end

	-- игнор-лист (точные совпадения с part или model)
	for _, v in ipairs(self.IgnoreList) do
		if v == part or v == part.Parent then
			return
		end
	end

	local model = part.Parent -- Model или Model-like

	-- опционально: если хотим пропускать не-модели, можно проверить IsA("Model") — но не обязательно
	-- local modelIsModel = model:IsA("Model")
	-- if not modelIsModel then return end

	-- если есть Humanoid и он мёртв — игнорируем
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then return end

	-- проверяем возможность сработать по модели (single/cooldown/always)
	if not self:_canTouchModel(model) then return end

	-- помечаем заранее
	self:_markTouchedModel(model)

	-- вызываем колбэк (если задан)
	if self.OnModelTouched then
		local ok, result = pcall(function()
			return self.OnModelTouched(model, self, part)
		end)
		-- если колбэк вернул { Consume = false }, снимаем пометку
		if ok then
			if type(result) == "table" and result.Consume == false then
				self._touchedPlayers[model] = nil
			end
		else
			warn("AxeMHitbox: ошибка в OnModelTouched:", result)
		end
	end
end

function AxeMHitbox:Enable()
	if self._enabled then return end
	self._enabled = true
	self:_updateVisual()

	if self._visual then
		if self._touchConn then
			self._touchConn:Disconnect()
			self._touchConn = nil
		end
		self._touchConn = self._visual.Touched:Connect(function(part)
			self:_handleCandidatePart(part)
		end)
	end

	local accum = 0
	self._hbConn = RunService.Heartbeat:Connect(function(dt)
		if not self._enabled then return end
		self:_updateVisual()
		accum = accum + dt
		if accum < self.PollRate then return end
		accum = accum - self.PollRate

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
		overlapParams.FilterDescendantsInstances = self.IgnoreList

		local cframe = self.AnchorPart.CFrame * CFrame.new(self.Offset)
		local parts = safeGetPartsInBox(cframe, self.Size, overlapParams)
		for _, p in ipairs(parts) do
			if p ~= self._visual then
				self:_handleCandidatePart(p)
			end
		end
	end)
end

function AxeMHitbox:Disable()
	if not self._enabled then return end
	self._enabled = false
	if self._touchConn then
		self._touchConn:Disconnect()
		self._touchConn = nil
	end
	if self._hbConn then
		self._hbConn:Disconnect()
		self._hbConn = nil
	end
	if self._visual then
		self._visual.Transparency = 1
	end
end

function AxeMHitbox:Destroy()
	self:Disable()
	if self._visual then
		self._visual:Destroy()
		self._visual = nil
	end
	self._touchedPlayers = {}
	setmetatable(self, nil)
end

-- Сбрасываем касания: по модели (Instance) или все
function AxeMHitbox:ResetTouches(model)
	if model then
		self._touchedPlayers[model] = nil
	else
		self._touchedPlayers = {}
	end
end

function AxeMHitbox:HasModelTouched(model)
	return self._touchedPlayers[model] ~= nil
end

-- runtime setters
function AxeMHitbox:SetSize(vec3) self.Size = vec3 if self._visual then self._visual.Size = vec3 end end
function AxeMHitbox:SetColor(color3) self.Color = color3 if self._visual then self._visual.Color = color3 end end
function AxeMHitbox:SetVisible(visible, optionalTransparency)
	self.Visible = visible
	if optionalTransparency ~= nil then self.VisibleTransparency = optionalTransparency end
	if self._visual then self._visual.Transparency = self.Visible and self.VisibleTransparency or 1 end
end
function AxeMHitbox:SetOffset(vec3) self.Offset = vec3 self:_updateVisual() end
function AxeMHitbox:AddIgnore(instance) table.insert(self.IgnoreList, instance) end
function AxeMHitbox:RemoveIgnore(instance) return tableRemoveValue(self.IgnoreList, instance) end
function AxeMHitbox:SetTouchMode(mode) assert(mode=="single"or mode=="cooldown"or mode=="always","Invalid TouchMode") self.TouchMode=mode end
function AxeMHitbox:SetTouchCooldown(seconds) self.TouchCooldown=seconds end
function AxeMHitbox:SetOnModelTouched(fn) self.OnModelTouched = fn end

return AxeMHitbox