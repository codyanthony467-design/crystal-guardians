extends CanvasLayer

@onready var health_label: Label = $HUDContainer/HealthPanel/VBoxContainer/HealthLabel
@onready var health_bar: ProgressBar = $HUDContainer/HealthPanel/VBoxContainer/HealthBar
@onready var hearts_label: Label = $HUDContainer/HealthPanel/VBoxContainer/HeartsLabel
@onready var crystal_label: Label = $HUDContainer/CrystalsPanel/CrystalLabel
@onready var quest_label: Label = $HUDContainer/QuestPanel/QuestLabel

func _ready() -> void:
	QuestManager.quest_updated.connect(update_quest_info)
	update_quest_info()

func update_health(current: int, max: int) -> void:
	health_bar.max_value = max
	health_bar.value = current
	health_label.text = "VIDA: %d/%d" % [current, max]
	var total_hearts := 5
	var filled := int(ceil(float(current) / maxf(float(max), 1.0) * total_hearts))
	hearts_label.text = "♥ ".repeat(filled).strip_edges() + (" ♡ ".repeat(total_hearts - filled)).strip_edges()

func update_quest_info() -> void:
	crystal_label.text = "CRISTALES: %d/%d" % [
		QuestManager.collected_crystals,
		QuestManager.required_crystals
	]
	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			quest_label.text = "MISION: Habla con Han Solo"
		QuestManager.QuestState.ACTIVE:
			quest_label.text = "MISION: Recolectar los cristales"
		QuestManager.QuestState.READY_TO_DELIVER:
			quest_label.text = "MISION: Entrega los cristales a Han Solo"
		QuestManager.QuestState.COMPLETED:
			quest_label.text = "MISION COMPLETADA"
