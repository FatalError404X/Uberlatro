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
    key = 'Spectral2',
    path = 'Spectral2.png',
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
    key = 'Blinds',
    path = 'Blinds.png',
    px = 34,
    py = 34,
    atlas_table ='ANIMATION_ATLAS',
    frames = 21,
    fps = 10
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


Uberlatro = SMODS.current_mod

Uberlatro.optional_features = {
    retrigger_joker = true,
    post_trigger = true,
    quantum_enhancements = true,
    object_weights = true,
    cardareas = {
        discard = true,
        deck = true
    }
}

Uberlatro.set_debuff = function(card)
    if card and card.seal and card.seal == 'Uber_UberSeal1' then return 'prevent_debuff' end
end

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

SMODS.Consumable{
    key = 'NewTarot8',
    set = 'Tarot',
    atlas = 'Tarot2',
    cost = 5,
    pos = {x = 2, y = 1},
    loc_txt = {
        name = 'The Interest',
        text = {
            'Gain {C:money}$#1#{} of sell value',
            'after each round,',
            'Earn 1/2 of previous',
            'sell value at end of round.'
        }
    },
    config = {
        extra = {
            money = 2
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = {
                card.ability.extra.money
            } 
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            -- See note about SMODS Scaling Manipulation on the wiki
            card.ability.extra_value = card.ability.extra_value + card.ability.extra.money
            card:set_cost()
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY
            }
        end
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra_value / 2
    end
}

-- Seals and Spectral cards below

SMODS.Seal{
    key = 'UberSeal1',
    atlas = 'Enhancer',
    pos = {x = 1, y = 1},
    badge_colour = HEX('A17A2B'),
    loc_txt = {
        name = 'Oaken Seal',
        label = 'Oak Seal',
        text = {
            'This card is immune',
            'to {C:red}Debuffs{}'
        }
    },
    sound = { sound = 'timpani', per = 0.9, vol = 0.9 }
}

SMODS.Consumable{
    key = 'UberSpectral1',
    set = 'Spectral',
    atlas = 'Spectral2',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Permanence',
        text = {
            'Add an {C:attention}Oaken Seal{}',
            'to {C:attention}#1#{} selected',
            'card in your hand'
        }
    },
    config = { extra = { seal = 'Uber_UberSeal1' }, max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        local conv_card = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                conv_card:set_seal(card.ability.extra.seal, nil, true)
                return true
            end
        }))

        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end
}

SMODS.Consumable{
    key = 'UberSpectral2',
    set = 'Spectral',
    atlas = 'Spectral2',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Rift',
        text = {
            'Add {C:dark_edition}Negative{} effect to',
            '{C:attention}#1#{} selected card in hand'
        }
    },
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local rift_card = G.hand.highlighted[1]
                rift_card:set_edition('e_negative', true)
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted <= card.ability.max_highlighted and #G.hand.highlighted > 0 and
            (not G.hand.highlighted[1].edition)
    end
}

SMODS.Consumable{
    key = 'UberSpectral3',
    set = 'Spectral',
    atlas = 'Spectral2',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'Vision',
        text = {
            'Create up to {C:attention}#1#{}',
            'Spectral cards',
            '{C:inactive}(Must have room){}'
        }
    },
    config = { extra = { spectrals = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.spectrals } }
    end,
    use = function(self, card, area, copier)
        for i = 1, math.min(card.ability.extra.spectrals, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        SMODS.add_card({ set = 'Spectral' })
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return (G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit) or
            (card.area == G.consumeables)
    end
}

SMODS.Seal{
    key = 'UberSeal2',
    atlas = 'Enhancer',
    unlocked = true,
    discovered = true,
    badge_colour = HEX('990a0a'),
    pos = {x = 2, y = 1},
    loc_txt = {
        name = 'Laughing Seal',
        text = {
            '{C:green}#1# in #2#{} chance to create a',
            'random {C:attention}Joker{} when scored.'
        },
        label = 'Laughing Seal'
    },
    config = {
        extra = {
            numerator = 1,
            denominator = 7
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                self.config.extra.numerator,
                self.config.extra.denominator 
            } 
        }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            if SMODS.pseudorandom_probability(card, 'UberSeal2', self.config.extra.numerator, self.config.extra.denominator) then
                if G.jokers.config.card_limit > #G.jokers.cards then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        func = function()
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Joker', area = G.jokers, })
                            return {
                                message = 'Hahaha!',
                                colour = HEX('990a0a'),
                                delay = 0.3,
                                true
                            }
                        end
                    }))
                else 
                    return {
                        message = 'No Room!',
                        colour = G.C.ATTENTION,
                        delay = 0.3
                    }
                end
            end
        end
    end
}

SMODS.Consumable{
    key = 'UberSpectral4',
    set = 'Spectral',
    atlas = 'Spectral2',
    pos = { x = 0, y = 1 },
    loc_txt = {
        name = 'Haze',
        text = {
            'Add a {C:attention}Laughing Seal{}',
            'to {C:attention}#1#{} selected',
            'card in your hand'
        }
    },
    config = { extra = { seal = 'Uber_UberSeal2' }, max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        local conv_card = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                conv_card:set_seal(card.ability.extra.seal, nil, true)
                return true
            end
        }))

        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
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

SMODS.Blind{
    key = 'UberBlind1',
    atlas = 'Blinds',
    pos = { y = 0 },
    loc_txt = {
        name = 'The Power',
        text = {
            'All enhanced cards',
            'are debuffed'
        }
    },
    dollars = 5,
    mult = 2,
    boss = { min = 1 },
    boss_colour = HEX("ee0000"),
    calculate = function(self, blind, context)
        if blind.disabled then return end
        if context.debuff_card and context.debuff_card.area ~= G.jokers then
            if next(SMODS.get_enhancements(context.debuff_card)) then
                return {
                    debuff = true
                }
            end
        end
    end
}

SMODS.Blind{
    key = 'UberBlind2',
    atlas = 'Blinds',
    pos = { y = 1 },
    loc_txt = {
        name = 'The Weed',
        text = {
            'All Non Face cards',
            'are debuffed'
        }
    },
    dollars = 5,
    mult = 2,
    boss = { min = 3 },
    boss_colour = HEX("1b9f07"), 
    calculate = function(self, blind, context)
        if context.debuff_card and context.debuff_card.area ~= G.jokers and not context.debuff_card:is_face(true) then
            return {
                debuff = true
            }
        end
    end
}

SMODS.Blind{
    key = 'UberBlind3',
    atlas = 'Blinds',
    pos = { y = 2 },
    loc_txt = {
        name = 'The Bucket',
        text = {
            '{C:green}#1# in #2#{} cards get',
            'drawn debuffed'
        }
    },
    dollars = 5,
    mult = 2,
    boss = { min = 2 },
    boss_colour = HEX("56018b"),
    config = {
        extra = {
            numerator = 1,
            denominator = 6
        }
    },
    loc_vars = function(self)
        return { vars = { card.ability.extra.numerator, card.ability.extra.denominator } }
    end,
    collection_loc_vars = function(self)
        return { vars = { '1' } }
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end
        if context.debuff_card and context.debuff_card.area ~= G.jokers and SMODS.pseudorandom_probability(blind, 'Uber_UberBlind3', 1, 6) then
            return {
                debuff = true
            }
        end
    end
}

SMODS.Blind{
    key = 'UberBlind4',
    atlas = 'Blinds',
    pos = { y = 3 },
    loc_txt = {
        name = 'The Oddity',
        text = {
            'All Odd cards',
            'are debuffed'
        }
    },
    dollars = 5,
    mult = 2,
    boss = { min = 1 },
    boss_colour = HEX("cbcc83"),
    calculate = function(self, blind, context)
        if blind.disabled then return end
        if context.debuff_card and context.debuff_card.area ~= G.jokers then
            local id = context.debuff_card:get_id()
            if (id <= 10 and id >= 0 and id % 2 == 1) or (id == 14) then
                return {
                    debuff = true
                }
            end
        end
    end
}

SMODS.Blind{
    key = 'UberBlind5',
    atlas = 'Blinds',
    pos = { y = 4 },
    loc_txt = {
        name = 'The Evening',
        text = {
            'All Even cards',
            'are debuffed'
        }
    },
    dollars = 5,
    mult = 2,
    boss = { min = 1 },
    boss_colour = HEX("cbcc83"),
    calculate = function(self, blind, context)
        if blind.disabled then return end
        if context.debuff_card and context.debuff_card.area ~= G.jokers then
            local id = context.debuff_card:get_id()
            if id <= 10 and id >= 0 and id % 2 == 0 then
                return {
                    debuff = true
                }
            end
        end
    end
}

SMODS.Blind{
    key = 'UberBlind6',
    atlas = 'Blinds',
    pos = { y = 5 },
    loc_txt = {
        name = 'The Lesser',
        text = {
            '-#1# hand',
            '-#2# discard'
        }
    },
    config = {
        extra = {
            subtraction = 1
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.subtraction, self.config.extra.subtraction } }
    end,
    dollars = 5,
    mult = 2,
    boss = { min = 1 },
    boss_colour = HEX("ec5800"),
    calculate = function(self, blind, context)
        if context.blind_disabled then
            ease_discard(blind.effect.discards_sub)
            ease_hands_played(blind.effect.hands_sub)
        end

        if blind.disabled then return end

        if context.setting_blind then
            blind.effect.discards_sub = self.config.extra.subtraction
            blind.effect.hands_sub = self.config.extra.subtraction
            ease_discard(-blind.effect.discards_sub)
            ease_hands_played(-blind.effect.hands_sub)
        end
    end
}

SMODS.Blind{
    key = 'UberBossBlind1',
    atlas = 'Blinds',
    pos = { y = 6 },
    loc_txt = {
        name = 'Greater Grime',
        text = {
            'Greater Difficulty',
            'Less hands and discards'
        }
    },
    dollars = 8,
    mult = 3,
    boss = { showdown = true },
    boss_colour = HEX("344019"),
    config = {
        extra = {
            subtraction = 2
        }
    },
    calculate = function(self, blind, context)
        if context.blind_disabled then
            ease_discard(blind.effect.discards_sub)
            ease_hands_played(blind.effect.hands_sub)
        end

        if blind.disabled then return end

        if context.setting_blind then
            blind.effect.discards_sub = self.config.extra.subtraction
            blind.effect.hands_sub = self.config.extra.subtraction
            ease_discard(-blind.effect.discards_sub)
            ease_hands_played(-blind.effect.hands_sub)
        end
    end
}

SMODS.Blind{
    key = 'UberBossBlind2',
    atlas = 'Blinds',
    pos = { y = 7 },
    loc_txt = {
        name = 'Citric Cleanse',
        text = {
            'Enhancements and Seals are removed',
            'from cards before scoring'
        }
    },
    dollars = 8,
    mult = 1.5,
    boss = { showdown = true },
    boss_colour = HEX("ec5800"),
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.press_play then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i = 1, #G.play.cards do
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.play.cards[i]:juice_up()
                                return true
                            end
                        }))
                        G.play.cards[i]:set_seal(nil, false, true)
                        G.play.cards[i]:set_ability('c_base', false, true)
                        delay(0.23)
                    end
                    return true
                end
            }))
            blind.triggered = true 
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = (function()
                    SMODS.juice_up_blind()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.06 * G.SETTINGS.GAMESPEED,
                        blockable = false,
                        blocking = false,
                        func = function()
                            play_sound('tarot2', 0.76, 0.4)
                            return true
                        end
                    }))
                    play_sound('tarot2', 1, 0.4)
                    return true
                end)
            }))
            delay(0.4)
        end
    end
}

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
    rarity = 2,
    cost = 6,
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
    rarity = 2,
    cost = 7,
    discovered = true,
    pos = {x = 3, y = 0},
    enhancement_gate = {'m_Uber_NewEnhancer4'},
    loc_txt = {
        name = 'Lone Construct',
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

SMODS.Joker{
    key = 'UberJoker5',
    atlas = 'Jokers',
    rarity = 1,
    cost = 2,
    discovered = true,
    pos = {x = 4, y = 0},
    loc_txt = {
        name = 'Magician',
        text = {
            '{C:chips}+#1#{} chips',
            '{C:inactive,s:0.8}Full Name: Malarkey M. Magician{}'
        }
    },
    config = {
        extra = {
            chips = 40
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chips
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker6',
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    discovered = true,
    pos = {x = 0, y = 1},
    loc_txt = {
        name = 'Cursed Spade',
        text = {
            'This card gains {C:chips}+#1#{} chips',
            'for each {C:attention}Ace{} of {C:spades}Spades{}',
            'in your {C:attention}full deck{}',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}chips){}'
        }
    },
    config = {
        extra = {
            chips = 70,
            suit = 'Spades'
        }
    },
    loc_vars = function(self, info_queue, card)
        local ace_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
        end
        return {
            vars = {
                card.ability.extra.chips,
                card.ability.extra.chips * ace_tally
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ace_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
            return {
                chips = card.ability.extra.chips * ace_tally
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker6',
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    discovered = true,
    pos = {x = 0, y = 1},
    loc_txt = {
        name = 'Cursed Spade',
        text = {
            'This card gains {C:chips}+#1#{} chips',
            'for each {C:attention}Ace{} of {C:spades}Spades{}',
            'in your {C:attention}full deck{}',
            '{C:inactive}(Currently{} {C:chips}+#2#{} {C:inactive}chips){}'
        }
    },
    config = {
        extra = {
            chips = 70,
            suit = 'Spades'
        }
    },
    loc_vars = function(self, info_queue, card)
        local ace_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
        end
        return {
            vars = {
                card.ability.extra.chips,
                card.ability.extra.chips * ace_tally
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ace_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
            return {
                chips = card.ability.extra.chips * ace_tally
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker7',
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    discovered = true,
    pos = {x = 1, y = 1},
    loc_txt = {
        name = 'Brilliant Diamond',
        text = {
            'Earn {C:money}$#1#{} for each',
            '{C:attention}Ace{} of {C:diamonds}Diamonds{} in your {C:attention}full deck{}',
            'at end of round',
            '{C:inactive}(Currently{} {C:money}+$#2#{}{C:inactive}){}'
        }
    },
    config = {
        extra = {
            dollars = 4,
            suit = 'Diamonds'
        }
    },
    loc_vars = function(self, info_queue, card)
        local ace_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
        end
        return {
            vars = {
                card.ability.extra.dollars,
                card.ability.extra.dollars * ace_tally
            }
        }
    end,
    calc_dollar_bonus = function(self, card)
        local ace_tally = 0
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then 
                ace_tally = ace_tally + 1 
            end
        end
        return ace_tally > 0 and card.ability.extra.dollars * ace_tally or nil
    end
}

SMODS.Joker{
    key = 'UberJoker8',
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    discovered = true,
    pos = {x = 2, y = 1},
    loc_txt = {
        name = 'Broken Heart',
        text = {
            'This card gains {X:mult,C:white}+X#1#{} mult',
            'for each {C:attention}Ace{} of {C:hearts}Hearts{}',
            'in your {C:attention}full deck{}',
            '{C:inactive}(Currently{} {X:mult,C:white}X#2#{} {C:inactive}mult){}'
        }
    },
    config = {
        extra = {
            xmult = 0.6,
            suit = 'Hearts'
        }
    },
    loc_vars = function(self, info_queue, card)
        local ace_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
        end
        return {
            vars = {
                card.ability.extra.xmult,
                1 + card.ability.extra.xmult * ace_tally
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ace_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
            return {
                x_mult = 1 + card.ability.extra.xmult * ace_tally
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker9',
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    discovered = true,
    pos = {x = 3, y = 1},
    loc_txt = {
        name = 'Overgrown Club',
        text = {
            'This card gains {C:mult}+#1#{} mult',
            'for each {C:attention}Ace{} of {C:clubs}Clubs{}',
            'in your {C:attention}full deck{}',
            '{C:inactive}(Currently{} {C:mult}+#2#{} {C:inactive}mult){}'
        }
    },
    config = {
        extra = {
            mult = 12,
            suit = 'Clubs'
        }
    },
    loc_vars = function(self, info_queue, card)
        local ace_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
        end
        return {
            vars = {
                card.ability.extra.mult,
                card.ability.extra.mult * ace_tally
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ace_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card:get_id() == 14 and playing_card:is_suit(card.ability.extra.suit) then ace_tally = ace_tally + 1 end
            end
            return {
                mult = card.ability.extra.mult * ace_tally
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker10',
    atlas = 'Jokers',
    rarity = 3,
    cost = 12,
    discovered = true,
    blueprint_compat = false,
    pos = {x = 4, y = 1},
    loc_txt = {
        name = 'Bingo Card',
        text = {
            'After {C:attention}#1#{} {C:inactive}(#2#){} cards played,',
            'receive a random {C:attention,E:1}PRIZE!{}',
            '{C:green}#3# in #4#{} chance for card count',
            'to reset after each hand'
        }
    },
    config = {
        extra = {
            cards = 24,
            current_cards = 0,
            numerator = 1,
            denominator = 6,
            dollars = 15,
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.cards, 
                card.ability.extra.current_cards, 
                card.ability.extra.numerator, 
                card.ability.extra.denominator,
                
            } 
        }
    end,
    calculate = function(self, card, context)
        local money_gain = false
        if context.before and context.full_hand then
            card.ability.extra.current_cards = card.ability.extra.current_cards + #context.full_hand
            if SMODS.pseudorandom_probability(card, 'UberJoker10', card.ability.extra.numerator, card.ability.extra.denominator) then
                card.ability.extra.current_cards = 0
                return {
                    message = 'Unlucky!',
                    colour = G.C.RED,
                    delay = 0.3,
                    nil,
                    true
                }
            end
            if card.ability.extra.current_cards >= card.ability.extra.cards then
                card.ability.extra.current_cards = card.ability.extra.current_cards - card.ability.extra.cards
                money_gain = true
                if SMODS.pseudorandom_probability(card, 'UberJoker10', 1, 12) then
                    SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 2, edition = 'e_negative' })
                    SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 3, edition = 'e_negative' })
                end
                if SMODS.pseudorandom_probability(card, 'UberJoker10', 1, 8) then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Spectral', edition = 'e_negative' })
                            SMODS.add_card({ set = 'Spectral', edition = 'e_negative' })
                            SMODS.add_card({ set = 'Spectral', edition = 'e_negative' })
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                if SMODS.pseudorandom_probability(card, 'UberJoker10', 1, 5) then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Tarot', edition = 'e_negative' })
                            SMODS.add_card({ set = 'Tarot', edition = 'e_negative' })
                            SMODS.add_card({ set = 'Tarot', edition = 'e_negative' })
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                if SMODS.pseudorandom_probability(card, 'UberJoker10', 1, 3) then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Planet', edition = 'e_negative' })
                            SMODS.add_card({ set = 'Planet', edition = 'e_negative' })
                            SMODS.add_card({ set = 'Planet', edition = 'e_negative' })
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                return {
                    message = "BINGO!",
                    colour = G.C.GOLD,
                    delay = 0.3,
                    dollars = card.ability.extra.dollars
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'UberJoker11',
    atlas = 'Jokers',
    rarity = 2,
    cost = 5,
    discovered = true,
    blueprint_compat = true,
    pos = {x = 2, y = 2},
    loc_txt = {
        name = {
            'Steak in the',
            'shape of Jimbo'
        },
        text = {
            '{C:mult}+#1#{} mult',
            '{C:mult}-#2#{} mult when any',
            '{C:attention}consumable{} is used'
        }
    },
    config = {
        extra = {
            mult = 60,
            subtraction = 10
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.mult, 
                card.ability.extra.subtraction
            } 
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then 
            if card.ability.extra.mult - card.ability.extra.subtraction <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.RED
                }
            else
                card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.subtraction
                return {
                    message = localize { type = 'variable', key = 'a_mult_minus', vars = { card.ability.extra.subtraction } },
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker12',
    atlas = 'Jokers',
    rarity = 2,
    cost = 12,
    discovered = true,
    pos = {x = 3, y = 2},
    loc_txt = {
        name = 'Conspiracy Theorist',
        text = {
            'Retrigger all played {C:dark_edition}Foil Edition{}',
            'cards and Jokers {C:inactive}(excluding self){}',
            'This joker is always {C:dark_edition}Foil{}'
        }
    },
    calculate = function(self, card, context)
        if context.retrigger_joker_check and (context.other_card.edition or {}).foil and context.other_card ~= card then
            return {
                repetitions = 1
            }
        end
        if context.repetition and context.cardarea == G.play and (context.other_card.edition or {}).foil then
            return {
                repetitions = 1
            }
        end
    end,
    set_ability = function (self, card)
        card:set_edition("e_foil")
    end
}

SMODS.Joker{
    key = 'UberJoker13',
    atlas = 'Jokers',
    rarity = 2,
    cost = 8,
    discovered = true,
    pos = {x = 4, y = 2},
    loc_txt = {
        name = 'Lost Black Card',
        text = {
            '{C:gold,E:1}Doesnt Take Up Space{}',
            '{C:attention}+#1#{} Joker Slot',
            '{C:red}#2#{} Hand'
        }
    },
    config = {
        extra_slots_used = -1,
        card_limit = 1,
        extra = {
            hands = -1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.card_limit,
                card.ability.extra.hands
            } 
        }
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
        ease_hands_played(-card.ability.extra.hands)
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
        ease_hands_played(card.ability.extra.hands)
    end
}

SMODS.Joker{
    key = 'UberJoker14',
    atlas = 'Jokers',
    rarity = 2,
    cost = 8,
    discovered = true,
    pos = {x = 2, y = 3},
    loc_txt = {
        name = 'Linear Joker',
        text = {
            'If scored hand is a',
            '{C:attention}Straight Flush{}, earn {C:money}$15{}'
        }
    },
    config = {
        extra = {
            dollars = 15
        }
    },
    calculate = function(self, card, context)
        if context.before and next(context.poker_hands['Straight Flush']) then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end
}

SMODS.Joker{
    key = 'UberJoker15',
    atlas = 'Jokers',
    rarity = 2,
    cost = 8,
    discovered = true,
    pos = {x = 3, y = 3},
    loc_txt = {
        name = 'Ferrous Flow',
        text = {
            '{C:attention}Gold{} and {C:attention}Bronze{} cards',
            'held in hand give',
            '{X:mult,C:white}X#1#{} Mult'
        }
    },
    config = {
        extra = {
            x_mult = 1.5
        }
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.x_mult
            } 
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if SMODS.has_enhancement(context.other_card, 'm_gold') or SMODS.has_enhancement(context.other_card, 'm_Uber_NewEnhancer1') then
                return {
                    x_mult = card.ability.extra.x_mult
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'UberJoker16',
    atlas = 'Jokers',
    rarity = 1,
    cost = 4,
    discovered = true,
    pos = {x = 4, y = 3},
    loc_txt = {
        name = 'Blank Joker',
        text = {
            'Create a random {C:attention}Joker{}',
            'when sold'
        }
    },
    calculate = function(self, card, context)
        if context.selling_card and context.card then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    play_sound('timpani')
                    SMODS.add_card({ set = 'Joker', area = G.jokers, })
                    return true
                end
            }))
        end
    end
}

SMODS.Joker{
    key = 'UberLegend1',
    atlas = 'Jokers',
    rarity = 4,
    cost = 20,
    discovered = false,
    blueprint_compat = false,
    pos = {x = 0, y = 2},
    soul_pos = {x = 0, y = 3},
    loc_txt = {
        name = 'Vestea',
        text = {
            '{X:edition,C:dark_edition,s:1.2}^#1#{} {C:mult}Mult{} and {X:edition,C:dark_edition,s:1.2}^#2#{} {C:chips}Chips{}',
            'if your full deck contains',
            'at least {C:attention}6{} {C:inactive}(#3#){} {C:gold}Gold Cards{}',
            '{C:inactive,s:0.8}This joker stands alone{}'
        }
    },
    config = {
        extra = {
            e_mult = 1.618,
            e_chips = 1.618,
        }
    },
    loc_vars = function(self, info_queue, card)
        local gold_tally = 0
        for _, playing_card in pairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, "m_gold") then gold_tally = gold_tally + 1 end
        end
        return {
            vars = {
                card.ability.extra.e_mult,
                card.ability.extra.e_chips,
                gold_tally
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local gold_tally = 0
            for _, playing_card in pairs(G.playing_cards or {}) do
                if SMODS.has_enhancement(playing_card, "m_gold") then gold_tally = gold_tally + 1 end
            end
            if gold_tally >= 6 then
                return {
                    emult = card.ability.extra.e_mult,
                    echips = card.ability.extra.e_chips
                }
            end
        end
        if #SMODS.find_card(self.key) >= 2 and context.debuff_card and context.debuff_card == card then
            return {debuff = true}
        end
    end
}

SMODS.Joker{
    key = 'UberLegend2',
    atlas = 'Jokers',
    rarity = 4,
    cost = 20,
    discovered = false,
    blueprint_compat = true,
    pos = {x = 1, y = 2},
    soul_pos = {x = 1, y = 3},
    loc_txt = {
        name = 'Foole',
        text = {
            '{X:chips,C:white}+X#1#{} Chips for each {C:tarot}Tarot{} card used',
            '{X:mult,C:white}+X#2#{} Mult for each {C:spectral}Spectral{} card used',
            '{C:money}+$#3#{} for each {C:planet}Planet{} card used',
            '{C:red}#4#{} to {C:chips}XChips{} and {C:mult}XMult{} and',
            '{C:red}#5#{} {C:money}dollars{} every ante',
            '{C:inactive}(currently{} {X:chips,C:white}X#6#{} {C:inactive}chips,{} {X:mult,C:white}X#7#{} {C:inactive}mult, and{} {C:money}+$#8#{} {C:inactive}){}'
        }
    },
    config = {
        extra = {
            x_chips = 1,
            x_mult = 1,
            dollars = 1,
            subtraction1 = -0.5,
            subtraction2 = -1,
            current_x_chips = 1,
            current_x_mult = 1,
            current_dollars = 0,
        }
    },
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == 'Tarot' then
            card.ability.extra.current_x_chips = card.ability.extra.current_x_chips + card.ability.extra.x_chips
            return {
                message = 'XChips!',
                colour = G.C.CHIPS,
                delay = 0.2
            }
        end
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == 'Spectral' then
            card.ability.extra.current_x_mult = card.ability.extra.current_x_mult + card.ability.extra.x_mult
            return {
                message = 'XMult!',
                colour = G.C.MULT,
                delay = 0.2
            }
        end
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == 'Planet' then
            card.ability.extra.current_dollars = card.ability.extra.current_dollars + card.ability.extra.dollars
            return {
                message = 'Dollars!',
                colour = G.C.MONEY,
                delay = 0.2
            }
        end
        if context.ante_change and not context.blueprint and context.ante_end == true then
            card.ability.extra.current_x_chips = card.ability.extra.current_x_chips + card.ability.extra.subtraction1
            card.ability.extra.current_x_mult = card.ability.extra.current_x_mult + card.ability.extra.subtraction1
            card.ability.extra.current_dollars = card.ability.extra.current_dollars + card.ability.extra.subtraction2
            if card.ability.extra.current_x_chips <= 0.5 then
                card.ability.extra.current_x_chips = 1
            end
            if card.ability.extra.current_x_mult <= 0.5 then
                card.ability.extra.current_x_mult = 1
            end
            if card.ability.extra.current_dollars <= -1 then
                card.ability.extra.current_dollars = 0
            end
            return {
                message = 'Subtracted!',
                colour = G.C.RED,
                delay = 0.2
            }
        end
        if context.joker_main then
            return {
                x_chips = card.ability.extra.current_x_chips,
                x_mult = card.ability.extra.current_x_mult,
                dollars = card.ability.extra.current_dollars
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.x_chips, 
                card.ability.extra.x_mult, 
                card.ability.extra.dollars,
                card.ability.extra.subtraction1,
                card.ability.extra.subtraction2,
                card.ability.extra.current_x_chips,
                card.ability.extra.current_x_mult,
                card.ability.extra.current_dollars
            } 
        }
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

SMODS.Tag{
    key = 'UberTag5',
    atlas = 'Tags',
    pos = {x = 1, y = 1},
    loc_txt = {
        name = 'Fission Tag',
        text = {
            'Splits into two random',
            '{C:attention}Skip Tags{}',
            'at the end of round'
        }
    },
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            tag:yep('+', G.C.SECONDARY_SET.Tarot, function()
                add_tag(Tag(get_next_tag_key('ubertagrandom')))
                play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                delay(0.5)
                add_tag(Tag(get_next_tag_key('ubertagrandom')))
                play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
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