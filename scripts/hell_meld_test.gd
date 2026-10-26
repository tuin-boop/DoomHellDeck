extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	var finish_check = Meld.new()
	finish_check.next_round()
	finish_check.finish_round(0,"won on round points")
	assert(finish_check.scores[0]==30 and finish_check.rounds[0]==1)
	finish_check.finish_round(0,"won on round points")
	assert(finish_check.scores[0]==30 and finish_check.rounds[0]==1,"A round can only award its win bonus once")
	assert(Meld.FAMILY_HELP["type"].contains("damage type"))
	var scoring_check = Meld.new()
	scoring_check.next_round()
	scoring_check.hands = [[0,1,2,5,8],[0,0,1,2,3]]
	scoring_check.side = 0
	assert(scoring_check.play(0,[0,1,2,3,4],-1))
	assert(scoring_check.hands[0].is_empty() and not scoring_check.round_over,"Opening Apocalypse must not end the round")
	assert(scoring_check.draw_one(1))
	assert(scoring_check.draw_one(0) and scoring_check.hands[0].size()==1,"Empty hands can draw and continue")
	scoring_check.turns = [9,10]
	scoring_check.round_scores = [10,20]
	scoring_check.end_action(0)
	assert(scoring_check.round_over and scoring_check.rounds[1]==1,"Higher score wins even with more cards left")
	scoring_check.next_round()
	scoring_check.turns = [9,10]
	scoring_check.round_scores = [20,20]
	scoring_check.hands = [[],[0,1]]
	scoring_check.end_action(0)
	assert(scoring_check.round_message=="Tied round. No round bonus.")
	assert(Meld.pattern([0,0]).name=="IMP MISCHIEF")
	assert(Meld.pattern([0,0,0]).name=="IMP PACK")
	assert(Meld.pattern([0,0,0,0]).name=="IMP INFERNO")
	assert(Meld.pattern([0,7,18]).kind=="type")
	assert(Meld.pattern([0,2,5]).kind=="run")
	assert(Meld.pattern([0,0,2,2]).kind=="pairs")
	assert(Meld.pattern([0,2]).is_empty())
	assert(Meld.pattern([0,0,2,2,2]).name=="FULL HOUSE")
	assert(Meld.pattern([0,0,0,2,2,2]).name=="TWIN LEGIONS")
	assert(Meld.pattern([0,7,18,20]).name=="HELLFIRE UPRISING")
	assert(Meld.pattern([0,2,5,17]).name=="HELL'S LADDER")
	assert(Meld.pattern([0,1,2,5,8]).name=="APOCALYPSE")
	for team in Meld.TEAMS:
		assert(Meld.pattern(team.ids).kind=="team")
		assert(Meld.pattern(team.ids+[team.ids[0]]).points==50)
	var bonus_check = Meld.new()
	bonus_check.next_round()
	bonus_check.hands = [[0,0,1],[0,2]]
	bonus_check.modifier = 0
	bonus_check.relic = 1
	assert(bonus_check.evaluate(0,[0,1]).gain==20)
	assert(not bonus_check.relic_used[0], "Evaluation never consumes a relic")
	assert(bonus_check.play(0,[0,1],-1))
	assert(bonus_check.melds[0].points==10, "Bonuses must not inflate shared base")
	bonus_check.modifier = 1
	bonus_check.relic = 0
	assert(bonus_check.evaluate(1,[0]).gain==43, "20 increase + 8 round + 15 relic")
	assert(bonus_check.play(1,[0],0))
	assert(bonus_check.relic_used[1] and not bonus_check.relic_used[0])
	assert(bonus_check.melds[0].points==30)
	bonus_check.next_round()
	assert(bonus_check.relic_used==[false,false])
	bonus_check.modifier = -1
	bonus_check.relic = 2
	bonus_check.hands = [[0,0,1],[2,3]]
	assert(bonus_check.draw_one(0))
	bonus_check.side = 0
	assert(bonus_check.evaluate(0,[0,1]).relic_bonus==10)
	assert(bonus_check.play(0,[0,1],-1))
	assert(bonus_check.relic_used[0])
	bonus_check.hands[0] = [0,0,0]
	assert(bonus_check.evaluate(0,[0,1,2]).relic_bonus==0, "Spent relic cannot trigger twice")
	bonus_check.melds.clear()
	bonus_check.relic_used = [false,false]
	bonus_check.relic = 1
	assert(bonus_check.evaluate(0,[0,1,2]).relic_bonus==12)
	bonus_check.relic = -1
	bonus_check.modifier = 2
	bonus_check.hands[0] = [8,21,6]
	assert(bonus_check.evaluate(0,[0,1,2]).gain==45)
	assert(bonus_check.best_move(0).indices.size()==3, "AI recognizes named teams and bonuses")
	var apocalypse := [17,0,1,19,2]
	assert(Meld.pattern(apocalypse+[3,8,14,16,7]).name=="DOUBLE APOCALYPSE")
	assert(Meld.pattern(apocalypse+[0]).is_empty())
	assert(Meld.pattern([0,0,2,2,5,5]).name=="DOUBLE MARCH")
	assert(Meld.pattern([0,1,2,3,5,16]).name=="DOUBLE MARCH")
	assert(Meld.pattern([0,Meld.JOKER]).name=="IMP MISCHIEF")
	assert(Meld.pattern([8,21,Meld.JOKER]).kind=="team")
	var wild = Meld.new()
	wild.next_round()
	wild.modifier = -1
	wild.relic = -1
	wild.hands = [[0,Meld.JOKER,2],[0,3]]
	assert(wild.play(0,[0,1],-1))
	assert(wild.melds[0].resolved_ids==[0,0])
	assert(wild.play(1,[0],0))
	assert(wild.melds[0].resolved_ids==[0,0,0], "Joker identity survives extensions")
	wild.melds = [Meld.pattern(apocalypse)]
	wild.melds[0].ids = apocalypse
	wild.hands[0] = [3,8,14,16,7,17]
	assert(wild.evaluate(0,[0,1,2,3,4]).gain==85)
	assert(wild.best_move(0).indices.size()==5)
	var powers = Meld.new()
	powers.next_round()
	powers.modifier = -1
	powers.relic = -1
	powers.hands = [[0,0,2],[1,3]]
	powers.upgrades[0]["set"] = 2
	powers.passive_joker = [0,0]
	powers.enhancements = {0:"GILDED"}
	assert(powers.evaluate(0,[0,1]).gain==36, "10 base +10 upgrade +8 Joker +8 gilded")
	powers.draw_flights.clear()
	assert(powers.hands[0]==[0,0,2],"Powers do not alter monster identities")
	powers.round_over = true
	powers.upgrade_pending = true
	powers.upgrade_offers = ["set","type","run"]
	powers.family_plays[1]["run"] = 4
	powers.choose_upgrade(0)
	powers.support.chosen = powers.support.offers[0]
	powers.support.finish_pick(powers)
	assert(powers.round_number==2 and powers.upgrades[0]["set"]==3 and powers.upgrades[1]["run"]==1)
	powers.side = 1
	powers.hands[1] = [1,2]
	powers.melds.clear()
	powers.draw_flights.clear()
	assert(powers.hands[1]==[1,2],"CPU cannot morph cards either")
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	g.frontend.finish_leaving(g)
	g.mode_tutorials = false
	g.frontend.select_mode(g,1)
	assert(g.modal=="hell_meld" and not g.frontend.at_home)
	m.support.reset()
	m.passive_joker = [-1,-1]
	m.enhancements.clear()
	m.modifier = -1
	m.relic = -1
	m.hands = [[0,0,1],[0,2]]
	var draw_check = Meld.new()
	draw_check.next_round()
	draw_check.hands = [[0,0,1],[2,2,5]]
	assert(not draw_check.best_move(0).indices.is_empty())
	assert(draw_check.draw_one(0), "Player may draw despite holding a combo")
	assert(draw_check.hands[0].size()==4 and draw_check.side==1)
	assert(draw_check.draw_one(1), "CPU uses the same optional-draw rule")
	draw_check.stock.clear()
	assert(draw_check.draw_one(0), "Empty stock still allows a pass")
	assert(draw_check.side==1 and draw_check.hands[0].size()==4)
	for key in ["DSSGCOCK","DSITEMUP","DSPUNCH","DSBAREXP","DSGETPOW"]:
		assert(g.audio.sounds.has(key), "Meld sound must exist: "+key)
	m.draw_flights.clear()
	assert(m.play(0,[0,1],-1))
	assert(m.scores[0]==10 and m.hands[0]==[1])
	assert(m.play(1,[0],0),"CPU can extend player meld")
	assert(m.melds[0].name=="IMP PACK" and m.scores[1]==20)
	assert(m.hands[1]==[2])
	assert(m.stock.size()==59)
	assert(m.best_move(0).indices.is_empty())
	assert(m.draw_one(0))
	assert(m.melds.is_empty() and m.discarded==[0,0,0],"Failed response clears the shared centre")
	assert(m.side==1 and m.scores==[10,20],"Points stay earned; opponent leads")
	m.hands = [[0,2,2],[5,5]]
	m.melds = [{"ids":[0,0],"kind":"set","name":"IMP MISCHIEF","points":10}]
	m.side = 0
	assert(m.evaluate(0,[1,2]).name=="DOUBLE TROUBLE", "Pairs can evolve into two armies")
	assert(m.evaluate(0,[0,1]).is_empty(),"Every added card must fit the resulting pattern")
	m.banner_age = 99
	m.melds.clear()
	m.hands = [[0,0,2],[5,5]]
	m.selected = [0,1]
	var drag_press := InputEventMouseButton.new()
	drag_press.button_index = MOUSE_BUTTON_LEFT
	drag_press.pressed = true
	drag_press.position = m.hand_center(0,3)
	m.handle(g,drag_press)
	var drag_motion := InputEventMouseMotion.new()
	drag_motion.position = Vector2(30,400)
	m.handle(g,drag_motion)
	drag_press.pressed = false
	drag_press.position = drag_motion.position
	m.handle(g,drag_press)
	assert(m.hands[0]==[0,0,2] and m.melds.is_empty() and not m.dragging,"Outside drop preserves cards")
	g.frontend.open(g)
	assert(g.modal=="leave_match")
	g.frontend.click(g,Vector2(200,600))
	assert(g.modal=="hell_meld")
	for letter in "JOHNROMEROGOD":
		var key := InputEventKey.new()
		key.pressed = true
		key.unicode = letter.unicode_at(0)
		m.handle(g,key)
	m.tick(g,0.01)
	assert(m.cheat_hints and m.hint_cards.has(0) and m.hint_cards.has(1))
	assert(not m.hint_cards.has(2), "Hints only mark cards belonging to legal plays")
	for letter in "johnromerogod":
		var key := InputEventKey.new()
		key.pressed = true
		key.unicode = letter.unicode_at(0)
		m.handle(g,key)
	m.tick(g,0.01)
	assert(not m.cheat_hints and m.hint_cards.is_empty())
	var total_rounds := 0
	for match_index in 20:
		m.start(g)
		m.support.chosen = m.support.offers[0]
		m.support.chosen = m.support.offers[0]
		m.support.finish_pick(m)
		m.random.seed = 2026102100+match_index
		m.next_round()
		for round_index in 5:
			var moves := 0
			while not m.round_over:
				var move: Dictionary = m.best_move(m.side)
				if move.indices.is_empty() or (match_index%3==0 and moves%4==0): assert(m.draw_one(m.side))
				else: assert(m.play(m.side,move.indices,move.target))
				moves += 1
				assert(moves<=20)
				assert(m.melds.size()<=1)
				var cards: int = m.stock.size()+m.hands[0].size()+m.hands[1].size()+m.discarded.size()
				for meld in m.melds: cards += meld.ids.size()
				assert(cards==69,"No card duplication or loss")
			total_rounds += 1
			assert(moves==20 and m.turns==[10,10],"Both players always receive ten turns")
			if round_index<4:
				m.round_number += 1
				m.next_round()
				m.support.offer(m)
				m.support.chosen = m.support.offers[0]
				m.support.finish_pick(m)
		assert(m.finished and m.round_number==5)
	if "--visual-test" in OS.get_cmdline_user_args():
		m.start(g)
		m.support.chosen = m.support.offers[0]
		m.support.finish_pick(m)
		await create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-draw.png")
		m.draw_flights.clear()
		m.hands = [[2,14,Meld.JOKER],[0,1,2,3,4]]
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-spectre-back.png")
		m.hands = [[0,0,2,5,17],[3,3,1,18,7]]
		m.age = 3
		m.selected = [0,1]
		m.tick(g,0.01)
		assert(m.selected==[0,1], "Selection stays manual")
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		press.position = m.hand_center(0,5)
		m.handle(g,press)
		var motion := InputEventMouseMotion.new()
		motion.position = Vector2(720,390)
		m.handle(g,motion)
		assert(m.dragging and m.drag_cards==[0,1])
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-hand.png")
		press.pressed = false
		press.position = motion.position
		m.handle(g,press)
		assert(m.melds.size()==1 and m.melds[0].ids==[0,0] and not m.dragging)
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-flight.png")
		m.banner_age = 0.8
		m.banner = "TWIN LEGIONS"
		m.announcement = {"owner":1,"gain":20,"upgrade":true,"before":"FULL HOUSE","old_points":45,"points":65,"new":true}
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-upgrade.png")
		m.banner_age = 1.65
		m.banner = "DOUBLE APOCALYPSE"
		m.announcement = {"kind":"rainbow","ids":[0,1,2,5,8],"owner":0,"gain":85,"upgrade":true,"old_points":65,"points":150,"new":true}
		m.melds = [{"ids":[0,1,2,5,8],"name":"APOCALYPSE","points":65}]
		m.flights.clear()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-combo-dance.png")
		m.banner_age = Meld.REVEAL_TIME
		assert(m.celebration_pose(0,5).center==m.center_card(0,5), "Celebrations settle back to the table")
		m.power_panel = true
		m.upgrades[0] = {"type":2,"set":1,"run":1,"pairs":1}
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-powers.png")
		root.warp_mouse(Vector2(310,490))
		await create_timer(0.65).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-hover-help.png")
		m.round_over = true
		m.finished = false
		m.upgrade_pending = true
		m.upgrade_offers = ["set","rainbow","team"]
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-upgrades.png")
		m.round_over = false
		m.power_panel = false
		m.guide = true
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hell-meld-guide.png")
		for page in Meld.GUIDE_PAGES:
			m.guide_page = page
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://captures/hell-meld-guide-%d.png" % page)
	print("PASS: 100 Hell Meld rounds; combinations, shared extensions, scoring, optional draw/pass, turn limits, card conservation, five-round finish, leave/cancel flow")
	g.queue_free()
	await process_frame
	quit()
