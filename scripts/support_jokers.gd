extends RefCounted
const Editions = preload("res://scripts/joker_editions.gd")
var editions := [{},{}]
var offer_editions := {}
func edition_of(owner: int, id: int) -> int:
	return int(editions[owner].get(id,0)) if owner>=0 else 0

# Stable IDs also name optional assets/jokers/<id>.png illustrations.
const DATA := [
	["joker_imp", "JOKER IMP", "+5 points on every scoring play."],
	["vampire_imp", "VAMPIRE IMP", "After scoring, drain one played monster species' enhancement for your side this round. Gain +3 on future plays per drain, for this match."],
	["cowboy_doomguy", "COWBOY DOOMGUY", "+4 per Bullet monster you play."],
	["lucky_imp", "LUCKY IMP", "25% chance of +20 on each scoring play."],
	["greedy_pinky", "GREEDY JOKER", "+6 extra per Gilded monster you play."],
	["professor_revenant", "PROFESSOR REVENANT", "Every third March you play upgrades your March bonus by +5 for this match."],
	["magician_arch_vile", "MAGICIAN ARCH-VILE", "+15 when you play John Romero in a valid combination."],
	["pirate_cacodemon", "PIRATE CACODEMON", "Add cards to a combo on the table originally started by your opponent to earn +12 extra points. Automatic; no activation needed."],
	["sleepy_mancubus", "SLEEPY MANCUBUS", "Each draw/pass stores +4, up to +16. Your next scoring play collects it."],
	["king_cyberdemon", "KING CYBERDEMON", "+10 if a Cyberdemon remains in your hand after playing. Once per play."],
	["disco_revenant", "DISCO REVENANT", "Repeat the leftmost played card's enhancement: Gilded +4, or Charged +8 on extension."],
	["chef_mancubus", "CHEF MANCUBUS", "Each Fire monster played adds +1 to future Fire-play bonuses, up to +20, for this match."],
	["mime_spectre", "MIME DOOMGUY", "Copy the previous slot's fixed scoring bonus. Cannot copy Mime, chance, stored growth, multipliers or extra actions. Swap your slots by clicking them."],
	["boxer_pinky", "REVENANT BOXER", "+12 when you add exactly two cards in a valid play."],
	["general_baron", "GENERAL BARON", "+15 when you play or extend a named team."],
	["astronaut_lost_soul", "ASTRONAUT LOST SOUL", "+20 when you play or extend Apocalypse."],
	["electric_arachnotron", "ELECTRIC ARACHNOTRON", "+5 per Charged monster played, including when starting a combination."],
	["berserker_doomguy", "BERSERKER DOOMGUY", "Multiply your tenth-turn scoring play by 1.5, rounding down. Draw/pass gets no bonus."],
	["clown_pain_elemental", "CLOWN PAIN ELEMENTAL", "Your first draw/pass each round draws two monsters instead of one, if available."],
	["rockstar_imp", "ROCKSTAR IMP", "+10 when your combo family differs from your previous scoring play this round. No bonus on your first play."],
	["uac_coffee", "UAC COFFEE", "Your first scoring play each round gains +10."],
	["blue_keycard", "BLUE KEYCARD", "+10 when you extend the combo on the table by playing exactly one card."],
	["explosive_barrel", "EXPLOSIVE BARREL", "While equipped, every third scoring play adds +20. Any valid combo counts; no barrel monster is needed. Charge carries across rounds. Charge 0/3 means three scoring plays until the next explosion; draw/pass does not charge it."],
	["demon_contract", "DEMON CONTRACT", "Pay 20 points each round while held, including the round acquired. Gain +6 per scoring play."],
	["glitch_disk", "GLITCH DISK", "Your first new matching-monster pair each round gains +20: the base-score difference to three of a kind. Does not add a card."],
	["ammo_box", "AMMO BOX", "+2 points for each card you add to a valid combo."],
	["gluttonous_joker", "GLUTTONOUS JOKER", "Playing 4 or more cards grows this Joker by +3 for future scoring plays, up to +24 for the match."],
	["valentine_joker", "VALENTINE JOKER", "+6 for each matching monster pair among the cards you play. Three identical monsters count as one pair, four as two. Romero does not form a pair."],
	["clown_doomguy", "CLOWN DOOMGUY", "+12 when you play exactly three cards with three different damage types."],
	["business_zombieman", "BUSINESS ZOMBIEMAN", "+2 per card left in your hand after playing, capped at +10 per scoring play."],
	["banjo_zombieman", "BANJO ZOMBIEMAN", "+10 when you play or extend a March."],
	["party_mastermind", "PARTY MASTERMIND", "+12 when you play four or more cards in one valid play."],
	["propeller_ss_soldier", "PROPELLER SS SOLDIER", "+8 when your combo family matches the most recent scoring play by either player this round. No bonus before the round's first scoring play."],
	["john_carmack", "JOHN CARMACK", "Optimization: +10 when a scoring play leaves your hand empty."],
	["commander_keen", "COMMANDER KEEN", "Comeback: +4 on a scoring play if your round score is lower than your opponent's before playing."],
	["bloody_smiley", "BLOODY SMILEY", "Keep smiling: +6 on a scoring play if you lead the round before playing."],
	["the_two_johns", "THE TWO JOHNS", "Romero & Carmack: +10 when you play exactly two different monsters in a valid play. The Romero wild card does not count as a monster."],
	["doom_guy_book", "DOOM GUY: THE BOOK", "New chapter: +6 the first time you score each combo family while holding this Joker each round."],
	["daikatana_romero", "DAIKATANA ROMERO", "Swordplay: +4 for each Melee monster you play. The Romero wild card does not count."],
	["jester_imp", "JESTER IMP", "Common: +4 when you start a new combination. No bonus for extensions."],
	["glitch_jester_imp", "GLITCH JESTER IMP", "+10 every second scoring play while held. Progress resets each round."],
	["screaming_doomguy", "SCREAMING DOOMGUY", "Last scream: +20 on your tenth-turn scoring play each round. Draw/pass gets no bonus."],
	["bj_blazkowicz", "B.J. BLAZKOWICZ", "Castle Breakout: +15 when you extend a combo started by your opponent with at least one Bullet or Melee monster."],
	["baseball_baron", "BASEBALL BARON", "Triple: +10 when you play exactly three cards in a valid combination."],
	["campfire_imps", "CAMPFIRE IMPS", "Rest by the fire: draw/pass to ready +10 for your next scoring play containing a Fire monster. Does not stack. Resets each round."],
	["doomguy_lisa", "DOOMGUY LISA", "Masterpiece: +15 when you play at least three different monsters with no duplicates or Romero wild card in a valid play."],
	["deathmatch", "DEATHMATCH", "Lead change: +12 when your play takes you from behind to ahead in round points, before Joker bonuses. Tying does not count."],
	["rift_walker", "RIFT WALKER", "Rule breaker: your Marches may skip exactly one rank. At least three different monsters. Normal March points; no extra Joker points."],
	["hell_recruiter", "HELL RECRUITER", "Rule breaker: Imp can replace one missing member of a named team that does not normally contain Imp. Normal team points; no extra Joker points."],
	["prism_core", "PRISM CORE", "Rule breaker: your Type Gatherings may include one monster of a different damage type. At least three different monsters. Normal Gathering points."],
 ["deadeye_doomguy", "DEADEYE DOOMGUY", "Rare Cowboy variant: +12 when you add exactly one Bullet monster to a combo on the table."],
 ["high_noon_doomguy", "HIGH NOON DOOMGUY", "Legendary Cowboy variant: +6 per Bullet monster played. Add another +12 when a play of at least three Bullet monsters empties your hand."],
 ["volatile_barrel", "VOLATILE BARREL", "Rare Barrel variant: every second scoring play containing Fire explodes for +18. Other plays do not charge it. Charge carries across rounds."],
 ["doomsday_barrel", "DOOMSDAY BARREL", "Legendary Barrel variant: every third extension explodes for +30, plus +10 if that extension contains Fire. Other plays do not charge it. Charge carries across rounds."],
 ["ringmaster_doomguy", "RINGMASTER DOOMGUY", "Rare Clown variant: +14 when exactly three cards of three damage types change your previous scoring combo family this round. No first-play bonus."],
 ["grand_carnival", "GRAND CARNIVAL", "Legendary Clown variant: +20 when you play at least four cards of four or more damage types. Add +10 if that play overtakes the opponent before Joker bonuses."],
	["tennis_pinky", "TENNIS PINKY", "Return Serve: +10 when you extend a combo originally started by your opponent with exactly one card. No bonus for starting a combo or extending your own."],
	["helmet_doomguy", "HELMET DOOMGUY", "Hold Your Ground: +8 when you start a new combo while behind in round points."],
	["joker_imp", "VETERAN JOKER IMP", "+5 points on every scoring play. When its ability activates on an extension: +3."],
	["joker_imp", "ELITE JOKER IMP", "+5 points on every scoring play. When its ability activates after you change combo type: +5."],
	["joker_imp", "EXALTED JOKER IMP", "+5 points on every scoring play. When its ability activates while behind in round points: +8."],
	["joker_imp", "ETERNAL JOKER IMP", "+5 points on every scoring play. When its ability activates with at least 3 new cards: +12."],
	["vampire_imp", "VETERAN VAMPIRE IMP", "After scoring, drain one played monster species' enhancement for your side this round. Gain +3 on future plays per drain, for this match. When its ability activates on an extension: +3."],
	["vampire_imp", "ELITE VAMPIRE IMP", "After scoring, drain one played monster species' enhancement for your side this round. Gain +3 on future plays per drain, for this match. When its ability activates after you change combo type: +5."],
	["vampire_imp", "EXALTED VAMPIRE IMP", "After scoring, drain one played monster species' enhancement for your side this round. Gain +3 on future plays per drain, for this match. When its ability activates while behind in round points: +8."],
	["vampire_imp", "ETERNAL VAMPIRE IMP", "After scoring, drain one played monster species' enhancement for your side this round. Gain +3 on future plays per drain, for this match. When its ability activates with at least 3 new cards: +12."],
	["cowboy_doomguy", "ELITE COWBOY DOOMGUY", "+4 per Bullet monster you play. When its ability activates after you change combo type: +5."],
	["cowboy_doomguy", "ETERNAL COWBOY DOOMGUY", "+4 per Bullet monster you play. When its ability activates with at least 3 new cards: +12."],
	["lucky_imp", "VETERAN LUCKY IMP", "25% chance of +20 on each scoring play. When its ability activates on an extension: +3."],
	["lucky_imp", "ELITE LUCKY IMP", "25% chance of +20 on each scoring play. When its ability activates after you change combo type: +5."],
	["lucky_imp", "EXALTED LUCKY IMP", "25% chance of +20 on each scoring play. When its ability activates while behind in round points: +8."],
	["lucky_imp", "ETERNAL LUCKY IMP", "25% chance of +20 on each scoring play. When its ability activates with at least 3 new cards: +12."],
	["greedy_pinky", "VETERAN GREEDY JOKER", "+6 extra per Gilded monster you play. When its ability activates on an extension: +3."],
	["greedy_pinky", "ELITE GREEDY JOKER", "+6 extra per Gilded monster you play. When its ability activates after you change combo type: +5."],
	["greedy_pinky", "EXALTED GREEDY JOKER", "+6 extra per Gilded monster you play. When its ability activates while behind in round points: +8."],
	["greedy_pinky", "ETERNAL GREEDY JOKER", "+6 extra per Gilded monster you play. When its ability activates with at least 3 new cards: +12."],
	["professor_revenant", "VETERAN PROFESSOR REVENANT", "Every third March you play upgrades your March bonus by +5 for this match. When its ability activates on an extension: +3."],
	["professor_revenant", "ELITE PROFESSOR REVENANT", "Every third March you play upgrades your March bonus by +5 for this match. When its ability activates after you change combo type: +5."],
	["professor_revenant", "EXALTED PROFESSOR REVENANT", "Every third March you play upgrades your March bonus by +5 for this match. When its ability activates while behind in round points: +8."],
	["professor_revenant", "ETERNAL PROFESSOR REVENANT", "Every third March you play upgrades your March bonus by +5 for this match. When its ability activates with at least 3 new cards: +12."],
	["magician_arch_vile", "VETERAN MAGICIAN ARCH-VILE", "+15 when you play John Romero in a valid combination. When its ability activates on an extension: +3."],
	["magician_arch_vile", "ELITE MAGICIAN ARCH-VILE", "+15 when you play John Romero in a valid combination. When its ability activates after you change combo type: +5."],
	["magician_arch_vile", "EXALTED MAGICIAN ARCH-VILE", "+15 when you play John Romero in a valid combination. When its ability activates while behind in round points: +8."],
	["magician_arch_vile", "ETERNAL MAGICIAN ARCH-VILE", "+15 when you play John Romero in a valid combination. When its ability activates with at least 3 new cards: +12."],
	["pirate_cacodemon", "VETERAN PIRATE CACODEMON", "Add cards to a combo on the table originally started by your opponent to earn +12 extra points. Automatic; no activation needed. When its ability activates on an extension: +3."],
	["pirate_cacodemon", "ELITE PIRATE CACODEMON", "Add cards to a combo on the table originally started by your opponent to earn +12 extra points. Automatic; no activation needed. When its ability activates after you change combo type: +5."],
	["pirate_cacodemon", "EXALTED PIRATE CACODEMON", "Add cards to a combo on the table originally started by your opponent to earn +12 extra points. Automatic; no activation needed. When its ability activates while behind in round points: +8."],
	["pirate_cacodemon", "ETERNAL PIRATE CACODEMON", "Add cards to a combo on the table originally started by your opponent to earn +12 extra points. Automatic; no activation needed. When its ability activates with at least 3 new cards: +12."],
	["sleepy_mancubus", "VETERAN SLEEPY MANCUBUS", "Each draw/pass stores +4, up to +16. Your next scoring play collects it. When its ability activates on an extension: +3."],
	["sleepy_mancubus", "ELITE SLEEPY MANCUBUS", "Each draw/pass stores +4, up to +16. Your next scoring play collects it. When its ability activates after you change combo type: +5."],
	["sleepy_mancubus", "EXALTED SLEEPY MANCUBUS", "Each draw/pass stores +4, up to +16. Your next scoring play collects it. When its ability activates while behind in round points: +8."],
	["sleepy_mancubus", "ETERNAL SLEEPY MANCUBUS", "Each draw/pass stores +4, up to +16. Your next scoring play collects it. When its ability activates with at least 3 new cards: +12."],
	["king_cyberdemon", "VETERAN KING CYBERDEMON", "+10 if a Cyberdemon remains in your hand after playing. Once per play. When its ability activates on an extension: +3."],
	["king_cyberdemon", "ELITE KING CYBERDEMON", "+10 if a Cyberdemon remains in your hand after playing. Once per play. When its ability activates after you change combo type: +5."],
	["king_cyberdemon", "EXALTED KING CYBERDEMON", "+10 if a Cyberdemon remains in your hand after playing. Once per play. When its ability activates while behind in round points: +8."],
	["king_cyberdemon", "ETERNAL KING CYBERDEMON", "+10 if a Cyberdemon remains in your hand after playing. Once per play. When its ability activates with at least 3 new cards: +12."],
	["disco_revenant", "VETERAN DISCO REVENANT", "Repeat the leftmost played card's enhancement: Gilded +4, or Charged +8 on extension. When its ability activates on an extension: +3."],
	["disco_revenant", "ELITE DISCO REVENANT", "Repeat the leftmost played card's enhancement: Gilded +4, or Charged +8 on extension. When its ability activates after you change combo type: +5."],
	["disco_revenant", "EXALTED DISCO REVENANT", "Repeat the leftmost played card's enhancement: Gilded +4, or Charged +8 on extension. When its ability activates while behind in round points: +8."],
	["disco_revenant", "ETERNAL DISCO REVENANT", "Repeat the leftmost played card's enhancement: Gilded +4, or Charged +8 on extension. When its ability activates with at least 3 new cards: +12."],
	["chef_mancubus", "VETERAN CHEF MANCUBUS", "Each Fire monster played adds +1 to future Fire-play bonuses, up to +20, for this match. When its ability activates on an extension: +3."],
	["chef_mancubus", "ELITE CHEF MANCUBUS", "Each Fire monster played adds +1 to future Fire-play bonuses, up to +20, for this match. When its ability activates after you change combo type: +5."],
	["chef_mancubus", "EXALTED CHEF MANCUBUS", "Each Fire monster played adds +1 to future Fire-play bonuses, up to +20, for this match. When its ability activates while behind in round points: +8."],
	["chef_mancubus", "ETERNAL CHEF MANCUBUS", "Each Fire monster played adds +1 to future Fire-play bonuses, up to +20, for this match. When its ability activates with at least 3 new cards: +12."],
	["mime_spectre", "VETERAN MIME DOOMGUY", "Copy the previous slot's fixed scoring bonus. Cannot copy Mime, chance, stored growth, multipliers or extra actions. Swap your slots by clicking them. When its ability activates on an extension: +3."],
	["mime_spectre", "ELITE MIME DOOMGUY", "Copy the previous slot's fixed scoring bonus. Cannot copy Mime, chance, stored growth, multipliers or extra actions. Swap your slots by clicking them. When its ability activates after you change combo type: +5."],
	["mime_spectre", "EXALTED MIME DOOMGUY", "Copy the previous slot's fixed scoring bonus. Cannot copy Mime, chance, stored growth, multipliers or extra actions. Swap your slots by clicking them. When its ability activates while behind in round points: +8."],
	["mime_spectre", "ETERNAL MIME DOOMGUY", "Copy the previous slot's fixed scoring bonus. Cannot copy Mime, chance, stored growth, multipliers or extra actions. Swap your slots by clicking them. When its ability activates with at least 3 new cards: +12."],
	["boxer_pinky", "VETERAN REVENANT BOXER", "+12 when you add exactly two cards in a valid play. When its ability activates on an extension: +3."],
	["boxer_pinky", "ELITE REVENANT BOXER", "+12 when you add exactly two cards in a valid play. When its ability activates after you change combo type: +5."],
	["boxer_pinky", "EXALTED REVENANT BOXER", "+12 when you add exactly two cards in a valid play. When its ability activates while behind in round points: +8."],
	["boxer_pinky", "ETERNAL REVENANT BOXER", "+12 when you add exactly two cards in a valid play. When its ability activates with exactly 2 new cards: +12."],
	["general_baron", "VETERAN GENERAL BARON", "+15 when you play or extend a named team. When its ability activates on an extension: +3."],
	["general_baron", "ELITE GENERAL BARON", "+15 when you play or extend a named team. When its ability activates after you change combo type: +5."],
	["general_baron", "EXALTED GENERAL BARON", "+15 when you play or extend a named team. When its ability activates while behind in round points: +8."],
	["general_baron", "ETERNAL GENERAL BARON", "+15 when you play or extend a named team. When its ability activates with at least 3 new cards: +12."],
	["astronaut_lost_soul", "VETERAN ASTRONAUT LOST SOUL", "+20 when you play or extend Apocalypse. When its ability activates on an extension: +3."],
	["astronaut_lost_soul", "ELITE ASTRONAUT LOST SOUL", "+20 when you play or extend Apocalypse. When its ability activates after you change combo type: +5."],
	["astronaut_lost_soul", "EXALTED ASTRONAUT LOST SOUL", "+20 when you play or extend Apocalypse. When its ability activates while behind in round points: +8."],
	["astronaut_lost_soul", "ETERNAL ASTRONAUT LOST SOUL", "+20 when you play or extend Apocalypse. When its ability activates with at least 3 new cards: +12."],
	["electric_arachnotron", "VETERAN ELECTRIC ARACHNOTRON", "+5 per Charged monster played, including when starting a combination. When its ability activates on an extension: +3."],
	["electric_arachnotron", "ELITE ELECTRIC ARACHNOTRON", "+5 per Charged monster played, including when starting a combination. When its ability activates after you change combo type: +5."],
	["electric_arachnotron", "EXALTED ELECTRIC ARACHNOTRON", "+5 per Charged monster played, including when starting a combination. When its ability activates while behind in round points: +8."],
	["electric_arachnotron", "ETERNAL ELECTRIC ARACHNOTRON", "+5 per Charged monster played, including when starting a combination. When its ability activates with at least 3 new cards: +12."],
	["berserker_doomguy", "VETERAN BERSERKER DOOMGUY", "Multiply your tenth-turn scoring play by 1.5, rounding down. Draw/pass gets no bonus. When its ability activates on an extension: +3."],
	["berserker_doomguy", "ELITE BERSERKER DOOMGUY", "Multiply your tenth-turn scoring play by 1.5, rounding down. Draw/pass gets no bonus. When its ability activates after you change combo type: +5."],
	["berserker_doomguy", "EXALTED BERSERKER DOOMGUY", "Multiply your tenth-turn scoring play by 1.5, rounding down. Draw/pass gets no bonus. When its ability activates while behind in round points: +8."],
	["berserker_doomguy", "ETERNAL BERSERKER DOOMGUY", "Multiply your tenth-turn scoring play by 1.5, rounding down. Draw/pass gets no bonus. When its ability activates with at least 3 new cards: +12."],
	["clown_pain_elemental", "VETERAN CLOWN PAIN ELEMENTAL", "Your first draw/pass each round draws two monsters instead of one, if available. When its ability activates on an extension: +3."],
	["clown_pain_elemental", "ELITE CLOWN PAIN ELEMENTAL", "Your first draw/pass each round draws two monsters instead of one, if available. When its ability activates after you change combo type: +5."],
	["clown_pain_elemental", "EXALTED CLOWN PAIN ELEMENTAL", "Your first draw/pass each round draws two monsters instead of one, if available. When its ability activates while behind in round points: +8."],
	["clown_pain_elemental", "ETERNAL CLOWN PAIN ELEMENTAL", "Your first draw/pass each round draws two monsters instead of one, if available. When its ability activates with at least 3 new cards: +12."],
	["rockstar_imp", "VETERAN ROCKSTAR IMP", "+10 when your combo family differs from your previous scoring play this round. No bonus on your first play. When its ability activates on an extension: +3."],
	["rockstar_imp", "ELITE ROCKSTAR IMP", "+10 when your combo family differs from your previous scoring play this round. No bonus on your first play. When its ability activates after you change combo type: +5."],
	["rockstar_imp", "EXALTED ROCKSTAR IMP", "+10 when your combo family differs from your previous scoring play this round. No bonus on your first play. When its ability activates while behind in round points: +8."],
	["rockstar_imp", "ETERNAL ROCKSTAR IMP", "+10 when your combo family differs from your previous scoring play this round. No bonus on your first play. When its ability activates with at least 3 new cards: +12."],
	["uac_coffee", "VETERAN UAC COFFEE", "Your first scoring play each round gains +10. When its ability activates on an extension: +3."],
	["uac_coffee", "ELITE UAC COFFEE", "Your first scoring play each round gains +10. When its ability activates while behind in round points: +5."],
	["uac_coffee", "EXALTED UAC COFFEE", "Your first scoring play each round gains +10. When its ability activates while behind in round points: +8."],
	["uac_coffee", "ETERNAL UAC COFFEE", "Your first scoring play each round gains +10. When its ability activates with at least 3 new cards: +12."],
	["blue_keycard", "VETERAN BLUE KEYCARD", "+10 when you extend the combo on the table by playing exactly one card. When its ability activates on an extension: +3."],
	["blue_keycard", "ELITE BLUE KEYCARD", "+10 when you extend the combo on the table by playing exactly one card. When its ability activates after you change combo type: +5."],
	["blue_keycard", "EXALTED BLUE KEYCARD", "+10 when you extend the combo on the table by playing exactly one card. When its ability activates while behind in round points: +8."],
	["blue_keycard", "ETERNAL BLUE KEYCARD", "+10 when you extend the combo on the table by playing exactly one card. When its ability activates with exactly 1 new card: +12."],
	["explosive_barrel", "ELITE EXPLOSIVE BARREL", "While equipped, every third scoring play adds +20. Any valid combo counts; no barrel monster is needed. Charge carries across rounds. Charge 0/3 means three scoring plays until the next explosion; draw/pass does not charge it. When its ability activates after you change combo type: +5."],
	["explosive_barrel", "ETERNAL EXPLOSIVE BARREL", "While equipped, every third scoring play adds +20. Any valid combo counts; no barrel monster is needed. Charge carries across rounds. Charge 0/3 means three scoring plays until the next explosion; draw/pass does not charge it. When its ability activates with at least 3 new cards: +12."],
	["demon_contract", "VETERAN DEMON CONTRACT", "Pay 20 points each round while held, including the round acquired. Gain +6 per scoring play. When its ability activates on an extension: +3."],
	["demon_contract", "ELITE DEMON CONTRACT", "Pay 20 points each round while held, including the round acquired. Gain +6 per scoring play. When its ability activates after you change combo type: +5."],
	["demon_contract", "EXALTED DEMON CONTRACT", "Pay 20 points each round while held, including the round acquired. Gain +6 per scoring play. When its ability activates while behind in round points: +8."],
	["demon_contract", "ETERNAL DEMON CONTRACT", "Pay 20 points each round while held, including the round acquired. Gain +6 per scoring play. When its ability activates with at least 3 new cards: +12."],
	["glitch_disk", "VETERAN GLITCH DISK", "Your first new matching-monster pair each round gains +20: the base-score difference to three of a kind. Does not add a card. When its ability activates on a new combo: +3."],
	["glitch_disk", "ELITE GLITCH DISK", "Your first new matching-monster pair each round gains +20: the base-score difference to three of a kind. Does not add a card. When its ability activates after you change combo type: +5."],
	["glitch_disk", "EXALTED GLITCH DISK", "Your first new matching-monster pair each round gains +20: the base-score difference to three of a kind. Does not add a card. When its ability activates while behind in round points: +8."],
	["glitch_disk", "ETERNAL GLITCH DISK", "Your first new matching-monster pair each round gains +20: the base-score difference to three of a kind. Does not add a card. When its ability activates with exactly 2 new cards: +12."],
	["ammo_box", "VETERAN AMMO BOX", "+2 points for each card you add to a valid combo. When its ability activates on an extension: +3."],
	["ammo_box", "ELITE AMMO BOX", "+2 points for each card you add to a valid combo. When its ability activates after you change combo type: +5."],
	["ammo_box", "EXALTED AMMO BOX", "+2 points for each card you add to a valid combo. When its ability activates while behind in round points: +8."],
	["ammo_box", "ETERNAL AMMO BOX", "+2 points for each card you add to a valid combo. When its ability activates with at least 3 new cards: +12."],
	["gluttonous_joker", "VETERAN GLUTTONOUS JOKER", "Playing 4 or more cards grows this Joker by +3 for future scoring plays, up to +24 for the match. When its ability activates on an extension: +3."],
	["gluttonous_joker", "ELITE GLUTTONOUS JOKER", "Playing 4 or more cards grows this Joker by +3 for future scoring plays, up to +24 for the match. When its ability activates after you change combo type: +5."],
	["gluttonous_joker", "EXALTED GLUTTONOUS JOKER", "Playing 4 or more cards grows this Joker by +3 for future scoring plays, up to +24 for the match. When its ability activates while behind in round points: +8."],
	["gluttonous_joker", "ETERNAL GLUTTONOUS JOKER", "Playing 4 or more cards grows this Joker by +3 for future scoring plays, up to +24 for the match. When its ability activates with at least 3 new cards: +12."],
	["valentine_joker", "VETERAN VALENTINE JOKER", "+6 for each matching monster pair among the cards you play. Three identical monsters count as one pair, four as two. Romero does not form a pair. When its ability activates on an extension: +3."],
	["valentine_joker", "ELITE VALENTINE JOKER", "+6 for each matching monster pair among the cards you play. Three identical monsters count as one pair, four as two. Romero does not form a pair. When its ability activates after you change combo type: +5."],
	["valentine_joker", "EXALTED VALENTINE JOKER", "+6 for each matching monster pair among the cards you play. Three identical monsters count as one pair, four as two. Romero does not form a pair. When its ability activates while behind in round points: +8."],
	["valentine_joker", "ETERNAL VALENTINE JOKER", "+6 for each matching monster pair among the cards you play. Three identical monsters count as one pair, four as two. Romero does not form a pair. When its ability activates with at least 3 new cards: +12."],
	["clown_doomguy", "ELITE CLOWN DOOMGUY", "+12 when you play exactly three cards with three different damage types. When its ability activates after you change combo type: +5."],
	["clown_doomguy", "ETERNAL CLOWN DOOMGUY", "+12 when you play exactly three cards with three different damage types. When its ability activates with at least 3 new cards: +12."],
	["business_zombieman", "VETERAN BUSINESS ZOMBIEMAN", "+2 per card left in your hand after playing, capped at +10 per scoring play. When its ability activates on an extension: +3."],
	["business_zombieman", "ELITE BUSINESS ZOMBIEMAN", "+2 per card left in your hand after playing, capped at +10 per scoring play. When its ability activates after you change combo type: +5."],
	["business_zombieman", "EXALTED BUSINESS ZOMBIEMAN", "+2 per card left in your hand after playing, capped at +10 per scoring play. When its ability activates while behind in round points: +8."],
	["business_zombieman", "ETERNAL BUSINESS ZOMBIEMAN", "+2 per card left in your hand after playing, capped at +10 per scoring play. When its ability activates with at least 3 new cards: +12."],
	["banjo_zombieman", "VETERAN BANJO ZOMBIEMAN", "+10 when you play or extend a March. When its ability activates on an extension: +3."],
	["banjo_zombieman", "ELITE BANJO ZOMBIEMAN", "+10 when you play or extend a March. When its ability activates after you change combo type: +5."],
	["banjo_zombieman", "EXALTED BANJO ZOMBIEMAN", "+10 when you play or extend a March. When its ability activates while behind in round points: +8."],
	["banjo_zombieman", "ETERNAL BANJO ZOMBIEMAN", "+10 when you play or extend a March. When its ability activates with at least 3 new cards: +12."],
	["party_mastermind", "VETERAN PARTY MASTERMIND", "+12 when you play four or more cards in one valid play. When its ability activates on an extension: +3."],
	["party_mastermind", "ELITE PARTY MASTERMIND", "+12 when you play four or more cards in one valid play. When its ability activates after you change combo type: +5."],
	["party_mastermind", "EXALTED PARTY MASTERMIND", "+12 when you play four or more cards in one valid play. When its ability activates while behind in round points: +8."],
	["party_mastermind", "ETERNAL PARTY MASTERMIND", "+12 when you play four or more cards in one valid play. When its ability activates with at least 3 new cards: +12."],
	["propeller_ss_soldier", "VETERAN PROPELLER SS SOLDIER", "+8 when your combo family matches the most recent scoring play by either player this round. No bonus before the round's first scoring play. When its ability activates on an extension: +3."],
	["propeller_ss_soldier", "ELITE PROPELLER SS SOLDIER", "+8 when your combo family matches the most recent scoring play by either player this round. No bonus before the round's first scoring play. When its ability activates after you change combo type: +5."],
	["propeller_ss_soldier", "EXALTED PROPELLER SS SOLDIER", "+8 when your combo family matches the most recent scoring play by either player this round. No bonus before the round's first scoring play. When its ability activates while behind in round points: +8."],
	["propeller_ss_soldier", "ETERNAL PROPELLER SS SOLDIER", "+8 when your combo family matches the most recent scoring play by either player this round. No bonus before the round's first scoring play. When its ability activates with at least 3 new cards: +12."],
	["john_carmack", "VETERAN JOHN CARMACK", "Optimization: +10 when a scoring play leaves your hand empty. When its ability activates on an extension: +3."],
	["john_carmack", "ELITE JOHN CARMACK", "Optimization: +10 when a scoring play leaves your hand empty. When its ability activates after you change combo type: +5."],
	["john_carmack", "EXALTED JOHN CARMACK", "Optimization: +10 when a scoring play leaves your hand empty. When its ability activates while behind in round points: +8."],
	["john_carmack", "ETERNAL JOHN CARMACK", "Optimization: +10 when a scoring play leaves your hand empty. When its ability activates with at least 3 new cards: +12."],
	["commander_keen", "VETERAN COMMANDER KEEN", "Comeback: +4 on a scoring play if your round score is lower than your opponent's before playing. When its ability activates on an extension: +3."],
	["commander_keen", "ELITE COMMANDER KEEN", "Comeback: +4 on a scoring play if your round score is lower than your opponent's before playing. When its ability activates after you change combo type: +5."],
	["commander_keen", "EXALTED COMMANDER KEEN", "Comeback: +4 on a scoring play if your round score is lower than your opponent's before playing. When its ability activates while behind in round points: +8."],
	["commander_keen", "ETERNAL COMMANDER KEEN", "Comeback: +4 on a scoring play if your round score is lower than your opponent's before playing. When its ability activates with at least 3 new cards: +12."],
	["bloody_smiley", "VETERAN BLOODY SMILEY", "Keep smiling: +6 on a scoring play if you lead the round before playing. When its ability activates on an extension: +3."],
	["bloody_smiley", "ELITE BLOODY SMILEY", "Keep smiling: +6 on a scoring play if you lead the round before playing. When its ability activates after you change combo type: +5."],
	["bloody_smiley", "EXALTED BLOODY SMILEY", "Keep smiling: +6 on a scoring play if you lead the round before playing. When its ability activates while behind in round points: +8."],
	["bloody_smiley", "ETERNAL BLOODY SMILEY", "Keep smiling: +6 on a scoring play if you lead the round before playing. When its ability activates with at least 3 new cards: +12."],
	["the_two_johns", "VETERAN THE TWO JOHNS", "Romero & Carmack: +10 when you play exactly two different monsters in a valid play. The Romero wild card does not count as a monster. When its ability activates on an extension: +3."],
	["the_two_johns", "ELITE THE TWO JOHNS", "Romero & Carmack: +10 when you play exactly two different monsters in a valid play. The Romero wild card does not count as a monster. When its ability activates after you change combo type: +5."],
	["the_two_johns", "EXALTED THE TWO JOHNS", "Romero & Carmack: +10 when you play exactly two different monsters in a valid play. The Romero wild card does not count as a monster. When its ability activates while behind in round points: +8."],
	["the_two_johns", "ETERNAL THE TWO JOHNS", "Romero & Carmack: +10 when you play exactly two different monsters in a valid play. The Romero wild card does not count as a monster. When its ability activates with exactly 2 new cards: +12."],
	["doom_guy_book", "VETERAN DOOM GUY: THE BOOK", "New chapter: +6 the first time you score each combo family while holding this Joker each round. When its ability activates on an extension: +3."],
	["doom_guy_book", "ELITE DOOM GUY: THE BOOK", "New chapter: +6 the first time you score each combo family while holding this Joker each round. When its ability activates after you change combo type: +5."],
	["doom_guy_book", "EXALTED DOOM GUY: THE BOOK", "New chapter: +6 the first time you score each combo family while holding this Joker each round. When its ability activates while behind in round points: +8."],
	["doom_guy_book", "ETERNAL DOOM GUY: THE BOOK", "New chapter: +6 the first time you score each combo family while holding this Joker each round. When its ability activates with at least 3 new cards: +12."],
	["daikatana_romero", "VETERAN DAIKATANA ROMERO", "Swordplay: +4 for each Melee monster you play. The Romero wild card does not count. When its ability activates on an extension: +3."],
	["daikatana_romero", "ELITE DAIKATANA ROMERO", "Swordplay: +4 for each Melee monster you play. The Romero wild card does not count. When its ability activates after you change combo type: +5."],
	["daikatana_romero", "EXALTED DAIKATANA ROMERO", "Swordplay: +4 for each Melee monster you play. The Romero wild card does not count. When its ability activates while behind in round points: +8."],
	["daikatana_romero", "ETERNAL DAIKATANA ROMERO", "Swordplay: +4 for each Melee monster you play. The Romero wild card does not count. When its ability activates with at least 3 new cards: +12."],
	["jester_imp", "VETERAN JESTER IMP", "Common: +4 when you start a new combination. No bonus for extensions. When its ability activates on a new combo: +3."],
	["jester_imp", "ELITE JESTER IMP", "Common: +4 when you start a new combination. No bonus for extensions. When its ability activates after you change combo type: +5."],
	["jester_imp", "EXALTED JESTER IMP", "Common: +4 when you start a new combination. No bonus for extensions. When its ability activates while behind in round points: +8."],
	["jester_imp", "ETERNAL JESTER IMP", "Common: +4 when you start a new combination. No bonus for extensions. When its ability activates with at least 3 new cards: +12."],
	["glitch_jester_imp", "VETERAN GLITCH JESTER IMP", "+10 every second scoring play while held. Progress resets each round. When its ability activates on an extension: +3."],
	["glitch_jester_imp", "ELITE GLITCH JESTER IMP", "+10 every second scoring play while held. Progress resets each round. When its ability activates after you change combo type: +5."],
	["glitch_jester_imp", "EXALTED GLITCH JESTER IMP", "+10 every second scoring play while held. Progress resets each round. When its ability activates while behind in round points: +8."],
	["glitch_jester_imp", "ETERNAL GLITCH JESTER IMP", "+10 every second scoring play while held. Progress resets each round. When its ability activates with at least 3 new cards: +12."],
	["screaming_doomguy", "VETERAN SCREAMING DOOMGUY", "Last scream: +20 on your tenth-turn scoring play each round. Draw/pass gets no bonus. When its ability activates on an extension: +3."],
	["screaming_doomguy", "ELITE SCREAMING DOOMGUY", "Last scream: +20 on your tenth-turn scoring play each round. Draw/pass gets no bonus. When its ability activates after you change combo type: +5."],
	["screaming_doomguy", "EXALTED SCREAMING DOOMGUY", "Last scream: +20 on your tenth-turn scoring play each round. Draw/pass gets no bonus. When its ability activates while behind in round points: +8."],
	["screaming_doomguy", "ETERNAL SCREAMING DOOMGUY", "Last scream: +20 on your tenth-turn scoring play each round. Draw/pass gets no bonus. When its ability activates with at least 3 new cards: +12."],
	["bj_blazkowicz", "VETERAN B.J. BLAZKOWICZ", "Castle Breakout: +15 when you extend a combo started by your opponent with at least one Bullet or Melee monster. When its ability activates on an extension: +3."],
	["bj_blazkowicz", "ELITE B.J. BLAZKOWICZ", "Castle Breakout: +15 when you extend a combo started by your opponent with at least one Bullet or Melee monster. When its ability activates after you change combo type: +5."],
	["bj_blazkowicz", "EXALTED B.J. BLAZKOWICZ", "Castle Breakout: +15 when you extend a combo started by your opponent with at least one Bullet or Melee monster. When its ability activates while behind in round points: +8."],
	["bj_blazkowicz", "ETERNAL B.J. BLAZKOWICZ", "Castle Breakout: +15 when you extend a combo started by your opponent with at least one Bullet or Melee monster. When its ability activates with at least 3 new cards: +12."],
	["baseball_baron", "VETERAN BASEBALL BARON", "Triple: +10 when you play exactly three cards in a valid combination. When its ability activates on an extension: +3."],
	["baseball_baron", "ELITE BASEBALL BARON", "Triple: +10 when you play exactly three cards in a valid combination. When its ability activates after you change combo type: +5."],
	["baseball_baron", "EXALTED BASEBALL BARON", "Triple: +10 when you play exactly three cards in a valid combination. When its ability activates while behind in round points: +8."],
	["baseball_baron", "ETERNAL BASEBALL BARON", "Triple: +10 when you play exactly three cards in a valid combination. When its ability activates with at least 3 new cards: +12."],
	["campfire_imps", "VETERAN CAMPFIRE IMPS", "Rest by the fire: draw/pass to ready +10 for your next scoring play containing a Fire monster. Does not stack. Resets each round. When its ability activates on an extension: +3."],
	["campfire_imps", "ELITE CAMPFIRE IMPS", "Rest by the fire: draw/pass to ready +10 for your next scoring play containing a Fire monster. Does not stack. Resets each round. When its ability activates after you change combo type: +5."],
	["campfire_imps", "EXALTED CAMPFIRE IMPS", "Rest by the fire: draw/pass to ready +10 for your next scoring play containing a Fire monster. Does not stack. Resets each round. When its ability activates while behind in round points: +8."],
	["campfire_imps", "ETERNAL CAMPFIRE IMPS", "Rest by the fire: draw/pass to ready +10 for your next scoring play containing a Fire monster. Does not stack. Resets each round. When its ability activates with at least 3 new cards: +12."],
	["doomguy_lisa", "VETERAN DOOMGUY LISA", "Masterpiece: +15 when you play at least three different monsters with no duplicates or Romero wild card in a valid play. When its ability activates on an extension: +3."],
	["doomguy_lisa", "ELITE DOOMGUY LISA", "Masterpiece: +15 when you play at least three different monsters with no duplicates or Romero wild card in a valid play. When its ability activates after you change combo type: +5."],
	["doomguy_lisa", "EXALTED DOOMGUY LISA", "Masterpiece: +15 when you play at least three different monsters with no duplicates or Romero wild card in a valid play. When its ability activates while behind in round points: +8."],
	["doomguy_lisa", "ETERNAL DOOMGUY LISA", "Masterpiece: +15 when you play at least three different monsters with no duplicates or Romero wild card in a valid play. When its ability activates with at least 3 new cards: +12."],
	["deathmatch", "VETERAN DEATHMATCH", "Lead change: +12 when your play takes you from behind to ahead in round points, before Joker bonuses. Tying does not count. When its ability activates on an extension: +3."],
	["deathmatch", "ELITE DEATHMATCH", "Lead change: +12 when your play takes you from behind to ahead in round points, before Joker bonuses. Tying does not count. When its ability activates after you change combo type: +5."],
	["deathmatch", "EXALTED DEATHMATCH", "Lead change: +12 when your play takes you from behind to ahead in round points, before Joker bonuses. Tying does not count. When its ability activates while behind in round points: +8."],
	["deathmatch", "ETERNAL DEATHMATCH", "Lead change: +12 when your play takes you from behind to ahead in round points, before Joker bonuses. Tying does not count. When its ability activates with at least 3 new cards: +12."],
	["rift_walker", "VETERAN RIFT WALKER", "Rule breaker: your Marches may skip exactly one rank. At least three different monsters. Normal March points; no extra Joker points. When its ability activates on an extension: +3."],
	["rift_walker", "ELITE RIFT WALKER", "Rule breaker: your Marches may skip exactly one rank. At least three different monsters. Normal March points; no extra Joker points. When its ability activates after you change combo type: +5."],
	["rift_walker", "EXALTED RIFT WALKER", "Rule breaker: your Marches may skip exactly one rank. At least three different monsters. Normal March points; no extra Joker points. When its ability activates while behind in round points: +8."],
	["rift_walker", "ETERNAL RIFT WALKER", "Rule breaker: your Marches may skip exactly one rank. At least three different monsters. Normal March points; no extra Joker points. When its ability activates with at least 3 new cards: +12."],
	["hell_recruiter", "VETERAN HELL RECRUITER", "Rule breaker: Imp can replace one missing member of a named team that does not normally contain Imp. Normal team points; no extra Joker points. When its ability activates on an extension: +3."],
	["hell_recruiter", "ELITE HELL RECRUITER", "Rule breaker: Imp can replace one missing member of a named team that does not normally contain Imp. Normal team points; no extra Joker points. When its ability activates after you change combo type: +5."],
	["hell_recruiter", "EXALTED HELL RECRUITER", "Rule breaker: Imp can replace one missing member of a named team that does not normally contain Imp. Normal team points; no extra Joker points. When its ability activates while behind in round points: +8."],
	["hell_recruiter", "ETERNAL HELL RECRUITER", "Rule breaker: Imp can replace one missing member of a named team that does not normally contain Imp. Normal team points; no extra Joker points. When its ability activates with at least 3 new cards: +12."],
	["prism_core", "VETERAN PRISM CORE", "Rule breaker: your Type Gatherings may include one monster of a different damage type. At least three different monsters. Normal Gathering points. When its ability activates on an extension: +3."],
	["prism_core", "ELITE PRISM CORE", "Rule breaker: your Type Gatherings may include one monster of a different damage type. At least three different monsters. Normal Gathering points. When its ability activates after you change combo type: +5."],
	["prism_core", "EXALTED PRISM CORE", "Rule breaker: your Type Gatherings may include one monster of a different damage type. At least three different monsters. Normal Gathering points. When its ability activates while behind in round points: +8."],
	["prism_core", "ETERNAL PRISM CORE", "Rule breaker: your Type Gatherings may include one monster of a different damage type. At least three different monsters. Normal Gathering points. When its ability activates with at least 3 new cards: +12."],
	["tennis_pinky", "VETERAN TENNIS PINKY", "Return Serve: +10 when you extend a combo originally started by your opponent with exactly one card. No bonus for starting a combo or extending your own. When its ability activates on an extension: +3."],
	["tennis_pinky", "ELITE TENNIS PINKY", "Return Serve: +10 when you extend a combo originally started by your opponent with exactly one card. No bonus for starting a combo or extending your own. When its ability activates after you change combo type: +5."],
	["tennis_pinky", "EXALTED TENNIS PINKY", "Return Serve: +10 when you extend a combo originally started by your opponent with exactly one card. No bonus for starting a combo or extending your own. When its ability activates while behind in round points: +8."],
	["tennis_pinky", "ETERNAL TENNIS PINKY", "Return Serve: +10 when you extend a combo originally started by your opponent with exactly one card. No bonus for starting a combo or extending your own. When its ability activates with exactly 1 new card: +12."],
	["helmet_doomguy", "VETERAN HELMET DOOMGUY", "Hold Your Ground: +8 when you start a new combo while behind in round points. When its ability activates on a new combo: +3."],
	["helmet_doomguy", "ELITE HELMET DOOMGUY", "Hold Your Ground: +8 when you start a new combo while behind in round points. When its ability activates after you change combo type: +5."],
	["helmet_doomguy", "EXALTED HELMET DOOMGUY", "Hold Your Ground: +8 when you start a new combo while behind in round points. When its ability activates while behind in round points: +8."],
	["helmet_doomguy", "ETERNAL HELMET DOOMGUY", "Hold Your Ground: +8 when you start a new combo while behind in round points. When its ability activates with at least 3 new cards: +12."],
	["wolf_jester", "WOLF JESTER", "Crossfire: +14 when you play at least 3 Bullet monsters in one valid play."],
	["wolf_jester", "VETERAN WOLF JESTER", "Crossfire: +14 when you play at least 3 Bullet monsters in one valid play. When its ability activates on an extension: +3."],
	["wolf_jester", "ELITE WOLF JESTER", "Crossfire: +14 when you play at least 3 Bullet monsters in one valid play. When its ability activates after you change combo type: +5."],
	["wolf_jester", "EXALTED WOLF JESTER", "Crossfire: +14 when you play at least 3 Bullet monsters in one valid play. When its ability activates while behind in round points: +8."],
	["wolf_jester", "ETERNAL WOLF JESTER", "Crossfire: +14 when you play at least 3 Bullet monsters in one valid play. When its ability activates with at least 3 new cards: +12."],
	["vr_carmack", "VR CARMACK", "New Perspective: +12 when you change combo type from your previous scoring play this round and play at least one Energy monster. No bonus on your first scoring play."],
	["vr_carmack", "VETERAN VR CARMACK", "New Perspective: +12 when you change combo type from your previous scoring play this round and play at least one Energy monster. No bonus on your first scoring play. When its ability activates on an extension: +3."],
	["vr_carmack", "ELITE VR CARMACK", "New Perspective: +12 when you change combo type from your previous scoring play this round and play at least one Energy monster. No bonus on your first scoring play. When its ability activates after you change combo type: +5."],
	["vr_carmack", "EXALTED VR CARMACK", "New Perspective: +12 when you change combo type from your previous scoring play this round and play at least one Energy monster. No bonus on your first scoring play. When its ability activates while behind in round points: +8."],
	["vr_carmack", "ETERNAL VR CARMACK", "New Perspective: +12 when you change combo type from your previous scoring play this round and play at least one Energy monster. No bonus on your first scoring play. When its ability activates with at least 3 new cards: +12."],
	["the_heretic", "THE HERETIC", "Arcane Fire: +12 when the cards you add in one valid play include both Fire and Energy monsters. Cards already on the table do not count."],
	["the_heretic", "VETERAN THE HERETIC", "Arcane Fire: +12 when the cards you add in one valid play include both Fire and Energy monsters. Cards already on the table do not count. When its ability activates on an extension: +3."],
	["the_heretic", "ELITE THE HERETIC", "Arcane Fire: +12 when the cards you add in one valid play include both Fire and Energy monsters. Cards already on the table do not count. When its ability activates after you change combo type: +5."],
	["the_heretic", "EXALTED THE HERETIC", "Arcane Fire: +12 when the cards you add in one valid play include both Fire and Energy monsters. Cards already on the table do not count. When its ability activates while behind in round points: +8."],
	["the_heretic", "ETERNAL THE HERETIC", "Arcane Fire: +12 when the cards you add in one valid play include both Fire and Energy monsters. Cards already on the table do not count. When its ability activates with at least 3 new cards: +12."],
	["farmer_caco", "FARMER CACO", "Harvest: +10 when you add at least two monsters with a value of 2 or less in one valid play. Cards already on the table do not count."],
	["farmer_caco", "VETERAN FARMER CACO", "Harvest: +10 when you add at least two monsters with a value of 2 or less in one valid play. Cards already on the table do not count. When its ability activates on an extension: +3."],
	["farmer_caco", "ELITE FARMER CACO", "Harvest: +10 when you add at least two monsters with a value of 2 or less in one valid play. Cards already on the table do not count. When its ability activates after you change combo type: +5."],
	["farmer_caco", "EXALTED FARMER CACO", "Harvest: +10 when you add at least two monsters with a value of 2 or less in one valid play. Cards already on the table do not count. When its ability activates while behind in round points: +8."],
	["farmer_caco", "ETERNAL FARMER CACO", "Harvest: +10 when you add at least two monsters with a value of 2 or less in one valid play. Cards already on the table do not count. When its ability activates with at least 3 new cards: +12."],
	["marine_daisy", "MARINE DAISY", "Rule breaker: Bunny Hop. Play 3+ monsters whose values rise by exactly 2 each step, such as 1, 3, 5. Scores 20 for three cards, then +20 per extra card. Uses March upgrades."],
	["marine_daisy", "VETERAN MARINE DAISY", "Rule breaker: Bunny Hop. Play 3+ monsters whose values rise by exactly 2 each step, such as 1, 3, 5. Scores 20 for three cards, then +20 per extra card. Uses March upgrades. When its ability activates on an extension: +3."],
	["marine_daisy", "ELITE MARINE DAISY", "Rule breaker: Bunny Hop. Play 3+ monsters whose values rise by exactly 2 each step, such as 1, 3, 5. Scores 20 for three cards, then +20 per extra card. Uses March upgrades. When its ability activates after you change combo type: +5."],
	["marine_daisy", "EXALTED MARINE DAISY", "Rule breaker: Bunny Hop. Play 3+ monsters whose values rise by exactly 2 each step, such as 1, 3, 5. Scores 20 for three cards, then +20 per extra card. Uses March upgrades. When its ability activates while behind in round points: +8."],
	["marine_daisy", "ETERNAL MARINE DAISY", "Rule breaker: Bunny Hop. Play 3+ monsters whose values rise by exactly 2 each step, such as 1, 3, 5. Scores 20 for three cards, then +20 per extra card. Uses March upgrades. When its ability activates with at least 3 new cards: +12."],
	["baby_doomguy", "BABY DOOMGUY", "Baby Steps: +12 when you play at least two new monsters, all with printed values of 1 or 2. Romero does not count."],
	["baby_doomguy", "VETERAN BABY DOOMGUY", "Baby Steps: +12 when you play at least two new monsters, all with printed values of 1 or 2. Romero does not count. When its ability activates on an extension: +3."],
	["baby_doomguy", "ELITE BABY DOOMGUY", "Baby Steps: +12 when you play at least two new monsters, all with printed values of 1 or 2. Romero does not count. When its ability activates after you change combo type: +5."],
	["baby_doomguy", "EXALTED BABY DOOMGUY", "Baby Steps: +12 when you play at least two new monsters, all with printed values of 1 or 2. Romero does not count. When its ability activates while behind in round points: +8."],
	["baby_doomguy", "ETERNAL BABY DOOMGUY", "Baby Steps: +12 when you play at least two new monsters, all with printed values of 1 or 2. Romero does not count. When its ability activates with at least 3 new cards: +12."]
]
# Decorative themes only; colours do not encode rarity or scoring rules.
const THEMES := [
	["302044","c791ed","diamonds"], # Jester velvet
	["390f23","ea4966","diamonds"], # Vampire brocade
	["3c291b","e1b46b","stars"], # Cowboy leather
	["143c29","7bdb8c","diamonds"], # Lucky emerald
	["423417","edc957","rings"], # Greedy gold
	["182b48","9fbeeb","grid"], # Professor notebook
	["301943","cf9df0","stars"], # Magician midnight
	["163b40","6fc4c1","waves"], # Pirate sea
	["242b52","a2b9fa","stars"], # Sleepy night sky
	["3b203d","dfb96d","rays"], # Royal purple
	["421b4a","f18bde","grid"], # Disco dance floor
	["3d2925","e6a88f","checks"], # Chef gingham
	["282a30","bfc7d2","stripes"], # Mime monochrome
	["451f21","f08a77","stripes"], # Boxing ring
	["2d3723","c0c788","chevrons"], # General olive
	["16213f","8abde9","stars"], # Astronaut space
	["123b3c","69e5d7","grid"], # Electric circuitry
	["431b16","ef7756","chevrons"], # Berserker fire
	["403019","f4ce7a","diamonds"], # Clown carnival
	["291d3c","c791ec","rays"],
	["3e2f25","e4c69b","waves"], ["142b51","73afff","grid"],
	["293c20","afdf60","chevrons"], ["3d1720","ea9274","diamonds"],
	["291738","ee70e0","grid"], ["293426","a9bc7c","checks"],
	["432c16","f3b45e","rings"], ["481e34","f49abb","hearts"], ["442118","f5ad66","diamonds"], ["172d32","9abca6","stripes"], ["3b2318","e5b875","checks"], ["352045","e5a5ef","stars"], ["182b48","86bdf1","rings"], ["132b3e","68cbed","grid"], ["302043","f0d16f","stars"], ["493719","ffda52","rings"], ["252b34","ced9ee","grid"], ["472217","f2ad52","stripes"], ["252d32","b6d5df","chevrons"], ["183e36","cbdc66","diamonds"], ["271a3d","5ee8ed","grid"], # Glitch circuitry
	["421b18","ff8263","rays"],
	["44241c","e8c18c","chevrons"],
	["402326","efb9aa","stripes"],
	["352718","ffb853","stars"],
	["342c19","f0cf79","rings"],
	["351b22","ef756c","grid"],
	["251638","cb8fff","rings"],
	["26391e","aad786","chevrons"],
	["16333c","79e5ec","grid"]
]

func draw_card_background(g, m, id: int, bounds: Rect2, active: bool) -> void:
	var theme: Array = ["173b32","ddedaa","grid"] if base_id(id) in [56,57,260,265,270,275,280,285] else THEMES[base_id(id)]
	if base_id(id)==275: theme = ["3b3520","e9c776","chevrons"]
	if base_id(id)==270: theme = ["23351d","b5e879","rings"]
	var accent := Color(theme[1])
	var style: StyleBoxFlat = m.card_style(active)
	style.bg_color = Color(theme[0]).lightened(0.08 if active else 0.0)
	if not active: style.border_color = accent.darkened(0.2)
	g.draw_style_box(style,bounds)
	# Keep every motif inside the frame and away from the title/footer.
	var area := Rect2(bounds.position+Vector2(20,49),bounds.size-Vector2(40,80))
	var ink := Color(accent,0.14)
	for row in 7:
		for col in 5:
			var point := area.position+Vector2((col+0.5)*area.size.x/5,(row+0.5)*area.size.y/7)
			var r := minf(area.size.x/13,area.size.y/20)
			match theme[2]:
				"hearts":
					g.draw_circle(point+Vector2(-r*0.4,-r*0.3),r*0.55,ink)
					g.draw_circle(point+Vector2(r*0.4,-r*0.3),r*0.55,ink)
					g.draw_colored_polygon(PackedVector2Array([point+Vector2(-r*0.9,0),point+Vector2(r*0.9,0),point+Vector2(0,r)]),ink)
				"diamonds": g.draw_colored_polygon(PackedVector2Array([point+Vector2(0,-r),point+Vector2(r,0),point+Vector2(0,r),point+Vector2(-r,0)]),ink)
				"stars":
					g.draw_line(point-Vector2(r,0),point+Vector2(r,0),ink,1)
					g.draw_line(point-Vector2(0,r),point+Vector2(0,r),ink,1)
				"rings": g.draw_arc(point,r,0,TAU,12,ink,1)
				"checks":
					if (row+col)%2==0: g.draw_rect(Rect2(point-Vector2.ONE*r,Vector2.ONE*r*2),ink)
				"chevrons": g.draw_polyline(PackedVector2Array([point+Vector2(-r,-r/2),point+Vector2(0,r/2),point+Vector2(r,-r/2)]),ink,1)
				"waves": g.draw_arc(point,r,0,PI,8,ink,1)
				"grid": g.draw_rect(Rect2(point-Vector2.ONE*r,Vector2.ONE*r*2),ink,false,1)
				"stripes": g.draw_line(point-Vector2(r,r),point+Vector2(r,r),ink,2)
				"rays":
					var direction := (point-area.get_center()).normalized()
					g.draw_line(point-direction*r,point+direction*r,ink,1)

var last_table_family := ""
var slots := [[],[]]
var stats := [{},{}]
var drained := [{},{}]
var reminder_age := 0.0
const REMINDER_TIME := 4.5
var player_drawer_open := false
var pending := false
var offers: Array = []
var chosen := -1
var swap_slot := -1
var guide_links: Array = []
var library := false
var page := 0
var art := {}
var pulses := [{},{}]
var drawer := [0.0,0.0]
var drawer_grace := [0.0,0.0]

func reset() -> void:
	editions = [{},{}]
	offer_editions.clear()
	player_drawer_open = false
	last_table_family = ""
	slots = [[],[]]
	stats = [{},{}]
	drained = [{},{}]
	pulses = [{},{}]
	drawer = [0.0,0.0]
	drawer_grace = [0.0,0.0]
	library = false
	pending = false
	swap_slot = -1

func has(owner: int, id: int) -> bool:
	for held in slots[owner]:
		if held==id or (id in BASE_IDS and held>=58 and base_id(held)==id): return true
	return false

func begin_round() -> void:
	reminder_age = 0.0
	last_table_family = ""
	drained = [{},{}]
	for s in stats:
		s.sleep = 0
		s.drawn = false
		s.edition_draw_ready = false
		s.last = ""
		s.coffee_used = false
		s.glitch_used = false
		s.contract_paid = false
		s.book_families = []
		s.glitch_plays = 0
		s.campfire_ready = false

var draft_age := 0.0
const VARIANT_BASE := {50: 2, 51: 2, 52: 22, 53: 22, 54: 28, 55: 28, 58: 0, 59: 0, 60: 0, 61: 0, 62: 1, 63: 1, 64: 1, 65: 1, 66: 2, 67: 2, 68: 3, 69: 3, 70: 3, 71: 3, 72: 4, 73: 4, 74: 4, 75: 4, 76: 5, 77: 5, 78: 5, 79: 5, 80: 6, 81: 6, 82: 6, 83: 6, 84: 7, 85: 7, 86: 7, 87: 7, 88: 8, 89: 8, 90: 8, 91: 8, 92: 9, 93: 9, 94: 9, 95: 9, 96: 10, 97: 10, 98: 10, 99: 10, 100: 11, 101: 11, 102: 11, 103: 11, 104: 12, 105: 12, 106: 12, 107: 12, 108: 13, 109: 13, 110: 13, 111: 13, 112: 14, 113: 14, 114: 14, 115: 14, 116: 15, 117: 15, 118: 15, 119: 15, 120: 16, 121: 16, 122: 16, 123: 16, 124: 17, 125: 17, 126: 17, 127: 17, 128: 18, 129: 18, 130: 18, 131: 18, 132: 19, 133: 19, 134: 19, 135: 19, 136: 20, 137: 20, 138: 20, 139: 20, 140: 21, 141: 21, 142: 21, 143: 21, 144: 22, 145: 22, 146: 23, 147: 23, 148: 23, 149: 23, 150: 24, 151: 24, 152: 24, 153: 24, 154: 25, 155: 25, 156: 25, 157: 25, 158: 26, 159: 26, 160: 26, 161: 26, 162: 27, 163: 27, 164: 27, 165: 27, 166: 28, 167: 28, 168: 29, 169: 29, 170: 29, 171: 29, 172: 30, 173: 30, 174: 30, 175: 30, 176: 31, 177: 31, 178: 31, 179: 31, 180: 32, 181: 32, 182: 32, 183: 32, 184: 33, 185: 33, 186: 33, 187: 33, 188: 34, 189: 34, 190: 34, 191: 34, 192: 35, 193: 35, 194: 35, 195: 35, 196: 36, 197: 36, 198: 36, 199: 36, 200: 37, 201: 37, 202: 37, 203: 37, 204: 38, 205: 38, 206: 38, 207: 38, 208: 39, 209: 39, 210: 39, 211: 39, 212: 40, 213: 40, 214: 40, 215: 40, 216: 41, 217: 41, 218: 41, 219: 41, 220: 42, 221: 42, 222: 42, 223: 42, 224: 43, 225: 43, 226: 43, 227: 43, 228: 44, 229: 44, 230: 44, 231: 44, 232: 45, 233: 45, 234: 45, 235: 45, 236: 46, 237: 46, 238: 46, 239: 46, 240: 47, 241: 47, 242: 47, 243: 47, 244: 48, 245: 48, 246: 48, 247: 48, 248: 49, 249: 49, 250: 49, 251: 49, 252: 56, 253: 56, 254: 56, 255: 56, 256: 57, 257: 57, 258: 57, 259: 57, 261: 260, 262: 260, 263: 260, 264: 260, 266: 265, 267: 265, 268: 265, 269: 265, 271: 270, 272: 270, 273: 270, 274: 270, 276: 275, 277: 275, 278: 275, 279: 275, 281: 280, 282: 280, 283: 280, 284: 280, 286: 285, 287: 285, 288: 285, 289: 285}
const VARIANT_TIER := {50: 1, 51: 3, 52: 1, 53: 3, 54: 1, 55: 3, 58: 1, 59: 2, 60: 3, 61: 4, 62: 1, 63: 2, 64: 3, 65: 4, 66: 2, 67: 4, 68: 1, 69: 2, 70: 3, 71: 4, 72: 1, 73: 2, 74: 3, 75: 4, 76: 1, 77: 2, 78: 3, 79: 4, 80: 1, 81: 2, 82: 3, 83: 4, 84: 1, 85: 2, 86: 3, 87: 4, 88: 1, 89: 2, 90: 3, 91: 4, 92: 1, 93: 2, 94: 3, 95: 4, 96: 1, 97: 2, 98: 3, 99: 4, 100: 1, 101: 2, 102: 3, 103: 4, 104: 1, 105: 2, 106: 3, 107: 4, 108: 1, 109: 2, 110: 3, 111: 4, 112: 1, 113: 2, 114: 3, 115: 4, 116: 1, 117: 2, 118: 3, 119: 4, 120: 1, 121: 2, 122: 3, 123: 4, 124: 1, 125: 2, 126: 3, 127: 4, 128: 1, 129: 2, 130: 3, 131: 4, 132: 1, 133: 2, 134: 3, 135: 4, 136: 1, 137: 2, 138: 3, 139: 4, 140: 1, 141: 2, 142: 3, 143: 4, 144: 2, 145: 4, 146: 1, 147: 2, 148: 3, 149: 4, 150: 1, 151: 2, 152: 3, 153: 4, 154: 1, 155: 2, 156: 3, 157: 4, 158: 1, 159: 2, 160: 3, 161: 4, 162: 1, 163: 2, 164: 3, 165: 4, 166: 2, 167: 4, 168: 1, 169: 2, 170: 3, 171: 4, 172: 1, 173: 2, 174: 3, 175: 4, 176: 1, 177: 2, 178: 3, 179: 4, 180: 1, 181: 2, 182: 3, 183: 4, 184: 1, 185: 2, 186: 3, 187: 4, 188: 1, 189: 2, 190: 3, 191: 4, 192: 1, 193: 2, 194: 3, 195: 4, 196: 1, 197: 2, 198: 3, 199: 4, 200: 1, 201: 2, 202: 3, 203: 4, 204: 1, 205: 2, 206: 3, 207: 4, 208: 1, 209: 2, 210: 3, 211: 4, 212: 1, 213: 2, 214: 3, 215: 4, 216: 1, 217: 2, 218: 3, 219: 4, 220: 1, 221: 2, 222: 3, 223: 4, 224: 1, 225: 2, 226: 3, 227: 4, 228: 1, 229: 2, 230: 3, 231: 4, 232: 1, 233: 2, 234: 3, 235: 4, 236: 1, 237: 2, 238: 3, 239: 4, 240: 1, 241: 2, 242: 3, 243: 4, 244: 1, 245: 2, 246: 3, 247: 4, 248: 1, 249: 2, 250: 3, 251: 4, 252: 1, 253: 2, 254: 3, 255: 4, 256: 1, 257: 2, 258: 3, 259: 4, 261: 1, 262: 2, 263: 3, 264: 4, 266: 1, 267: 2, 268: 3, 269: 4, 271: 1, 272: 2, 273: 3, 274: 4, 276: 1, 277: 2, 278: 3, 279: 4, 281: 1, 282: 2, 283: 3, 284: 4, 286: 1, 287: 2, 288: 3, 289: 4}
const BASE_IDS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 56, 57, 260, 265, 270, 275, 280, 285]
const LEGENDARY := [51,53,55]
func base_id(id: int) -> int:
	return int(VARIANT_BASE.get(id,id))
func effect_id(id: int) -> int:
	return base_id(id) if id>=58 else id
func owned_family(owner: int, id: int) -> bool:
	for held in slots[owner]:
		if base_id(held)==base_id(id): return true
	return false
func held_effect(owner: int, id: int) -> int:
	for held in slots[owner]:
		if effect_id(held)==id: return held
	return id
func available(m, id: int) -> bool:
	return not VARIANT_BASE.has(id) or (m.run.enabled and m.run.stage >= [0,2,3,4,6][VARIANT_TIER[id]])
func variant_chance(stage: int) -> float:
	return clampf(0.02*float(stage-1),0.0,0.25)
func discover_variant(m, owner: int, base: int) -> int:
	if owned_family(owner,base) or m.random.randf()>=variant_chance(m.run.stage if m.run.enabled else 1): return base
	var pool: Array = []
	for id in VARIANT_BASE:
		if base_id(id)==base and available(m,id):
			for copy in [0,16,6,2,1][VARIANT_TIER[id]]: pool.append(id)
	return pool[m.random.randi_range(0,pool.size()-1)] if not pool.is_empty() else base
func variant_bonus(id: int, c: Dictionary) -> int:
	if id<58: return 0
	match int(VARIANT_TIER.get(id,0)):
		1: return 3 if (not c.extension if base_id(id) in [24,39,57] else c.extension) else 0
		2: return 5 if (c.behind if base_id(id)==20 else c.changed) else 0
		3: return 8 if c.behind else 0
		4: return 12 if (c.count==1 if base_id(id) in [21,56] else c.count==2 if base_id(id) in [13,24,36] else c.count>=3) else 0
	return 0
const RARE := [280,50,52,54,6,12,15,17,18,24,36,40,47,48,49]
const UNCOMMON := [275,270,265,260,57,1,5,7,9,10,11,14,16,19,21,22,23,26,27,28,31,32,33,41,42,45,46]
func rarity(id: int) -> String:
	if VARIANT_TIER.has(id): return ["","RARE","EPIC","LEGENDARY","MYTHIC"][VARIANT_TIER[id]]
	return "LEGENDARY" if id in LEGENDARY else ("RARE" if id in RARE else ("UNCOMMON" if id in UNCOMMON else "COMMON"))
func rarity_weight(id: int) -> int:
	return 1 if id in LEGENDARY else (4 if id in RARE else (16 if id in UNCOMMON else 32))
func rarity_color(id: int) -> Color:
	if VARIANT_TIER.has(id): return Color(["ffffff","e99aff","ff9066","ffdc65","ff5e93"][VARIANT_TIER[id]])
	return Color("ffdc65") if id in LEGENDARY else Color("e99aff") if id in RARE else (Color("72d8ff") if id in UNCOMMON else Color("d0c5a8"))
const MAX_SLOTS := 5
const STARTER_POOL := [0,2,3,8,13,20,25,29,30,37,38,39,43,44]

func draft_offers(m, owner: int, pack_tier := 0) -> Array:
	var candidates: Array = []
	for id in BASE_IDS:
		if pack_tier>0 and not (id in RARE or (pack_tier==1 and id in UNCOMMON)): continue
		if available(m,id) and not owned_family(owner,id) and (m.round_number>1 or not slots[owner].is_empty() or id in STARTER_POOL): candidates.append(id)
	var choices: Array = []
	for i in mini(3,candidates.size()):
		var total := 0
		for id in candidates: total += rarity_weight(id)
		var roll: int = m.random.randi_range(1,total)
		for index in candidates.size():
			roll -= rarity_weight(candidates[index])
			if roll<=0:
				choices.append(discover_variant(m,owner,candidates.pop_at(index)))
				break
	return choices

func auto_pick(m, owner: int, choices: Array) -> int:
	var best: int = choices[0]
	var value := -1.0
	for id in choices:
		var weight: float = m.random.randf()*4+5
		if id in [2,11,38]:
			for card in m.hands[owner]:
				if m.card_data(card).type==({2:"BULLET",11:"FIRE",38:"MELEE"}[id]): weight += 2
		if id==12 and slots[owner].is_empty(): weight = 0
		if weight>value: best = id; value = weight
	return best

func offer(m) -> void:
	if slots[0].size()>=m.slot_limit():
		m.progression.open_shop(m)
		return
	draft_age = 0.0
	offers = draft_offers(m,0)
	offer_editions.clear()
	if m.progression.enabled:
		for id in offers: offer_editions[id] = Editions.roll(m.random)
	chosen = -1
	pending = true
	swap_slot = -1

func finish_pick(m) -> void:
	if not pending or not offers.has(chosen) or slots[0].size()>=m.slot_limit(): return
	slots[0].append(chosen)
	editions[0][chosen] = int(offer_editions.get(chosen,0))
	if slots[1].size()<m.slot_limit():
		slots[1].append(auto_pick(m,1,draft_offers(m,1)))
		if m.progression.enabled: editions[1][slots[1][-1]] = Editions.roll(m.random)
	pending = false
	chosen = -1
	apply_contract(m)
	m.hint_signature = ""
	m.progression.open_shop(m)

func apply_contract(m) -> void:
	for owner in 2:
		if has(owner,23) and not stats[owner].get("contract_paid",false):
			m.round_scores[owner] -= 20
			stats[owner].contract_paid = true

func enhancement(m, owner: int, id: int) -> String:
	return "" if drained[owner].has(id) else str(m.enhancements.get(id,""))

func fixed_bonus(id: int, c: Dictionary) -> int:
	match id:
		285: return 12 if c.count>=2 and c.get("harvest",0)==c.count else 0
		275: return 10 if c.get("harvest",0)>=2 else 0
		270: return 12 if c.get("fire",0)>0 and c.get("energy",false) else 0
		265: return 12 if c.get("changed",false) and c.get("energy",false) else 0
		260: return 14 if c.get("bullet",0)>=3 else 0
		57: return 8 if c.get("behind",false) and not c.get("extension",false) else 0
		56: return 10 if c.rival and c.extension and c.count==1 else 0
		50: return 12 if c.extension and c.count==1 and c.bullet==1 else 0
		51: return c.bullet*6+(12 if c.bullet>=3 and c.remaining==0 else 0)
		54: return 14 if c.count==3 and c.types==3 and c.changed else 0
		55: return (20+(10 if c.overtake else 0)) if c.count>=4 and c.types>=4 else 0
		46: return 12 if c.get("overtake",false) else 0
		45: return 15 if c.count>=3 and c.get("distinct",0)==c.count else 0
		43: return 10 if c.count==3 else 0
		42: return 15 if c.get("rival",false) and (c.get("bullet",0)>0 or c.get("melee",0)>0) else 0
		41: return 20 if c.get("final_turn",false) else 0
		0: return 5
		6: return 15 if c.get("romero",false) else 0
		21: return 10 if c.get("extension",false) and c.count==1 else 0
		2: return c.bullet*4
		4: return c.gilded*6
		7: return 12 if c.rival else 0
		9: return 10 if c.king else 0
		10: return c.echo
		13: return 12 if c.count==2 else 0
		14: return 15 if c.kind=="team" else 0
		15: return 20 if c.kind=="rainbow" else 0
		16: return c.charged*5
		19: return 10 if c.changed else 0
		23: return 6
		25: return c.count*2
		39: return 0 if c.get("extension",false) else 4
		38: return c.get("melee",0)*4
		36: return 10 if c.count==2 and c.get("distinct",0)==2 else 0
		35: return 6 if c.get("ahead",false) else 0
		34: return 4 if c.get("behind",false) else 0
		33: return 10 if c.get("remaining",-1)==0 else 0
		32: return 8 if c.get("repeated",false) else 0
		30: return 10 if c.kind=="run" else 0
		31: return 12 if c.count>=4 else 0
		29: return mini(10,c.get("remaining",0)*2)
		28: return 12 if c.count==3 and c.get("types",0)==3 else 0
		27: return c.get("pairs",0)*6
	return 0

func score(m, owner: int, ids: Array, combo: Dictionary, extension: bool, commit := false) -> Dictionary:
	var s: Dictionary = stats[owner]
	var context := {"bullet":0,"fire":0,"gilded":0,"charged":0,"echo":0,"count":ids.size(),"kind":combo.kind,"rival":extension and not m.melds.is_empty() and m.melds[0].get("starter",owner)!=owner,"king":m.hands[owner].count(8)>ids.count(8),"changed":s.get("last","")!="" and s.get("last","")!=combo.kind}
	context.final_turn = m.turns[owner]==9
	context.ahead = m.round_scores[owner]>m.round_scores[1-owner]
	context.behind = m.round_scores[owner]<m.round_scores[1-owner]
	context.overtake = context.behind and m.round_scores[owner]+int(combo.gain)>m.round_scores[1-owner]
	context.repeated = last_table_family!="" and last_table_family==combo.kind
	context.remaining = maxi(0,m.hands[owner].size()-ids.size())
	context.romero = ids.has(-1)
	context.extension = extension
	context.pairs = 0
	var pair_counts := {}
	for monster in ids:
		if monster>=0: pair_counts[monster] = int(pair_counts.get(monster,0))+1
	context.harvest = 0
	for monster in ids:
		if monster>=0 and m.card_data(monster).cost<=2: context.harvest += 1
	context.melee = 0
	for monster in ids:
		if monster>=0 and m.card_data(monster).type=="MELEE": context.melee += 1
	context.distinct = pair_counts.size()
	for count in pair_counts.values(): context.pairs += int(count/2)
	var played_types := {}
	for monster in ids: played_types[m.card_data(monster).type] = true
	context.types = played_types.size()
	context.energy = played_types.has("ENERGY")
	var drain_id := -1
	for i in ids.size():
		var id: int = ids[i]
		var type: String = m.card_data(id).type
		if type=="BULLET": context.bullet += 1
		if type=="FIRE": context.fire += 1
		var e := enhancement(m,owner,id)
		if e=="GILDED": context.gilded += 1
		if e=="CHARGED": context.charged += 1
		if e!="" and drain_id<0: drain_id = id
		if i==0: context.echo = 4 if e=="GILDED" else (8 if e=="CHARGED" and extension else 0)
	var total: int = combo.gain
	var events: Array = []
	var activations := {}
	if combo.get("rule_joker",-1)>=0:
		events.append({"id":held_effect(owner,combo.rule_joker),"text":"RULE BREAK / "+combo.name,"amount":0,"total":total})
	for slot in slots[owner].size():
		var actual_id: int = slots[owner][slot]
		var id: int = effect_id(actual_id)
		var bonus := fixed_bonus(id,context)
		if id==52: bonus = 18 if context.fire>0 and (int(s.get("volatile_charge",0))+1)%2==0 else 0
		if id==53: bonus = (30+(10 if context.fire>0 else 0)) if extension and (int(s.get("doomsday_charge",0))+1)%3==0 else 0
		if id==44: bonus = 10 if s.get("campfire_ready",false) and context.fire>0 else 0
		if id==40: bonus = 10 if (int(s.get("glitch_plays",0))+1)%2==0 else 0
		if id==37: bonus = 0 if combo.kind in s.get("book_families",[]) else 6
		if id==26: bonus = s.get("gluttonous",0)
		if id==20: bonus = 0 if s.get("coffee_used",false) else 10
		if id==22: bonus = 20 if (int(s.get("barrel",0))+1)%3==0 else 0
		if id==24: bonus = 20 if not s.get("glitch_used",false) and not extension and combo.kind=="set" and ids.size()==2 else 0
		if id==1: bonus = s.get("vampire",0)
		if id==3: bonus = (20 if m.random.randf()<0.25 else 0) if commit else 5
		if id==8: bonus = s.get("sleep",0)
		if id==11 and context.fire>0: bonus = s.get("chef",0)
		if id==12 and slot>0: bonus = fixed_bonus(effect_id(slots[owner][slot-1]),context)
		if bonus>0: activations[id] = bonus
		if id==1 and drain_id>=0: activations[id] = maxi(bonus,20)
		if id==11 and context.fire>0 and s.get("chef",0)<20: activations[id] = maxi(bonus,20)
		if id==26 and ids.size()>=4 and s.get("gluttonous",0)<24: activations[id] = maxi(bonus,20)
		if id==5 and combo.kind=="run" and (int(s.get("marches",0))+1)%3==0: activations[id] = 20
		if id==18 and s.get("edition_draw_ready",false): activations[id] = 20
		if combo.get("rule_joker",-1)==id: activations[id] = 20
		if id==17 and context.final_turn: activations[id] = maxi(1,int(combo.gain*0.5))
		if bonus>0: total += bonus; events.append({"id":id,"text":"+%d" % bonus,"amount":bonus,"total":total})
	for actual_id in slots[owner]:
		var inherited: int = effect_id(actual_id)
		if activations.has(inherited):
			var extra := variant_bonus(actual_id,context)
			if inherited==3 and not commit: extra = int(round(extra*0.25))
			if extra>0:
				total += extra
				events.append({"id":actual_id,"text":"VARIANT +%d" % extra,"amount":extra,"total":total})
	# Edition bonuses are separate scoring beats and cannot be copied by Mime.
	for id in slots[owner]:
		var edition := edition_of(owner,id)
		var edition_context: Dictionary = context.duplicate()
		edition_context.activated = activations.has(effect_id(id))
		edition_context.host_bonus = activations.get(effect_id(id),0)
		if effect_id(id)==3 and not commit: edition_context.host_bonus = 20
		var extra := Editions.bonus(edition,edition_context)
		if effect_id(id)==3 and not commit: extra = int(round(extra*0.25))
		if extra>0:
			total += extra
			events.append({"id":id,"text":Editions.DATA[edition][0]+" +%d" % extra,"amount":extra,"total":total})
	# Multipliers resolve after all additions, independent of slot order.
	if has(owner,17) and m.turns[owner]==9:
		var before := total
		total = int(floor(total*1.5)); events.append({"id":17,"text":"x1.5 / +%d" % (total-before),"amount":total-before,"total":total})
	if commit:
		s.edition_draw_ready = false
		if has(owner,52) and context.fire>0: s.volatile_charge = int(s.get("volatile_charge",0))+1
		if has(owner,53) and extension: s.doomsday_charge = int(s.get("doomsday_charge",0))+1
		if has(owner,44) and context.fire>0: s.campfire_ready = false
		if has(owner,40): s.glitch_plays = int(s.get("glitch_plays",0))+1
		if has(owner,37):
			if not s.has("book_families"): s.book_families = []
			if not combo.kind in s.book_families: s.book_families.append(combo.kind)
		if has(owner,26) and ids.size()>=4:
			s.gluttonous = mini(24,int(s.get("gluttonous",0))+3)
			events.append({"id":26,"text":"FUTURE BONUS +%d" % s.gluttonous,"total":total,"amount":0})
		if has(owner,20): s.coffee_used = true
		if has(owner,22): s.barrel = int(s.get("barrel",0))+1
		if has(owner,24) and not extension and combo.kind=="set" and ids.size()==2: s.glitch_used = true
		if has(owner,1) and drain_id>=0:
			drained[owner][drain_id] = true
			s.vampire = s.get("vampire",0)+3
			events.append({"id":1,"text":"FUTURE BONUS GROWS +3","total":total,"amount":0})
		if has(owner,11) and context.fire>0:
			s.chef = mini(20,s.get("chef",0)+context.fire)
			events.append({"id":11,"text":"FUTURE FIRE BONUS +%d" % s.chef,"total":total,"amount":0})
		if has(owner,5) and combo.kind=="run":
			s.marches = s.get("marches",0)+1
			if s.marches%3==0:
				m.upgrades[owner]["run"] = m.upgrades[owner].get("run",0)+1
				events.append({"id":5,"text":"FUTURE MARCHES +5","total":total,"amount":0})
		if has(owner,8): s.sleep = 0
		s.last = combo.kind
		last_table_family = combo.kind
	for event in events:
		event.id = held_effect(owner,event.id)
		if commit: pulses[owner][event.id] = m.age
	return {"gain":total,"events":events,"bonus":total-int(combo.gain)}

func on_draw(owner: int, stock_count := 2) -> int:
	var s: Dictionary = stats[owner]
	var count := 2 if has(owner,18) and not s.get("drawn",false) else 1
	s.drawn = true
	if count==2 and stock_count>=2: s.edition_draw_ready = true
	if has(owner,44): s.campfire_ready = true
	if has(owner,8): s.sleep = mini(16,s.get("sleep",0)+4)
	return count

func progress(owner: int, id: int) -> String:
	id = effect_id(id)
	if id==52: return "FIRE CHARGE %d/2" % (int(stats[owner].get("volatile_charge",0))%2)
	if id==53: return "EXTEND CHARGE %d/3" % (int(stats[owner].get("doomsday_charge",0))%3)
	if id==39: return "COMMON"
	if id==40: return "%d / 2 PLAYS" % (int(stats[owner].get("glitch_plays",0))%2)
	var s: Dictionary = stats[owner]
	match id:
		44: return "FIRE +10 READY" if s.get("campfire_ready",false) else "DRAW TO REST"
		26: return "APPETITE +%d" % s.get("gluttonous",0)
		20: return "USED" if s.get("coffee_used",false) else "FIRST +10"
		22: return "CHARGE %d/3" % (int(s.get("barrel",0))%3)
		24: return "USED" if s.get("glitch_used",false) else "PAIR +20"
		1: return "GROWTH +%d" % s.get("vampire",0)
		5: return "MARCHES %d/3" % (s.get("marches",0)%3)
		8: return "STORED +%d" % s.get("sleep",0)
		11: return "HEAT +%d" % s.get("chef",0)
		18: return "DRAW USED" if s.get("drawn",false) else "DOUBLE DRAW"
	return "PASSIVE"

func portrait_pose(id: int, time: float, width: float) -> Transform2D:
	if base_id(id)!=41: return Transform2D.IDENTITY
	var offset := Vector2(sin(time*57.0)+sin(time*83.0)*0.45,cos(time*67.0)*0.65)*width*0.018
	return Transform2D(sin(time*49.0)*0.045,offset)

func card(g, m, id: int, rect: Rect2, owner := -1, interactive := true, edition_override := -1) -> void:
	var edition: int = edition_override if edition_override>=0 else (edition_of(owner,id) if owner>=0 else int(offer_editions.get(id,0)) if pending else 0)
	var mouse: Vector2 = g.get_global_mouse_position()
	var local: Vector2 = (mouse-rect.get_center())/rect.size
	var hover := interactive and rect.has_point(mouse)
	var pulse := 0.0
	if owner>=0: pulse = maxf(0,1-(m.age-float(pulses[owner].get(id,-99)))/0.8)
	var center := rect.get_center()+Vector2(local.x*7 if hover else 0,0)
	# Signed side lean reverses across the centre; no mouse-height tilt.
	var card_transform := preload("res://scripts/card_tilt.gd").pose(center,local.x,hover)
	g.draw_set_transform_matrix(card_transform)
	var bounds := Rect2(-rect.size/2,rect.size)
	for depth in range(5,0,-1):
		g.draw_style_box(m.card_style(false),Rect2(bounds.position+Vector2(depth*(-signf(local.x) if hover and absf(local.x)>0.05 else 1.0),depth*1.5),bounds.size))
	draw_card_background(g,m,id,bounds,hover or pulse>0)
	var font_size := 18 if rect.size.x>=180 else maxi(7,roundi(rect.size.x*0.085))
	var padding := minf(14,rect.size.x*0.065)
	var title_width := rect.size.x-padding*2
	var lines: Array[String] = []
	var line := ""
	for word in str(DATA[id][1]).split(" "):
		var candidate := word if line=="" else line+" "+word
		if line!="" and g.font.get_string_size(candidate,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>title_width:
			lines.append(line)
			line = word
		else: line = candidate
	lines.append(line)
	var header_height := padding+lines.size()*(font_size+4)
	g.draw_rect(Rect2(bounds.position+Vector2(6,6),Vector2(rect.size.x-12,header_height)),Color("111b1d"))
	for row in lines.size():
		g.label_at(bounds.position+Vector2(padding,8+font_size+row*(font_size+4)),lines[row],font_size,g.INK)
	var has_guide_link: bool = interactive and "named team" in DATA[id][2].to_lower()
	var link_height := 24.0 if has_guide_link else 0.0
	var footer_size := 13 if rect.size.x>=180 else maxi(6,roundi(rect.size.x*0.06))
	var status_text := progress(owner,id) if owner>=0 else ""
	if status_text in ["PASSIVE","COMMON"]: status_text = ""
	var footer_height := (82.0 if rect.size.y>=230 else 58.0) if edition>0 else (48.0 if status_text!="" else 30.0)
	g.draw_rect(Rect2(Vector2(bounds.position.x+6,bounds.end.y-footer_height),Vector2(rect.size.x-12,footer_height-6)),Color("111b1d"))
	var rarity_text := rarity(id)+(" VARIANT" if VARIANT_BASE.has(id) else "")
	var rarity_y := bounds.end.y-(64 if edition>0 else 34 if status_text!="" else 15)
	if edition==0 or rect.size.y>=230:
		g.label_at(Vector2(bounds.position.x+12,rarity_y),rarity_text,footer_size,rarity_color(id))
	# Reserve a real portrait area between the measured title and footer.
	var portrait_top := bounds.position.y+6+header_height+12
	var portrait_bottom := bounds.end.y-footer_height-link_height-12
	var portrait_area := Rect2(Vector2(bounds.position.x+22,portrait_top),Vector2(rect.size.x-44,maxf(16,portrait_bottom-portrait_top)))
	if VARIANT_BASE.has(id):
		var variant_color := rarity_color(id)
		g.draw_rect(bounds.grow(-3),Color(variant_color,0.65+sin(g.clock*3)*0.2),false,3)
	var time: float = g.clock
	var tint := Color.from_hsv(fposmod(id*0.137,1.0),0.65,1.0)
	if id==0: tint = Color.from_hsv(fposmod(time*0.12,1),0.7,1)
	elif id==1: tint = Color("fa334f")
	elif id==2: tint = Color("ffbf62")
	elif id==3: tint = Color("64ec68")
	elif id==4: tint = Color("ffd34f")
	var glow_strength: float = 0.055+sin(time*2+id)*0.015+(0.035 if hover else 0)+pulse*0.09
	# Soft halo behind the portrait; no flashing or full-screen lighting.
	for ring in range(5,0,-1):
		g.draw_circle(Vector2.ZERO,rect.size.x*(0.23+ring*0.027),Color(tint,glow_strength/2))
	for spark in 7:
		var angle: float = time*0.5+spark*TAU/7+id
		var point := Vector2(cos(angle)*rect.size.x*0.34,sin(angle)*rect.size.y*0.28)
		var brightness: float = 0.2+0.3*maxf(0,sin(time*2.5+spark))
		g.draw_rect(Rect2(point,Vector2.ONE*(2 if rect.size.x<100 else 3)),Color(tint,brightness))
	var art_id: int = {47:6,48:14,49:16,50:2,51:2,52:22,53:22,54:28,55:28}.get(base_id(id),base_id(id))
	var path: String = "res://assets/jokers/"+DATA[art_id][0]+".png"
	if base_id(id)==57: path = "res://assets/jokers/helmet_doomguy.tres"
	if base_id(id)==25 and not art.has(id) and not g.art.textures.get("AMMO",[]).is_empty(): art[id] = g.art.textures["AMMO"][0]
	if not art.has(id): art[id] = load(path) if ResourceLoader.exists(path) else null
	if art[id]!=null:
		var tex: Texture2D = art[id]
		var size := tex.get_size()
		size *= minf(portrait_area.size.x/size.x,portrait_area.size.y/size.y)*0.85
		var dance := Transform2D(sin(time*7)*0.07,Vector2(sin(time*5)*3,-absf(sin(time*7))*7)) if hover else Transform2D.IDENTITY
		g.draw_set_transform_matrix(card_transform*Transform2D(0,portrait_area.get_center())*dance*portrait_pose(id,time,rect.size.x))
		g.draw_texture_rect(tex,Rect2(-size/2,size),false)
		g.draw_set_transform_matrix(card_transform)
	else:
		g.draw_circle(Vector2.ZERO,rect.size.x*0.22,Color.from_hsv(id/20.0,0.5,0.45))
		g.label_at(Vector2(-16,8),"%02d" % (id+1),20,g.INK)
		g.label_at(Vector2(-rect.size.x/2+7,27),"ART PENDING",9,g.MUTED)
	if id==4:
		# Coins flip about their vertical axes as they orbit the portrait.
		for coin in 5:
			var phase: float = time*0.9+coin*TAU/5
			var p := Vector2(cos(phase)*rect.size.x*0.28,sin(phase)*rect.size.y*0.23)
			var radius: float = maxf(3,rect.size.x*0.035)
			var width: float = maxf(1,radius*absf(cos(time*3+coin)))
			g.draw_set_transform_matrix(card_transform*Transform2D(0,Vector2(width/radius,1),0,p))
			g.draw_circle(Vector2.ZERO,radius,Color("ad6818"))
			g.draw_circle(Vector2(-0.5,-0.5),radius*0.75,Color("ffd65a"))
			g.draw_line(Vector2(0,-radius*0.45),Vector2(0,radius*0.45),Color("fff2a0"),1)
		g.draw_set_transform_matrix(card_transform)
	elif id==1:
		# Small pixel blood drops descend beside the face, within the card.
		for drop in 6:
			var phase: float = fposmod(time*0.35+drop*0.173,1)
			var p := Vector2((-1 if drop%2==0 else 1)*rect.size.x*(0.19+(drop%3)*0.04),rect.size.y*(-0.05+phase*0.36))
			var radius: float = maxf(1.5,rect.size.x*0.012)
			var blood := Color(0.8,0.025,0.07,sin(phase*PI)*0.9)
			g.draw_rect(Rect2(p-Vector2(radius*0.4,radius*2.5),Vector2(radius*0.8,radius*2.5)),blood)
			g.draw_circle(p,radius,blood)
	if id==40:
		for strip in 3:
			var phase: float = g.clock*2.0+strip*1.7
			var y: float = -rect.size.y*0.3+fposmod(phase*18.0,rect.size.y*0.6)
			var x: float = sin(phase*3.0)*rect.size.x*0.22
			g.draw_rect(Rect2(Vector2(x,y),Vector2(15,2)),Color(0.2,1.0,1.0,0.55))
			g.draw_rect(Rect2(Vector2(x+8,y+3),Vector2(10,2)),Color(1.0,0.1,0.7,0.45))
	if status_text!="": g.label_at(Vector2(bounds.position.x+12,bounds.end.y-13),status_text,footer_size,g.ORANGE)
	var side_font := maxi(6,roundi(rect.size.x*0.055))
	for opposite in 2:
		g.draw_set_transform_matrix(card_transform*Transform2D(PI if opposite==1 else 0.0,Vector2.ZERO))
		for letter in 5:
			g.label_at(Vector2(-rect.size.x/2+7,-rect.size.y/2+header_height+20+letter*(side_font+1)),"JOKER"[letter],side_font,Color("e49d61"))
	g.draw_set_transform_matrix(card_transform)
	# A brief, staggered border shimmer every 18-28 seconds per card.
	var cycle: float = fposmod(time+id*4.73,18.0+id%11)
	if cycle<1.6 or pulse>0:
		var shimmer: float = maxf(pulse,sin(cycle/1.6*PI))
		g.draw_rect(bounds.grow(-3),Color(tint,shimmer*0.65),false,2)
		for sparkle in 4:
			var x: float = -rect.size.x/2+6+fposmod(cycle*100+sparkle*rect.size.x/4,rect.size.x-12)
			g.draw_line(Vector2(x-3,-rect.size.y/2+4),Vector2(x+3,-rect.size.y/2+4),Color(tint,shimmer),2)
	if hover:
		var sheen_x := local.x*rect.size.x*0.7
		g.draw_rect(Rect2(sheen_x-rect.size.x*0.07,-rect.size.y/2+23,rect.size.x*0.14,rect.size.y-46),Color(1,1,1,0.06))
		g.draw_line(bounds.position+Vector2(5,3),bounds.position+Vector2(rect.size.x-5,3),Color(1,1,1,0.8),3)
	Editions.draw(g,bounds,edition,time)
	if has_guide_link:
		var link := Rect2(Vector2(bounds.position.x+7,bounds.end.y-footer_height-link_height),Vector2(rect.size.x-14,22))
		g.draw_rect(link,Color("13272c"))
		g.label_at(link.position+Vector2(4,15),"NAMED TEAMS >",mini(10,footer_size),Color("ffd482"))
		g.draw_line(link.position+Vector2(4,18),link.position+Vector2(link.size.x-4,18),Color("dca850"),1)
		guide_links.append(card_transform*link)
	g.draw_set_transform(Vector2.ZERO)
	if interactive: g.ui_help.offer_sections(rect,DATA[id][1],tooltip_sections(id,owner,edition))

func tooltip_sections(id: int, owner: int, edition: int) -> Array:
	var ability: String = {
		13:"Play exactly 2 cards: +12 points.",
		22:"Every 3rd scoring play: +20 points. Charge carries across rounds; draw/pass does not charge it.",
		3:"Each scoring play: 25% chance of +20 points.",
		21:"Extend with exactly 1 card: +10 points.",
		56:"Extend an opponent-started combo with exactly 1 card: +10 points."
	}.get(id,DATA[id][2])
	var result: Array = [{"text":ability,"color":Color("e5ebdf")}]
	if id>=58 and VARIANT_BASE.has(id):
		result[0].text = DATA[base_id(id)][2]
		var special: String = DATA[id][2].trim_prefix(DATA[base_id(id)][2]+" ")
		result.append({"text":rarity(id)+" VARIANT\n"+special,"color":rarity_color(id)})
	if edition>0:
		var rule: String = ["","When this Joker triggers on an extension: +3.","When this Joker triggers: add 30% of its bonus, rounded up (max +6).","When this Joker triggers: +2 per card you add (max +6).","When this Joker triggers after you change combo family: +4.","When this Joker triggers while you are behind in round points: +4.","When this Joker triggers: +2 per Fire card you add (max +6).","When this Joker triggers with exactly 2 cards you add: +4.","When this Joker triggers with 4 or more cards you add: +6."][edition]
		if id==13 and edition==7: rule = "When Revenant Boxer triggers with 2 cards, add +4."
		if edition==2 and effect_id(id) in [5,18,47,48,49,280]: rule = "When this Joker's special ability triggers: +6."
		result.append({"text":Editions.DATA[edition][0]+" UPGRADE\n"+rule,"color":Color(Editions.DATA[edition][2])})
		if id==13 and edition==7: result.append({"text":"TOTAL: +16 points","color":Color("ffda68")})
		if effect_id(id)==18: result.append({"text":"The extra draw readies this upgrade for your next scoring play this round.","color":Color("b4c5ca")})
	if owner>=0:
		var state := progress(owner,id)
		if state not in ["PASSIVE","COMMON"]: result.append({"text":"NOW: "+state,"color":Color("ffab68")})
	return result

func draw(g,m) -> void:
	guide_links.clear()
	if not pending and not library:
		for owner in 2:
			var panel := drawer_rect(owner)
			var tab := drawer_tab(owner)
			if drawer[owner]>0.01: g.draw_style_box(m.card_style(false),panel)
			var title := "YOUR" if owner==0 else "CPU"
			if owner==1:
				g.draw_style_box(m.card_style(drawer[owner]>0.1),tab)
				g.label_at(tab.position+Vector2(12,25),title+" JOKERS / "+str(slots[owner].size()),17,g.ORANGE)
				g.ui_help.offer(tab,"CPU JOKERS","Hover to inspect CPU Jokers.")
			if drawer[owner]>0.01:
				g.label_at(panel.position+Vector2(12,25),title+" / JOKERS",13,g.ORANGE)
				for i in slots[owner].size(): card(g,m,slots[owner][i],slot_rect(owner,i),owner)
				if slots[owner].is_empty(): g.label_at(panel.position+Vector2(12,70),"NO JOKERS",12,g.MUTED)
		if g.joker_reminders and m.banner_age>=m.reveal_duration() and not m.round_intro and not m.round_over and m.draw_flights.is_empty() and reminder_age<REMINDER_TIME: draw_reminder(g,m)
		if swap_slot>=0 and drawer[0]>0.01:
			g.draw_rect(slot_rect(0,swap_slot),g.ORANGE,false,3)
			g.ui_help.offer(slot_rect(0,swap_slot),"SWAP JOKERS","Click another of your Joker slots to swap positions. Mime copies its previous slot (to its left).")
	if not pending and not library: return
	g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.94))
	g.ui_help.reset()
	g.menu_frame(Rect2(110,65,1220,820))
	g.label_at(Vector2(155,120),"CHOOSE A SUPPORT JOKER" if pending else "JOKER COLLECTION / %d TYPES" % BASE_IDS.size(),28,g.ORANGE)
	g.label_at(Vector2(155,160),"Base Jokers only. Hidden variants can appear during runs; deeper stages improve your chances.",17,g.INK)
	if pending:
		for i in offers.size():
			if draft_age<i*0.65+1.0:
				var box := Rect2(260+i*335,200,230,335)
				g.draw_rect(box,Color("202c30"))
				g.draw_rect(box,rarity_color(offers[i]),false,3)
				for stripe in 6: g.draw_line(box.position+Vector2(10,30+stripe*52),box.position+Vector2(220,30+stripe*52),Color("586261"),4)
				g.label_at(box.position+Vector2(55,160),"UAC",40,g.INK)
				g.label_at(box.position+Vector2(38,215),rarity(offers[i]),18,rarity_color(offers[i]))
			else:
				card(g,m,offers[i],Rect2(260+i*335,200,230,335))
				var burst := clampf(1-(draft_age-i*0.65-1)/0.6,0,1)
				g.draw_rect(Rect2(260+i*335,200,230,335),Color(rarity_color(offers[i]),burst*0.35))
			if chosen==offers[i]: g.draw_rect(Rect2(260+i*335,200,230,335),g.ORANGE,false,4)
		g.label_at(Vector2(170,580),"ROUND %d / CHOOSE JOKER %d OF 5" % [m.round_number,slots[0].size()+1],17,g.INK)
		for i in slots[0].size(): card(g,m,slots[0][i],Rect2(270+i*180,610,105,150),0)
		g.label_at(Vector2(420,825),"CHOOSE A JOKER TO CONTINUE",20,g.ORANGE)
	else:
		for i in 10:
			var index := page*10+i
			if index>=BASE_IDS.size(): break
			var id: int = BASE_IDS[index]
			card(g,m,id,Rect2(165+(i%5)*230,190+(i/5)*290,185,270))
		g.button(Rect2(180,800,250,50),"PREVIOUS")
		g.button(Rect2(595,800,250,50),"CLOSE")
		g.button(Rect2(1010,800,250,50),"NEXT")

func set_player_drawer(g, opened: bool) -> void:
	if player_drawer_open==opened: return
	player_drawer_open = opened
	if opened: reminder_age = REMINDER_TIME
	g.audio.play("DSBDOPN" if opened else "DSBDCLS",-16)

func handle(g,m,event: InputEvent) -> bool:
	if not pending and not library and event is InputEventKey and not event.echo and event.keycode==KEY_SPACE:
		set_player_drawer(g,event.pressed)
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		for link in guide_links:
			if link.has_point(event.position):
				m.guide_page = 6
				m.guide = true
				g.ui_help.reset()
				return true
	if pending or library:
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
			if library: library = false
			return true
		if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			var p: Vector2 = event.position
			if pending:
				for i in offers.size():
					if draft_age>=i*0.65+1.0 and Rect2(260+i*335,200,230,335).has_point(p):
						chosen = offers[i]
						finish_pick(m)
						return true

			else:
				if Rect2(180,800,250,50).has_point(p): page = posmod(page-1,ceili(BASE_IDS.size()/10.0))
				elif Rect2(1010,800,250,50).has_point(p): page = (page+1)%ceili(BASE_IDS.size()/10.0)
				elif Rect2(595,800,250,50).has_point(p): library = false
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		for i in slots[0].size():
			if drawer[0]>0.95 and slot_rect(0,i).has_point(event.position):
				if m.side!=0 or m.banner_age<m.reveal_duration(): return true
				if swap_slot<0: swap_slot = i
				else:
					var temp: int = slots[0][i]; slots[0][i] = slots[0][swap_slot]; slots[0][swap_slot] = temp
					swap_slot = -1; m.hint_signature = ""
				return true
	if event is InputEventMouse and not m.dragging:
		for owner in 2:
			if (owner==1 and drawer_tab(owner).has_point(event.position)) or (drawer[owner]>0.01 and drawer_rect(owner).has_point(event.position)):
				return true
	return false

func update_drawers(mouse: Vector2, delta: float, enabled: bool) -> void:
	for owner in 2:
		var inside: bool = enabled and (drawer_tab(owner).grow(5).has_point(mouse) or (drawer[owner]>0.01 and drawer_rect(owner).grow(5).has_point(mouse)))
		if owner==0: inside = enabled and player_drawer_open
		if inside: drawer_grace[owner] = 0.25
		else: drawer_grace[owner] = maxf(0,drawer_grace[owner]-delta)
		var target := 1.0 if enabled and drawer_grace[owner]>0 else 0.0
		if owner==0: target = 1.0 if inside else 0.0
		drawer[owner] = move_toward(drawer[owner],target,delta*5)
	if drawer[0]==0: swap_slot = -1

func drawer_rect(owner: int) -> Rect2:
	if owner==0:
		var width := maxf(230,slots[0].size()*163+12)
		return Rect2(720-width/2,530+410*pow(1-drawer[0],3),width,255)
	return Rect2(310,153+20*(1-drawer[1]),820,255)

func drawer_tab(owner: int) -> Rect2:
	return Rect2(555,805,330,38) if owner==0 else Rect2(800,115,250,38)

func slot_rect(owner: int, slot: int) -> Rect2:
	var panel := drawer_rect(owner)
	var offset: float = (panel.size.x-(slots[owner].size()*163-18))/2 if owner==0 else 15.0
	return Rect2(panel.position+Vector2(offset+slot*163,40),Vector2(145,200))



func draw_reminder(g,m) -> void:
	var enter := smoothstep(0,1,clampf(reminder_age/0.35,0,1))
	var leave := smoothstep(0,1,clampf((reminder_age-3.8)/0.7,0,1))
	var alpha := enter*(1-leave)
	var rect := Rect2(465,603+22*(1-enter)+18*leave,510,62)
	var style = m.card_style(false)
	style.bg_color = Color(0.05,0.10,0.12,alpha)
	style.border_color = Color(1,0.69,0.28,alpha)
	g.draw_style_box(style,rect)
	var key := Rect2(rect.position+Vector2(16,12),Vector2(105,38))
	g.draw_rect(key,Color(0.25,0.19,0.10,alpha))
	g.draw_rect(key,Color(1,0.78,0.40,alpha*(0.7+0.3*sin(reminder_age*5))),false,2)
	g.label_at(key.position+Vector2(17,26),"SPACE",19,Color(1,0.87,0.62,alpha))
	g.label_at(rect.position+Vector2(138,29),"HOLD TO VIEW YOUR JOKERS",18,Color(1,0.76,0.40,alpha))
	g.label_at(rect.position+Vector2(138,49),"RELEASE TO CLOSE",12,Color(0.73,0.79,0.77,alpha))
	g.draw_line(rect.position+Vector2(12,59),rect.position+Vector2(12+486*(1-reminder_age/REMINDER_TIME),59),Color(1,0.65,0.25,alpha),2)

