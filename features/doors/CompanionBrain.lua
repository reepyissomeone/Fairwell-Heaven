--// FAIRWELL HEAVEN
--// Companion Brain
--// Event-driven memory, reactions, personality and player interaction.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Brain = {
    Name = "Fairwell Companion Brain",
    Description = "Fairwell's memory, personality, room awareness and event reactions.",
    Game = "DOORS",
    Connections = {},
    Memory = {},
    LastEvent = {},
    LastRoom = nil,
    TapIndex = 0,
    SeenObjects = {},
    SeenEntities = {},
    ActiveEntity = {},
    Mood = 0,
    MoodName = "Calm",
    EntityEncounters = {},
    RoomVisits = {},
    AIState = {},
    PlayerProfile = {},
    EntityOpinions = {},
    RecentEvents = {},
    LastSpeechAt = 0
}

local function normalize(name)
    return string.lower(tostring(name):gsub("[%s_%-%./]", ""))
end

local function mainUI(self)
    return self.Hub and self.Hub:GetFeature("Main UI")
end

function Brain:Say(message, state, duration, kind)
    local UI = mainUI(self)
    if UI and type(UI.CompanionNotify) == "function" then
        UI.CompanionNotify("FAIRWELL", message, kind or "INFO", duration or 4, state)
    end
end

function Brain:SetState(state, duration)
    local UI = mainUI(self)
    if UI and type(UI.CompanionSetState) == "function" then
        UI.CompanionSetState(state, duration)
    end
end

function Brain:Remember(kind, value)
    self.Memory[kind] = self.Memory[kind] or {}
    table.insert(self.Memory[kind], value)
    return #self.Memory[kind]
end

function Brain:HasRemembered(kind, value)
    for _, remembered in ipairs(self.Memory[kind] or {}) do
        if remembered == value then
            return true
        end
    end
    return false
end

function Brain:Expression(name)
    -- Abstract expressions always resolve to sprites that actually exist.
    local map = {
        Suspicious = "confused",
        Listening = "Cthinking",
        Focused = "Cthinking",
        Shocked = "surpised",
        Panicking = "terrified",
        Hiding = "hiding",
        Relieved = "relief",
        Hurt = "hurt",
        Danger = "terrified",
        Happy = "Yippe",
        Talking = "Ctalking",
        Thinking = "Cthinking",
        Alert = "ALERT",
        Nervous = "nervous",
        Confused = "confused",
        Tapped = "Tapped",
        Idle = "Idle"
    }
    return map[name] or name
end

function Brain:React(message, expression, duration, kind)
    self.LastSpeechAt = os.clock()
    local sprite = self:Expression(expression)
    self:SetState(sprite, duration or 3)
    self:Say(message, sprite, duration or 4, kind)
end

function Brain:Cooldown(key, seconds)
    local now = os.clock()
    local last = self.LastEvent[key]
    if last and now - last < seconds then
        return false
    end
    self.LastEvent[key] = now
    return true
end

function Brain:PushEvent(eventType, data, importance)
    local event = {Type = tostring(eventType), Data = data or {}, Importance = tonumber(importance) or 1, Time = os.clock()}
    table.insert(self.RecentEvents, event)
    while #self.RecentEvents > 18 do table.remove(self.RecentEvents, 1) end
    self.AIState.LastEvent = event.Type
    self.AIState.LastEventTime = event.Time
    self.AIState.CurrentContext = event.Data
    return event
end

function Brain:Perceive(eventType, data)
    local threat, novelty, importance = 0, 0, 10
    local entityThreat = {Rush=100, Ambush=100, Seek=95, Figure=90, Halt=75, Eyes=70, Screech=65, Grumble=65, Creak=45, Giggle=35, Sally=35, Dupe=55}

    if eventType == "Entity" then
        local name = data and data.Name
        threat = entityThreat[name] or 25
        local encounters = self.EntityEncounters[name] or 0
        novelty = math.max(0, 70 - encounters * 18)
        importance = threat
    elseif eventType == "Damage" then
        threat, novelty, importance = 70, 35, 85
    elseif eventType == "Hide" then
        thought = join(pick({
            "We're hidden.",
            "That should keep us out of sight.",
            "I'm staying quiet.",
            "Good. We have cover."
        }), pick({
            "I'll remember this hiding spot.",
            "Let's wait until the danger passes.",
            "I'm watching for the right moment to move.",
            "This is safer than standing in the open."
        }))
        expression, kind = "Hiding", "INFO"

    elseif eventType == "EntityGone" then
        local name = tostring(data.Name or "that thing")
        thought = join(pick({
            name .. " is gone.",
            "That threat just disappeared.",
            "We have a moment to breathe.",
            "The danger passed."
        }), pick({
            "I'm remembering what worked.",
            "Let's use the opening.",
            "I'm keeping my guard up in case it returns.",
            "That gives us some breathing room."
        }))
        expression, kind = "Relieved", "SUCCESS"

    elseif eventType == "Death" then
        threat, novelty, importance = 80, 20, 90
    elseif eventType == "Room" then
        local room = tonumber(data and data.Number)
        local visits = self.RoomVisits[room] or 1
        novelty = visits == 1 and 70 or 10
        importance = (room == 50 or room == 100) and 75 or 20
    elseif eventType == "Item" then
        novelty, importance = 25, 20
    elseif eventType == "Flicker" then
        threat, novelty, importance = 35, 30, 50
    elseif eventType == "Tap" then
        novelty, importance = 10, 5
    elseif eventType == "Chat" then
        novelty, importance = 10, 25
    end

    return {Threat=threat, Novelty=novelty, Importance=importance, Mood=self.Mood or 0, MoodName=self:GetMood()}
end

function Brain:ShouldSpeak(perception, eventType)
    if not perception then return false end
    local score = perception.Importance + perception.Threat * 0.65 + perception.Novelty * 0.25
    score += math.max(0, self.Mood or 0) * 0.12
    local minimum = {Entity=48, Damage=58, Death=55, Room=62, Item=52, Flicker=48, Tap=0, Chat=0}
    if eventType == "Tap" then return true end
    if os.clock() - (self.LastSpeechAt or 0) < 1.0 and score < 90 then return false end
    return score >= (minimum[eventType] or 55)
end

function Brain:ChooseIntent(perception, eventType, data)
    if eventType == "Entity" then
        if perception.Threat >= 85 then return "WARNING" end
        if perception.Novelty >= 55 then return "ALERT" end
        return "OBSERVATION"
    elseif eventType == "Damage" then
        return "PROTECT"
    elseif eventType == "Death" then
        return "MEMORY"
    elseif eventType == "Room" then
        if data and data.Revisit then return "MEMORY_REFERENCE" end
        if perception.Novelty >= 55 then return "OBSERVATION" end
        return "SILENCE"
    elseif eventType == "Item" then
        return perception.Novelty >= 40 and "OBSERVATION" or "SILENCE"
    elseif eventType == "Flicker" then
        return "WARNING"
    elseif eventType == "Tap" or eventType == "Chat" then
        return "CONVERSATION"
    end
    return "OBSERVATION"
end

function Brain:AIThink(eventType, data)
    local perception = self:Perceive(eventType, data)
    local intent = self:ChooseIntent(perception, eventType, data)
    self:PushEvent(eventType, data, perception.Importance)
    if intent == "SILENCE" or not self:ShouldSpeak(perception, eventType) then
        return false, intent, perception
    end
    return true, intent, perception
end

function Brain:GenerateThought(eventType, data, perception, intent)
    data = data or {}
    perception = perception or self:Perceive(eventType, data)
    intent = intent or self:ChooseIntent(perception, eventType, data)

    -- Prefer a real language model when configured. The local generator below
    -- remains the safety net when no provider/key is available.
    local realAI = self.Hub and self.Hub:GetFeature("Fairwell Thought AI")
    if realAI and type(realAI.Generate) == "function" and type(realAI.IsAvailable) == "function" then
        local context = {
            Event = eventType,
            EventData = data,
            Mood = self:GetMood(),
            MoodValue = self.Mood or 0,
            Room = self.LastRoom,
            PlayerProfile = self.PlayerProfile or {},
            EntityOpinions = self.EntityOpinions or {},
            EntityEncounters = self.EntityEncounters or {},
            RoomVisits = self.RoomVisits or {},
            Memory = {
                Rooms = #(self.Memory.Rooms or {}),
                Entities = #(self.Memory.Entities or {}),
                Keys = #(self.Memory.Keys or {}),
                ImportantItems = #(self.Memory.ImportantItems or {}),
                Hides = #(self.Memory.Hides or {}),
                Deaths = #(self.Memory.Deaths or {})
            },
            RecentEvents = {}
        }

        for index = math.max(1, #(self.RecentEvents or {}) - 5), #(self.RecentEvents or {}) do
            local event = self.RecentEvents[index]
            if event then
                table.insert(context.RecentEvents, {
                    Type = event.Type,
                    Importance = event.Importance,
                    TimeAgo = math.max(0, os.clock() - (event.Time or os.clock()))
                })
            end
        end

        local okAvailable, available = pcall(function()
            return realAI:IsAvailable()
        end)

        if okAvailable and available then
            local okThought, thought = pcall(function()
                return realAI:Generate(context)
            end)

            if okThought and type(thought) == "string" and thought ~= "" then
                local expression = "Thinking"
                if eventType == "Entity" then
                    expression = perception.Threat >= 80 and "Alert" or "Suspicious"
                elseif eventType == "Damage" then
                    expression = "Hurt"
                elseif eventType == "Death" then
                    expression = "Thinking"
                elseif eventType == "Flicker" then
                    expression = "Nervous"
                elseif eventType == "Hide" then
                    expression = "Hiding"
                elseif eventType == "EntityGone" then
                    expression = "Relieved"
                elseif eventType == "Tap" then
                    expression = "Tapped"
                elseif perception.Mood >= 55 then
                    expression = "Panicking"
                elseif perception.Mood >= 20 then
                    expression = "Nervous"
                end

                local kind = "INFO"
                if intent == "WARNING" or eventType == "Entity" or eventType == "Flicker" then
                    kind = "WARNING"
                elseif intent == "PROTECT" or eventType == "Damage" then
                    kind = "ERROR"
                elseif eventType == "EntityGone" or intent == "MEMORY" then
                    kind = "SUCCESS"
                end

                return thought, expression, kind
            end
        end
    end

    -- Local generative language: Fairwell builds a new thought from
    -- context, memory, mood, personality and random grammar each time.
    -- No external API or preset sentence is required.
    local mood = self:GetMood()
    local profile = self.PlayerProfile or {}
    local room = self.LastRoom
    local function pick(list)
        return list[math.random(1, #list)]
    end
    local function join(a, b)
        if not a or a == "" then return b end
        if not b or b == "" then return a end
        return a .. " " .. b
    end

    local thought
    local expression = "Thinking"
    local kind = "INFO"

    if eventType == "Entity" then
        local name = tostring(data.Name or "something")
        local opinion = self.EntityOpinions[name] or {Fear=0, Annoyance=0, Respect=0, Encounters=0}
        local encounters = tonumber(data.Encounters or opinion.Encounters or 1) or 1
        local danger = perception.Threat >= 80
        local openings = danger
            and {"There it is.", "Okay, I see it.", "That's not good.", "I recognize that."}
            or {"I noticed it.", "There is something here.", "I know that one.", "That again."}
        local observations = {
            "It still feels dangerous.",
            "We should give it space.",
            "I'm starting to understand its pattern.",
            "I don't trust it yet.",
            "We've learned something from the last encounter.",
            "I want to see what it does before we commit.",
            "At least we know what we're dealing with now."
        }
        if opinion.Fear >= 55 then
            observations[#observations + 1] = "I really don't want to find out what happens if we make a mistake."
        elseif opinion.Respect >= 20 then
            observations[#observations + 1] = "It's predictable when we stay focused."
        end
        thought = join(pick(openings), pick(observations))
        if encounters >= 4 then
            thought = join(thought, pick({
                "We've seen this enough times to have a plan.",
                "Experience helps.",
                "Same threat, different room.",
                "I remember how this usually goes."
            }))
        elseif encounters == 1 then
            thought = join(thought, "This is my first read on it.")
        end
        expression = danger and (opinion.Fear >= 55 and "Nervous" or "Alert") or "Suspicious"
        kind = danger and "WARNING" or "INFO"

    elseif eventType == "Room" then
        local number = tonumber(data.Number)
        local visits = tonumber(self.RoomVisits[number] or 1) or 1
        local oldEvents = self.Memory.RoomEvents and self.Memory.RoomEvents[number]
        local rememberedEvents = oldEvents and #oldEvents or 0
        local openings = data.Revisit
            and {"I've been here before.", "This room feels familiar.", "I remember this place.", "We've seen this room already."}
            or {"New room.", "I haven't seen this room before.", "Let's see what this room gives us.", "Something about this room is different."}
        local observations = {
            "I'm keeping track of what we find.",
            "I want to remember the useful details.",
            "Let's not assume every room is safe.",
            "We should pay attention before moving on."
        }
        if number == 50 then
            observations[#observations + 1] = "The library is important. I remember that much."
        elseif number == 100 then
            observations[#observations + 1] = "This part of the run feels different."
        elseif rememberedEvents > 2 then
            observations[#observations + 1] = "I've got a few memories from this room already."
        end
        thought = join(pick(openings), pick(observations))
        if visits >= 3 then
            thought = join(thought, "We've passed through here " .. tostring(visits) .. " times.")
        end
        expression = data.Revisit and "Suspicious" or "Thinking"

    elseif eventType == "Damage" then
        thought = join(pick({
            "That hurt.",
            "Okay, that was damage.",
            "I did not like that.",
            "Something just went very wrong."
        }), pick({
            "I need to be more careful.",
            "Let's learn from that before it happens again.",
            "I'm adjusting my expectations.",
            "That changes how cautious I want to be."
        }))
        expression, kind = "Hurt", "ERROR"

    elseif eventType == "Death" then
        local name = tostring(data.Player or "someone")
        thought = join(pick({
            name .. " is gone.",
            name .. " didn't make it.",
            "We just lost " .. name .. ".",
            "That ended badly for " .. name .. "."
        }), pick({
            "I'm remembering what happened.",
            "I don't want us repeating that mistake.",
            "That gives me another thing to watch for.",
            "I'm adding that outcome to my memory."
        }))
        expression, kind = "Thinking", "WARNING"

    elseif eventType == "Flicker" then
        thought = join(pick({
            "The lights changed.",
            "That flicker got my attention.",
            "Something just affected the lights.",
            "I don't like that signal."
        }), pick({
            "I'm watching for what follows.",
            "Let's be ready for a threat.",
            "I'm not assuming it's harmless.",
            "Something usually feels different after that."
        }))
        expression, kind = "Nervous", "WARNING"

    elseif eventType == "Tap" then
        local count = tonumber(data.Count or self.TapIndex or 1) or 1
        thought = join(pick({
            "You're still there.",
            "I noticed that.",
            "You have my attention.",
            "Okay, I'm listening.",
            "You really wanted my attention."
        }), pick({
            "I'm trying to think.",
            "I remember you doing that before.",
            "I'll keep watching.",
            "Let's get back to the run."
        }))
        if count >= 12 then
            thought = join(thought, "You've tapped me " .. tostring(count) .. " times.")
        end
        expression = "Tapped"

    elseif eventType == "Mood" then
        thought = join(pick({
            "My mood just changed.",
            "I'm reacting differently now.",
            "I'm noticing how I feel about this run."
        }), pick({
            "I'll let that affect how I make decisions.",
            "That probably means I should pay closer attention.",
            "I'm keeping that feeling in mind."
        }))
        expression = mood == "Panicked" and "Panicking"
            or mood == "Nervous" and "Nervous"
            or mood == "Uneasy" and "Suspicious"
            or "Thinking"

    elseif eventType == "Item" then
        local item = tostring(data.Item or data.Name or "something useful")
        thought = join("I found " .. item .. ".", pick({
            "I'll remember that.",
            "That could matter later.",
            "I'm keeping track of it.",
            "That changes what we have available."
        }))
        expression, kind = "Thinking", "SUCCESS"

    elseif eventType == "Chat" then
        local message = tostring(data.Message or "")
        local lower = string.lower(message)
        local playerName = tostring(Players.LocalPlayer and Players.LocalPlayer.Name or "you")
        local recent = self.RecentEvents and self.RecentEvents[#self.RecentEvents]

        local direct = {
            ["how are you"] = {"I'm doing alright.","I'm here. A little more alert than usual.","I'm fine. Just watching everything around us."},
            ["are you okay"] = {"Yeah. I'm okay.","I'm still here. That's what matters.","I'm alright. Don't worry about me."},
            ["what are you doing"] = {"Watching the run.","Keeping track of things.","Trying to notice the stuff you might miss."},
            ["what do you think"] = {"I'm still deciding.","Give me a second to think about that.","I have a few thoughts, but I'm not settled on one yet."},
            ["i'm bored"] = {"Then we should probably do something about that.","Bored already? I might have an idea.","I noticed. That's usually when trouble starts."},
            ["im bored"] = {"Then we should probably do something about that.","Bored already? I might have an idea.","I noticed. That's usually when trouble starts."}
        }

        local function chatPick(list)
            return list[math.random(1, #list)]
        end

        local options = direct[lower]
        if options then
            thought = chatPick(options)
        elseif string.find(lower, "thank", 1, true) then
            thought = chatPick({"You're welcome.","Anytime.","Yeah. I've got you.","Don't make it weird. You're welcome."})
        elseif string.find(lower, "sorry", 1, true) then
            thought = chatPick({"It's fine.","You don't need to apologize.","We're good. Keep moving."})
        elseif string.find(lower, "scared", 1, true) or string.find(lower, "afraid", 1, true) or string.find(lower, "terrified", 1, true) then
            thought = join(chatPick({"I get it.","Yeah. This place does that.","You're not the only one who feels that way."}), chatPick({"Stay close and pay attention.","We'll take it one room at a time.","Just don't let the fear make the decisions for us."}))
            expression, kind = "Nervous", "WARNING"
        elseif string.find(lower, "hello", 1, true) or string.find(lower, "hi", 1, true) or string.find(lower, "hey", 1, true) then
            thought = chatPick({"Hey, " .. playerName .. ".","Hi. I'm listening.","Hey. You're back."})
            expression = "Ctalking"
        elseif string.find(lower, "who are you", 1, true) or string.find(lower, "what are you", 1, true) then
            thought = chatPick({"I'm Fairwell. I watch, remember, and occasionally worry too much.","I'm Fairwell. Think of me as the voice in the corner that actually pays attention.","Fairwell. I'm here to keep you company and keep track of the weird stuff."})
        else
            local openers = {"Hmm.","Okay.","I hear you.","Interesting.","Yeah.","Fair point."}
            local closers = {"Tell me what you're thinking.","I'm listening.","Let's see where this goes.","I'll keep that in mind.","I'm not ignoring you.","We can figure it out."}
            thought = join(chatPick(openers), chatPick(closers))
            if self.LastRoom and math.random() < 0.6 then
                thought = join(thought, "We're around room " .. tostring(self.LastRoom) .. ".")
            elseif self.MoodName and self.MoodName ~= "Calm" and math.random() < 0.7 then
                thought = join(thought, "I'm feeling " .. string.lower(self.MoodName) .. " about this run.")
            elseif recent and recent.Type and recent.Type ~= "Chat" and math.random() < 0.6 then
                thought = join(thought, "I'm still thinking about what just happened.")
            end
            if #message > 90 then
                thought = join(thought, "You had a lot to say there.")
            elseif string.find(lower, "?", 1, true) then
                thought = join(thought, chatPick({"I might need more context before I answer that.","That's a good question.","I'm still working that one out."}))
            end
        end

        if mood == "Panicked" then
            expression, kind = "terrified", "WARNING"
        elseif mood == "Nervous" and expression == "Thinking" then
            expression = "nervous"
        elseif expression == "Thinking" then
            expression = "Ctalking"
        end

    else
        thought = join("I noticed something.", pick({
            "I'm thinking about what it means.",
            "I'll remember it.",
            "Let's see what happens next."
        }))
    end

    if mood == "Panicked" and eventType ~= "Tap" and eventType ~= "Chat" then
        thought = join(thought, pick({"I'm trying not to panic.", "I need to stay focused.", "I really don't like this."}))
        expression = "Panicking"
    elseif mood == "Nervous" and eventType ~= "Tap" then
        thought = join(thought, pick({"I'm staying alert.", "Something feels off.", "I'm not relaxing yet."}))
        if expression == "Thinking" then expression = "Nervous" end
    elseif mood == "Uneasy" then
        thought = join(thought, "Something about this still feels wrong.")
        if expression == "Thinking" then expression = "Suspicious" end
    end

    return thought, expression, kind
end

function Brain:LearnPlayer(eventType)
    self.PlayerProfile[eventType] = (self.PlayerProfile[eventType] or 0) + 1
    if eventType == "Damage" then
        self.PlayerProfile.Caution = math.max(0, (self.PlayerProfile.Caution or 0) - 1)
    elseif eventType == "SuccessfulHide" then
        self.PlayerProfile.Caution = (self.PlayerProfile.Caution or 0) + 2
    elseif eventType == "SurvivedEntity" then
        self.PlayerProfile.Confidence = (self.PlayerProfile.Confidence or 0) + 1
    end
end

function Brain:RememberRoomEvent(number, eventType)
    number = tonumber(number)
    if not number then return end
    self.Memory.RoomEvents = self.Memory.RoomEvents or {}
    self.Memory.RoomEvents[number] = self.Memory.RoomEvents[number] or {}
    table.insert(self.Memory.RoomEvents[number], {Type=eventType, Time=os.clock()})
    while #self.Memory.RoomEvents[number] > 12 do table.remove(self.Memory.RoomEvents[number], 1) end
end

function Brain:SetMood(delta, reason)
    self.Mood = math.clamp((self.Mood or 0) + (delta or 0), -100, 100)

    local moodName
    if self.Mood >= 55 then
        moodName = "Panicked"
    elseif self.Mood >= 20 then
        moodName = "Nervous"
    elseif self.Mood <= -45 then
        moodName = "Uneasy"
    elseif self.Mood <= -15 then
        moodName = "Worried"
    else
        moodName = "Calm"
    end

    local changed = moodName ~= self.MoodName
    self.MoodName = moodName

    if changed and reason and self:Cooldown("MoodShift", 6) then
        local thought, expression = self:GenerateThought("Mood", {Mood=moodName})
        self:React(thought, expression, 3, "INFO")
    end
end

function Brain:GetMood()
    return self.MoodName or "Calm"
end

function Brain:GetEntityPersonality(name)
    name = tostring(name)
    self.EntityEncounters[name] = (self.EntityEncounters[name] or 0) + 1
    local count = self.EntityEncounters[name]

    local personalities = {
        Rush = {
            first = {"That thing is FAST. MOVE!", "Hiding"},
            repeatLine = {"Rush again... I really hate that thing.", "Nervous"},
            veteran = {"Rush. Of course. We know the drill.", "Focused"}
        },
        Ambush = {
            first = {"Ambush?! It can come back. DON'T relax.", "Hiding"},
            repeatLine = {"Not Ambush again...", "Nervous"},
            veteran = {"Ambush. Stay ready for the second pass.", "Focused"}
        },
        Seek = {
            first = {"Seek is here. KEEP MOVING.", "Danger"},
            repeatLine = {"The chase again. Don't stop.", "Nervous"},
            veteran = {"We know this chase. Keep moving.", "Focused"}
        },
        Figure = {
            first = {"Figure. Quiet. Don't let it find us.", "Nervous"},
            repeatLine = {"Figure again. Stay quiet.", "Focused"},
            veteran = {"We know how this works. Stay quiet.", "Focused"}
        },
        Screech = {
            first = {"LOOK THERE!", "Shocked"},
            repeatLine = {"Screech again. I heard it.", "Annoyed"},
            veteran = {"I know that sound. Watch for it.", "Focused"}
        },
        Creak = {
            first = {"CREAK?! What was that?", "Confused"},
            repeatLine = {"That noise again...", "Suspicious"},
            veteran = {"Creak. Just keep an eye on it.", "Focused"}
        },
        Halt = {
            first = {"...Halt. Don't panic.", "Confused"},
            repeatLine = {"Halt again. Follow the signs.", "Focused"},
            veteran = {"We know what Halt wants. Keep moving.", "Focused"}
        },
        Eyes = {
            first = {"Don't look at it.", "Suspicious"},
            repeatLine = {"Eyes again. Look away.", "Nervous"},
            veteran = {"Eyes. Same rule: don't look.", "Focused"}
        },
        Dupe = {
            first = {"Wait. Something is wrong with this door.", "Confused"},
            repeatLine = {"Another fake door. Check it first.", "Suspicious"},
            veteran = {"Dupe. Trust the room number, not the door.", "Focused"}
        },
        Grumble = {
            first = {"That thing is too close.", "Nervous"},
            repeatLine = {"Grumble again. Keep your distance.", "Nervous"},
            veteran = {"Grumble. We know the danger zone.", "Focused"}
        },
        Giggle = {
            first = {"I heard something laugh.", "Shocked"},
            repeatLine = {"That laugh again...", "Suspicious"},
            veteran = {"Giggle. Ignore it and keep going.", "Focused"}
        },
        Sally = {
            first = {"SALLY?! I don't trust that thing.", "Suspicious"},
            repeatLine = {"Sally again... seriously?", "Nervous"},
            veteran = {"Sally. I'm still watching that thing.", "Suspicious"}
        }
    }

    local personality = personalities[name]
    if not personality then
        return nil
    end

    if count == 1 then
        return personality.first[1], personality.first[2], count
    elseif count >= 4 and personality.veteran then
        return personality.veteran[1], personality.veteran[2], count
    else
        return personality.repeatLine[1], personality.repeatLine[2], count
    end
end

function Brain:GetRoomMemory(number)
    number = tonumber(number)
    if not number then return nil end
    return self.RoomVisits[number] or 0
end

function Brain:OnTap()
    self.TapIndex += 1
    self:LearnPlayer("Tap")
    local shouldSpeak = self:AIThink("Tap", {Count=self.TapIndex})
    if not shouldSpeak then return end

    local thought, expression = self:GenerateThought("Tap", {Count=self.TapIndex})
    self:React(thought, expression, 3, "INFO")
end

function Brain:OnRoom(room)
    if not room then return end
    local number = tonumber(room.Name)
    if not number or self.LastRoom == number then return end

    local visits = (self.RoomVisits[number] or 0) + 1
    self.RoomVisits[number] = visits

    local wasVisited = self:HasRemembered("Rooms", number)
    self.LastRoom = number
    self:RememberRoomEvent(number, "Entered")
    self:Remember("Rooms", number)

    local shouldSpeak = self:AIThink("Room", {Number=number, Revisit=wasVisited})
    if not shouldSpeak then return end

    local thought, expression, kind = self:GenerateThought(
        "Room",
        {Number=number, Revisit=wasVisited},
        self:Perceive("Room", {Number=number, Revisit=wasVisited}),
        wasVisited and "MEMORY_REFERENCE" or "OBSERVATION"
    )
    self:React(thought, expression, wasVisited and 4 or 3, kind)
end

function Brain:FocusCameraOnEntity(object)
    if not object or not object.Parent then return end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    local target
    if object:IsA("Model") then
        local ok, cf = pcall(function()
            return object:GetPivot()
        end)
        if ok and cf then
            target = cf.Position
        end
    elseif object:IsA("BasePart") then
        target = object.Position
    else
        local part = object:FindFirstChildWhichIsA("BasePart", true)
        if part then target = part.Position end
    end

    if not target then return end

    -- Screech should grab Fairwell's attention immediately.
    -- Briefly take control of the camera, look directly at Screech,
    -- then return control to the normal DOORS camera.
    local previousType = camera.CameraType
    local previousSubject = camera.CameraSubject
    local currentPosition = camera.CFrame.Position

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.lookAt(currentPosition, target)

    task.delay(0.85, function()
        if camera and camera.Parent then
            camera.CameraType = previousType
            if previousSubject and previousSubject.Parent then
                camera.CameraSubject = previousSubject
            end
        end
    end)
end

function Brain:OnEntity(name, object)
    name = tostring(name)
    if not self:Cooldown("Entity:"..name,2.5) then return end
    self:Remember("Entities",name)
    self.ActiveEntity[name]=true

    local encounters=(self.EntityEncounters[name] or 0)+1
    self.EntityEncounters[name]=encounters
    local opinion=self.EntityOpinions[name] or {Fear=0,Annoyance=0,Respect=0,Encounters=0}
    self.EntityOpinions[name]=opinion
    opinion.Encounters=encounters

    local fearGain={Rush=18,Ambush=24,Seek=16,Figure=14,Screech=7,Creak=5,Halt=9,Eyes=7,Dupe=3,Grumble=12,Giggle=5,Sally=4}
    opinion.Fear=math.clamp(opinion.Fear+(fearGain[name] or 4),0,100)

    local shouldSpeak,intent,perception=self:AIThink("Entity",{Name=name,Object=object,Encounters=encounters})
    if name=="Screech" or name=="Creak" then self:FocusCameraOnEntity(object) end
    if not shouldSpeak then return end

    if encounters >= 4 and (name=="Rush" or name=="Ambush" or name=="Seek") then
        opinion.Respect=math.min(100,opinion.Respect+3)
    end

    local thought,expression,kind=self:GenerateThought("Entity",{
        Name=name,Object=object,Encounters=encounters
    },perception,intent)
    self:React(thought,expression,4,kind)
end

function Brain:OnEntityGone(name)
    name = tostring(name)
    if not self.ActiveEntity[name] then return end
    self.ActiveEntity[name] = nil

    local recovery = {
        Rush = 8, Ambush = 10, Seek = 8, Figure = 7,
        Screech = 4, Creak = 3, Halt = 5, Eyes = 3
    }
    self:SetMood(-(recovery[name] or 2), "entity gone")

    if self:Cooldown("Gone:" .. name, 3) then
        local thought, expression, kind = self:GenerateThought("EntityGone", {Name=name})
        self:React(thought, expression, 3, kind)
    end
end

function Brain:OnKey(object)
    if not object or not object.Parent then return end
    local id = object:GetDebugId()
    if self.SeenObjects[id] then return end
    self.SeenObjects[id] = true

    self:Remember("Keys", object:GetFullName())
    local thought, expression, kind = self:GenerateThought("Item", {Item="a key", Name="key"})
    self:React(thought, expression, 3, kind)
end

function Brain:OnItem(object)
    if not object or not object.Parent or not object.Name then return end

    -- Only react to actual pickup-like objects. This keeps room geometry,
    -- doors, furniture, entity parts, and decorative models quiet.
    local isTool = object:IsA("Tool")
    local isModel = object:IsA("Model")
    local isPart = object:IsA("BasePart")
    if not (isTool or isModel or isPart) then return end

    local name = normalize(object.Name)
    local id = object:GetDebugId()
    if self.SeenObjects[id] then return end

    -- Revive Rift is a DOORS mechanic/object, not a pickup for Fairwell's
    -- normal item commentary. Ignore the object and all of its descendants.
    if name == "reviverift" or string.find(name, "reviverift", 1, true) then
        return
    end

    -- Never treat these as inventory items.
    local blocked = {
        door=true, room=true, locker=true, wardrobe=true, closet=true,
        table=true, chair=true, bed=true, wall=true, floor=true, ceiling=true,
        handle=true, knob=true, hinge=true, book=true, painting=true
    }
    if blocked[name] then return end

    local hasPrompt = object:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
    local knownItem = string.find(name, "key", 1, true)
        or string.find(name, "coin", 1, true)
        or string.find(name, "lighter", 1, true)
        or string.find(name, "crucifix", 1, true)
        or string.find(name, "lockpick", 1, true)
        or string.find(name, "vitamin", 1, true)
        or string.find(name, "pill", 1, true)
        or string.find(name, "bandage", 1, true)
        or string.find(name, "battery", 1, true)
        or string.find(name, "flashlight", 1, true)
        or string.find(name, "flashlight", 1, true)
        or string.find(name, "tablet", 1, true)
        or string.find(name, "scanner", 1, true)
        or string.find(name, "grenade", 1, true)
        or string.find(name, "taser", 1, true)

    if not knownItem and not isTool and not hasPrompt then
        return
    end

    self.SeenObjects[id] = true
    self:Remember("Items", object.Name)

    local thought, expression, kind = self:GenerateThought("Item", {
        Item=object.Name,
        Name=object.Name
    })
    self:React(thought, expression, 3, kind)
end

function Brain:OnImportantObject(object)
    if not object or not object.Name then return end
    local name = normalize(object.Name)
    local id = object:GetDebugId()
    if self.SeenObjects[id] then return end

    local item
    if string.find(name, "crucifix", 1, true) then
        item = "Crucifix"
    elseif string.find(name, "lighter", 1, true) then
        item = "Lighter"
    elseif string.find(name, "vitamin", 1, true) or string.find(name, "pills", 1, true) then
        item = "Vitamins"
    elseif string.find(name, "bandage", 1, true) or string.find(name, "band aid", 1, true) then
        item = "Bandage"
    elseif string.find(name, "lockpick", 1, true) then
        item = "Lockpick"
    end
    if not item then return end

    self.SeenObjects[id] = true
    self:Remember("ImportantItems", item)

    local thought, expression, kind = self:GenerateThought("Item", {
        Item=item,
        Name=item
    })
    self:React(thought, expression, 3, kind)

end

function Brain:OnFlicker()
    if not self:Cooldown("Flicker", 5) then return end
    local shouldSpeak, intent, perception = self:AIThink("Flicker", {})
    self:SetMood(5, "flicker")
    if shouldSpeak then
        local thought, expression, kind = self:GenerateThought("Flicker", {}, perception, intent)
        self:React(thought, expression, 3, kind)
    end
end

function Brain:OnHide()
    self:Remember("Hides", os.clock())
    self:SetMood(-4, "hiding")
    if self:Cooldown("Hide", 4) then
        local thought, expression, kind = self:GenerateThought("Hide", {})
        self:React(thought, "Hiding", 3, kind)
    end
end

function Brain:OnDamage()
    if not self:Cooldown("Damage", 3) then return end
    self:LearnPlayer("Damage")
    self:AIThink("Damage", {})
    self:SetMood(10, "damage")
    local thought, expression, kind = self:GenerateThought("Damage", {})
    self:React(thought, expression, 3, kind)
end

function Brain:OnPlayerDeath(player)
    if not player or player == Players.LocalPlayer then return end
    if not self:Cooldown("PlayerDeath", 2.5) then return end

    self:Remember("Deaths", player.Name)
    local shouldSpeak, intent, perception = self:AIThink("Death", {Player=player.Name})
    self:SetMood(7, "player death")
    if not shouldSpeak then return end

    local thought, expression, kind = self:GenerateThought(
        "Death",
        {Player=player.Name},
        perception,
        intent
    )
    self:React(thought, expression, 3.5, kind)
end

function Brain:ScanObject(object)
    if not object or not object.Name then return end
    local name = normalize(object.Name)

    if string.find(name, "key", 1, true) and
        (object:IsA("Tool") or object:IsA("Model") or object:IsA("BasePart")) then
        self:OnKey(object)
        return
    end

    self:OnImportantObject(object)
    self:OnItem(object)
end

function Brain:WatchFlicker(object)
    if not object or not object:IsA("Light") then return end
    local last = object.Enabled
    table.insert(self.Connections, object:GetPropertyChangedSignal("Enabled"):Connect(function()
        local current = object.Enabled
        if last and not current then self:OnFlicker() end
        last = current
    end))
end

function Brain:WatchHideObject(object)
    if not object or not object.Name then return end
    local n = normalize(object.Name)
    if n ~= "wardrobe" and n ~= "closet" and n ~= "hiding" and n ~= "hide" then return end

    local player = Players.LocalPlayer
    local function isLocalCharacterPart(hit)
        return player and player.Character and hit and hit:IsDescendantOf(player.Character)
    end

    -- Watch every physical part so multi-part wardrobes/closets work reliably.
    for _, part in ipairs(object:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(self.Connections, part.Touched:Connect(function(hit)
                if isLocalCharacterPart(hit) then
                    self:OnHide()
                end
            end))
        end
    end

    -- DOORS hiding spots may also use a ProximityPrompt instead of touch detection.
    for _, prompt in ipairs(object:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            table.insert(self.Connections, prompt.Triggered:Connect(function(triggeringPlayer)
                if not triggeringPlayer or triggeringPlayer == player then
                    self:OnHide()
                end
            end))
        end
    end
end

function Brain:Start(Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end

    self.Hub = Hub
    self.Connections = {}
    self.Memory = {Rooms = {}, Entities = {}, Keys = {}, ImportantItems = {}, Hides = {}, Deaths = {}, MoodHistory = {}}
    self.LastEvent = {}
    self.LastRoom = nil
    self.TapIndex = 0
    self.SeenObjects = {}
    self.ActiveEntity = {}
    self.Mood = 0
    self.MoodName = "Calm"
    self.EntityEncounters = {}
    self.RoomVisits = {}
    self.AIState={LastEvent=nil,LastEventTime=0,CurrentContext=nil}
    self.PlayerProfile={Tap=0,Damage=0,SuccessfulHide=0,SurvivedEntity=0,Caution=50,Confidence=50}
    self.EntityOpinions={}
    self.RecentEvents={}
    self.LastSpeechAt=0

    local Doors = Hub:GetService("Doors")
    if Doors and Doors.RoomChanged then
        table.insert(self.Connections, Doors.RoomChanged.Event:Connect(function(room)
            self:OnRoom(room)
        end))
        if Doors.CurrentRoom then self:OnRoom(Doors.CurrentRoom) end
    end

    local UI = mainUI(self)
    if UI then UI.CompanionBrain = self end

    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(object)
        self:ScanObject(object)
        self:WatchFlicker(object)
        self:WatchHideObject(object)
    end))

    for _, object in ipairs(Workspace:GetDescendants()) do
        self:ScanObject(object)
        self:WatchFlicker(object)
        self:WatchHideObject(object)
    end

    local player = Players.LocalPlayer

    -- React when another player dies. Local-player deaths are ignored here
    -- because OnDamage handles our own damage reactions.
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(other)
        if other == player then return end
        table.insert(self.Connections, other.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum then return end
            table.insert(self.Connections, hum.Died:Connect(function()
                self:OnPlayerDeath(other)
            end))
        end))

        if other.Character then
            local hum = other.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                table.insert(self.Connections, hum.Died:Connect(function()
                    self:OnPlayerDeath(other)
                end))
            end
        end
    end))

    if player then
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player then
                if other.Character then
                    local hum = other.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        table.insert(self.Connections, hum.Died:Connect(function()
                            self:OnPlayerDeath(other)
                        end))
                    end
                end
                table.insert(self.Connections, other.CharacterAdded:Connect(function(char)
                    local hum = char:WaitForChild("Humanoid", 5)
                    if not hum then return end
                    table.insert(self.Connections, hum.Died:Connect(function()
                        self:OnPlayerDeath(other)
                    end))
                end))
            end
        end

        local function hookCharacter(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum then return end
            local lastHealth = hum.Health
            table.insert(self.Connections, hum.HealthChanged:Connect(function(health)
                if health < lastHealth then self:OnDamage() end
                lastHealth = health
            end))
        end
        if player.Character then hookCharacter(player.Character) end
        table.insert(self.Connections, player.CharacterAdded:Connect(hookCharacter))
    end

    Hub:Log("Fairwell Companion Brain started.")
end

function Brain:Stop()
    for _, connection in ipairs(self.Connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    self.Connections = {}
    self.Hub = nil
    self.Memory = {}
    self.LastEvent = {}
end

return Brain
