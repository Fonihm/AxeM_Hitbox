# AxeM_Hitbox

Параметры при создании:
-AnchorPart        : BasePart (обязательно)
-Size              : Vector3, размер хитбокса
- Offset            : Vector3, смещение
- Color             : Color3, цвет визуала
- Visible           : boolean, показывать визуал
- TouchMode         : "single" | "cooldown" | "always"
- TouchCooldown     : задержка между касаниями (сек) 
- OnModelTouched    : функция при касании модели
- IgnoreList        : объекты для игнорирования
- Debug             : true/false, для тестирования

Runtime-сеттеры:
SetSize(Vector3) — изменить размер
SetColor(Color3) — изменить цвет
SetVisible(boolean, optionalTransparency) — показать/скрыть визуал
SetOffset(Vector3) — сместить хитбокс
AddIgnore(instance)  RemoveIgnore(instance) — игнор-лист
SetTouchMode(mode) — сменить режим касания
SetTouchCooldown(seconds) — изменить задержку
SetOnModelTouched(fn) — изменить коллбек

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
