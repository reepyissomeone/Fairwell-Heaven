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
    local event = {
        Type = tostring(eventType),
        Data = data or {},
        Importance = tonumber(importance) or 1,
        Time = os.clock()
    }

    table.insert(self.RecentEvents, event)
    while #self.RecentEvents > 18 do
        table.remove(self.RecentEvents, 1)
    end

    self.AIState.LastEvent = event.Type
    self.AIState.LastEventTime = event.Time
    self.AIState.CurrentContext = event.Data
    return event
end

function Brain:Perceive(eventType, data)
    local threat = 0
    local novelty = 0
    local importance = 10

    local entityThreat = {
        Rush = 100, Ambush = 100, Seek = 95, Figure = 90,
        Halt = 75, Eyes = 70, Screech = 65, Grumble = 65,
        Creak = 45, Giggle = 35, Sally = 35, Dupe = 55
    }

    if eventType == "Entity" then
        local name = data and data.Name
        threat = entityThreat[name] or 25
        local encounters = self.EntityEncounters[name] or 0
        novelty = math.max(0, 70 - encounters * 18)
        importance = threat
    elseif eventType == "Damage" then
        threat, novelty, importance = 70, 35, 85
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
    end

    return {
        Threat = threat,
        Novelty = novelty,
        Importance = importance,
        Mood = self.Mood or 0,
        MoodName = self:GetMood()
    }
end

function Brain:ShouldSpeak(perception, eventType)
    if not perception then return false end
    local score = perception.Importance + perception.Threat * 0.65 + perception.Novelty * 0.25
    score += math.max(0, self.Mood or 0) * 0.12

    local minimum = {
        Entity = 48,
        Damage = 58,
        Death = 55,
        Room = 62,
        Item = 52,
        Flicker = 48,
        Tap = 0
    }

    if eventType == "Tap" then return true end
    if os.clock() - (self.LastSpeechAt or 0) < 1.0 and score < 90 then
        return false
    end

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
    elseif eventType == "Tap" then
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
    table.insert(self.Memory.RoomEvents[number], {
        Type = eventType,
        Time = os.clock()
    })

    while #self.Memory.RoomEvents[number] > 12 do
        table.remove(self.Memory.RoomEvents[number], 1)
    end
end

function Brain:BuildContextLine(prefix, detail)
    if not prefix then return detail end
    return tostring(prefix) .. " " .. tostring(detail or "")
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
        local lines = {
            Calm = "Okay. We're doing fine.",
            Worried = "I don't like how this run is going.",
            Uneasy = "Something about this place feels wrong.",
            Nervous = "I'm getting a little nervous.",
            Panicked = "I REALLY don't like this."
        }
        self:React(lines[moodName], moodName == "Panicked" and "Panicking"
            or moodName == "Nervous" and "Nervous"
            or moodName == "Calm" and "Thinking"
            or "Suspicious", 3, "INFO")
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
    local _, _, perception = self:AIThink("Tap", {Count = self.TapIndex})

    local lines = {
        {"Hey.", "Talking"},
        {"What?", "Confused"},
        {"You keep poking me.", "Tapped"},
        {"I'm watching.", "Thinking"},
        {"We have a game to finish.", "Nervous"},
        {"...yes?", "Talking"},
        {"Don't distract me.", "Alert"},
        {"I'm trying to remember what happened.", "Thinking"}
    }

    if self.TapIndex >= 12 and math.random(1, 4) == 1 then
        self:React("You really like pressing that button, huh?", "Tapped", 3)
        return
    end

    if math.random(1, 18) == 1 then
        local rare = {
            {"I remember you.", "Suspicious"},
            {"Don't tap me again.", "Hurt"},
            {"Something feels wrong.", "Nervous"}
        }
        local pick = rare[math.random(1, #rare)]
        self:React(pick[1], pick[2], 3)
        return
    end

    local pick = lines[((self.TapIndex - 1) % #lines) + 1]
    self:React(pick[1], pick[2], 3)
end
function Brain:OnEntity(name, object)
    name = tostring(name)
    if not self:Cooldown("Entity:" .. name, 2.5) then return end

    self:Remember("Entities", name)
    self.ActiveEntity[name] = true

    local encounters = (self.EntityEncounters[name] or 0) + 1
    self.EntityEncounters[name] = encounters
    self.EntityOpinions[name] = self.EntityOpinions[name] or {
        Fear = 0, Annoyance = 0, Respect = 0, Encounters = 0
    }

    local opinion = self.EntityOpinions[name]
    opinion.Encounters = encounters

    local fearGain = {
        Rush = 18, Ambush = 24, Seek = 16, Figure = 14,
        Screech = 7, Creak = 5, Halt = 9, Eyes = 7,
        Dupe = 3, Grumble = 12, Giggle = 5, Sally = 4
    }
    opinion.Fear = math.clamp(opinion.Fear + (fearGain[name] or 4), 0, 100)

    local shouldSpeak, intent = self:AIThink("Entity", {
        Name = name,
        Object = object,
        Encounters = encounters
    })

    if name == "Screech" or name == "Creak" then
        self:FocusCameraOnEntity(object)
    end

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
            repeatLine = {"Screech again. I heard it.", "Nervous"},
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
    if not personality or not shouldSpeak then return end

    local message, expression
    if encounters == 1 then
        message, expression = personality.first[1], personality.first[2]
    elseif encounters >= 4 then
        message, expression = personality.veteran[1], personality.veteran[2]
    else
        message, expression = personality.repeatLine[1], personality.repeatLine[2]
    end

    -- High fear keeps the first few encounters emotional; experience makes
    -- Fairwell more tactical instead of endlessly panicking.
    if encounters >= 4 and (name == "Rush" or name == "Ambush" or name == "Seek") then
        opinion.Respect = math.min(100, opinion.Respect + 3)
    end

    self:React(message, expression, 4, intent == "WARNING" and "WARNING" or "INFO")
end

