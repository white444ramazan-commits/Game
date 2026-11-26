extends Node3D

const SKIN := Color("#e9bba7")
const HAIR_DEFAULT := Color("#c97968")
const INK := Color("#171722")
const ACCENT := Color("#d48b9b")

var avatar_root: Node3D
var outfit_root: Node3D
var parts: Dictionary = {}
var hair_nodes: Array[MeshInstance3D] = []
var eye_nodes: Array[MeshInstance3D] = []

var height_value := 1.0
var bust_value := 1.0
var hip_value := 1.0
var glute_value := 1.0
var waist_value := 1.0
var outfit_index := 0
var face_style := 0
var hair_color := HAIR_DEFAULT
var eye_color := Color("#6c9b8b")
var status_label: Label


func _ready() -> void:
    _load_profile()
    _create_stage()
    _create_avatar()
    _build_ui()


func _create_stage() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#171a27")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#b7bfd8")
    environment.ambient_light_energy = 0.62
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = environment
    add_child(world)

    var camera := Camera3D.new()
    camera.name = "AvatarCamera"
    camera.position = Vector3(0.0, 1.78, 5.7)
    camera.fov = 34.0
    camera.look_at(Vector3(0.0, 1.62, 0.0), Vector3.UP)
    add_child(camera)

    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-38.0, -24.0, 0.0)
    key_light.light_energy = 1.45
    key_light.shadow_enabled = true
    add_child(key_light)

    var fill_light := OmniLight3D.new()
    fill_light.position = Vector3(2.2, 2.8, 2.2)
    fill_light.light_color = Color("#d7b5c7")
    fill_light.light_energy = 0.75
    fill_light.omni_range = 8.0
    add_child(fill_light)

    var rim_light := OmniLight3D.new()
    rim_light.position = Vector3(-2.3, 3.0, -1.5)
    rim_light.light_color = Color("#8d9ed7")
    rim_light.light_energy = 1.2
    rim_light.omni_range = 7.0
    add_child(rim_light)

    var floor := MeshInstance3D.new()
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(30.0, 30.0)
    floor.mesh = floor_mesh
    floor.position.y = -0.19
    floor.material_override = _material(Color("#242737"), 0.86)
    add_child(floor)

    var pedestal := MeshInstance3D.new()
    var pedestal_mesh := CylinderMesh.new()
    pedestal_mesh.top_radius = 0.66
    pedestal_mesh.bottom_radius = 0.75
    pedestal_mesh.height = 0.18
    pedestal.mesh = pedestal_mesh
    pedestal.position.y = -0.1
    pedestal.material_override = _material(Color("#34374b"), 0.32, 0.28)
    add_child(pedestal)


func _create_avatar() -> void:
    if avatar_root != null:
        avatar_root.queue_free()

    avatar_root = Node3D.new()
    avatar_root.name = "AdultAvatar"
    add_child(avatar_root)
    parts.clear()
    hair_nodes.clear()
    eye_nodes.clear()

    # Body: deliberately stylized procedural forms; the starter outfit is opaque.
    parts["torso"] = _sphere(avatar_root, "Torso", Vector3(0, 1.88, 0), Vector3(0.45, 0.69, 0.29), SKIN)
    parts["hips"] = _sphere(avatar_root, "Hips", Vector3(0, 1.18, 0), Vector3(0.55, 0.43, 0.34), SKIN)
    parts["glute_left"] = _sphere(avatar_root, "GluteLeft", Vector3(-0.22, 1.14, -0.18), Vector3(0.29, 0.31, 0.23), SKIN)
    parts["glute_right"] = _sphere(avatar_root, "GluteRight", Vector3(0.22, 1.14, -0.18), Vector3(0.29, 0.31, 0.23), SKIN)
    parts["bust_left"] = _sphere(avatar_root, "BustLeft", Vector3(-0.21, 2.13, 0.20), Vector3(0.22, 0.24, 0.16), SKIN)
    parts["bust_right"] = _sphere(avatar_root, "BustRight", Vector3(0.21, 2.13, 0.20), Vector3(0.22, 0.24, 0.16), SKIN)

    _sphere(avatar_root, "ShoulderLeft", Vector3(-0.43, 2.28, 0.0), Vector3(0.19, 0.20, 0.20), SKIN)
    _sphere(avatar_root, "ShoulderRight", Vector3(0.43, 2.28, 0.0), Vector3(0.19, 0.20, 0.20), SKIN)
    _sphere(avatar_root, "UpperArmLeft", Vector3(-0.56, 1.88, 0.0), Vector3(0.14, 0.48, 0.14), SKIN)
    _sphere(avatar_root, "UpperArmRight", Vector3(0.56, 1.88, 0.0), Vector3(0.14, 0.48, 0.14), SKIN)
    _sphere(avatar_root, "ForearmLeft", Vector3(-0.64, 1.35, 0.02), Vector3(0.115, 0.43, 0.12), SKIN)
    _sphere(avatar_root, "ForearmRight", Vector3(0.64, 1.35, 0.02), Vector3(0.115, 0.43, 0.12), SKIN)
    _sphere(avatar_root, "HandLeft", Vector3(-0.67, 0.94, 0.05), Vector3(0.12, 0.15, 0.09), SKIN)
    _sphere(avatar_root, "HandRight", Vector3(0.67, 0.94, 0.05), Vector3(0.12, 0.15, 0.09), SKIN)

    parts["thigh_left"] = _sphere(avatar_root, "ThighLeft", Vector3(-0.23, 0.67, 0.0), Vector3(0.21, 0.53, 0.22), SKIN)
    parts["thigh_right"] = _sphere(avatar_root, "ThighRight", Vector3(0.23, 0.67, 0.0), Vector3(0.21, 0.53, 0.22), SKIN)
    _sphere(avatar_root, "CalfLeft", Vector3(-0.23, 0.22, 0.02), Vector3(0.145, 0.38, 0.15), SKIN)
    _sphere(avatar_root, "CalfRight", Vector3(0.23, 0.22, 0.02), Vector3(0.145, 0.38, 0.15), SKIN)
    _sphere(avatar_root, "FootLeft", Vector3(-0.23, 0.045, 0.12), Vector3(0.17, 0.09, 0.29), SKIN)
    _sphere(avatar_root, "FootRight", Vector3(0.23, 0.045, 0.12), Vector3(0.17, 0.09, 0.29), SKIN)

    _cylinder(avatar_root, "Neck", Vector3(0, 2.52, 0), 0.19, 0.42, SKIN)
    parts["head"] = _sphere(avatar_root, "Head", Vector3(0, 2.99, 0.02), Vector3(0.34, 0.44, 0.31), SKIN)
    _sphere(avatar_root, "EarLeft", Vector3(-0.34, 2.98, 0.02), Vector3(0.075, 0.12, 0.07), SKIN)
    _sphere(avatar_root, "EarRight", Vector3(0.34, 2.98, 0.02), Vector3(0.075, 0.12, 0.07), SKIN)

    _build_face()
    _build_hair()
    _build_choker()
    _build_outfit()
    _apply_shape()
    _apply_face()


func _build_face() -> void:
    var white := Color("#fff7f1")
    var dark := Color("#25202a")
    eye_nodes.clear()

    eye_nodes.append(_sphere(avatar_root, "EyeLeft", Vector3(-0.135, 3.035, 0.292), Vector3(0.072, 0.045, 0.033), white))
    eye_nodes.append(_sphere(avatar_root, "EyeRight", Vector3(0.135, 3.035, 0.292), Vector3(0.072, 0.045, 0.033), white))
    parts["pupil_left"] = _sphere(avatar_root, "PupilLeft", Vector3(-0.135, 3.035, 0.322), Vector3(0.027, 0.032, 0.018), eye_color)
    parts["pupil_right"] = _sphere(avatar_root, "PupilRight", Vector3(0.135, 3.035, 0.322), Vector3(0.027, 0.032, 0.018), eye_color)
    _sphere(avatar_root, "BrowLeft", Vector3(-0.14, 3.12, 0.29), Vector3(0.09, 0.018, 0.025), dark)
    _sphere(avatar_root, "BrowRight", Vector3(0.14, 3.12, 0.29), Vector3(0.09, 0.018, 0.025), dark)
    _sphere(avatar_root, "Nose", Vector3(0, 2.94, 0.34), Vector3(0.045, 0.075, 0.055), Color("#dba995"))
    parts["mouth"] = _sphere(avatar_root, "Mouth", Vector3(0, 2.82, 0.305), Vector3(0.09, 0.025, 0.025), Color("#a64d61"))


func _build_hair() -> void:
    hair_nodes.clear()
    hair_nodes.append(_sphere(avatar_root, "HairCap", Vector3(0, 3.28, -0.015), Vector3(0.39, 0.31, 0.35), hair_color))
    hair_nodes.append(_sphere(avatar_root, "HairFringe", Vector3(0, 3.18, 0.255), Vector3(0.34, 0.14, 0.13), hair_color))
    hair_nodes.append(_sphere(avatar_root, "HairLeftLock", Vector3(-0.34, 2.55, 0.04), Vector3(0.085, 0.68, 0.10), hair_color))
    hair_nodes.append(_sphere(avatar_root, "HairRightLock", Vector3(0.34, 2.55, 0.04), Vector3(0.085, 0.68, 0.10), hair_color))
    hair_nodes.append(_sphere(avatar_root, "HairBack", Vector3(0, 2.63, -0.20), Vector3(0.37, 0.72, 0.13), hair_color))
    _sphere(avatar_root, "HairStrandLeft", Vector3(-0.13, 3.20, 0.32), Vector3(0.12, 0.18, 0.045), hair_color)
    _sphere(avatar_root, "HairStrandRight", Vector3(0.12, 3.20, 0.32), Vector3(0.12, 0.18, 0.045), hair_color)


func _build_choker() -> void:
    _cylinder(avatar_root, "Choker", Vector3(0, 2.53, 0.015), 0.205, 0.09, Color("#20212b"))
    _box(avatar_root, "ChokerClasp", Vector3(0, 2.53, 0.22), Vector3(0.09, 0.055, 0.025), Color("#c7b7a7"))
    _box(avatar_root, "PendantVertical", Vector3(0, 2.34, 0.28), Vector3(0.035, 0.20, 0.025), Color("#aeb4c2"))
    _box(avatar_root, "PendantHorizontal", Vector3(0, 2.36, 0.28), Vector3(0.12, 0.035, 0.025), Color("#aeb4c2"))


func _build_outfit() -> void:
    if outfit_root != null:
        outfit_root.queue_free()
    outfit_root = Node3D.new()
    outfit_root.name = "Outfit"
    avatar_root.add_child(outfit_root)

    parts.erase("bra_left")
    parts.erase("bra_right")

    if outfit_index == 0:
        var fabric := Color("#292637")
        parts["bra_left"] = _sphere(outfit_root, "BraCupLeft", Vector3(-0.21, 2.13, 0.265), Vector3(0.245, 0.255, 0.105), fabric)
        parts["bra_right"] = _sphere(outfit_root, "BraCupRight", Vector3(0.21, 2.13, 0.265), Vector3(0.245, 0.255, 0.105), fabric)
        _box(outfit_root, "BraBand", Vector3(0, 1.96, 0.255), Vector3(0.62, 0.085, 0.10), fabric)
        _box(outfit_root, "BraStrapLeft", Vector3(-0.27, 2.30, 0.10), Vector3(0.055, 0.31, 0.055), fabric).rotation_degrees.z = -10.0
        _box(outfit_root, "BraStrapRight", Vector3(0.27, 2.30, 0.10), Vector3(0.055, 0.31, 0.055), fabric).rotation_degrees.z = 10.0
        _sphere(outfit_root, "OpaquePanties", Vector3(0, 1.18, 0.255), Vector3(0.43, 0.25, 0.13), Color("#292637"))
        _box(outfit_root, "PantiesWaist", Vector3(0, 1.39, 0.235), Vector3(0.73, 0.065, 0.08), Color("#d7c9d6"))
    elif outfit_index == 1:
        var top_color := Color("#8c445e")
        _sphere(outfit_root, "CasualTop", Vector3(0, 1.96, 0.12), Vector3(0.47, 0.51, 0.31), top_color)
        _box(outfit_root, "TopHem", Vector3(0, 1.53, 0.18), Vector3(0.87, 0.09, 0.40), top_color)
        _sphere(outfit_root, "Shorts", Vector3(0, 1.18, 0.12), Vector3(0.53, 0.30, 0.35), Color("#252d45"))
    else:
        var dress_color := Color("#394b70")
        _sphere(outfit_root, "DressBodice", Vector3(0, 1.95, 0.09), Vector3(0.48, 0.56, 0.30), dress_color)
        var skirt := MeshInstance3D.new()
        var skirt_mesh := CylinderMesh.new()
        skirt_mesh.top_radius = 0.34
        skirt_mesh.bottom_radius = 0.58
        skirt_mesh.height = 0.72
        skirt_mesh.radial_segments = 40
        skirt.mesh = skirt_mesh
        skirt.position = Vector3(0, 1.23, 0)
        skirt.material_override = _material(dress_color, 0.48)
        outfit_root.add_child(skirt)


func _apply_shape() -> void:
    if avatar_root == null:
        return

    avatar_root.scale.y = height_value
    parts["torso"].scale.x = 0.45 * waist_value
    parts["hips"].scale.x = 0.55 * hip_value
    parts["thigh_left"].scale.x = 0.21 * hip_value
    parts["thigh_right"].scale.x = 0.21 * hip_value
    parts["glute_left"].scale = Vector3(0.29 * glute_value, 0.31 * glute_value, 0.23 * glute_value)
    parts["glute_right"].scale = Vector3(0.29 * glute_value, 0.31 * glute_value, 0.23 * glute_value)
    parts["bust_left"].scale = Vector3(0.22 * bust_value, 0.24 * bust_value, 0.16 * bust_value)
    parts["bust_right"].scale = Vector3(0.22 * bust_value, 0.24 * bust_value, 0.16 * bust_value)

    if outfit_index == 0 and parts.has("bra_left"):
        parts["bra_left"].scale = Vector3(0.245 * bust_value, 0.255 * bust_value, 0.105)
        parts["bra_right"].scale = Vector3(0.245 * bust_value, 0.255 * bust_value, 0.105)


func _apply_face() -> void:
    if not parts.has("head"):
        return
    var head := parts["head"] as MeshInstance3D
    if face_style == 0:
        head.scale = Vector3(0.34, 0.44, 0.31)
    elif face_style == 1:
        head.scale = Vector3(0.35, 0.42, 0.31)
    else:
        head.scale = Vector3(0.33, 0.46, 0.30)


func _set_hair_color(color: Color) -> void:
    hair_color = color
    for hair_part in hair_nodes:
        hair_part.material_override = _material(hair_color, 0.78)


func _set_eye_color(color: Color) -> void:
    eye_color = color
    parts["pupil_left"].material_override = _material(eye_color, 0.24)
    parts["pupil_right"].material_override = _material(eye_color, 0.24)


func _set_outfit(index: int) -> void:
    outfit_index = index
    _build_outfit()
    _apply_shape()


func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(root)

    var panel := PanelContainer.new()
    panel.anchor_left = 0.0
    panel.anchor_top = 0.0
    panel.anchor_right = 0.0
    panel.anchor_bottom = 1.0
    panel.offset_left = 18.0
    panel.offset_top = 18.0
    panel.offset_right = 370.0
    panel.offset_bottom = -18.0
    panel.custom_minimum_size = Vector2(352, 0)
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("#171b2b")
    panel_style.border_color = Color("#343a55")
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(18)
    panel_style.content_margin_left = 16
    panel_style.content_margin_right = 16
    panel_style.content_margin_top = 14
    panel_style.content_margin_bottom = 12
    panel.add_theme_stylebox_override("panel", panel_style)
    root.add_child(panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 10)
    panel.add_child(layout)

    var brand := Label.new()
    brand.text = "ELYSIA  /  AVATAR LAB"
    brand.add_theme_font_size_override("font_size", 22)
    brand.add_theme_color_override("font_color", Color("#f3dce5"))
    layout.add_child(brand)

    var subtitle := Label.new()
    subtitle.text = "3D-редактор персонажа"
    subtitle.add_theme_font_size_override("font_size", 13)
    subtitle.add_theme_color_override("font_color", Color("#aab2c9"))
    layout.add_child(subtitle)

    var separator := HSeparator.new()
    layout.add_child(separator)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    layout.add_child(scroll)

    var controls := VBoxContainer.new()
    controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_theme_constant_override("separation", 9)
    scroll.add_child(controls)

    _section(controls, "ПРОПОРЦИИ")
    _add_slider(controls, "Рост", 0.90, 1.10, height_value, func(value: float):
        height_value = value
        _apply_shape()
    )
    _add_slider(controls, "Объём груди", 0.75, 1.35, bust_value, func(value: float):
        bust_value = value
        _apply_shape()
    )
    _add_slider(controls, "Ширина бёдер", 0.80, 1.40, hip_value, func(value: float):
        hip_value = value
        _apply_shape()
    )
    _add_slider(controls, "Объём ягодиц", 0.70, 1.50, glute_value, func(value: float):
        glute_value = value
        _apply_shape()
    )
    _add_slider(controls, "Талия", 0.72, 1.16, waist_value, func(value: float):
        waist_value = value
        _apply_shape()
    )

    _section(controls, "ЛИЦО И ГЛАЗА")
    var face_select := OptionButton.new()
    face_select.add_item("Мягкие черты", 0)
    face_select.add_item("Выразительные черты", 1)
    face_select.add_item("Удлинённое лицо", 2)
    face_select.select(face_style)
    face_select.item_selected.connect(func(index: int):
        face_style = index
        _apply_face()
    )
    controls.add_child(face_select)

    var eyes_select := OptionButton.new()
    eyes_select.add_item("Зелёные глаза", 0)
    eyes_select.add_item("Голубые глаза", 1)
    eyes_select.add_item("Карие глаза", 2)
    eyes_select.item_selected.connect(func(index: int):
        if index == 0:
            _set_eye_color(Color("#6c9b8b"))
        elif index == 1:
            _set_eye_color(Color("#6d9ed7"))
        else:
            _set_eye_color(Color("#80513a"))
    )
    controls.add_child(eyes_select)

    _section(controls, "ЦВЕТ ВОЛОС")
    var hair_row := HBoxContainer.new()
    controls.add_child(hair_row)
    _color_button(hair_row, "Медный", Color("#c97968"))
    _color_button(hair_row, "Чёрный", Color("#29242b"))
    _color_button(hair_row, "Блонд", Color("#d6b77c"))
    _color_button(hair_row, "Розовый", Color("#d98bb4"))

    _section(controls, "ОДЕЖДА")
    _add_outfit_button(controls, "Стартовый комплект", 0)
    _add_outfit_button(controls, "Повседневный образ", 1)
    _add_outfit_button(controls, "Вечернее платье", 2)

    var save_button := Button.new()
    save_button.text = "СОХРАНИТЬ ОБРАЗ"
    save_button.custom_minimum_size = Vector2(0, 46)
    save_button.add_theme_color_override("font_color", Color("#ffffff"))
    save_button.add_theme_color_override("font_hover_color", Color("#ffffff"))
    var save_style := StyleBoxFlat.new()
    save_style.bg_color = Color("#a95575")
    save_style.set_corner_radius_all(10)
    save_button.add_theme_stylebox_override("normal", save_style)
    save_button.pressed.connect(_save_profile)
    layout.add_child(save_button)

    status_label = Label.new()
    status_label.text = "Проведи пальцем по сцене, чтобы повернуть модель"
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 12)
    status_label.add_theme_color_override("font_color", Color("#aab2c9"))
    layout.add_child(status_label)

    var right_title := Label.new()
    right_title.text = "CHARACTER  /  PREVIEW"
    right_title.anchor_left = 1.0
    right_title.anchor_right = 1.0
    right_title.anchor_top = 0.0
    right_title.anchor_bottom = 0.0
    right_title.offset_left = -300.0
    right_title.offset_right = -22.0
    right_title.offset_top = 22.0
    right_title.offset_bottom = 52.0
    right_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    right_title.add_theme_color_override("font_color", Color("#d8dced"))
    right_title.add_theme_font_size_override("font_size", 14)
    root.add_child(right_title)


func _section(parent: VBoxContainer, text_value: String) -> void:
    var label := Label.new()
    label.text = text_value
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", Color("#d48b9b"))
    parent.add_child(label)


func _add_slider(parent: VBoxContainer, title: String, minimum: float, maximum: float, initial: float, callback: Callable) -> void:
    var block := VBoxContainer.new()
    block.add_theme_constant_override("separation", 2)
    parent.add_child(block)

    var label := Label.new()
    label.text = title
    label.add_theme_font_size_override("font_size", 14)
    label.add_theme_color_override("font_color", Color("#eef0f7"))
    block.add_child(label)

    var slider := HSlider.new()
    slider.min_value = minimum
    slider.max_value = maximum
    slider.step = 0.01
    slider.value = initial
    slider.custom_minimum_size = Vector2(0, 24)
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.value_changed.connect(callback)
    block.add_child(slider)


func _add_outfit_button(parent: VBoxContainer, title: String, index: int) -> void:
    var button := Button.new()
    button.text = title
    button.custom_minimum_size = Vector2(0, 38)
    button.pressed.connect(func():
        _set_outfit(index)
        if status_label != null:
            status_label.text = "Выбран новый комплект одежды"
    )
    parent.add_child(button)


func _color_button(parent: HBoxContainer, title: String, color: Color) -> void:
    var button := Button.new()
    button.text = title
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 36)
    button.add_theme_font_size_override("font_size", 11)
    button.pressed.connect(func():
        _set_hair_color(color)
    )
    parent.add_child(button)


func _save_profile() -> void:
    var config := ConfigFile.new()
    config.set_value("avatar", "height", height_value)
    config.set_value("avatar", "bust", bust_value)
    config.set_value("avatar", "hips", hip_value)
    config.set_value("avatar", "glutes", glute_value)
    config.set_value("avatar", "waist", waist_value)
    config.set_value("avatar", "outfit", outfit_index)
    config.set_value("avatar", "face", face_style)
    config.set_value("avatar", "hair", hair_color.to_html())
    config.set_value("avatar", "eyes", eye_color.to_html())
    var result := config.save("user://avatar_profile.cfg")
    if result == OK:
        status_label.text = "Образ сохранён на устройстве"
    else:
        status_label.text = "Не удалось сохранить профиль"


func _load_profile() -> void:
    var config := ConfigFile.new()
    if config.load("user://avatar_profile.cfg") != OK:
        return
    height_value = float(config.get_value("avatar", "height", 1.0))
    bust_value = float(config.get_value("avatar", "bust", 1.0))
    hip_value = float(config.get_value("avatar", "hips", 1.0))
    glute_value = float(config.get_value("avatar", "glutes", 1.0))
    waist_value = float(config.get_value("avatar", "waist", 1.0))
    outfit_index = int(config.get_value("avatar", "outfit", 0))
    face_style = int(config.get_value("avatar", "face", 0))
    hair_color = Color.from_string(str(config.get_value("avatar", "hair", "#c97968")), HAIR_DEFAULT)
    eye_color = Color.from_string(str(config.get_value("avatar", "eyes", "#6c9b8b")), Color("#6c9b8b"))


func _input(event: InputEvent) -> void:
    if avatar_root == null:
        return
    if event is InputEventScreenDrag and event.position.x > 380.0:
        avatar_root.rotate_y(-event.relative.x * 0.006)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        if event.position.x > 380.0:
            avatar_root.rotate_y(-event.relative.x * 0.006)


func _material(color: Color, roughness: float = 0.62, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material


func _sphere(parent: Node3D, part_name: String, position: Vector3, part_scale: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var sphere_mesh := SphereMesh.new()
    sphere_mesh.radius = 0.5
    sphere_mesh.height = 1.0
    sphere_mesh.radial_segments = 32
    sphere_mesh.rings = 20
    node.mesh = sphere_mesh
    node.position = position
    node.scale = part_scale
    node.material_override = _material(color)
    parent.add_child(node)
    return node


func _box(parent: Node3D, part_name: String, position: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var box_mesh := BoxMesh.new()
    box_mesh.size = Vector3.ONE
    node.mesh = box_mesh
    node.position = position
    node.scale = dimensions
    node.material_override = _material(color)
    parent.add_child(node)
    return node


func _cylinder(parent: Node3D, part_name: String, position: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var cylinder_mesh := CylinderMesh.new()
    cylinder_mesh.top_radius = radius
    cylinder_mesh.bottom_radius = radius
    cylinder_mesh.height = height
    cylinder_mesh.radial_segments = 32
    node.mesh = cylinder_mesh
    node.position = position
    node.material_override = _material(color, 0.42, 0.12)
    parent.add_child(node)
    return node
