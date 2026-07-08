## UI de configuración de la ruleta. Se instancia por código desde Player
## (no necesita escena .tscn propia). Pausa el juego mientras está abierta.
class_name LoadoutUI
extends CanvasLayer

var _rows: Dictionary = {}  # ability_id -> Dictionary con los Controls de esa fila
var _points_label: Label
var _message_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	visible = false
	_build_ui()
	LoadoutManager.loadout_changed.connect(_refresh)
	LoadoutManager.action_failed.connect(_show_message)
	Game.mushroom_changed.connect(func(_v): _refresh())


## Llamar una vez desde Player, pasándole su RouletteManager.
func setup(roulette_manager: RouletterManager) -> void:
	LoadoutManager.register_roulette(roulette_manager)
	_refresh()


func open() -> void:
	visible = true
	get_tree().paused = true
	_refresh()


func close() -> void:
	visible = false
	get_tree().paused = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 18)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Configurar Ruleta"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	_points_label = Label.new()
	vbox.add_child(_points_label)

	vbox.add_child(HSeparator.new())

	for opt in LoadoutManager.options:
		vbox.add_child(_build_row(opt))
		vbox.add_child(HSeparator.new())

	_message_label = Label.new()
	_message_label.modulate = Color(1, 0.55, 0.55)
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_message_label)

	var close_btn := Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)


func _build_row(opt: AbilityLoadoutOption) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var name_label := Label.new()
	name_label.text = opt.display_name
	name_label.custom_minimum_size = Vector2(130, 0)
	hbox.add_child(name_label)

	var count_label := Label.new()
	count_label.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(count_label)

	var minus_btn := Button.new()
	minus_btn.text = "-"
	minus_btn.pressed.connect(func(): LoadoutManager.decrease_slot(opt.ability_id))
	hbox.add_child(minus_btn)

	var plus_btn := Button.new()
	plus_btn.text = "+  (%d pts)" % opt.point_cost_per_slot
	plus_btn.pressed.connect(func(): LoadoutManager.increase_slot(opt.ability_id))
	hbox.add_child(plus_btn)

	row.add_child(hbox)

	var stored := {"count": count_label, "minus": minus_btn, "plus": plus_btn}

	if opt.upgradable:
		var upgrade_hbox := HBoxContainer.new()
		upgrade_hbox.add_theme_constant_override("separation", 10)

		var upgrade_label := Label.new()
		upgrade_label.custom_minimum_size = Vector2(220, 0)
		upgrade_hbox.add_child(upgrade_label)

		var upgrade_btn := Button.new()
		upgrade_btn.pressed.connect(func(): LoadoutManager.upgrade_ability(opt.ability_id))
		upgrade_hbox.add_child(upgrade_btn)

		row.add_child(upgrade_hbox)
		stored["upgrade_label"] = upgrade_label
		stored["upgrade_btn"] = upgrade_btn

	_rows[opt.ability_id] = stored
	return row


func _refresh() -> void:
	_points_label.text = "Puntos disponibles: %d" % Game.mushroom
	_message_label.text = ""

	for opt in LoadoutManager.options:
		var count := LoadoutManager.loadout.get_count(opt.ability_id)
		var r: Dictionary = _rows[opt.ability_id]

		r.count.text = "%d / %d slots" % [count, LoadoutManager.TOTAL_SLOTS]
		r.minus.disabled = count <= opt.min_slots
		r.plus.disabled = count >= opt.max_slots or Game.mushroom < opt.point_cost_per_slot

		if opt.upgradable:
			var level := LoadoutManager.loadout.get_level(opt.ability_id)
			r.upgrade_label.text = "Poder %d/%d  (+%.1f %s)" % [level, opt.max_upgrade_level, opt.upgrade_amount, opt.upgrade_stat]
			r.upgrade_btn.text = "Mejorar (-%d slots)" % opt.upgrade_slot_cost
			r.upgrade_btn.disabled = level >= opt.max_upgrade_level or (count - opt.upgrade_slot_cost) < opt.min_slots


func _show_message(reason: String) -> void:
	_message_label.text = reason
