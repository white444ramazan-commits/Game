extends Node3D

const AvatarModel = preload("res://scripts/avatar_model.gd")

var avatar
var status_label: Label
var height_value := 1.0
var bust_value := 1.0
var hip_value := 1.0
var glute_value := 1.0
var waist_value := 1.0
var outfit_index := 0
var hair_color := Color("#a94f3f")
var eye_color := Color("#668f7c")


func _ready() -> void:
    _load_profile()
    _create_stage()
    _create_bedroom()
    _create_avatar()
    _build_ui()


func _create_stage() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#17131a")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#d6c4b8")
    environment.ambient_light_energy = 0.62
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.ssao_enabled = true
    environment.ssao_radius = 1.1
    environment.ssao_intensity = 1.65
    environment.ssao_power = 1.35
    environment.glow_enabled = true
    environment.glow_intensity = 0.28
    environment.glow_strength = 0.35
    environment.glow_bloom = 0.08
    world.environment = environment
    add_child(world)

    var camera := Camera3D.new()
    camera.name = "RoomCamera"
    camera.position = Vector3(-0.4, 7.4, 7.2)
    camera.fov = 42.0
    camera.look_at(Vector3(0.0, 0.72, 0.0), Vector3.UP)
    add_child(camera)

    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-48.0, -22.0, -10.0)
    key_light.light_color = Color("#ffe0c9")
    key_light.light_energy = 1.65
    key_light.shadow_enabled = true
    key_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
    add_child(key_light)

    var fill_light := OmniLight3D.new()
    fill_light.position = Vector3(-1.5, 3.2, 3.8)
    fill_light.light_color = Color("#e4b5b5")
    fill_light.light_energy = 0.72
    fill_light.omni_range = 9.0
    fill_light.omni_attenuation = 1.35
    add_child(fill_light)

    var rim_light := OmniLight3D.new()
    rim_light.position = Vector3(2.4, 3.0, -2.0)
    rim_light.light_color = Color("#aab5ec")
    rim_light.light_energy = 1.05
    rim_light.omni_range = 8.0
    add_child(rim_light)


func _create_bedroom() -> void:
    var floor_material := _material(Color("#24202a"), 0.86)
    var wall_material := _material(Color("#211b25"), 0.94)
    var wood_material := _material(Color("#49333a"), 0.42)
    var frame_material := _material(Color("#30252e"), 0.36)
    var mattress_material := _material(Color("#e0d8d3"), 0.92)
    var sheet_material := _material(Color("#c6b5b8"), 0.96)
    var pillow_material := _material(Color("#eee6df"), 0.96)

    _box("RoomFloor", Vector3(0.0, -0.18, 0.0), Vector3(14.0, 0.30, 12.0), floor_material)
    _box("BackWall", Vector3(0.0, 2.4, -4.8), Vector3(14.0, 5.2, 0.24), wall_material)
    _box("BedFrame", Vector3(0.0, 0.30, 0.0), Vector3(5.9, 0.42, 3.05), frame_material)
    _box("Mattress", Vector3(0.0, 0.59, 0.0), Vector3(5.65, 0.32, 2.86), mattress_material)
    _box("Headboard", Vector3(2.78, 1.20, 0.0), Vector3(0.26, 1.62, 3.18), wood_material)
    _box("BedSheet", Vector3(-0.10, 0.765, 0.0), Vector3(4.9, 0.055, 2.50), sheet_material)

    _ellipsoid("HeadPillow", Vector3(1.43, 0.82, 0.0), Vector3(0.56, 0.19, 0.78), pillow_material)
    _ellipsoid("SidePillow", Vector3(0.70, 0.80, -0.78), Vector3(0.52, 0.15, 0.48), pillow_material)
    _ellipsoid("SidePillow2", Vector3(0.70, 0.80, 0.78), Vector3(0.52, 0.15, 0.48), pillow_material)

    _box("BedsideTable", Vector3(3.3, 0.48, 2.45), Vector3(0.86, 0.9, 0.8), wood_material)
    _cylinder("LampBase", Vector3(3.3, 1.02, 2.45), 0.18, 0.08, frame_material)
    _ellipsoid("LampShade", Vector3(3.3, 1.35, 2.45), Vector3(0.36, 0.28, 0.36), _material(Color("#f5d8aa"), 0.45))
    var lamp := OmniLight3D.new()
    lamp.position = Vector3(3.3, 1.46, 2.45)
    lamp.light_color = Color("#ffd4a8")
    lamp.light_energy = 0.85
    lamp.omni_range = 5.5
    add_child(lamp)
    _box("RoomRug", Vector3(-0.1, 0.005, 0.0), Vector3(7.8, 0.025, 4.3), _material(Color("#51404a"), 0.98))


func _create_avatar() -> void:
    if avatar != null:
        avatar.queue_free()
    avatar = AvatarModel.new()
    avatar.name = "LyingAdultCharacter"
    avatar.configure(height_value, bust_value, hip_value, glute_value, waist_value, outfit_index, hair_color, eye_color)
    add_child(avatar)


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
    panel.offset_left = 16.0
    panel.offset_top = 16.0
    panel.offset_right = 356.0
    panel.offset_bottom = -16.0
    panel.custom_minimum_size = Vector2(340, 0)
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("#181720")
    panel_style.bg_color.a = 0.94
    panel_style.border_color = Color("#48404d")
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(18)
    panel_style.content_margin_left = 15
    panel_style.content_margin_right = 15
    panel_style.content_margin_top = 13
    panel_style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", panel_style)
    root.add_child(panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 8)
    panel.add_child(layout)
    var brand := Label.new()
    brand.text = "ELYSIA  /  AVATAR STUDIO"
    brand.add_theme_font_size_override("font_size", 20)
    brand.add_theme_color_override("font_color", Color("#f1dce0"))
    layout.add_child(brand)
    var subtitle := Label.new()
    subtitle.text = "3D-персонаж · поза лёжа"
    subtitle.add_theme_font_size_override("font_size", 12)
    subtitle.add_theme_color_override("font_color", Color("#b4aab5"))
    layout.add_child(subtitle)
    layout.add_child(HSeparator.new())

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(scroll)
    var controls := VBoxContainer.new()
    controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_theme_constant_override("separation", 8)
    scroll.add_child(controls)

    _section(controls, "ПРОПОРЦИИ")
    _add_slider(controls, "Рост", 0.92, 1.08, height_value, func(value: float):
        height_value = value
        _update_shape()
    )
    _add_slider(controls, "Объём груди", 0.75, 1.35, bust_value, func(value: float):
        bust_value = value
        _update_shape()
    )
    _add_slider(controls, "Ширина бёдер", 0.82, 1.32, hip_value, func(value: float):
        hip_value = value
        _update_shape()
    )
    _add_slider(controls, "Объём ягодиц", 0.78, 1.42, glute_value, func(value: float):
        glute_value = value
        _update_shape()
    )
    _add_slider(controls, "Талия", 0.82, 1.16, waist_value, func(value: float):
        waist_value = value
        _update_shape()
    )

    _section(controls, "ГЛАЗА")
    var eyes_select := OptionButton.new()
    eyes_select.add_item("Зелёные глаза", 0)
    eyes_select.add_item("Голубые глаза", 1)
    eyes_select.add_item("Карие глаза", 2)
    eyes_select.item_selected.connect(func(index: int):
        if index == 0:
            eye_color = Color("#668f7c")
        elif index == 1:
            eye_color = Color("#6e98c6")
        else:
            eye_color = Color("#80513d")
        _create_avatar()
    )
    controls.add_child(eyes_select)

    _section(controls, "ВОЛОСЫ")
    var hair_row := HBoxContainer.new()
    controls.add_child(hair_row)
    _color_button(hair_row, "Медный", Color("#a94f3f"))
    _color_button(hair_row, "Чёрный", Color("#28212a"))
    _color_button(hair_row, "Блонд", Color("#c7a675"))
    _color_button(hair_row, "Розовый", Color("#c8799d"))

    _section(controls, "ОДЕЖДА")
    _add_outfit_button(controls, "Стартовый комплект", 0)
    _add_outfit_button(controls, "Повседневный образ", 1)
    _add_outfit_button(controls, "Вечернее платье", 2)

    var save_button := Button.new()
    save_button.text = "СОХРАНИТЬ ОБРАЗ"
    save_button.custom_minimum_size = Vector2(0, 44)
    var save_style := StyleBoxFlat.new()
    save_style.bg_color = Color("#9c526e")
    save_style.set_corner_radius_all(10)
    save_button.add_theme_stylebox_override("normal", save_style)
    save_button.pressed.connect(_save_profile)
    layout.add_child(save_button)

    status_label = Label.new()
    status_label.text = "Проведи пальцем по модели, чтобы повернуть"
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 11)
    status_label.add_theme_color_override("font_color", Color("#b9afbb"))
    layout.add_child(status_label)

    var right_title := Label.new()
    right_title.text = "3D CHARACTER PREVIEW"
    right_title.anchor_left = 1.0
    right_title.anchor_right = 1.0
    right_title.offset_left = -280.0
    right_title.offset_right = -22.0
    right_title.offset_top = 20.0
    right_title.offset_bottom = 48.0
    right_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    right_title.add_theme_color_override("font_color", Color("#e0d4dc"))
    right_title.add_theme_font_size_override("font_size", 13)
    root.add_child(right_title)


func _update_shape() -> void:
    if avatar != null:
        avatar.set_shape(height_value, bust_value, hip_value, glute_value, waist_value)


func _section(parent: VBoxContainer, title: String) -> void:
    var label := Label.new()
    label.text = title
    label.add_theme_font_size_override("font_size", 11)
    label.add_theme_color_override("font_color", Color("#d18b9d"))
    parent.add_child(label)


func _add_slider(parent: VBoxContainer, title: String, minimum: float, maximum: float, initial: float, callback: Callable) -> void:
    var block := VBoxContainer.new()
    block.add_theme_constant_override("separation", 1)
    parent.add_child(block)
    var label := Label.new()
    label.text = title
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", Color("#f0eaf0"))
    block.add_child(label)
    var slider := HSlider.new()
    slider.min_value = minimum
    slider.max_value = maximum
    slider.step = 0.01
    slider.value = initial
    slider.custom_minimum_size = Vector2(0, 22)
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.value_changed.connect(callback)
    block.add_child(slider)


func _add_outfit_button(parent: VBoxContainer, title: String, index: int) -> void:
    var button := Button.new()
    button.text = title
    button.custom_minimum_size = Vector2(0, 36)
    button.pressed.connect(func():
        outfit_index = index
        if avatar != null:
            avatar.set_outfit(index)
        status_label.text = "Комплект одежды изменён"
    )
    parent.add_child(button)


func _color_button(parent: HBoxContainer, title: String, color: Color) -> void:
    var button := Button.new()
    button.text = title
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 34)
    button.add_theme_font_size_override("font_size", 10)
    button.pressed.connect(func():
        hair_color = color
        _create_avatar()
        status_label.text = "Цвет волос изменён"
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
    config.set_value("avatar", "hair", hair_color.to_html())
    config.set_value("avatar", "eyes", eye_color.to_html())
    if config.save("user://avatar_profile.cfg") == OK:
        status_label.text = "Образ сохранён на устройстве"
    else:
        status_label.text = "Ошибка сохранения профиля"


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
    hair_color = Color.from_string(str(config.get_value("avatar", "hair", "#a94f3f")), Color("#a94f3f"))
    eye_color = Color.from_string(str(config.get_value("avatar", "eyes", "#668f7c")), Color("#668f7c"))


func _input(event: InputEvent) -> void:
    if avatar == null:
        return
    if event is InputEventScreenDrag and event.position.x > 370.0:
        avatar.turn(-event.relative.x * 0.006)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        if event.position.x > 370.0:
            avatar.turn(-event.relative.x * 0.006)


func _material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material


func _box(part_name: String, position: Vector3, dimensions: Vector3, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    node.mesh = mesh
    node.position = position
    node.material_override = material
    add_child(node)
    return node


func _ellipsoid(part_name: String, position: Vector3, dimensions: Vector3, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 48
    mesh.rings = 32
    node.mesh = mesh
    node.position = position
    node.scale = dimensions
    node.material_override = material
    add_child(node)
    return node


func _cylinder(part_name: String, position: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 40
    node.mesh = mesh
    node.position = position
    node.material_override = material
    add_child(node)
    return node
