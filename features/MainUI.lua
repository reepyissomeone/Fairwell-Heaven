--// FAIRWELL HEAVEN
--// Main UI - clean mobile rebuild
--// One navigation system, one page controller, no invisible touch overlays.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local MainUI = {
    Name = "Main UI",
    Description = "Fairwell Heaven mobile interface."
}

local BLUE = Color3.fromRGB(27,147,227)
local BACKGROUND = Color3.fromRGB(6,4,43)
local PANEL = Color3.fromRGB(10,8,55)
local PANEL2 = Color3.fromRGB(15,13,68)
local WHITE = Color3.fromRGB(255,255,255)
local GREY = Color3.fromRGB(165,165,185)
local GREEN = Color3.fromRGB(65,205,125)
local RED = Color3.fromRGB(210,70,85)

local HIDDEN_FEATURES = {
    ["Main UI"]=true,
    ["Loading Screen"]=true,
    ["UI Repair"]=true,
    ["Mini Notification Test"]=true,
    ["Test Feature"]=true,
    ["Developer Diagnostics"]=true,
    ["Fairwell Dev Lab"]=true
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k,v in pairs(props or {}) do
        pcall(function() obj[k] = v end)
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius or 6)
    c.Parent = obj
    return c
end

local function line(obj, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or BLUE
    s.Thickness = 1
    s.Transparency = transparency or 0.25
    s.Parent = obj
    return s
end

local function text(parent, name, value, pos, size, fontSize, color)
    return make("TextLabel",{
        Name=name,
        Text=tostring(value or ""),
        Position=pos,
        Size=size,
        BackgroundTransparency=1,
        TextColor3=color or WHITE,
        TextSize=fontSize or 11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        TextWrapped=false
    },parent)
end

local function trim(s)
    return tostring(s or ""):gsub("^%s+",""):gsub("%s+$","")
end

local function featureId(name)
    return "F_"..tostring(name):gsub("[^%w_]","_")
end

-- A single activation path. Roblox Activated is touch-safe and this
-- deliberately avoids stacking MouseButton1Click + Activated handlers.
local function tap(button, callback)
    if not button then return end
    local locked = false
    button.Activated:Connect(function()
        if locked or not button.Parent then return end
        locked = true
        local ok,err = pcall(callback)
        if not ok then warn("[Fairwell UI] Button error:",err) end
        task.defer(function() locked=false end)
    end)
end

local function isDoors(info)
    return info and info.Feature and info.Feature.Game == "DOORS"
end

function MainUI:_FeatureList(Hub)
    local list={}
    if not Hub or type(Hub.GetFeatures)~="function" then return list end
    for _,info in ipairs(Hub:GetFeatures()) do
        if not HIDDEN_FEATURES[info.Name] then
            if not isDoors(info) or Hub:IsDOORS() then
                table.insert(list,info)
            end
        end
    end
    table.sort(list,function(a,b) return tostring(a.Name):lower()<tostring(b.Name):lower() end)
    return list
end

function MainUI:_SetFeature(Hub,name,on)
    local settings=Hub:GetService("Settings")
    local ok
    if on then ok=Hub:Enable(name) else ok=Hub:Disable(name) end
    if settings and type(settings.SetFeatureEnabled)=="function" then
        pcall(function() settings:SetFeatureEnabled(name,on,true) end)
    end
    return ok
end

function MainUI:_MakePage(name,titleText)
    local page=make("ScrollingFrame",{
        Name=name,
        Position=UDim2.fromOffset(78,60),
        Size=UDim2.new(1,-86,1,-60),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=4,
        ScrollBarImageColor3=BLUE,
        CanvasSize=UDim2.fromOffset(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        Visible=false
    },self.Window)
    text(page,"PageTitle",titleText,UDim2.fromOffset(6,4),UDim2.new(1,-12,0,32),17,BLUE).Font=Enum.Font.GothamBold
    return page
end

function MainUI:_AddFeature(page,Hub,info,index)
    local button=make("TextButton",{
        Name=featureId(info.Name),
        Size=UDim2.new(1,-4,0,58),
        Position=UDim2.fromOffset(2,0),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=true,
        LayoutOrder=index,
        Active=true
    },page)
    round(button,7)
    local border=line(button,BLUE,0.6)

    local title=text(button,"Name",info.Name,UDim2.fromOffset(12,5),UDim2.new(1,-95,0,23),11,WHITE)
    title.Font=Enum.Font.GothamBold

    local desc=text(button,"Description",info.Feature and info.Feature.Description or "Feature",UDim2.fromOffset(12,28),UDim2.new(1,-95,0,22),8,GREY)
    desc.TextTruncate=Enum.TextTruncate.AtEnd

    local state=text(button,"State","OFF",UDim2.new(1,-72,0,0),UDim2.fromOffset(60,58),10,GREY)
    state.TextXAlignment=Enum.TextXAlignment.Center

    local function refresh()
        local on=Hub:IsEnabled(info.Name)
        state.Text=on and "ON" or "OFF"
        state.TextColor3=on and GREEN or GREY
        border.Color=on and GREEN or BLUE
    end
    refresh()

    tap(button,function()
        self:_SetFeature(Hub,info.Name,not Hub:IsEnabled(info.Name))
        refresh()
        self:_UpdateStatus(Hub)
    end)
end

function MainUI:_BuildMain(Hub)
    local page=self.Pages.Main
    for _,c in ipairs(page:GetChildren()) do
        if c.Name=="FeatureContainer" then c:Destroy() end
    end

    local gameBox=make("Frame",{
        Name="StatusBox",
        Position=UDim2.fromOffset(6,43),
        Size=UDim2.new(1,-12,0,86),
        BackgroundColor3=PANEL,
        BorderSizePixel=0
    },page)
    round(gameBox,7); line(gameBox,BLUE,0.45)

    self.GameText=text(gameBox,"Game","Game: Unknown",UDim2.fromOffset(12,9),UDim2.new(1,-24,0,24),12,WHITE)
    self.GameText.Font=Enum.Font.GothamBold
    self.PlaceText=text(gameBox,"Place","Place ID: "..tostring(game.PlaceId),UDim2.fromOffset(12,34),UDim2.new(1,-24,0,20),9,GREY)
    self.CountText=text(gameBox,"Count","Features: 0",UDim2.fromOffset(12,56),UDim2.new(1,-24,0,20),9,GREY)

    local holder=make("Frame",{
        Name="FeatureContainer",
        Position=UDim2.fromOffset(6,137),
        Size=UDim2.new(1,-12,0,10),
        BackgroundTransparency=1
    },page)
    make("UIListLayout",{
        Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder
    },holder)

    for i,info in ipairs(self:_FeatureList(Hub)) do
        self:_AddFeature(holder,Hub,info,i)
    end
end

function MainUI:_BuildLogs(Hub)
    local page=self.Pages.Logs
    local box=make("TextLabel",{
        Name="LogText",
        Position=UDim2.fromOffset(6,43),
        Size=UDim2.new(1,-12,0,360),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        Text="",
        TextColor3=GREY,
        TextSize=9,
        Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true
    },page)
    round(box,7); line(box,BLUE,0.55)
    self.LogBox=box
    self:_RefreshLogs(Hub)
end

function MainUI:_RefreshLogs(Hub)
    if not self.LogBox or not self.LogBox.Parent then return end
    local logs=type(Hub.GetLogs)=="function" and Hub:GetLogs() or {}
    local out={}
    for i=math.max(1,#logs-90),#logs do
        table.insert(out,tostring(logs[i]))
    end
    self.LogBox.Text=#out>0 and table.concat(out,"\n") or "No Fairwell logs yet."
end

function MainUI:_BuildVisual(Hub)
    local page=self.Pages.Visual
    local holder=make("Frame",{
        Name="VisualContainer",
        Position=UDim2.fromOffset(6,43),
        Size=UDim2.new(1,-12,0,10),
        BackgroundTransparency=1
    },page)
    make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},holder)

    local i=0
    for _,info in ipairs(self:_FeatureList(Hub)) do
        if not isDoors(info) then
            i+=1
            self:_AddFeature(holder,Hub,info,i)
        end
    end
    if i==0 then
        text(holder,"Empty","No visual/general features are available.",UDim2.fromOffset(4,4),UDim2.new(1,-8,0,30),10,GREY)
    end
end

function MainUI:_BuildSettings(Hub)
    local page=self.Pages.Settings
    local info=text(page,"Info","Tap a feature to enable or disable it. Settings are saved automatically.",UDim2.fromOffset(6,43),UDim2.new(1,-12,0,38),9,GREY)
    info.TextWrapped=true

    local holder=make("Frame",{
        Name="SettingsContainer",
        Position=UDim2.fromOffset(6,88),
        Size=UDim2.new(1,-12,0,10),
        BackgroundTransparency=1
    },page)
    make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},holder)

    for i,feature in ipairs(self:_FeatureList(Hub)) do
        self:_AddFeature(holder,Hub,feature,i)
    end

    local reset=make("TextButton",{
        Name="Reset",
        Size=UDim2.new(1,0,0,44),
        BackgroundColor3=RED,
        BorderSizePixel=0,
        Text="RESET FEATURE SETTINGS",
        TextColor3=WHITE,
        TextSize=10,
        Font=Enum.Font.GothamBold,
        LayoutOrder=999,
        Active=true
    },holder)
    round(reset,7)
    tap(reset,function()
        local settings=Hub:GetService("Settings")
        if settings and type(settings.Reset)=="function" then pcall(function() settings:Reset() end) end
        for _,f in ipairs(Hub:GetFeatures()) do
            if not HIDDEN_FEATURES[f.Name] then pcall(function() Hub:Disable(f.Name) end) end
        end
        Hub:Notify("SETTINGS","Feature settings reset.","SUCCESS",3)
        self:_BuildSettings(Hub)
    end)
end

function MainUI:_RevealGameTab()
    if self.GameRevealed then return end
    self.GameRevealed=true
    if self.Tabs and self.Tabs.Game then
        self.Tabs.Game.Visible=true
    end
end

function MainUI:_BuildGame(Hub)
    local page=self.Pages.Game

    local info=text(page,"Info","FAIRWELL HUNT • Catch him. Build a streak. Don't miss.",UDim2.fromOffset(6,43),UDim2.new(1,-12,0,34),9,GREY)
    info.TextWrapped=true

    local scoreLabel=text(page,"Score","SCORE 0",UDim2.fromOffset(8,79),UDim2.new(0.55,-10,0,28),11,WHITE)
    scoreLabel.Font=Enum.Font.GothamBold

    local timeLabel=text(page,"Time","20s",UDim2.new(0.55,0,0,79),UDim2.new(0.45,-8,0,28),11,BLUE)
    timeLabel.TextXAlignment=Enum.TextXAlignment.Right
    timeLabel.Font=Enum.Font.GothamBold

    local board=make("Frame",{
        Name="HuntBoard",
        Position=UDim2.fromOffset(6,112),
        Size=UDim2.new(1,-12,0,250),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        ClipsDescendants=true
    },page)
    round(board,9); line(board,BLUE,0.3)

    local boardTitle=text(board,"BoardTitle","READY?",UDim2.new(0,0,0,8),UDim2.new(1,0,0,25),10,GREY)
    boardTitle.TextXAlignment=Enum.TextXAlignment.Center
    boardTitle.Font=Enum.Font.GothamBold

    local target=make("TextButton",{
        Name="Target",
        Size=UDim2.fromOffset(58,58),
        BackgroundColor3=BLUE,
        BorderSizePixel=0,
        Text="FW",
        TextColor3=WHITE,
        TextSize=14,
        Font=Enum.Font.GothamBold,
        AutoButtonColor=false,
        Visible=false,
        Active=true
    },board)
    round(target,29); line(target,WHITE,0.25)

    local result=text(page,"Result","Find Fairwell as fast as you can.",UDim2.fromOffset(6,369),UDim2.new(1,-12,0,32),9,GREY)
    result.TextXAlignment=Enum.TextXAlignment.Center
    result.TextWrapped=true

    local start=make("TextButton",{
        Name="StartGame",
        Position=UDim2.fromOffset(6,408),
        Size=UDim2.new(1,-12,0,50),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        Text="START ROUND",
        TextColor3=WHITE,
        TextSize=12,
        Font=Enum.Font.GothamBold,
        Active=true
    },page)
    round(start,7); line(start,BLUE,0.35)

    local roundActive=false
    local score=0
    local combo=0
    local bestCombo=0
    local misses=0
    local lives=3
    local remaining=20
    local moveToken=0
    local highScore=0
    local roundNumber=0
    local keyUnlocked=false
    local startTapCount=0
    local firstStartTapAt=0
    local devConsoleUnlocked=false

    local devSecret=make("Frame",{
        Name="SecretFeatureConsole",
        Position=UDim2.fromOffset(6,468),
        Size=UDim2.new(1,-12,0,300),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        Visible=false
    },page)
    round(devSecret,8); line(devSecret,GREEN,0.2)

    local devHeader=text(devSecret,"Header","PRIVATE FEATURE ADDING",UDim2.fromOffset(10,8),UDim2.new(1,-20,0,26),12,GREEN)
    devHeader.Font=Enum.Font.GothamBold

    local devName=make("TextBox",{
        Name="FeatureName",Position=UDim2.fromOffset(10,44),Size=UDim2.new(1,-20,0,40),
        BackgroundColor3=BACKGROUND,BorderSizePixel=0,Text="",PlaceholderText="Feature name",
        TextColor3=WHITE,PlaceholderColor3=GREY,TextSize=10,Font=Enum.Font.Gotham,ClearTextOnFocus=false
    },devSecret)
    round(devName,6); line(devName,BLUE,0.5)

    local devRequest=make("TextBox",{
        Name="FeatureRequest",Position=UDim2.fromOffset(10,92),Size=UDim2.new(1,-20,0,110),
        BackgroundColor3=BACKGROUND,BorderSizePixel=0,Text="",
        PlaceholderText="Type what you want Fairwell to add...",
        TextColor3=WHITE,PlaceholderColor3=GREY,TextSize=10,Font=Enum.Font.Gotham,
        TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
        ClearTextOnFocus=false,MultiLine=true
    },devSecret)
    round(devRequest,6); line(devRequest,BLUE,0.5)

    local devSave=make("TextButton",{
        Name="SaveFeature",Position=UDim2.fromOffset(10,214),Size=UDim2.new(1,-20,0,40),
        BackgroundColor3=GREEN,BorderSizePixel=0,Text="ADD FEATURE IDEA",
        TextColor3=WHITE,TextSize=10,Font=Enum.Font.GothamBold,Active=true
    },devSecret)
    round(devSave,6)

    local devSaved=text(devSecret,"Saved","Unlocked with the Hunt key + 10 score.",UDim2.fromOffset(10,260),UDim2.new(1,-20,0,30),9,GREY)
    devSaved.TextWrapped=true

    local function showDevConsoleIfEligible()
        if devConsoleUnlocked or not keyUnlocked or score < 10 then return end
        devConsoleUnlocked=true
        devSecret.Visible=true
        devSaved.Text="KEY ACCEPTED • Feature adding unlocked."
        devSaved.TextColor3=GREEN
        result.Text="KEY ACCEPTED. PRIVATE FEATURE ADDING UNLOCKED."
        result.TextColor3=GREEN
    end

    tap(devSave,function()
        local name=trim(devName.Text)
        local request=trim(devRequest.Text)
        if name=="" or request=="" then
            devSaved.Text="Enter a feature name and description first."
            devSaved.TextColor3=RED
            return
        end

        -- Send the same two fields used by /suggest to the Discord
        -- suggestion channel. The Discord bot can turn this into the
        -- normal GitHub suggestions/<feature>.md entry.
        local webhook="https://discord.com/api/webhooks/1556506568592195627/-1JabXG5oVpmlBHGjnd1d8onLf9yLlJ7TWc6dilVxfMDBqdkevv383Sjo-cGiouIeJl8"

        local payload={
            username="Fairwell Suggestion",
            content="/suggest\nname: "..name.."\ndescription: "..request.."\nsubmitted by: "..Players.LocalPlayer.Name
        }

        local ok=false
        local errMessage="Unknown error"

        pcall(function()
            local HttpService=game:GetService("HttpService")
            local response=HttpService:RequestAsync({
                Url=webhook,
                Method="POST",
                Headers={["Content-Type"]="application/json"},
                Body=HttpService:JSONEncode(payload)
            })
            ok=response and response.Success==true
            if not ok then
                errMessage="Discord webhook returned HTTP "..tostring(response and response.StatusCode or "?")
            end
        end)

        if ok then
            devSaved.Text="SUGGESTION SENT: "..name
            devSaved.TextColor3=GREEN
            result.Text="FEATURE IDEA SENT TO FAIRWELL."
            result.TextColor3=GREEN
            devName.Text=""
            devRequest.Text=""
        else
            devSaved.Text="Could not send suggestion: "..errMessage
            devSaved.TextColor3=RED
        end
    end)

    local function cleanupTarget()
        target.Visible=false
        moveToken+=1
    end

    local function updateHud()
        scoreLabel.Text="SCORE "..tostring(score).."  •  x"..tostring(math.max(1,math.min(5,1+math.floor(combo/5))))
        timeLabel.Text=tostring(remaining).."s  •  ❤ "..tostring(lives)
    end

    local function moveTarget()
        if not roundActive then return end
        moveToken+=1
        local token=moveToken
        local maxX=math.max(8,board.AbsoluteSize.X-66)
        local maxY=math.max(42,board.AbsoluteSize.Y-66)
        target.Position=UDim2.fromOffset(math.random(8,maxX),math.random(42,maxY))
        target.Visible=true
        boardTitle.Text="FIND HIM!"

        local speed=math.max(0.42,1.05-(roundNumber*0.08)-math.min(combo*0.012,0.3))
        task.delay(speed,function()
            if not roundActive or token~=moveToken then return end

            target.Visible=false
            combo=0
            misses+=1
            lives-=1
            updateHud()

            if lives<=0 then
                roundActive=false
                boardTitle.Text="CAUGHT YOU."
                result.Text="No lives left. Score: "..tostring(score).." • Misses: "..tostring(misses)
                result.TextColor3=RED
                start.Text="TRY AGAIN"
                showDevConsoleIfEligible()
                return
            end

            result.Text="Too slow! Stay sharp."
            result.TextColor3=GREY
            task.delay(0.08,function()
                if roundActive and token==moveToken then moveTarget() end
            end)
        end)
    end

    local function finish()
        if not roundActive then return end
        roundActive=false
        cleanupTarget()

        if score>highScore then
            highScore=score
            result.Text="NEW HIGH SCORE! "..tostring(score)
            result.TextColor3=GREEN
        elseif combo>=8 then
            result.Text="PERFECT STREAK! x"..tostring(combo).." • Score "..tostring(score)
            result.TextColor3=GREEN
        else
            result.Text="Final score: "..tostring(score).." • Best combo: "..tostring(bestCombo)
            result.TextColor3=score>0 and GREEN or GREY
        end

        boardTitle.Text="ROUND OVER"
        start.Text="PLAY AGAIN"
        timeLabel.Text="0s  •  ❤ "..tostring(lives)
        showDevConsoleIfEligible()
    end

    tap(target,function()
        if not roundActive then return end

        score+=math.max(1,math.min(5,1+math.floor(combo/5)))
        combo+=1
        if combo>bestCombo then bestCombo=combo end

        if combo%5==0 then
            result.Text="STREAK x"..tostring(combo).."! Bonus multiplier!"
        else
            result.Text=combo>=8 and "Fairwell is panicking!" or "Got him!"
        end
        result.TextColor3=GREEN
        updateHud()
        moveTarget()
    end)

    tap(start,function()
        local now=os.clock()
        if firstStartTapAt==0 or now-firstStartTapAt>1 then
            firstStartTapAt=now
            startTapCount=1
        else
            startTapCount+=1
        end

        if startTapCount>=5 and not keyUnlocked then
            keyUnlocked=true
            startTapCount=0
            firstStartTapAt=0
            result.Text="KEY UNLOCKED. Now finish with 10+ score."
            result.TextColor3=GREEN
        end

        if roundActive then return end

        roundNumber+=1
        roundActive=true
        score=0
        combo=0
        bestCombo=0
        misses=0
        lives=3
        remaining=20
        moveToken+=1

        scoreLabel.Text="SCORE 0  •  x1"
        timeLabel.Text="20s  •  ❤ 3"
        result.Text=roundNumber==1 and "Go!" or "Round "..tostring(roundNumber)..". Faster this time."
        result.TextColor3=WHITE
        start.Text="ROUND ACTIVE"
        boardTitle.Text="FIND HIM!"

        moveTarget()

        task.spawn(function()
            while roundActive and remaining>0 do
                task.wait(1)
                if not roundActive then break end
                remaining-=1
                updateHud()
            end
            if roundActive then finish() end
        end)
    end)

    self.GameCleanup=function()
        roundActive=false
        cleanupTarget()
        if devSecret and devSecret.Parent then devSecret.Visible=false end
        self.GameCleanup=nil
    end
end

function MainUI:_BuildChat(Hub)
    local page=self.Pages.Chat

    -- Chat header: gives the page an identity instead of looking like a log.
    local header=make("Frame",{
        Name="ChatHeader",
        Position=UDim2.fromOffset(6,42),
        Size=UDim2.new(1,-12,0,54),
        BackgroundColor3=PANEL,
        BorderSizePixel=0
    },page)
    round(header,8); line(header,BLUE,0.45)

    local avatar=make("ImageLabel",{
        Name="HeaderAvatar",
        Position=UDim2.fromOffset(8,7),
        Size=UDim2.fromOffset(40,40),
        BackgroundColor3=PANEL2,
        BorderSizePixel=0,
        BackgroundTransparency=0.15,
        Image="",
        ScaleType=Enum.ScaleType.Fit
    },header)
    round(avatar,20)

    local who=text(header,"Who","FAIRWELL",UDim2.fromOffset(57,6),UDim2.new(1,-70,0,20),11,WHITE)
    who.Font=Enum.Font.GothamBold
    local online=text(header,"Online","Your companion • ready to talk",UDim2.fromOffset(57,26),UDim2.new(1,-70,0,18),8,GREEN)

    local messages=make("ScrollingFrame",{
        Name="Messages",
        Position=UDim2.fromOffset(6,103),
        Size=UDim2.new(1,-12,1,-172),
        BackgroundColor3=Color3.fromRGB(5,4,34),
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=BLUE,
        CanvasSize=UDim2.fromOffset(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y
    },page)
    round(messages,8); line(messages,BLUE,0.72)

    local list=make("UIListLayout",{
        Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder
    },messages)
    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,9)
    pad.PaddingLeft=UDim.new(0,9)
    pad.PaddingRight=UDim.new(0,9)
    pad.PaddingBottom=UDim.new(0,9)
    pad.Parent=messages

    local inputBar=make("Frame",{
        Name="InputBar",
        Position=UDim2.new(0,6,1,-62),
        Size=UDim2.new(1,-12,0,52),
        BackgroundColor3=PANEL,
        BorderSizePixel=0
    },page)
    round(inputBar,8); line(inputBar,BLUE,0.5)

    local input=make("TextBox",{
        Name="Input",
        Position=UDim2.fromOffset(10,4),
        Size=UDim2.new(1,-68,1,-8),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Text="",
        PlaceholderText="Message Fairwell...",
        PlaceholderColor3=GREY,
        TextColor3=WHITE,
        TextSize=10,
        Font=Enum.Font.Gotham,
        ClearTextOnFocus=false,
        MultiLine=false,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center
    },inputBar)

    local send=make("TextButton",{
        Name="Send",
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-5,0.5,0),
        Size=UDim2.fromOffset(44,42),
        BackgroundColor3=BLUE,
        BorderSizePixel=0,
        Text="➤",
        TextColor3=WHITE,
        TextSize=18,
        Font=Enum.Font.GothamBold,
        Active=true,
        AutoButtonColor=true
    },inputBar)
    round(send,7)

    self.ChatMessages=messages
    self.ChatHeaderAvatar=avatar

    local function setPortrait(imageObject,state)
        local assets=self.CompanionAssets or {}
        if assets[state] then
            imageObject.Image=assets[state]
            imageObject.Visible=true
        else
            imageObject.Visible=false
        end
    end

    local function add(who,msg,color,state)
        local isFairwell=(who=="FAIRWELL")
        local row=make("Frame",{
            Name="Message",
            Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,
            LayoutOrder=#messages:GetChildren()
        },messages)

        local bubbleWidth=isFairwell and 0.78 or 0.76
        local bubble=make("Frame",{
            Name="Bubble",
            Position=isFairwell and UDim2.fromScale(0.17,0) or UDim2.fromScale(0.24,0),
            Size=UDim2.new(bubbleWidth,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=isFairwell and PANEL2 or Color3.fromRGB(19,17,66),
            BorderSizePixel=0
        },row)
        round(bubble,8)
        line(bubble,isFairwell and BLUE or GREEN,0.62)

        local body=text(bubble,"Text",msg,UDim2.fromOffset(10,7),UDim2.new(1,-20,0,0),10,color or WHITE)
        body.AutomaticSize=Enum.AutomaticSize.Y
        body.TextWrapped=true
        body.TextYAlignment=Enum.TextYAlignment.Top

        local nameLabel=text(bubble,"Name",isFairwell and "FAIRWELL" or "YOU",
            UDim2.fromOffset(10,3),UDim2.new(1,-20,0,15),7,isFairwell and BLUE or GREEN)
        nameLabel.Font=Enum.Font.GothamBold
        body.Position=UDim2.fromOffset(10,20)

        if isFairwell then
            local portrait=make("ImageLabel",{
                Name="Portrait",
                Position=UDim2.fromOffset(0,2),
                Size=UDim2.fromOffset(43,43),
                BackgroundColor3=PANEL2,
                BorderSizePixel=0,
                BackgroundTransparency=0.1,
                Image="",
                ScaleType=Enum.ScaleType.Fit
            },row)
            round(portrait,21)
            line(portrait,BLUE,0.5)
            setPortrait(portrait,state or "Ctalking")
            table.insert(self.ChatPortraits or {},portrait)
        end

        return row
    end

    local function scrollBottom()
        task.defer(function()
            if messages.Parent then
                messages.CanvasPosition=Vector2.new(0,math.max(0,messages.AbsoluteCanvasSize.Y-messages.AbsoluteWindowSize.Y))
            end
        end)
    end

    local function reply(message)
        local lower=message:lower()
        if lower=="hi" or lower=="hello" or lower=="hey" then
            return "Hey. I'm right here.","Ctalking"
        elseif lower:find("how are you",1,true) then
            return "Doing alright. Better now that you're talking to me.","Ctalking"
        elseif lower:find("help",1,true) then
            return "Try /status or /clear. Or just tell me what's going on.","Cthinking"
        elseif lower:find("scared",1,true) then
            return "Stay close. We'll deal with it together.","Scared"
        elseif lower:find("rush",1,true) or lower:find("hide",1,true) then
            return "Hide. Don't run around looking for him.","hiding"
        elseif lower:find("figure",1,true) then
            return "Keep quiet. I don't want him finding us.","nervous"
        elseif lower:find("where",1,true) then
            return "Room "..tostring(Hub.Game and Hub.Game.CurrentRoom or "?")..". Keep moving.","Cthinking"
        elseif lower:find("bored",1,true) then
            return "Then we need something to do.","Yippe"
        else
            local choices={
                {"I'm listening.","Ctalking"},
                {"Hmm. Tell me more.","Cthinking"},
                {"I'm thinking.","Cthinking"},
                {"Fair enough.","Idle"},
                {"I'll keep that in mind.","Ctalking"}
            }
            local pick=choices[math.random(1,#choices)]
            return pick[1],pick[2]
        end
    end

    local function sendMessage()
        local msg=trim(input.Text)
        if msg=="" then return end
        input.Text=""
        add("YOU",msg,GREEN)
        scrollBottom()

        local lower=msg:lower()
        if lower=="/clear" then
            for _,c in ipairs(messages:GetChildren()) do
                if c.Name=="Message" then c:Destroy() end
            end
            add("FAIRWELL","Chat cleared.",BLUE,"Ctalking")
            scrollBottom()
            return
        end

        if lower=="/status" then
            add("FAIRWELL",
                "Game: "..tostring(Hub.Game and Hub.Game.Name or "Unknown")..
                "\nPlace: "..tostring(game.PlaceId),
                BLUE,"Cthinking")
            scrollBottom()
            return
        end

        if lower=="im bored" or lower=="i'm bored" then
            task.spawn(function()
                self:_CompanionState("Cthinking")
                add("FAIRWELL","Bored? ...Fine. I know a game.",BLUE,"Cthinking")
                scrollBottom()
                task.wait(0.65)
                self:_CompanionState("Yippe")
                self:_RevealGameTab()
            end)
            return
        end

        self:_CompanionState("Cthinking")
        task.delay(0.45,function()
            if not messages.Parent then return end
            local answer,state=reply(msg)
            add("FAIRWELL",answer,BLUE,state)
            scrollBottom()
            self:_CompanionState(state)
            task.delay(1.5,function()
                if self.CompanionSetState then self:_CompanionState("Idle") end
            end)
        end)
    end

    tap(send,sendMessage)
    input.FocusLost:Connect(function(enter)
        if enter then sendMessage() end
    end)

    add("FAIRWELL","Hey. I'm here if you need me.","Ctalking","Ctalking")
    setPortrait(avatar,"Idle")
end

function MainUI:_Switch(pageName)
    if not self.Pages or not self.Pages[pageName] then return false end
    if pageName=="Game" and not self.GameRevealed then return false end

    for _,page in pairs(self.Pages) do
        if page and page.Parent then page.Visible=false end
    end
    self.Pages[pageName].Visible=true

    for _,button in pairs(self.Tabs or {}) do
        if button and button.Parent then
            button.BackgroundColor3=PANEL
            button.TextColor3=GREY
        end
    end

    local button=self.Tabs and self.Tabs[pageName]
    if button then
        button.BackgroundColor3=PANEL2
        button.TextColor3=BLUE
    end

    self.CurrentPage=pageName
    return true
end

function MainUI:_MakeTabs()
    local rail=make("Frame",{
        Name="Navigation",
        Position=UDim2.fromOffset(6,60),
        Size=UDim2.fromOffset(62,330),
        BackgroundTransparency=1,
        ClipsDescendants=true
    },self.Window)

    local list=make("UIListLayout",{
        Padding=UDim.new(0,5),
        SortOrder=Enum.SortOrder.LayoutOrder
    },rail)

    self.Tabs={}
    local definitions={
        {"Main","MAIN",1},
        {"Logs","LOGS",2},
        {"Chat","CHAT",3},
        {"Visual","VISUAL",4},
        {"Settings","SET",5},
        {"Game","GAME",6}
    }

    for _,d in ipairs(definitions) do
        local b=make("TextButton",{
            Name=d[1],
            Size=UDim2.fromOffset(62,46),
            BackgroundColor3=PANEL,
            BorderSizePixel=0,
            Text=d[2],
            TextColor3=GREY,
            TextSize=8,
            Font=Enum.Font.GothamBold,
            LayoutOrder=d[3],
            Active=true,
            AutoButtonColor=true
        },rail)
        round(b,6); line(b,BLUE,0.7)
        self.Tabs[d[1]]=b

        if d[1]=="Game" then b.Visible=false end

        local page=d[1]
        tap(b,function() self:_Switch(page) end)
    end
end

function MainUI:_StartDrag()
    local window=self.Window
    local handle=self.DragHandle
    local dragging=false
    local startInput
    local startPos

    self.DragConnections = self.DragConnections or {}
    table.insert(self.DragConnections, handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            startInput=input.Position
            startPos=window.Position
        end
    end))

    table.insert(self.DragConnections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local delta=input.Position-startInput
        window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end))

    table.insert(self.DragConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end))
end

function MainUI:_CompanionState(state)
    if self.CompanionSetState then
        pcall(function() self.CompanionSetState(state) end)
    end
end

function MainUI:_CreateCompanion()
    local player=Players.LocalPlayer
    local pg=player and player:FindFirstChildOfClass("PlayerGui")
    if not pg then return end

    local old=pg:FindFirstChild("FairwellHeaven_Companion")
    if old then old:Destroy() end

    local gui=make("ScreenGui",{
        Name="FairwellHeaven_Companion",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        DisplayOrder=1000001,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    },pg)

    local holder=make("Frame",{
        Name="Companion",
        AnchorPoint=Vector2.new(0,1),
        Position=UDim2.new(0,8,1,-12),
        Size=UDim2.fromOffset(115,150),
        BackgroundTransparency=1
    },gui)

    local bubble=make("TextLabel",{
        Name="Bubble",
        Position=UDim2.fromOffset(0,0),
        Size=UDim2.fromOffset(115,48),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        Text="I'm here.",
        TextColor3=WHITE,
        TextSize=9,
        Font=Enum.Font.Gotham,
        TextWrapped=true,
        Visible=false
    },holder)
    round(bubble,7); line(bubble,BLUE,0.4)

    local image=make("ImageLabel",{
        Name="Fairwell",
        Position=UDim2.fromOffset(15,45),
        Size=UDim2.fromOffset(85,100),
        BackgroundTransparency=1,
        Image="",
        ScaleType=Enum.ScaleType.Fit
    },holder)

    self.CompanionGui=gui
    self.CompanionHolder=holder
    self.CompanionBubble=bubble

    -- Small Fairwell idle animation: gentle breathing/bobbing so the
    -- companion never feels like a static image.
    local alive=true
    self.CompanionAnimationStop=function()
        alive=false
    end

    task.spawn(function()
        local basePosition=holder.Position
        while alive and holder.Parent do
            local up=TweenService:Create(holder,
                TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
                {Position=basePosition+UDim2.fromOffset(0,-5)})
            up:Play()
            up.Completed:Wait()
            if not alive or not holder.Parent then break end

            local down=TweenService:Create(holder,
                TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
                {Position=basePosition})
            down:Play()
            down.Completed:Wait()
        end
    end)

    -- Tiny tap reaction: squash, then return to normal.
    local originalSize=image.Size
    local originalPosition=image.Position
    self.CompanionTapAnimation=function()
        local squash=TweenService:Create(image,
            TweenInfo.new(0.09,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {
                Size=UDim2.fromOffset(94,88),
                Position=UDim2.fromOffset(10,57)
            })
        squash:Play()
        squash.Completed:Wait()
        if not image.Parent then return end
        TweenService:Create(image,
            TweenInfo.new(0.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=originalSize,Position=originalPosition}
        ):Play()
    end

    local base="https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/assets/Fairwell/Companion/"
    local paths={
        Idle="FairwellHeaven/assets/Fairwell/Companion/Idle.png",
        Ctalking="FairwellHeaven/assets/Fairwell/Companion/Ctalking.png",
        Cthinking="FairwellHeaven/assets/Fairwell/Companion/Cthinking.png",
        Yippe="FairwellHeaven/assets/Fairwell/Companion/Yippe.png",
        Tapped="FairwellHeaven/assets/Fairwell/Companion/Tapped.png",
        Scared="FairwellHeaven/assets/Fairwell/Companion/Scared.png",
        confused="FairwellHeaven/assets/Fairwell/Companion/confused.png",
        nervous="FairwellHeaven/assets/Fairwell/Companion/nervous.png",
        hiding="FairwellHeaven/assets/Fairwell/Companion/hiding.png",
        hurt="FairwellHeaven/assets/Fairwell/Companion/hurt.png",
        relief="FairwellHeaven/assets/Fairwell/Companion/relief.png",
        surpised="FairwellHeaven/assets/Fairwell/Companion/surpised.png",
        terrified="FairwellHeaven/assets/Fairwell/Companion/terrified.png",
        ALERT="FairwellHeaven/assets/Fairwell/Companion/ALERT.png"
    }
    local urls={
        Idle=base.."Idle.png",Ctalking=base.."Ctalking.png",
        Cthinking=base.."Cthinking.png",Yippe=base.."Yippe.png",Tapped=base.."Tapped.png",
        Scared=base.."Scared.png",confused=base.."confused.png",nervous=base.."nervous.png",
        hiding=base.."hiding.png",hurt=base.."hurt.png",relief=base.."relief.png",
        surpised=base.."surpised.png",terrified=base.."terrified.png",ALERT=base.."ALERT.png"
    }
    local assets={}
    self.CompanionAssets=assets
    self.ChatPortraits={}

    local function loader()
        if type(getcustomasset)=="function" then return getcustomasset end
        if type(getsynasset)=="function" then return getsynasset end
        return nil
    end

    task.spawn(function()
        local get=loader()
        if not get then return end
        for state,path in pairs(paths) do
            pcall(function()
                if type(isfile)=="function" and isfile(path) then
                    assets[state]=get(path)
                elseif type(writefile)=="function" then
                    local data=game:HttpGet(urls[state].."?cache="..tostring(math.floor(os.clock()*100000)))
                    if data and data~="" then
                        local folder="FairwellHeaven/assets/Fairwell/Companion"
                        if type(makefolder)=="function" then
                            pcall(makefolder,"FairwellHeaven")
                            pcall(makefolder,"FairwellHeaven/assets")
                            pcall(makefolder,"FairwellHeaven/assets/Fairwell")
                            pcall(makefolder,folder)
                        end
                        writefile(path,data)
                        assets[state]=get(path)
                    end
                end
            end)
        end
        if assets.Idle then image.Image=assets.Idle end
        if self.ChatHeaderAvatar and assets.Idle then
            self.ChatHeaderAvatar.Image=assets.Idle
        end
        for _,portrait in ipairs(self.ChatPortraits or {}) do
            if portrait and portrait.Parent and assets.Ctalking then
                portrait.Image=assets.Ctalking
                portrait.Visible=true
            end
        end
    end)

    local current="Idle"
    self.CompanionSetState=function(state)
        current=assets[state] and state or "Idle"
        if assets[current] then image.Image=assets[current] end
    end

    tap(image,function()
        task.spawn(function()
            if self.CompanionTapAnimation then
                pcall(self.CompanionTapAnimation)
            end
        end)
        self:_CompanionState("Tapped")
        bubble.Text="You tapped me."
        bubble.Visible=true
        task.delay(0.9,function()
            if bubble.Parent then bubble.Visible=false end
            self:_CompanionState("Idle")
        end)
    end)
end

function MainUI:CompanionNotify(title,msg,kind,duration)
    if self.Hidden then return end
    if not self.CompanionBubble then return end
    self.CompanionBubble.Text=tostring(title).."\n"..tostring(msg)
    self.CompanionBubble.Visible=true
    task.delay(tonumber(duration) or 3,function()
        if self.CompanionBubble and self.CompanionBubble.Parent then
            self.CompanionBubble.Visible=false
        end
    end)
end

function MainUI:SetVisible(visible)
    visible = (visible == true)

    local player = Players.LocalPlayer
    local pg = player and player:FindFirstChild("PlayerGui")
    if pg then
        local liveGui = pg:FindFirstChild("FairwellHeaven_MainUI")
        if liveGui and liveGui:IsA("ScreenGui") then
            self.Gui = liveGui
        end
    end

    self.MenuVisible = visible
    self.Hidden = not visible

    if self.Gui and self.Gui.Parent then
        self.Gui.Enabled = visible
    end

    -- Update the new switch from one source of truth.
    local switch = self.ToggleSwitch
    if switch and switch.Parent then
        local track = self.ToggleTrack
        local knob = self.ToggleKnob
        local state = self.ToggleState

        if track then
            track.BackgroundColor3 = visible and BLUE or PANEL2
        end

        if knob then
            knob.Position = visible
                and UDim2.new(1,-28,0.5,0)
                or UDim2.new(0,4,0.5,0)
        end

        if state then
            state.Text = visible and "ON" or "OFF"
            state.TextColor3 = visible and GREEN or GREY
        end

        switch.Visible = true
    end

    if self.CompanionGui then
        self.CompanionGui.Enabled = true
    end
end

function MainUI:Start(Hub)
    if self.Gui and self.Gui.Parent then
        -- A feature restart must never undo the user's FW visibility choice.
        -- Preserve the current state instead of forcing the menu back on.
        self:SetVisible(self.MenuVisible ~= false)
        return true
    end

    local player=Players.LocalPlayer
    if not player then return false end
    local pg=player:WaitForChild("PlayerGui")

    -- Remove every stale instance, not just the first matching child.
    -- This keeps the FW button and menu bound to the same GUI after reloads.
    for _,name in ipairs({"FairwellHeaven_MainUI","FairwellHeaven_Toggle","FairwellHeaven_Companion"}) do
        for _,old in ipairs(pg:GetChildren()) do
            if old.Name == name then
                old:Destroy()
            end
        end
    end

    self.Hub=Hub
    self.Hidden=false
    self.MenuVisible=true
    self.GameRevealed=false
    Hub.SuppressTopNotifications=false

    local gui=make("ScreenGui",{
        Name="FairwellHeaven_MainUI",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        DisplayOrder=1000002,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    },pg)
    self.Gui=gui

    local window=make("Frame",{
        Name="Window",
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromScale(0.74,0.76),
        BackgroundColor3=BACKGROUND,
        BorderSizePixel=0,
        Active=true,
        ClipsDescendants=true
    },gui)
    round(window,9); line(window,BLUE,0.08)
    make("UISizeConstraint",{MinSize=Vector2.new(285,340),MaxSize=Vector2.new(720,620)},window)
    self.Window=window

    local top=make("Frame",{
        Name="TopBar",
        Size=UDim2.new(1,0,0,52),
        BackgroundColor3=PANEL,
        BorderSizePixel=0,
        Active=true
    },window)
    self.DragHandle=top
    local title=text(top,"Title","FAIRWELL HEAVEN",UDim2.fromOffset(14,2),UDim2.new(1,-60,0,25),14,WHITE)
    title.Font=Enum.Font.GothamBold
    text(top,"Subtitle","your companion hub",UDim2.fromOffset(15,27),UDim2.new(1,-60,0,15),7,GREY)
    local accent=make("Frame",{Name="Accent",Position=UDim2.fromOffset(0,50),Size=UDim2.new(1,0,0,2),BackgroundColor3=BLUE,BorderSizePixel=0},top)

    local close=make("TextButton",{
        Name="Close",
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-7,0.5,0),
        Size=UDim2.fromOffset(34,32),
        BackgroundColor3=Color3.fromRGB(65,20,35),
        BorderSizePixel=0,
        Text="×",
        TextColor3=WHITE,
        TextSize=14,
        Font=Enum.Font.GothamBold,
        Active=true
    },top)
    round(close,6)
    tap(close,function() self:SetVisible(false) end)

    self:_MakeTabs()

    self.Pages={
        Main=self:_MakePage("MainPage","MAIN"),
        Logs=self:_MakePage("LogsPage","LOGS"),
        Chat=self:_MakePage("ChatPage","FAIRWELL CHAT"),
        Visual=self:_MakePage("VisualPage","VISUAL"),
        Settings=self:_MakePage("SettingsPage","SETTINGS"),
        Game=self:_MakePage("GamePage","GAME")
    }

    self:_BuildMain(Hub)
    self:_BuildLogs(Hub)
    self:_BuildChat(Hub)
    self:_BuildVisual(Hub)
    self:_BuildSettings(Hub)
    self:_BuildGame(Hub)

    self:_Switch("Main")
    self:_StartDrag()

    -- Standalone mobile-friendly Fairwell switch.
    -- It controls only the main menu; the companion stays independent.
    local toggleGui=make("ScreenGui",{
        Name="FairwellHeaven_Toggle",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        DisplayOrder=1000005
    },pg)

    local toggle=make("TextButton",{
        Name="FWToggle",
        Position=UDim2.new(0,12,0.5,-31),
        Size=UDim2.fromOffset(86,62),
        BackgroundColor3=BACKGROUND,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=false,
        Active=true
    },toggleGui)
    round(toggle,12); line(toggle,BLUE,0.04)

    local label=text(toggle,"Label","FAIRWELL",
        UDim2.fromOffset(8,5),UDim2.new(1,-16,0,16),9,WHITE)
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.Font=Enum.Font.GothamBold

    local track=make("Frame",{
        Name="Track",
        AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,8,0,39),
        Size=UDim2.fromOffset(70,16),
        BackgroundColor3=PANEL2,
        BorderSizePixel=0
    },toggle)
    round(track,8)

    local knob=make("Frame",{
        Name="Knob",
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0,4,0.5,0),
        Size=UDim2.fromOffset(24,24),
        BackgroundColor3=WHITE,
        BorderSizePixel=0
    },track)
    round(knob,12)

    local state=text(toggle,"State","ON",
        UDim2.new(0,0,0,39),UDim2.new(1,-8,0,16),8,GREEN)
    state.TextXAlignment=Enum.TextXAlignment.Right
    state.Font=Enum.Font.GothamBold

    self.ToggleGui=toggleGui
    self.ToggleSwitch=toggle
    self.ToggleTrack=track
    self.ToggleKnob=knob
    self.ToggleState=state

    self:SetVisible(self.Gui and self.Gui.Enabled ~= false)

    tap(toggle,function()
        local current
        if self.Gui and self.Gui.Parent then
            current=self.Gui.Enabled
        else
            current=self.MenuVisible == true
        end
        self:SetVisible(not current)
    end)

    task.spawn(function() pcall(function() self:_CreateCompanion(Hub) end) end)

    if Hub.NotificationEvent then
        self.NotificationConnection=Hub.NotificationEvent.Event:Connect(function(a,b,c,d)
            if self.CompanionNotify then self:CompanionNotify(a,b,c,d) end
        end)
    end

    self.RefreshLoop=task.spawn(function()
        while self.Gui==gui and gui.Parent do
            pcall(function()
                self:_UpdateStatus(Hub)
                self:_RefreshLogs(Hub)
            end)
            task.wait(1)
        end
    end)

    Hub:Log("Main UI clean rebuild started.")
    return true
end

function MainUI:_UpdateStatus(Hub)
    if self.GameText then
        self.GameText.Text="Game: "..tostring(Hub.Game and Hub.Game.Name or "Unknown")
    end
    if self.PlaceText then
        self.PlaceText.Text="Place ID: "..tostring(game.PlaceId)
    end
    if self.CountText then
        local count=#self:_FeatureList(Hub)
        local enabled=0
        for _,f in ipairs(self:_FeatureList(Hub)) do
            if Hub:IsEnabled(f.Name) then enabled+=1 end
        end
        self.CountText.Text="Features: "..count.."  •  Enabled: "..enabled
    end
end

function MainUI:Stop()
    if self.DragConnections then
        for _,connection in ipairs(self.DragConnections) do
            pcall(function() connection:Disconnect() end)
        end
        self.DragConnections=nil
    end
    if self.RefreshLoop then pcall(task.cancel,self.RefreshLoop) end
    self.RefreshLoop=nil
    if self.GameCleanup then pcall(self.GameCleanup) end
    if self.NotificationConnection then self.NotificationConnection:Disconnect() end
    self.NotificationConnection=nil

    for _,key in ipairs({"CompanionGui","ToggleGui","Gui"}) do
        if self[key] then pcall(function() self[key]:Destroy() end) end
        self[key]=nil
    end

    self.Window=nil
    self.Pages=nil
    self.Tabs=nil
    self.ToggleButton=nil
    self.ToggleIndicator=nil
    self.ToggleSwitch=nil
    self.ToggleTrack=nil
    self.ToggleKnob=nil
    self.ToggleState=nil
    self.MenuVisible=nil
    self.DragHandle=nil
    self.CompanionBubble=nil
    if self.CompanionAnimationStop then pcall(self.CompanionAnimationStop) end
    self.CompanionAnimationStop=nil
    self.CompanionTapAnimation=nil
    self.CompanionSetState=nil
    self.CompanionAssets=nil
    self.ChatPortraits=nil
    self.ChatMessages=nil
    self.ChatHeaderAvatar=nil
    self.Hub=nil
end

return MainUI
