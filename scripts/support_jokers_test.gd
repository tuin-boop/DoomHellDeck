extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	var tilt = preload("res://scripts/card_tilt.gd")
	var left: Transform2D = tilt.pose(Vector2.ZERO,-0.4,true)
	var right: Transform2D = tilt.pose(Vector2.ZERO,0.4,true)
	assert(left.x.y<0 and right.x.y>0,"Side tilt must reverse with pointer direction")
	assert(left.y==Vector2(0,1) and right.y==Vector2(0,1),"Vertical edges stay upright")
	assert(tilt.pose(Vector2.ZERO,0.4,false)==Transform2D.IDENTITY,"Mouse exit resets tilt")
	var m = Meld.new()
	m.next_round()
	var j = m.support
	assert(j.DATA.size()==41)
	j.slots = [[39,40],[]]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==4)
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false,true).bonus==4)
	assert(j.score(m,0,[0],{"gain":20,"kind":"set"},true).bonus==10)
	assert(j.score(m,0,[0],{"gain":20,"kind":"set"},true,true).bonus==10)
	assert(j.score(m,0,[0],{"gain":20,"kind":"set"},true).bonus==0)
	j.begin_round()
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==4)
	assert(j.stats[1].get("glitch_plays",0)==0)
	j.reset()
	j.slots = [[37],[]]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==6)
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false,true).bonus==6)
	assert(j.score(m,0,[0],{"gain":20,"kind":"set"},true).bonus==0)
	assert(j.score(m,0,[0,2,5],{"gain":20,"kind":"run"},false,true).bonus==6)
	j.begin_round()
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==6)
	j.reset()
	j.slots = [[38],[]]
	assert(j.score(m,0,[2,2],{"gain":10,"kind":"set"},false).bonus==8)
	assert(j.score(m,0,[-1,2],{"gain":10,"kind":"set"},false).bonus==4)
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.reset()
	j.slots = [[36],[]]
	assert(j.score(m,0,[0,2],{"gain":20,"kind":"run"},true).bonus==10)
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	assert(j.score(m,0,[0,2,5],{"gain":20,"kind":"run"},false).bonus==0)
	assert(j.score(m,0,[-1,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.reset()
	j.slots = [[35],[]]
	m.round_scores = [20,10]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==6)
	m.round_scores = [10,10]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	m.round_scores = [0,10]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.reset()
	j.slots = [[34],[]]
	m.round_scores = [10,20]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==4)
	m.round_scores = [20,20]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	m.round_scores = [30,20]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	m.round_scores = [0,0]
	j.reset()
	j.slots = [[33],[]]
	m.hands[0] = [0,0]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==10)
	m.hands[0] = [0,0,1]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.reset()
	j.slots = [[32],[]]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false,true).bonus==0)
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==8)
	assert(j.score(m,0,[0,1,2],{"gain":20,"kind":"run"},false).bonus==0)
	j.score(m,1,[0,1,2],{"gain":20,"kind":"run"},false,true)
	assert(j.score(m,0,[0,1,2],{"gain":20,"kind":"run"},false).bonus==8,"CPU's last scoring family counts")
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.begin_round()
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.reset()
	j.slots = [[30,31],[]]
	assert(j.score(m,0,[0,1,2],{"gain":20,"kind":"run"},false).bonus==10)
	assert(j.score(m,0,[0,1,2,3],{"gain":20,"kind":"run"},true).bonus==22)
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==0)
	j.reset()
	j.slots = [[29],[]]
	m.hands[0] = [0,0,1,2,3,4,5,6]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==10)
	m.hands[0] = [0,0,1]
	assert(j.score(m,0,[0,0],{"gain":10,"kind":"set"},false).bonus==2)
	j.reset()
	j.slots = [[28],[]]
	assert(j.score(m,0,[0,1,2],{"gain":20,"kind":"run"},false).bonus==12)
	assert(j.score(m,0,[0,0,2],{"gain":20,"kind":"run"},false).bonus==0)
	j.reset()
	j.slots = [[26,27],[]]
	var feast := {"gain":25,"kind":"pairs"}
	assert(j.score(m,0,[0,0,1,1],feast,false).bonus==12)
	assert(j.score(m,0,[0,0,1,1],feast,false,true).bonus==12)
	assert(j.stats[0].gluttonous==3)
	assert(j.score(m,0,[0,0,0],feast,false).bonus==9)
	assert(j.score(m,0,[-1,0],feast,false).bonus==3)
	for n in 12: j.score(m,0,[0,0,0,0],feast,false,true)
	assert(j.stats[0].gluttonous==24)
	j.begin_round()
	assert(j.stats[0].gluttonous==24)
	assert(j.stats[1].get("gluttonous",0)==0)
	j.reset()
	j.slots = [[20,21,22],[]]
	var object_combo := {"gain":10,"kind":"set"}
	assert(j.score(m,0,[0,0],object_combo,false).bonus==10)
	assert(j.stats[0].is_empty() or not j.stats[0].get("coffee_used",false))
	assert(j.score(m,0,[0,0],object_combo,false,true).bonus==10)
	assert(j.score(m,0,[0],object_combo,true,true).bonus==10)
	assert(j.score(m,0,[0,0],object_combo,false).bonus==25)
	assert(j.score(m,0,[0,0],object_combo,false,true).bonus==25)
	j.slots = [[23,24,25],[]]
	j.apply_contract(m)
	j.apply_contract(m)
	assert(m.round_scores[0]==-20 and m.round_scores[1]==0)
	assert(j.score(m,0,[0,0],object_combo,false,true).bonus==30)
	assert(j.score(m,0,[0,0],object_combo,false).bonus==10)
	j.begin_round()
	m.round_scores = [0,0]
	j.apply_contract(m)
	assert(m.round_scores[0]==-20)
	assert(j.score(m,0,[0,0],object_combo,true).bonus==10)
	assert(j.score(m,0,[0,0],object_combo,false).bonus==30)
	j.reset()
	m.round_scores = [0,0]
	j.update_drawers(j.drawer_tab(0).get_center(),0.3,true)
	assert(j.drawer[0]==1 and j.drawer[1]==0,"Only hovered sidebar opens")
	j.update_drawers(j.slot_rect(0,1).get_center(),0.3,true)
	assert(j.drawer[0]==1,"Sidebar stays open while inspecting cards")
	j.update_drawers(Vector2(400,450),0.5,true)
	assert(j.drawer[0]==0,"Sidebar closes away from cards")
	j.update_drawers(j.drawer_tab(1).get_center(),0.3,true)
	assert(j.drawer[1]==1,"CPU sidebar opens independently")
	j.update_drawers(j.drawer_tab(1).get_center(),0.3,false)
	assert(j.drawer[1]==0,"Modal and dragging close sidebars")
	var combo := {"gain":20,"kind":"set"}
	m.hands = [[0,0,1,8],[0,0]]
	# Every flat-bonus card, including Mime and enhancements.
	var cases := [[0,[0,0],"set",5],[2,[1,1],"set",8],[4,[0,0],"set",12],[7,[0],"set",12],[9,[0,0],"set",10],[10,[0],"set",4],[13,[0,0],"set",12],[14,[0],"team",15],[15,[0],"rainbow",20],[16,[1],"set",5],[19,[0],"set",10]]
	m.enhancements = {0:"GILDED",1:"CHARGED"}
	m.melds = [{"starter":1}]
	j.stats[0].last = "run"
	for c in cases:
		j.slots = [[c[0]],[]]
		combo.kind = c[2]
		assert(j.score(m,0,c[1],combo,true).bonus==c[3],"Fixed bonus: "+j.DATA[c[0]][1])
	j.slots = [[0,12],[]]
	assert(j.score(m,0,[0],combo,true).bonus==10)
	j.slots = [[12,0],[]]
	assert(j.score(m,0,[0],combo,true).bonus==5)
	j.slots = [[3,12],[]]
	assert(j.score(m,0,[0],combo,true).bonus==5,"Mime never copies chance")
	# Evaluation cannot mutate state or consume random rolls.
	j.slots = [[1,3,11],[]]
	var rng_before: int = m.random.state
	var state_before := str(j.stats)
	for i in 20: j.score(m,0,[0,0],combo,false)
	assert(m.random.state==rng_before and str(j.stats)==state_before and j.drained[0].is_empty())
	j.score(m,0,[0,0],combo,false,true)
	assert(j.stats[0].vampire==3 and j.stats[0].chef==2)
	assert(j.enhancement(m,0,0)=="" and j.enhancement(m,1,0)=="GILDED")
	j.begin_round()
	assert(j.enhancement(m,0,0)=="GILDED" and j.stats[0].vampire==3)
	j.slots = [[5],[]]
	combo.kind = "run"
	for i in 3: j.score(m,0,[0],combo,false,true)
	assert(m.upgrades[0].run==1)
	j.slots = [[8,18],[]]
	assert(j.on_draw(0)==2 and j.on_draw(0)==1 and j.stats[0].sleep==8)
	j.score(m,0,[0],combo,false,true)
	assert(j.stats[0].sleep==0)
	j.slots = [[17],[]]
	m.turns[0] = 9
	assert(j.score(m,0,[0],combo,false).gain==30)
	m.turns[0] = 8
	assert(j.score(m,0,[0],combo,false).gain==20)
	j.slots = [[6],[]]
	m.side = 0
	m.banner_age = 99
	m.draw_flights.clear()
	assert(j.score(m,0,[-1,0],combo,false).bonus==15)
	assert(j.score(m,0,[0,0],combo,false).bonus==0)
	j.slots = [[21],[]]
	assert(j.score(m,0,[0],combo,true).bonus==10)
	assert(j.score(m,0,[0,0],combo,true).bonus==0)
	assert(j.score(m,0,[0],combo,false).bonus==0)
	var hit := false
	var miss := false
	j.slots = [[3],[]]
	for i in 100:
		var result: Dictionary = j.score(m,0,[0],combo,false,true)
		assert(result.bonus in [0,20])
		hit = hit or result.bonus==20
		miss = miss or result.bonus==0
	assert(hit and miss)
	# Committed scoring must replace the preview, not award it a second time.
	var actual = Meld.new()
	actual.next_round()
	actual.modifier = -1
	actual.relic = -1
	actual.hands = [[0,0],[0,0]]
	actual.side = 0
	actual.turns = [9,9]
	actual.support.slots = [[0,17],[]]
	assert(actual.play(0,[0,1],-1))
	assert(actual.round_scores[0]==22,"(10 base + 5 Joker) x1.5 floors to 22, once")
	assert(actual.melds[0].points==10,"Personal Jokers never inflate shared base score")
	actual.next_round()
	actual.support.slots = [[18],[]]
	actual.side = 0
	var held: int = actual.hands[0].size()
	var stock_count: int = actual.stock.size()
	assert(actual.draw_one(0))
	assert(actual.hands[0].size()==held+2 and actual.stock.size()==stock_count-2)
	assert(actual.turns[0]==1 and actual.side==1)
	j.reset()
	assert(j.slots==[[],[]] and j.stats==[{},{}])
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	g.hell_meld.start(g)
	m = g.hell_meld
	j = m.support
	assert(j.pending and j.offers.size()==3 and not m.draw_one(0))
	j.chosen = -1
	j.finish_pick(m)
	assert(j.pending and j.slots[0].is_empty(),"Cannot skip an empty Joker slot")
	j.offers = [0,1,2]
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-draft.png")
	var click := InputEventMouseButton.new()
	click.pressed = true
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = Vector2(375,350)
	assert(j.handle(g,m,click))
	assert(j.slots[0]==[0] and j.slots[1].size()==1)
	for round_id in range(2,6):
		m.round_number = round_id
		j.offer(m)
		assert(j.pending and j.offers.size()==3)
		for id in j.offers: assert(not j.slots[0].has(id))
		j.chosen = j.offers[0]
		j.finish_pick(m)
		assert(j.slots[0].size()==round_id and j.slots[1].size()==round_id)
		j.offer(m)
		assert(not j.pending,"Only one pick per round")
	assert(j.drawer_rect(0).encloses(j.slot_rect(0,4)))
	j.drawer = [1.0,1.0]
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/five-joker-trays.png")
	m.round_number = 1
	j.slots = [[0,1,2],[3,8,11]]
	j.library = true
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-collection.png")
	j.page = 1
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-collection-page-two.png")
	assert(not j.guide_links.is_empty())
	click.position = j.guide_links[0].get_center()
	assert(j.handle(g,m,click))
	assert(m.guide and m.guide_page==6 and j.library)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/named-team-guide-link.png")
	click.position = Vector2(700,780)
	m.handle(g,click)
	assert(not m.guide and j.library,"Closing linked guide returns to collection")

	j.page = 2
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-objects.png")
	j.page = 3
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-new-five.png")
	j.page = 4
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/glitch-jester.png")
	assert(j.art[39]!=null and j.art[40]!=null)

	assert(j.art[30]!=null and j.art[31]!=null and j.art[32]!=null and j.art[33]!=null and j.art[34]!=null)
	assert(j.art[25]!=null,"Original ammo box sprite loads")
	j.page = 0
	root.warp_mouse(Vector2(280,240))
	await create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-tilt-help.png")
	j.library = false
	m.draw_flights.clear()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-table.png")
	m.cheat_hints = true
	m.hands[0] = [0,0,1,1]
	m.melds.clear()
	var hinted: Dictionary = m.best_move(0)
	assert(hinted.hints.has(0) and hinted.hints[0].size()>0)
	m.announcement = {"owner":0,"gain":22,"upgrade":false,"points":10,"new":false,"support_bonus":12,"support_events":[{"id":4,"text":"+12"}]}
	m.banner = "IMP MISCHIEF"
	m.announcement.support_events = [{"id":0,"text":"+5","amount":5,"total":15},{"id":4,"text":"+6","amount":6,"total":21},{"id":17,"text":"x1.5 / +10","amount":10,"total":31}]
	m.announcement.gain = 31
	m.announcement.support_bonus = 21
	assert(m.reveal_duration()>6.0,"Three Joker triggers each get a readable beat")
	m.banner_age = 3.5
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-trigger.png")
	m.banner_age = 99
	j.drawer = [1.0,1.0]
	j.drawer_grace = [1.0,1.0]
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-sidebars.png")
	print("PASS: 41 Jokers, scoring, growth, side isolation, RNG-safe previews, copying, combo triggers, draw, multiplier, draft, one-to-five progression and reset")
	j.drawer = [0.0,0.0]
	j.drawer_grace = [0.0,0.0]
	m.round_over = false
	m.banner_age = 99
	m.turns = [9,8]
	m.side = 0
	m.tick(g,0.1)
	assert(m.final_turn_seen[0] and m.final_turn_owner==0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/final-turn-alert.png")
	m.turns = [10,9]
	m.side = 1
	m.tick(g,0.1)
	assert(m.final_turn_seen[1] and m.final_turn_owner==1 and m.cpu_wait>2.0)
	m.round_number = 5
	m.rounds = [3,1]
	m.round_over = false
	m.finish_round(1,"test")
	assert(m.result_winner==0,"Match winner overrides last round winner")
	m.banner_age = 99
	m.result_age = 0.0
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/result-popup-start.png")
	m.result_age = 1.0
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/result-player-win.png")
	m.round_over = false
	m.rounds = [1,3]
	m.finish_round(0,"test")
	assert(m.result_winner==1)
	m.result_age = 1.0
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/result-cpu-win.png")
	for winner in 2:
		m.result_winner = winner
		m.result_variant = 1
		m.result_age = 1.0
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/result-variant-two-%d.png" % winner)
	m.next_round()
	assert(m.result_winner==-1 and m.result_age==0.0)
	print("PASS: result art, final-match winner and next-round reset")
	g.queue_free()
	await process_frame
	quit()
