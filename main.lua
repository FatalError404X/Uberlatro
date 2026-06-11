SMODS.Atlas{
    key = 'Enhancer',
    path = 'Enhancers.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Tarot2',
    path = 'Tarot2.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Decks',
    path = 'Decks.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Voucher',
    path = 'Vouchers.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Tags',
    path = 'Tags.png',
    px = 34,
    py = 34
}

SMODS.Atlas{
    key = 'LegendCons',
    path = 'LegendaryConsumable.png',
    px = 71,
    py = 95
}

SMODS.Gradient{
    key = 'Consumable_Grad',
    colours = {
        G.C.SECONDARY_SET.Tarot,
        G.C.SECONDARY_SET.Planet,
        G.C.SECONDARY_SET.Spectral
    }
}

SMODS.ConsumableType{
    key = 'LegendaryCons',
    primary_colour = HEX('08d5b7'),
    secondary_colour = SMODS.Gradients.Uber_Consumable_Grad,
    loc_txt = {
 		name = 'Legendary Consumable', 
 		collection = 'Legendary Consumables'
 	},
    collection_rows = {4, 4, 4}
}

-- Enhancements and Tarots Below

SMODS.Enhancement{
    key = 'NewEnhancer1',
    atlas = 'Enhancer',
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Bronze Card',
        text = {
            '{X:chips,C:white}X#1#{} chips',
            'while this card',
            'stays in hand'
        }
    },
    config = {
        h_x_chips = 1.5
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.h_x_chips
            }
        }
    end
}

SMODS.Consumable{
    key = 'NewTarot1',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = {x = 0, y = 0},
    cost = 3,
    rate = 2,
    loc_txt = {
        name = 'The Industry',
        text = {
            'Enhances {C:attention}#1#{}',
            'selected card to',
            '{C:attention}Bronze Card{}'
        }
    },
    config = {max_highlighted = 1, mod_conv = 'm_Uber_NewEnhancer1'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}

SMODS.Enhancement{
    key = 'NewEnhancer2',
    atlas = 'Enhancer',
    pos = {x = 1, y = 0},
    loc_txt = {
        name = 'Star Card',
        text = {
            '{C:money}+$#1#{}',
            '{C:mult}+#2#{} mult',
            '{X:chips,C:white}X#3#{} chips'
        }
    },
    config = {
        extra = {
            p_dollars = 1,
            s_mult = 3,
            x_chips = 1.2
        }
    },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            return {
                dollars = card.ability.extra.p_dollars,
                mult = card.ability.extra.s_mult,
                xchips = card.ability.extra.x_chips
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.p_dollars,
                card.ability.extra.s_mult,
                card.ability.extra.x_chips
            }
        }
    end
}

SMODS.Consumable{
    key = 'NewTarot2',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = {x = 1, y = 0},
    cost = 3,
    rate = 2,
    loc_txt = {
        name = 'The Award',
        text = {
            'Enhances {C:attention}#1#{}',
            'selected cards to',
            '{X:attention,C:white}Star Cards{}'
        }
    },
    config = {max_highlighted = 2, mod_conv = 'm_Uber_NewEnhancer2'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}

SMODS.Enhancement{
    key = 'NewEnhancer3',
    atlas = 'Enhancer',
    pos = {x = 2, y = 0},
    loc_txt = {
        name = 'Notepage',
        text = {
            '{C:chips}+5{} chips and {C:mult}+1{} mult',
            'when this card is scored',
            '{s:0.8,C:inactive}(currently +#1# chips and +#2# mult){}'
        }
    },
    config = {
        extra = {
            chips = 0,
            mult = 0,
            extra_chips = 5,
            extra_mult = 1
        }
    },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.extra_chips
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chips,
                card.ability.extra.mult
            }
        }
    end
}

SMODS.Consumable{
    key = 'NewTarot3',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = {x = 2, y = 0},
    cost = 3,
    rate = 2,
    loc_txt = {
        name = 'The Lecture',
        text = {
            'Enhances {C:attention}#1#{}',
            'selected cards to',
            '{C:attention}Notepages{}'
        }
    },
    config = {max_highlighted = 2, mod_conv = 'm_Uber_NewEnhancer3'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}

SMODS.Enhancement{
    key = 'NewEnhancer4',
    atlas = 'Enhancer',
    pos = {x = 3, y = 0},
    loc_txt = {
        name = 'Brick Card',
        text = {
            '{X:mult,C:white}+X0.1{} mult when',
            'this card is scored',
            '{s:0.8,C:inactive}(currently{} {S:0.8,X:mult,C:white}X#1#{} {S:0.8,C:inactive}mult){}'
        }
    },
    config = {
        extra = {
            x_mult = 1,
            extra_x_mult = 0.1
        }
    },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.extra_x_mult
            return {
                x_mult = card.ability.extra.x_mult
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.x_mult
            }
        }
    end
}

SMODS.Consumable{
    key = 'NewTarot4',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = {x = 3, y = 0},
    cost = 3,
    rate = 1,
    loc_txt = {
        name = 'The Mason',
        text = {
            'Enhances {C:attention}#1#{}',
            'selected card to',
            '{C:attention}Brick Card{}'
        }
    },
    config = {max_highlighted = 1, mod_conv = 'm_Uber_NewEnhancer4'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}

SMODS.Consumable {
    key = 'NewTarot5',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = { x = 4, y = 0 },
    cost = 4,
    rate = 1.5,
    loc_txt = {
        name = 'The Djinn',
        text = {
            'Creates up to {C:attention}#1#{}',
            'random {C:spectral}spectral{} card.',
            '{C:inactive}(Must have room){}'
        }
    },
    config = { extra = { spectral = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.spectral } }
    end,
    use = function(self, card, area, copier)
        for i = 1, math.min(card.ability.extra.spectral, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        SMODS.add_card({ set = 'Spectral', key_append = "vremade_pri" })
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit or
            (card.area == G.consumeables)
    end
}

SMODS.Enhancement{
    key = 'NewEnhancer5',
    atlas = 'Enhancer',
    pos = {x = 4, y = 0},
    loc_txt = {
        name = 'Balanced Card',
        text = {
            'Balances the Current',
            '{C:chips}Chips{} and {C:mult}Mult{} value',
            'when scored'
        }
    },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            return {
                balance = true,
            }
        end
    end
}

SMODS.Consumable{
    key = 'NewTarot6',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = {x = 0, y = 1},
    cost = 3,
    rate = 2,
    loc_txt = {
        name = 'Zen',
        text = {
            'Enhances {C:attention}#1#{}',
            'selected card to',
            '{C:attention}Balanced Card{}'
        }
    },
    config = {max_highlighted = 1, mod_conv = 'm_Uber_NewEnhancer5'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}

SMODS.Enhancement{
    key = 'NewEnhancer6',
    atlas = 'Enhancer',
    pos = {x = 0, y = 1},
    loc_txt = {
        name = 'Swapper Card',
        text = {
            'Swaps {C:chips}Chips{} and {C:mult}Mult{}',
            'when scored'
        }
    },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            return {
                swap = true,
            }
        end
    end
}

SMODS.Consumable{
    key = 'NewTarot7',
    atlas = 'Tarot2',
    set = 'Tarot',
    pos = {x = 1, y = 1},
    cost = 3,
    rate = 2,
    loc_txt = {
        name = 'The Exchange',
        text = {
            'Enhances {C:attention}#1#{}',
            'selected card to',
            '{C:attention}Swapper Card{}'
        }
    },
    config = {max_highlighted = 1, mod_conv = 'm_Uber_NewEnhancer6'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return { vars = { card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability(card.ability.mod_conv)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}

-- New Decks Below

SMODS.Back{
    key = 'UberDeck1',
    atlas = 'Decks',
    pos = {x = 3, y = 1},
    unlocked = true,
    loc_txt = {
        name = 'Maroon Deck',
        text = {
            '{C:attention}+#1#{} Joker Slot',
            '{C:attention}+#2#{} Hand Size',
            'Start at {C:red}#3#{} discards'
        }
    },
    config = {
        joker_slot = 1,
        hand_size = 2,
        discards = 0 
    },
    loc_vars = function(self, info_queue, back)
        return { 
            vars = {
                self.config.joker_slot,
                self.config.hand_size,
                self.config.discards
            } 
        }
    end,
    apply = function(self, back)
        G.GAME.starting_params.discards = G.GAME.starting_params.discards * self.config.discards
    end
}

SMODS.Back{
    key = 'UberDeck2',
    atlas = 'Decks',
    pos = {x = 1, y = 1},
    unlocked = true,
    loc_txt = {
        name = 'Navy Deck',
        text = {
            '{C:attention}+#1#{} Hand Size',
            'Start at {C:blue}#2#{} hand',
            'and with extra {C:money}$#3#{}'
        }
    },
    config = {
        hand_size = 5,
        hands = -3,
        bonus_hands = 1,
        dollars = 5
    },
    loc_vars = function(self, info_queue, back)
        return { 
            vars = {
                self.config.hand_size,
                self.config.bonus_hands,
                self.config.dollars
            } 
        }
    end
}

SMODS.Back{
    key = 'UberDeck3',
    atlas = 'Decks',
    pos = {x = 0, y = 1},
    unlocked = true,
    loc_txt = {
        name = 'Mustard Deck',
        text = {
            'Start with {C:attention}Clearance Sale{},',
            '{C:attention}Liquidation{}, and',
            '{C:money}$20{} in debt.'
        }
    },
    config = {
        dollars = -24,
        voucher1 = 'v_clearance_sale',
        voucher2 = 'v_liquidation'
    },
    apply = function(self, back)
        G.GAME.used_vouchers[self.config.voucher1] = true
        G.GAME.used_vouchers[self.config.voucher2] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 2
        G.E_MANAGER:add_event(Event({ 
            func = function()
                Card.apply_to_run(nil, G.P_CENTERS[self.config.voucher1])
                Card.apply_to_run(nil, G.P_CENTERS[self.config.voucher2])
                return true
            end
        }))
    end
}

SMODS.Back{
    key = 'UberDeck4',
    atlas = 'Decks',
    pos = {x = 3, y = 0},
    unlocked = true,
    loc_txt = {
        name = 'Tarotmancy Deck',
        text = {
            'Start with {C:attention}Tarot Merchant{} and',
            'a copy of both {C:attention}Cartomancer{}',
            'and {C:attention}Fortune Teller{}',
            '{C:red}#1#{} consumable slot'
        }
    },
    config = {
        consumable_slot = -1,
        voucher = 'v_tarot_merchant',
        jokers = {
            'j_cartomancer',
            'j_fortune_teller'
        }
    },
    loc_vars = function(self, info_queue, back)
        return { 
            vars = {
                self.config.consumable_slot
            } 
        }
    end,
    apply = function(self, back)
        G.GAME.used_vouchers[self.config.voucher] = true
        G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
        G.E_MANAGER:add_event(Event({ 
            func = function()
                Card.apply_to_run(nil, G.P_CENTERS[self.config.voucher])
                return true
            end
        }))
    end
}

-- New Blinds Below

-- will do these next update

-- New Jokers Below

SMODS.Joker{
    key = 'UberJoker1',
    atlas = 'Jokers',
    rarity = 3,
    discovered = true,
    pos = {x = 0, y = 0},
    enhancement_gate = 'm_Uber_NewEnhancer2',
    loc_txt = {
        name = 'Shooting Star',
        text = {
            '{C:blue}+#1#{} chips',
            'when a {X:attention,C:white}Star Card{} is scored',
            'Retrigger all played {X:attention,C:white}Star Cards{} once'
        }
    },
    config = {
        mod_conv = 'm_Uber_NewEnhancer2',
        extra = {
            chips = 30
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                card.ability.extra.chips
            }
        }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_Uber_NewEnhancer2') then
            return {
                chips = card.ability.extra.chips,
                repetitions = 1
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker2',
    atlas = 'Jokers',
    rarity = 2,
    discovered = true,
    pos = {x = 1, y = 0},
    enhancement_gate = 'm_Uber_NewEnhancer1',
    loc_txt = {
        name = 'Bronze Joker',
        text = {
            'Gives {X:blue,C:white}X#1#{} chips',
            'for each {C:attention}Bronze Card{}',
            'in your {C:attention}full deck{}',
            '{C:inactive}(currently{} {X:blue,C:white}X#2#{} {C:inactive}chips){}'
        }
    },
    config = {
        mod_conv = 'm_Uber_NewEnhancer1',
        extra = {
            xchips = 0.3,
            bonus_x_chips = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]

        local bronze_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_Uber_NewEnhancer1') then bronze_tally = bronze_tally + 1 end
            end
        end
        return { vars = { card.ability.extra.xchips, 1 + card.ability.extra.xchips * bronze_tally } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local bronze_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_Uber_NewEnhancer1') then bronze_tally = bronze_tally + 1 end
            end
            return {
                x_chips = 1 + card.ability.extra.xchips * bronze_tally,
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker3',
    atlas = 'Jokers',
    rarity = 3,
    discovered = true,
    pos = {x = 2, y = 0},
    enhancement_gate = 'm_Uber_NewEnhancer3',
    loc_txt = {
        name = 'Scholarly Notebook',
        text = {
            '{X:blue,C:white}+X#1#{} chips and {X:mult,C:white}+X#2#{} mult',
            'for each {C:attention}Notepage{}',
            'in the deck,',
            '{C:attention}Notepages{} count as any suit',
            '{C:inactive}(currently{} {X:blue,C:white}X#3#{} {C:inactive}chips and{} {X:mult,C:white}X#4#{} {C:inactive}mult){}'
        }
    },
    config = {
        mod_conv = 'm_Uber_NewEnhancer3',
        extra = {
            xchips = 0.1,
            xmult = 0.1
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]

        local note_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_Uber_NewEnhancer3') then note_tally = note_tally + 1 end
            end
        end
        return {
            vars = {
                card.ability.extra.xchips,
                card.ability.extra.xmult,
                1 + card.ability.extra.xchips * note_tally,
                1 + card.ability.extra.xmult * note_tally,
            }
        }
    end,
    calculate = function(self, card, context)
        local oldcardissuit = Card.is_suit
        function Card:is_suit(suit, bypass_debuff, flush_calc)
            local g = oldcardissuit(self, suit, bypass_debuff, flush_calc)
            if next(SMODS.find_card('j_Uber_UberJoker3')) and SMODS.has_enhancement(self, 'm_Uber_NewEnhancer3') then return true end
            return g
        end
        if context.joker_main then
            local note_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_Uber_NewEnhancer3') then note_tally = note_tally + 1 end
            end
            return {
                x_chips = 1 + card.ability.extra.xchips * note_tally,
                x_mult = 1 + card.ability.extra.xmult * note_tally
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker4',
    atlas = 'Jokers',
    rarity = 3,
    discovered = true,
    pos = {x = 3, y = 0},
    enhancement_gate = 'm_Uber_NewEnhancer4',
    loc_txt = {
        name = 'Break Through',
        text = {
            'Earn {C:money}$#1#{} when',
            'any number of {C:attention}Brick Cards{} are played',
            'Played {C:attention}Brick Cards{} also',
            'earn {C:money}+$#2#{} when scored'
        }
    },
    config = {
        mod_conv = 'm_Uber_NewEnhancer4',
        extra = {
            money = 3,
            bonus_money = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
        return {
            vars = {
                card.ability.extra.money,
                card.ability.extra.bonus_money
            }
        }
    end,
    calculate = function(self, card, context)
        if context.before then
            for _, playing_card in ipairs(G.play.cards) do
                if SMODS.has_enhancement(playing_card, 'm_Uber_NewEnhancer4') then 
                    playing_card.ability.perma_p_dollars = playing_card.ability.perma_p_dollars or 0
                    playing_card.ability.perma_p_dollars = playing_card.ability.perma_p_dollars + card.ability.extra.bonus_money
                    return {
                        p_dollars = card.ability.extra.money
                    }
                end
            end
        end
    end

}

-- New Vouchers Below

SMODS.Voucher{
    key = 'UberVoucher1',
    atlas = 'Voucher',
    cost = 15,
    rate = 2,
    discovered = true,
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Pizza For Two',
        text = {
            'Adds a second {C:attention}Voucher{}',
            'Every {C:attention}Ante{}'
        }
    },
    config = {
        extra = {
            voucher_limit = 1
        }
    },
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.change_voucher_limit(card.ability.extra.voucher_limit)
                return true
            end
        }))
    end
}

SMODS.Voucher{
    key = 'UberVoucher2',
    atlas = 'Voucher',
    cost = 15,
    rate = 2,
    discovered = true,
    requires = {'v_Uber_UberVoucher1'},
    pos = {x = 1, y = 0},
    loc_txt = {
        name = 'Lost In The Sauce',
        text = {
            'Adds an additional',
            'third {C:attention}Voucher{}',
            'Every {C:attention}Ante{}'
        }
    },
    config = {
        extra = {
            voucher_limit = 1
        }
    },
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.change_voucher_limit(card.ability.extra.voucher_limit)
                return true
            end
        }))
    end
}

SMODS.Voucher{
    key = 'UberVoucher3',
    atlas = 'Voucher',
    cost = 15,
    rate = 2,
    discovered = true,
    pos = {x = 2, y = 0},
    loc_txt = {
        name = 'Hoarding',
        text = {
            'Adds an additional',
            '{C:attention}Booster Pack{}',
            'To the store'
        }
    },
    config = {
        extra = {
            booster_limit = 1
        }
    },
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.change_booster_limit(card.ability.extra.booster_limit)
                return true
            end
        }))
    end
}

SMODS.Voucher{
    key = 'UberVoucher4',
    atlas = 'Voucher',
    cost = 15,
    rate = 2,
    discovered = true,
    pos = {x = 3, y = 0},
    requires = {'v_Uber_UberVoucher3'},
    loc_txt = {
        name = 'Scalping',
        text = {
            'Adds an additional',
            '{C:attention}Booster Pack{}',
            'To the store',
            '{C:red}#1#{} Hand Size'
        }
    },
    config = {
        extra = {
            size = -1,
            voucher_limit = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.size } }
    end,
    redeem = function(self, card)
        G.hand:change_size(card.ability.extra.size)
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.change_voucher_limit(card.ability.extra.voucher_limit)
                return true
            end
        }))
    end
}

-- New Tags Below

SMODS.Tag{
    key = 'UberTag1',
    atlas = 'Tags',
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Silence Tag',
        text = {
            'Disables the next',
            '{C:attention}Boss Blind{}'
        }
    },
    apply = function(self, tag, context)
        if context.type == 'round_start_bonus' then
            if G.GAME.blind.boss then
                tag:yep('X', G.C.BLACK, function()
                    return true
                end)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.blind:disable()
                                play_sound('timpani')
                                delay(0.4)
                                return true
                            end
                        }))
                        return true
                    end
                }))
                tag.triggered = true
                return true
            end
        end
    end
}

SMODS.Tag{
    key = 'UberTag2',
    atlas = 'Tags',
    pos = {x = 1, y = 0},
    loc_txt = {
        name = 'Trashbag Tag',
        text = {
            '{C:red}+#1#{} discard',
            'next round'
        }
    },
    config = {
        discards = 1
    },
    loc_vars = function(self, info_queue, tag)
        return { 
            vars = {
                tag.config.discards
            } 
        }
    end,
    apply = function(self, tag, context)
        if context.type == 'round_start_bonus' then
            tag:yep('+', G.C.RED, function()
                return true
            end)
            G.GAME.round_resets.temp_discards = (G.GAME.round_resets.discards or 0) + tag.config.discards
            ease_discard(tag.config.discards)
            tag.triggered = true
            return true
        end
    end
}

SMODS.Tag{
    key = 'UberTag3',
    atlas = 'Tags',
    pos = {x = 2, y = 0},
    loc_txt = {
        name = 'Thumbs Up Tag',
        text = {
            '{C:blue}+#1#{} hand',
            'next round'
        }
    },
    config = {
        hands = 1
    },
    loc_vars = function(self, info_queue, tag)
        return { 
            vars = {
                tag.config.hands
            } 
        }
    end,
    apply = function(self, tag, context)
        if context.type == 'round_start_bonus' then
            tag:yep('+', G.C.BLUE, function()
                return true
            end)
            G.GAME.round_resets.temp_hands = (G.GAME.round_resets.hands or 0) + tag.config.hands
            ease_hands_played(tag.config.hands)
            tag.triggered = true
            return true
        end
    end
}

SMODS.Tag{
    key = 'UberTag4',
    atlas = 'Tags',
    pos = {x = 0, y = 1},
    loc_txt = {
        name = 'Booster Tag',
        text = {
            'Adds an additional',
            '{C:attention}Booster Pack{}',
            'to the next store'
        }
    },
    apply = function(self, tag, context)
        if context.type == 'voucher_add' then
            tag:yep('+', G.C.SECONDARY_SET.spectral, function()
                local booster = SMODS.add_booster_to_shop(nil, true)
                booster.from_tag = true
                return true
            end)
            tag.triggered = true
        end
    end
}

-- Legendary Consumables Below

SMODS.Consumable{
    key = 'LegendaryPlanet1',
    atlas = 'LegendCons',
    set = 'LegendaryCons',
    pos = {x = 0, y = 2},
    cost = 20,
    discovered = true,
    loc_txt = {
        name = 'Indra',
        text = {
            'Levels up {C:attention}Pair{},',
            '{C:attention}Three of a Kind{}, and {C:attention}Full House{}',
            'by three levels each.'
        }
    },
    config = {
        hand_type1 = 'Pair',
        hand_type2 = 'Three of a Kind',
        hand_type3 = 'Full House',
        levels = 3
    },
    hidden = {
        soul_set = 'Planet',
        soul_rate = 0.02,
        can_repeat_soul = true
    },
    use = function(self, card, area, copier)
        SMODS.upgrade_poker_hands({ from = card, hands = { card.ability.hand_type1, card.ability.hand_type2, card.ability.hand_type3 }, level_up = card.ability.levels })
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
    end
}

SMODS.Consumable{
    key = 'LegendaryPlanet2',
    atlas = 'LegendCons',
    set = 'LegendaryCons',
    pos = {x = 1, y = 2},
    cost = 20,
    discovered = true,
    loc_txt = {
        name = 'Mesolon',
        text = {
            'Levels up {C:attention}Four of a Kind{},',
            '{C:attention}Flush{}, and {C:attention}Flush House{}',
            'by three levels each.'
        }
    },
    config = {
        hand_type1 = 'Four of a Kind',
        hand_type2 = 'Flush',
        hand_type3 = 'Flush House',
        levels = 3
    },
    hidden = {
        soul_set = 'Planet',
        soul_rate = 0.02,
        can_repeat_soul = true
    },
    use = function(self, card, area, copier)
        SMODS.upgrade_poker_hands({ from = card, hands = { card.ability.hand_type1, card.ability.hand_type2, card.ability.hand_type3 }, level_up = card.ability.levels })
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
    end
}

SMODS.Consumable{
    key = 'LegendaryPlanet3',
    atlas = 'LegendCons',
    set = 'LegendaryCons',
    pos = {x = 2, y = 2},
    cost = 20,
    discovered = true,
    loc_txt = {
        name = 'Exodium',
        text = {
            'Levels up {C:attention}Straight{},',
            '{C:attention}Two Pair{}, and {C:attention}Straight Flush{}',
            'by three levels each.'
        }
    },
    config = {
        hand_type1 = 'Straight',
        hand_type2 = 'Two Pair',
        hand_type3 = 'Straight Flush',
        levels = 3
    },
    hidden = {
        soul_set = 'Planet',
        soul_rate = 0.02,
        can_repeat_soul = true
    },
    use = function(self, card, area, copier)
        SMODS.upgrade_poker_hands({ from = card, hands = { card.ability.hand_type1, card.ability.hand_type2, card.ability.hand_type3 }, level_up = card.ability.levels })
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
    end
}

SMODS.Consumable{
    key = 'LegendaryPlanet4',
    atlas = 'LegendCons',
    set = 'LegendaryCons',
    pos = {x = 3, y = 2},
    cost = 20,
    discovered = true,
    loc_txt = {
        name = 'Lostlow',
        text = {
            'Levels up {C:attention}High Card{},',
            '{C:attention}Five of a Kind{}, and {C:attention}Flush Five{}',
            'by three levels each.'
        }
    },
    config = {
        hand_type1 = 'High Card',
        hand_type2 = 'Five of a Kind',
        hand_type3 = 'Flush Five',
        levels = 3
    },
    hidden = {
        soul_set = 'Planet',
        soul_rate = 0.02,
        can_repeat_soul = true
    },
    use = function(self, card, area, copier)
        SMODS.upgrade_poker_hands({ from = card, hands = { card.ability.hand_type1, card.ability.hand_type2, card.ability.hand_type3 }, level_up = card.ability.levels })
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables)
    end
}