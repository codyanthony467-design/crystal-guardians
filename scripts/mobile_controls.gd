extends CanvasLayer

@onready var joystick_base: Control = $Controls/JoystickBase
@onready var joystick_knob: Control = $Controls/JoystickBase/JoystickKnob
@onready var attack_button: Button = $Controls/AttackButton
@onready var interact_button: Button = $Controls/InteractButton

@export var joystick_radius: float = 65.0
@export_range(0.0, 1.0) var deadzone: float = 0.15
var joystick_direction: Vector2 = Vector2.ZERO
var active_touch_index: int = -1
var base_center: Vector2

func _ready() -> void:
    joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    base_center = joystick_base.size / 2.0
    _center_knob()
    attack_button.pressed.connect(_attack_pressed)
    interact_button.pressed.connect(_interact_pressed)
    get_viewport().size_changed.connect(_layout_controls)
    _layout_controls()

func _layout_controls() -> void:
    var view := get_viewport().get_visible_rect().size
    joystick_base.position = Vector2(28, view.y - 190)
    joystick_base.size = Vector2(150, 150)
    base_center = joystick_base.size / 2.0
    attack_button.position = Vector2(view.x - 115, view.y - 175)
    attack_button.size = Vector2(88, 64)
    interact_button.position = Vector2(view.x - 205, view.y - 105)
    interact_button.size = Vector2(88, 58)
    _center_knob()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and active_touch_index == -1 and is_inside_joystick(event.position):
            active_touch_index = event.index
            update_joystick(event.position)
        elif not event.pressed and event.index == active_touch_index:
            active_touch_index = -1
            reset_joystick()
    elif event is InputEventScreenDrag and event.index == active_touch_index:
        update_joystick(event.position)

func is_inside_joystick(screen_position: Vector2) -> bool:
    var rect := Rect2(joystick_base.global_position, joystick_base.size)
    return rect.has_point(screen_position)

func update_joystick(screen_position: Vector2) -> void:
    var local_pos := screen_position - joystick_base.global_position
    var offset := local_pos - base_center
    if offset.length() > joystick_radius:
        offset = offset.normalized() * joystick_radius
    joystick_direction = offset / joystick_radius
    if joystick_direction.length() < deadzone:
        joystick_direction = Vector2.ZERO
    _set_move_action("move_left", joystick_direction.x < -deadzone)
    _set_move_action("move_right", joystick_direction.x > deadzone)
    _set_move_action("move_up", joystick_direction.y < -deadzone)
    _set_move_action("move_down", joystick_direction.y > deadzone)
    joystick_knob.position = base_center + offset - joystick_knob.size / 2.0

func reset_joystick() -> void:
    joystick_direction = Vector2.ZERO
    for action in ["move_left", "move_right", "move_up", "move_down"]:
        Input.action_release(action)
    _center_knob()

func _center_knob() -> void:
    joystick_knob.position = (joystick_base.size - joystick_knob.size) / 2.0

func _set_move_action(action: String, active: bool) -> void:
    if active:
        if not Input.is_action_pressed(action): Input.action_press(action)
    else:
        Input.action_release(action)

func _attack_pressed() -> void:
    Input.action_press("player_attack")
    await get_tree().create_timer(0.12).timeout
    Input.action_release("player_attack")

func _interact_pressed() -> void:
    Input.action_press("interact")
    await get_tree().create_timer(0.12).timeout
    Input.action_release("interact")
