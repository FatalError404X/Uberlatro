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

SMODS.Enhancement{
    key = 'NewEnhancer1',
    atlas = 'Enhancer',
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Bronze Card',
        text = {
            '{X:blue,C:white}X#1#{} chips',
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
    pos = {x = 1, y = 0},
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
            '{X:blue,C:white}X#3#{} chips'
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
    pos = {x = 0, y = 0},
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
            '{C:blue}+5{} chips and {C:mult}+1{} mult',
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
            '{X:mult,C:white}+X0.1{} mult each time',
            'this card is played',
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
        if context.before then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.extra_x_mult
        end
        if context.cardarea == G.play and context.main_scoring then
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
    rate = 2,
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