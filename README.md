# AxeM_Hitbox

# Параметры при создании
AnchorPart : BasePart (обязательно)

Size : Vector3 — размер хитбокса

Offset : Vector3 — смещение хитбокса относительно AnchorPart

Color : Color3 — цвет визуала

Visible : boolean — показывать визуал

TouchMode : "single" | "cooldown" | "always"

TouchCooldown : число — задержка между касаниями (сек)

OnModelTouched : функция — вызывается при касании модели

IgnoreList : массив объектов, которые будут игнорироваться

Debug : true/false — для тестирования

# Runtime-сеттеры

SetSize(Vector3) — изменить размер

SetColor(Color3) — изменить цвет

SetVisible(boolean, optionalTransparency) — показать/скрыть визуал

SetOffset(Vector3) — сместить хитбокс

AddIgnore(instance) / RemoveIgnore(instance) — управлять игнор-листом

SetTouchMode(mode) — сменить режим касания

SetTouchCooldown(seconds) — изменить задержку

SetOnModelTouched(fn) — изменить коллбек

# Пример

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
