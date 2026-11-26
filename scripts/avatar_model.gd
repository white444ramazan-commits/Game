extends Node3D

const SKIN := Color("#d9a78f")
const HAIR_DEFAULT := Color("#a94f3f")
const OUTFIT_DARK := Color("#332435")

var height_value := 1.0
var bust_value := 1.0
var hip_value := 1.0
var glute_value := 1.0
var waist_value := 1.0
var outfit_index := 0
var hair_color := HAIR_DEFAULT
var eye_color := Color("#668f7c")
var yaw_angle := 0.0

var skin_material: StandardMaterial3D
var hair_material: StandardMaterial3D


func configure(h: float, bust: float, hips: float, glutes: float, waist: float, outfit: int, hair: Color, eyes: Color) -> void:
    height_value = h
    bust_value = bust
    hip_value = hips
    glute_value = glutes
    waist_value = waist
    outfit_index = outfit
    hair_color = hair
    eye_color = eyes


func _ready() -> void:
    _rebuild()


func set_shape(h: float, bust: float, hips: float, glutes: float, waist: float) -> void:
    height_value = h
    bust_value = bust
    hip_value = hips
    glute_value = glutes
    waist_value = waist
    _rebuild()


func set_outfit(index: int) -> void:
    outfit_index = clampi(index, 0, 2)
    _rebuild()


func set_hair(color: Color) -> void:
    hair_color = color
    _rebuild()


func set_eyes(color: Color) -> void:
    eye_color = color
    _rebuild()


func turn(amount: float) -> void:
    yaw_angle += amount
    _apply_pose_transform()


func _apply_pose_transform() -> void:
    # Local X -> mattress width, local Y -> body length, local +Z -> upward.
    var lying_basis := Basis(
        Vector3(0.0, 0.0, 1.0),
        Vector3(1.0, 0.0, 0.0),
        Vector3(0.0, 1.0, 0.0)
    )
    transform = Transform3D(Basis(Vector3.UP, yaw_angle) * lying_basis, Vector3(-1.55, 0.94, 0.0))
    scale = Vector3.ONE * height_value


func _rebuild() -> void:
    for child in get_children():
        remove_child(child)
        child.free()

    _apply_pose_transform()
    skin_material = _make_skin_material()
    hair_material = _make_hair_material()
    _build_body()
    _build_face()
    _build_hair()
    _build_accessories()
    _build_outfit()


func _make_skin_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = SKIN
    material.roughness = 0.72
    material.metallic = 0.0
    material.subsurf_scattering_enabled = true
    material.subsurf_scattering_strength = 0.38
    material.backlight_enabled = true
    material.backlight = Color("#d89b84")
    return material


func _make_hair_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = hair_color
    material.roughness = 0.34
    material.anisotropy_enabled = true
    material.anisotropy = 0.36
    return material


func _make_fabric_material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.58
    material.clearcoat_enabled = true
    material.clearcoat = 0.16
    material.clearcoat_roughness = 0.42
    return material


func _build_body() -> void:
    var profile: Array[Vector4] = [
        Vector4(0.54, 0.27, 0.22, -0.015),
        Vector4(0.68, 0.36, 0.255, -0.010),
        Vector4(0.84, 0.43, 0.29, 0.000),
        Vector4(1.02, 0.405, 0.265, 0.000),
        Vector4(1.20, 0.345, 0.205, 0.000),
        Vector4(1.38, 0.315, 0.19, 0.000),
        Vector4(1.58, 0.34, 0.205, 0.000),
        Vector4(1.78, 0.395, 0.235, 0.000),
        Vector4(1.98, 0.445, 0.255, 0.000),
        Vector4(2.15, 0.43, 0.235, -0.005),
        Vector4(2.29, 0.335, 0.19, -0.005),
        Vector4(2.42, 0.18, 0.145, -0.005),
        Vector4(2.58, 0.14, 0.13, -0.005)
    ]
    for i in range(profile.size()):
        var p := profile[i]
        var width_scale := 1.0
        if p.x < 1.12:
            width_scale = hip_value
        elif p.x < 1.72:
            width_scale = waist_value
        profile[i] = Vector4(p.x, p.y * width_scale, p.z, p.w)
    _create_loft("ContinuousTorso", profile, skin_material, 64, 5)

    _ellipsoid(self, "ChestLeft", Vector3(-0.205, 2.04, 0.205),
        Vector3(0.225 * bust_value, 0.225 * bust_value, 0.145 * bust_value), skin_material, 48, 32)
    _ellipsoid(self, "ChestRight", Vector3(0.205, 2.04, 0.205),
        Vector3(0.225 * bust_value, 0.225 * bust_value, 0.145 * bust_value), skin_material, 48, 32)

    # The arms and legs are continuous tapered tubes rooted inside the torso.
    _tube("ArmLeft", [
        Vector3(-0.40, 2.20, -0.005), Vector3(-0.49, 2.04, 0.015),
        Vector3(-0.555, 1.83, 0.035), Vector3(-0.59, 1.61, 0.055),
        Vector3(-0.625, 1.39, 0.075), Vector3(-0.64, 1.25, 0.09)
    ], [0.155, 0.142, 0.125, 0.108, 0.092, 0.082], skin_material, 20)
    _tube("ArmRight", [
        Vector3(0.40, 2.20, -0.005), Vector3(0.49, 2.04, 0.015),
        Vector3(0.555, 1.83, 0.035), Vector3(0.59, 1.61, 0.055),
        Vector3(0.625, 1.39, 0.075), Vector3(0.64, 1.25, 0.09)
    ], [0.155, 0.142, 0.125, 0.108, 0.092, 0.082], skin_material, 20)
    _ellipsoid(self, "HandLeft", Vector3(-0.64, 1.19, 0.10), Vector3(0.095, 0.145, 0.065), skin_material)
    _ellipsoid(self, "HandRight", Vector3(0.64, 1.19, 0.10), Vector3(0.095, 0.145, 0.065), skin_material)

    var leg_radius := 0.18 * hip_value
    _tube("LegLeft", [
        Vector3(-0.235 * hip_value, 0.79, -0.015), Vector3(-0.25 * hip_value, 0.64, -0.02),
        Vector3(-0.265 * hip_value, 0.43, -0.025), Vector3(-0.25 * hip_value, 0.23, -0.035),
        Vector3(-0.245 * hip_value, 0.105, -0.025)
    ], [leg_radius, leg_radius * 0.98, 0.145 * hip_value, 0.108, 0.082], skin_material, 24)
    _tube("LegRight", [
        Vector3(0.235 * hip_value, 0.79, -0.015), Vector3(0.25 * hip_value, 0.64, -0.02),
        Vector3(0.265 * hip_value, 0.43, -0.025), Vector3(0.25 * hip_value, 0.23, -0.035),
        Vector3(0.245 * hip_value, 0.105, -0.025)
    ], [leg_radius, leg_radius * 0.98, 0.145 * hip_value, 0.108, 0.082], skin_material, 24)
    _ellipsoid(self, "FootLeft", Vector3(-0.245 * hip_value, 0.075, 0.105), Vector3(0.105, 0.085, 0.225), skin_material)
    _ellipsoid(self, "FootRight", Vector3(0.245 * hip_value, 0.075, 0.105), Vector3(0.105, 0.085, 0.225), skin_material)


func _build_face() -> void:
    _tube("Neck", [
        Vector3(0.0, 2.36, 0.0), Vector3(0.0, 2.48, 0.0),
        Vector3(0.0, 2.63, 0.0), Vector3(0.0, 2.73, 0.0)
    ], [0.17, 0.15, 0.135, 0.13], skin_material, 24)
    _ellipsoid(self, "Head", Vector3(0.0, 2.98, 0.025), Vector3(0.335, 0.435, 0.315), skin_material, 64, 40)
    _ellipsoid(self, "Jaw", Vector3(0.0, 2.78, 0.095), Vector3(0.255, 0.205, 0.235), skin_material, 48, 32)
    _ellipsoid(self, "EarLeft", Vector3(-0.33, 2.97, 0.015), Vector3(0.075, 0.12, 0.075), skin_material)
    _ellipsoid(self, "EarRight", Vector3(0.33, 2.97, 0.015), Vector3(0.075, 0.12, 0.075), skin_material)

    var sclera := _make_material(Color("#fff8f2"), 0.22)
    var iris := _make_material(eye_color, 0.26)
    var pupil := _make_material(Color("#17151a"), 0.18)
    var highlight := _make_material(Color("#ffffff"), 0.12)
    var eyeliner := _make_material(Color("#4a3034"), 0.52)
    var brows := _make_material(Color("#68443d"), 0.72)

    for side in [-1.0, 1.0]:
        _ellipsoid(self, "EyeSocket" + str(side), Vector3(side * 0.132, 3.035, 0.279),
            Vector3(0.088, 0.062, 0.032), _make_material(Color("#bd897d"), 0.78), 40, 24)
        _ellipsoid(self, "EyeWhite" + str(side), Vector3(side * 0.132, 3.036, 0.300),
            Vector3(0.071, 0.043, 0.027), sclera, 40, 24)
        _ellipsoid(self, "Iris" + str(side), Vector3(side * 0.132, 3.034, 0.324),
            Vector3(0.027, 0.031, 0.012), iris, 32, 20)
        _ellipsoid(self, "Pupil" + str(side), Vector3(side * 0.132, 3.034, 0.334),
            Vector3(0.013, 0.019, 0.008), pupil, 24, 16)
        _ellipsoid(self, "EyeCatchlight" + str(side), Vector3(side * 0.142, 3.047, 0.341),
            Vector3(0.009, 0.009, 0.005), highlight, 16, 12)
        _tube("UpperEyelid" + str(side), [
            Vector3(side * 0.205, 3.045, 0.292), Vector3(side * 0.17, 3.086, 0.300),
            Vector3(side * 0.132, 3.092, 0.304), Vector3(side * 0.095, 3.082, 0.300),
            Vector3(side * 0.065, 3.045, 0.292)
        ], [0.012, 0.014, 0.015, 0.014, 0.010], eyeliner, 10)
        _tube("Brow" + str(side), [
            Vector3(side * 0.065, 3.135, 0.292), Vector3(side * 0.115, 3.16, 0.287),
            Vector3(side * 0.17, 3.16, 0.28), Vector3(side * 0.215, 3.135, 0.265)
        ], [0.018, 0.022, 0.020, 0.012], brows, 10)

    _ellipsoid(self, "NoseBridge", Vector3(0.0, 2.98, 0.302), Vector3(0.045, 0.085, 0.058), skin_material)
    _ellipsoid(self, "NoseTip", Vector3(0.0, 2.925, 0.354), Vector3(0.055, 0.045, 0.042), _make_material(Color("#cf9987"), 0.66))
    _ellipsoid(self, "LipUpper", Vector3(0.0, 2.82, 0.315), Vector3(0.082, 0.022, 0.022), _make_material(Color("#9e5860"), 0.46))
    _ellipsoid(self, "LipLower", Vector3(0.0, 2.795, 0.314), Vector3(0.073, 0.024, 0.024), _make_material(Color("#bd7475"), 0.42))


func _build_hair() -> void:
    _ellipsoid(self, "HairCap", Vector3(0.0, 3.265, -0.025), Vector3(0.38, 0.285, 0.34), hair_material, 64, 40)
    _ellipsoid(self, "HairFringe", Vector3(0.0, 3.17, 0.235), Vector3(0.33, 0.135, 0.105), hair_material, 48, 32)
    _ellipsoid(self, "HairBack", Vector3(0.0, 2.70, -0.20), Vector3(0.37, 0.69, 0.14), hair_material, 48, 32)

    for side in [-1.0, 1.0]:
        _tube("LongHairLock" + str(side), [
            Vector3(side * 0.27, 3.18, 0.15), Vector3(side * 0.36, 2.95, 0.115),
            Vector3(side * 0.38, 2.70, 0.105), Vector3(side * 0.34, 2.45, 0.095),
            Vector3(side * 0.28, 2.22, 0.08), Vector3(side * 0.33, 2.03, 0.06)
        ], [0.12, 0.105, 0.085, 0.075, 0.055, 0.025], hair_material, 16)
        _tube("FaceFramingStrand" + str(side), [
            Vector3(side * 0.14, 3.23, 0.31), Vector3(side * 0.22, 3.08, 0.325),
            Vector3(side * 0.27, 2.91, 0.315), Vector3(side * 0.29, 2.72, 0.285),
            Vector3(side * 0.25, 2.54, 0.245)
        ], [0.045, 0.04, 0.034, 0.026, 0.012], hair_material, 12)

    for i in range(9):
        var x := -0.27 + float(i) * 0.067
        _tube("FringeStrand" + str(i), [
            Vector3(x, 3.37, 0.10), Vector3(x * 0.92, 3.29, 0.245),
            Vector3(x * 0.84, 3.19 - absf(x) * 0.10, 0.315),
            Vector3(x * 0.80, 3.10 - absf(x) * 0.14, 0.30)
        ], [0.035, 0.032, 0.024, 0.009], hair_material, 10)


func _build_accessories() -> void:
    var choker := _make_fabric_material(Color("#27232b"))
    _tube("Choker", [
        Vector3(-0.16, 2.59, 0.0), Vector3(-0.10, 2.56, 0.12),
        Vector3(0.0, 2.55, 0.145), Vector3(0.10, 2.56, 0.12),
        Vector3(0.16, 2.59, 0.0)
    ], [0.032, 0.035, 0.035, 0.035, 0.032], choker, 12)
    _ellipsoid(self, "Pendant", Vector3(0.0, 2.47, 0.17), Vector3(0.035, 0.10, 0.018), _make_material(Color("#c1b7ab"), 0.24))


func _build_outfit() -> void:
    var top_color := Color("#392d43")
    var bottom_color := Color("#33283d")
    if outfit_index == 1:
        top_color = Color("#98576a")
        bottom_color = Color("#34425b")
    elif outfit_index == 2:
        top_color = Color("#344965")
        bottom_color = Color("#344965")

    var top_material := _make_fabric_material(top_color)
    var bottom_material := _make_fabric_material(bottom_color)
    var top_profile: Array[Vector4] = [
        Vector4(1.48, 0.355, 0.235, 0.018),
        Vector4(1.60, 0.37, 0.245, 0.018),
        Vector4(1.78, 0.42, 0.275, 0.018),
        Vector4(1.96, 0.465, 0.285, 0.018),
        Vector4(2.12, 0.45, 0.265, 0.015),
        Vector4(2.24, 0.36, 0.215, 0.010)
    ]
    _create_loft("FittedTop", top_profile, top_material, 56, 4)

    if outfit_index == 0:
        _ellipsoid(self, "OpaqueShorts", Vector3(0.0, 0.91, 0.02),
            Vector3(0.435 * hip_value, 0.30 * glute_value, 0.315), bottom_material, 56, 36)
    elif outfit_index == 1:
        _ellipsoid(self, "CasualShorts", Vector3(0.0, 0.94, 0.02),
            Vector3(0.46 * hip_value, 0.33 * glute_value, 0.33), bottom_material, 56, 36)
    else:
        var skirt := MeshInstance3D.new()
        var skirt_mesh := CylinderMesh.new()
        skirt_mesh.top_radius = 0.34 * hip_value
        skirt_mesh.bottom_radius = 0.62 * hip_value
        skirt_mesh.height = 0.78
        skirt_mesh.radial_segments = 64
        skirt.mesh = skirt_mesh
        skirt.position = Vector3(0.0, 0.82, 0.0)
        skirt.material_override = bottom_material
        add_child(skirt)


func _create_loft(part_name: String, profile: Array[Vector4], material: Material, radial_segments: int = 48, samples_per_segment: int = 4) -> MeshInstance3D:
    var rings: Array[Vector4] = []
    for segment in range(profile.size() - 1):
        for step in range(samples_per_segment):
            var t := float(step) / float(samples_per_segment)
            var p0: Vector4 = profile[maxi(segment - 1, 0)]
            var p1: Vector4 = profile[segment]
            var p2: Vector4 = profile[segment + 1]
            var p3: Vector4 = profile[mini(segment + 2, profile.size() - 1)]
            rings.append(_catmull_rom(p0, p1, p2, p3, t))
    rings.append(profile[profile.size() - 1])

    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for ring in rings:
        for i in range(radial_segments):
            var angle := TAU * float(i) / float(radial_segments)
            st.add_vertex(Vector3(cos(angle) * ring.y, ring.x, ring.w + sin(angle) * ring.z))
    for r in range(rings.size() - 1):
        for i in range(radial_segments):
            var next_i := (i + 1) % radial_segments
            var a := r * radial_segments + i
            var b := (r + 1) * radial_segments + i
            var c := (r + 1) * radial_segments + next_i
            var d := r * radial_segments + next_i
            st.add_index(a)
            st.add_index(b)
            st.add_index(c)
            st.add_index(a)
            st.add_index(c)
            st.add_index(d)

    st.generate_normals()
    var node := MeshInstance3D.new()
    node.name = part_name
    node.mesh = st.commit()
    node.material_override = material
    add_child(node)
    return node


func _catmull_rom(p0: Vector4, p1: Vector4, p2: Vector4, p3: Vector4, t: float) -> Vector4:
    var t2 := t * t
    var t3 := t2 * t
    return 0.5 * (
        (2.0 * p1) +
        (-p0 + p2) * t +
        (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
        (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
    )


func _tube(part_name: String, points: Array[Vector3], radii: Array[float], material: Material, radial_segments: int = 16) -> MeshInstance3D:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(points.size()):
        var previous: Vector3 = points[maxi(i - 1, 0)]
        var following: Vector3 = points[mini(i + 1, points.size() - 1)]
        var tangent := (following - previous).normalized()
        var reference := Vector3.FORWARD
        if absf(tangent.dot(reference)) > 0.92:
            reference = Vector3.RIGHT
        var side := tangent.cross(reference).normalized()
        var normal := tangent.cross(side).normalized()
        for j in range(radial_segments):
            var angle := TAU * float(j) / float(radial_segments)
            var offset := side * cos(angle) + normal * sin(angle)
            st.add_vertex(points[i] + offset * radii[i])
    for i in range(points.size() - 1):
        for j in range(radial_segments):
            var next_j := (j + 1) % radial_segments
            var a := i * radial_segments + j
            var b := (i + 1) * radial_segments + j
            var c := (i + 1) * radial_segments + next_j
            var d := i * radial_segments + next_j
            st.add_index(a)
            st.add_index(b)
            st.add_index(c)
            st.add_index(a)
            st.add_index(c)
            st.add_index(d)
    st.generate_normals()
    var node := MeshInstance3D.new()
    node.name = part_name
    node.mesh = st.commit()
    node.material_override = material
    add_child(node)
    return node


func _ellipsoid(parent: Node3D, part_name: String, position: Vector3, dimensions: Vector3, material: Material, radial_segments: int = 48, rings: int = 32) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part_name
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = radial_segments
    mesh.rings = rings
    node.mesh = mesh
    node.position = position
    node.scale = dimensions
    node.material_override = material
    parent.add_child(node)
    return node


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material
