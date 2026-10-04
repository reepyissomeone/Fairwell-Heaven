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

    return {Threat=threat, Novelty=novelty, Importance=importance, Mood=self.Mood or 0, MoodName=self:GetMood()}
end

function Brain:ShouldSpeak(perception, eventType)
    if not perception then return false end
    local score = perception.Importance + perception.Threat * 0.65 + perception.Novelty * 0.25
    score += math.max(0, self.Mood or 0) * 0.12
    local minimum = {Entity=48, Damage=58, Death=55, Room=62, Item=52, Flicker=48, Tap=0}
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
    self:AIThink("Tap", {Count=self.TapIndex})

    local lines = {
        {"Hey.","Talking"},{"What?","Confused"},{"You keep poking me.","Tapped"},
        {"I'm watching.","Thinking"},{"We have a game to finish.","Nervous"},
        {"...yes?","Talking"},{"Don't distract me.","Alert"},
        {"I'm trying to remember what happened.","Thinking"}
    }

    if self.TapIndex >= 12 and math.random(1,4) == 1 then
        self:React("You really like pressing that button, huh?","Tapped",3)
        return
    end
    if math.random(1,18) == 1 then
        local rare={{"I remember you.","Suspicious"},{"Don't tap me again.","Hurt"},{"Something feels wrong.","Nervous"}}
        local pick=rare[math.random(1,#rare)]
        self:React(pick[1],pick[2],3)
        return
    end
    local pick=lines[((self.TapIndex-1)%#lines)+1]
    self:React(pick[1],pick[2],3)
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

    -- Returning to a room makes Fairwell reference what it remembers.
    if wasVisited and shouldSpeak and self:Cooldown("RoomRepeat:" .. tostring(number), 8) then
        local line
        if visits >= 3 then
            line = "Room " .. tostring(number) .. "... we've been through here " .. tostring(visits) .. " times."
        else
            line = "We've been in Room " .. tostring(number) .. " before..."
        end
        self:SetMood(-2, "familiar room")
        self:React(line, "Suspicious", 3, "INFO")
        return
    end

    local lower = normalize(room.Name)
    if lower == "seek" or lower == "seekroom" then
        self:SetMood(12, "Seek room")
        self:React("Good luck. Stay focused.", "Focused", 4, "WARNING")
        return
    end

    if number == 50 then
        self:SetMood(8, "Library")
        self:React("This is the library. Be careful. I remember this place.", "Listening", 5, "WARNING")
        return
    end

    if number == 100 then
        self:SetMood(8, "Room 100")
        self:React("Something feels different up here... I remember this part.", "Suspicious", 4, "WARNING")
        return
    end

    if number % 10 == 0 and shouldSpeak then
        self:React("Room " .. tostring(number) .. ". Stay alert.", "Thinking", 3)
    end
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

    local shouldSpeak,intent=self:AIThink("Entity",{Name=name,Object=object,Encounters=encounters})
    if name=="Screech" or name=="Creak" then self:FocusCameraOnEntity(object) end

    local personalities={
        Rush={{"That thing is FAST. MOVE!","Hiding"},{"Rush again... I really hate that thing.","Nervous"},{"Rush. Of course. We know the drill.","Focused"}},
        Ambush={{"Ambush?! It can come back. DON'T relax.","Hiding"},{"Not Ambush again...","Nervous"},{"Ambush. Stay ready for the second pass.","Focused"}},
        Seek={{"Seek is here. KEEP MOVING.","Danger"},{"The chase again. Don't stop.","Nervous"},{"We know this chase. Keep moving.","Focused"}},
        Figure={{"Figure. Quiet. Don't let it find us.","Nervous"},{"Figure again. Stay quiet.","Focused"},{"We know how this works. Stay quiet.","Focused"}},
        Screech={{"LOOK THERE!","Shocked"},{"Screech again. I heard it.","Nervous"},{"I know that sound. Watch for it.","Focused"}},
        Creak={{"CREAK?! What was that?","Confused"},{"That noise again...","Suspicious"},{"Creak. Just keep an eye on it.","Focused"}},
        Halt={{"...Halt. Don't panic.","Confused"},{"Halt again. Follow the signs.","Focused"},{"We know what Halt wants. Keep moving.","Focused"}},
        Eyes={{"Don't look at it.","Suspicious"},{"Eyes again. Look away.","Nervous"},{"Eyes. Same rule: don't look.","Focused"}},
        Dupe={{"Wait. Something is wrong with this door.","Confused"},{"Another fake door. Check it first.","Suspicious"},{"Dupe. Trust the room number, not the door.","Focused"}},
        Grumble={{"That thing is too close.","Nervous"},{"Grumble again. Keep your distance.","Nervous"},{"Grumble. We know the danger zone.","Focused"}},
        Giggle={{"I heard something laugh.","Shocked"},{"That laugh again...","Suspicious"},{"Giggle. Ignore it and keep going.","Focused"}},
        Sally={{"SALLY?! I don't trust that thing.","Suspicious"},{"Sally again... seriously?","Nervous"},{"Sally. I'm still watching that thing.","Suspicious"}}
    }

    local personality=personalities[name]
    if not personality or not shouldSpeak then return end
    local tier=encounters==1 and 1 or (encounters>=4 and 3 or 2)
    local message,expression=personality[tier][1],personality[tier][2]
    if tier==3 and (name=="Rush" or name=="Ambush" or name=="Seek") then
        opinion.Respect=math.min(100,opinion.Respect+3)
    end
    self:React(message,expression,4,intent=="WARNING" and "WARNING" or "INFO")
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
        local lines = {
            Rush = "Rush is gone. Breathe.",
            Ambush = "It's gone. Watch for another pass.",
            Seek = "The chase is over. Keep going.",
            Figure = "Figure is gone. Stay quiet.",
            Screech = "Screech is gone. Finally.",
            Creak = "That thing is gone. Keep moving.",
            Halt = "Halt is gone. We're okay.",
            Eyes = "Eyes is gone. Don't look back."
        }
        self:React(lines[name] or "It's gone. Keep going.", "Relieved", 3, "SUCCESS")
    end
end

function Brain:OnKey(object)
    if not object or not object.Parent then return end
    local id = object:GetDebugId()
    if self.SeenObjects[id] then return end
    self.SeenObjects[id] = true

    self:Remember("Keys", object:GetFullName())
    self:React("A key! Keep that.", "Happy", 3, "SUCCESS")
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

    local reactions = {
        key = {"A key! That could be useful.", "Happy", "SUCCESS"},
        coin = {"Money. Nice.", "Happy", "SUCCESS"},
        lighter = {"A lighter. Good to have.", "Thinking", "INFO"},
        crucifix = {"A Crucifix. Definitely keep that.", "Focused", "SUCCESS"},
        lockpick = {"A lockpick. That might save us later.", "Thinking", "SUCCESS"},
        vitamin = {"Vitamins. That could help us move faster.", "Happy", "SUCCESS"},
        pill = {"Something useful. Let's keep it.", "Thinking", "SUCCESS"},
        bandage = {"A bandage. Better to have one.", "Thinking", "SUCCESS"},
        battery = {"A battery. We might need that.", "Happy", "SUCCESS"},
        flashlight = {"A flashlight. Good.", "Happy", "SUCCESS"},
        tablet = {"That looks useful.", "Thinking", "SUCCESS"},
        scanner = {"A scanner? Interesting.", "Focused", "INFO"},
        grenade = {"That's... probably useful.", "Suspicious", "INFO"},
        taser = {"That could come in handy.", "Focused", "SUCCESS"}
    }

    local reaction
    for keyword, value in pairs(reactions) do
        if string.find(name, keyword, 1, true) then
            reaction = value
            break
        end
    end

    if not reaction then
        reaction = {"I found something: " .. tostring(object.Name), "Thinking", "INFO"}
    end

    self:React(reaction[1], reaction[2], 3, reaction[3])
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

    local messages = {
        Crucifix = "That's useful. Keep it.",
        Lighter = "Good. Light could matter later.",
        Vitamins = "Vitamins. That could help us move faster.",
        Bandage = "A bandage. Keep it in case we need it.",
        Lockpick = "A lockpick. That could save us some trouble."
    }

    self:React(
        messages[item] or "That could be useful.",
        "Thinking",
        3,
        "INFO"
    )
end

function Brain:OnFlicker()
    if not self:Cooldown("Flicker", 5) then return end
    self:AIThink("Flicker", {})
    self:SetMood(5, "flicker")
    self:React("The lights are flickering...", "Nervous", 3, "WARNING")
end

function Brain:OnHide()
    self:Remember("Hides", os.clock())
    self:SetMood(-4, "hiding")
    if self:Cooldown("Hide", 4) then
        self:React("Good. Stay hidden.", "Hiding", 3)
    end
end

function Brain:OnDamage()
    if not self:Cooldown("Damage", 3) then return end
    self:LearnPlayer("Damage")
    self:AIThink("Damage", {})
    self:SetMood(10, "damage")
    self:React("OW! Are you okay?!", "Hurt", 3, "ERROR")
end

function Brain:OnPlayerDeath(player)
    if not player or player == Players.LocalPlayer then return end
    if not self:Cooldown("PlayerDeath", 2.5) then return end

    local lines = {
        {"Welp. They didn't make it.", "Thinking", "INFO"},
        {"And there goes another one.", "Suspicious", "WARNING"},
        {"Ouch. That looked expensive.", "Confused", "INFO"},
        {"Well... that's one way to leave.", "Thinking", "INFO"},
        {"Should we mention that they died?", "Suspicious", "INFO"},
        {"I was going to say good luck.", "Confused", "INFO"},
        {"Okay. Maybe don't do whatever THEY did.", "Nervous", "WARNING"},
        {"Noted. Definitely avoiding that.", "Thinking", "WARNING"},
        {"Wow. They really committed to that mistake.", "Suspicious", "INFO"},
        {"That went spectacularly wrong.", "Confused", "WARNING"},
        {"I think the hallway won.", "Thinking", "INFO"},
        {"Well, that was unfortunate.", "Cthinking", "INFO"},
        {"They had a plan. It was a bad one.", "Suspicious", "INFO"},
        {"I would laugh, but we're next.", "Nervous", "WARNING"},
        {"And I thought WE were doing badly.", "Confused", "INFO"},
        {"Maybe don't copy that strategy.", "Thinking", "WARNING"},
        {"They really said 'watch this' and meant it.", "Suspicious", "INFO"},
        {"That could have gone better. Obviously.", "Confused", "INFO"},
        {"Another successful demonstration of what not to do.", "Thinking", "INFO"},
        {"Well... at least they were confident.", "Suspicious", "INFO"},
        {"I'm adding that to the list of bad ideas.", "Thinking", "INFO"},
        {"That was painful to watch.", "Hurt", "INFO"},
        {"Okay, everyone pretend we didn't see that.", "Confused", "INFO"},
        {"They've officially become hallway decoration.", "Suspicious", "WARNING"},
        {"I have several questions. Mostly 'why?'", "Confused", "INFO"},
        {"Congratulations. You found the worst possible outcome.", "Suspicious", "WARNING"},
        {"They lasted longer than I expected.", "Thinking", "INFO"},
        {"Well... that's one less person to worry about.", "Suspicious", "INFO"},
        {"Maybe the next person should read the instructions.", "Thinking", "INFO"},
        {"I feel like that was avoidable.", "Confused", "INFO"},
        {"The door remains undefeated.", "Suspicious", "INFO"},
        {"Not to be rude, but... yikes.", "Thinking", "INFO"},
        {"That was almost impressive.", "Suspicious", "INFO"},
        {"I vote we don't do that.", "Nervous", "WARNING"},
        {"And THAT is why I keep saying be careful.", "Thinking", "WARNING"}
    }

    local pick = lines[math.random(1, #lines)]
    self:Remember("Deaths", player.Name)
    self:AIThink("Death", {Player=player.Name})
    self:SetMood(7, "player death")
    self:React(pick[1], pick[2], 3.5, pick[3])
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
