extends Node
signal play_rewarded_ad()

@export var tile_map: TileMap
var interstitial_ad : InterstitialAd
var interstitial_ad_load_callback := InterstitialAdLoadCallback.new()
var rewarded_interstitial_ad : RewardedInterstitialAd
var rewarded_interstitial_ad_load_callback := RewardedInterstitialAdLoadCallback.new()
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()

func on_rewarded_interstitial_ad_loaded(_rewarded_interstitial_ad : RewardedInterstitialAd) -> void:
	print("loaded reward intersitial ad")
	self.rewarded_interstitial_ad = _rewarded_interstitial_ad

func on_interstitial_ad_failed_to_load(ad_error: LoadAdError) -> void:
	print(ad_error.message)

func on_interstitial_ad_loaded(ad: InterstitialAd) -> void:
	print("loaded ad")
	self.interstitial_ad = ad

func load_interstitial_rewarded() -> void:
	var unit_id : String
	if GameData.ad_mode == "TESTING":
		unit_id = "ca-app-pub-3940256099942544/6978759866"
	else:
		unit_id = "ca-app-pub-2418850822211418/8229186293"

	RewardedInterstitialAdLoader.new().load(unit_id, AdRequest.new(),
	rewarded_interstitial_ad_load_callback)

func load_interstitial() -> void:
	var unit_id : String
	#if OS.get_name() == "iOS":
	if GameData.ad_mode == "TESTING":
		unit_id = "ca-app-pub-3940256099942544/4411468910"
	else:
		unit_id = "ca-app-pub-2418850822211418/4257511065"

	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), interstitial_ad_load_callback)

func play_intersitial_ad() -> void:
	if interstitial_ad:
		interstitial_ad.show()
		interstitial_ad.destroy()
	load_interstitial()

func play_reward_ad() -> void:
	if rewarded_interstitial_ad:
		rewarded_interstitial_ad.show(on_user_earned_reward_listener)
		rewarded_interstitial_ad.destroy()
	load_interstitial_rewarded()

func _ready() -> void:
	$ConveyorAnimationSync.play()
	interstitial_ad_load_callback.on_ad_failed_to_load = on_interstitial_ad_failed_to_load
	interstitial_ad_load_callback.on_ad_loaded = on_interstitial_ad_loaded

	rewarded_interstitial_ad_load_callback.on_ad_failed_to_load = on_interstitial_ad_failed_to_load
	rewarded_interstitial_ad_load_callback.on_ad_loaded = on_rewarded_interstitial_ad_loaded

	load_interstitial()
	load_interstitial_rewarded()

	on_user_earned_reward_listener.on_user_earned_reward = func(rewarded_item : RewardedItem):
		print("on_user_earned_reward, rewarded_item: rewarded", rewarded_item.amount, rewarded_item.type)
		var rewarded = false

		if rewarded_item.type == "2x 10min":
			for buff in Player.data.buffs:
				if buff.name == "2x":
					buff.time_left += 600
					rewarded = true
			if not rewarded:
				Player.data.buffs.append(Buff.new("2x", 600))

		Player.buffs_changed.emit()
		SaveHandler.save_data(Player.data)

func _on_tile_map_ready() -> void:
	Player.tile_map_loaded.emit(tile_map)

func _on_save_timer_timeout() -> void:
	SaveHandler.save_data(Player.data)

func _on_ad_timer_timeout() -> void:
	print("playing ad")
	play_intersitial_ad()

func _on_play_rewarded_ad() -> void:
	print("playing reward ad")
	play_reward_ad()
