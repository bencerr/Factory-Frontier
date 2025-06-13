extends Node
signal play_rewarded_ad()

@export var tile_map: TileMap

var interstitial_ad : InterstitialAd
var rewarded_ad: RewardedAd
var rewarded_interstitial_ad : RewardedInterstitialAd

var interstitial_ad_load_callback := InterstitialAdLoadCallback.new()
var rewarded_interstitial_ad_load_callback := RewardedInterstitialAdLoadCallback.new()
var rewarded_ad_load_callback := RewardedAdLoadCallback.new()

var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()

func _on_rewarded_ad_loaded(_reward_ad: RewardedAd) -> void:
	print("rewarded ad loaded")
	rewarded_ad = _reward_ad

func _on_rewarded_interstitial_ad_loaded(_rewarded_interstitial_ad: RewardedInterstitialAd) -> void:
	print("loaded reward intersitial ad")
	self.rewarded_interstitial_ad = _rewarded_interstitial_ad

func _on_interstitial_ad_loaded(ad: InterstitialAd) -> void:
	print("loaded ad")
	self.interstitial_ad = ad

func _on_ad_failed_to_load(ad_error: LoadAdError) -> void:
	print(ad_error.message)

func load_rewarded() -> void:
	var unit_id : String
	if OS.get_name() == "iOS":
		if GameData.ad_mode == "TESTING":
			unit_id = "ca-app-pub-3940256099942544/1712485313"
		else:
			unit_id = "ca-app-pub-2418850822211418/5028114360"
	else:
		if GameData.ad_mode == "TESTING":
			unit_id = "ca-app-pub-3940256099942544/5224354917"
		else:
			unit_id = "ca-app-pub-2418850822211418/7343015383"

	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

func load_interstitial() -> void:
	var unit_id : String
	if OS.get_name() == "iOS":
		if GameData.ad_mode == "TESTING":
			unit_id = "ca-app-pub-3940256099942544/4411468910"
		else:
			unit_id = "ca-app-pub-2418850822211418/4257511065"
	else:
		if GameData.ad_mode == "TESTING":
			unit_id = "ca-app-pub-3940256099942544/1033173712"
		else:
			unit_id = "ca-app-pub-2418850822211418/7580423760"

	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), interstitial_ad_load_callback)

func play_intersitial_ad() -> void:
	if interstitial_ad:
		interstitial_ad.show()
		interstitial_ad.destroy()
	load_interstitial()

func play_reward_ad() -> void:
	if rewarded_ad:
		rewarded_ad.show(on_user_earned_reward_listener)
		rewarded_ad.destroy()
	load_rewarded()

func _ready() -> void:
	$ConveyorAnimationSync.play()
	interstitial_ad_load_callback.on_ad_failed_to_load = _on_ad_failed_to_load
	interstitial_ad_load_callback.on_ad_loaded = _on_interstitial_ad_loaded

	rewarded_interstitial_ad_load_callback.on_ad_failed_to_load = _on_ad_failed_to_load
	rewarded_interstitial_ad_load_callback.on_ad_loaded = _on_rewarded_interstitial_ad_loaded

	rewarded_ad_load_callback.on_ad_failed_to_load = _on_ad_failed_to_load
	rewarded_ad_load_callback.on_ad_loaded = _on_rewarded_ad_loaded

	load_interstitial()
	load_rewarded()

	on_user_earned_reward_listener.on_user_earned_reward = func(rewarded_item : RewardedItem):
		print("on_user_earned_reward, rewarded_item: rewarded", rewarded_item.amount, rewarded_item.type)
		var rewarded = false

		if rewarded_item.type == "2x 10min":
			for i in range(len(Player.data.buffs)):
				var buff = Player.data.buffs[i]
				if buff.name == "2x":
					Player.data.buffs[i].time_left += rewarded_item.amount
					rewarded = true
			if not rewarded:
				Player.data.buffs.append(Buff.new("2x", rewarded_item.amount))

		Player.buffs_changed.emit()
		SaveHandler.save_data(Player.data)

	Player.main_loaded.emit()

func load_base() -> void:
	var indx := Player.data.base_level
	var path := "res://scenes/bases/%s.tscn" % indx
	var tile_map_packed: PackedScene = load(path)
	var inst: TileMap = tile_map_packed.instantiate()
	get_node("/root/Main/TileMap").replace_by(inst)
	get_node("/root/Main").move_child(inst, 2)
	get_node("/root/Main/InputHandler/ItemPlacement").tilemap = inst
	Player.tile_map_loaded.emit(tile_map)

func _on_save_timer_timeout() -> void:
	SaveHandler.save_data(Player.data)

func _on_ad_timer_timeout() -> void:
	print("playing ad")
	play_intersitial_ad()

func _on_play_rewarded_ad() -> void:
	print("playing reward ad")
	play_reward_ad()

func _on_play_time_timer_timeout() -> void:
	Player.data.time_in_rebirth += 1
	for quest in Player.data.quests:
		if quest.type == QuestManager.QUESTTYPE.PLAY_TIME:
			quest.update_progress(quest.progress + (1 / quest.goal))
			Player.quest_changed.emit(quest)
		elif quest.type == QuestManager.QUESTTYPE.REBIRTH_TIME:
			Player.quest_changed.emit(quest)