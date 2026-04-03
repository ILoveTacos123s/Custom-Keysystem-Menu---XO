--[[
    MolchunHub - Roblox Luau UI Library
    1:1 Recreation of Cheeto UI Style

    Load in your script:
        local MolchunHub = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
        local Win = MolchunHub:CreateWindow("Molchun Hub")
        local Tab = Win:AddTab("Main")
        Tab:AddToggle({ Label = "Fly", Default = false, Callback = function(v) print(v) end })
]]

-- ════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════

local T = {
    WindowBG    = Color3.fromRGB(18,  18,  30),
    SidebarBG   = Color3.fromRGB(14,  14,  22),
    RowEven     = Color3.fromRGB(20,  20,  32),
    RowOdd      = Color3.fromRGB(22,  22,  36),
    Border      = Color3.fromRGB(36,  36,  58),
    Accent      = Color3.fromRGB(108, 108, 255),
    AccentDim   = Color3.fromRGB(48,  48,  82),
    SliderTrack = Color3.fromRGB(38,  38,  62),
    ToggleOff   = Color3.fromRGB(50,  50,  80),
    ToggleOn    = Color3.fromRGB(108, 108, 255),
    Knob        = Color3.fromRGB(255, 255, 255),
    TextBright  = Color3.fromRGB(210, 210, 225),
    TextMid     = Color3.fromRGB(150, 150, 175),
    TextDim     = Color3.fromRGB(100, 100, 130),
    TextActive  = Color3.fromRGB(120, 120, 255),
    NotifBG     = Color3.fromRGB(20,  20,  34),
    NInfo       = Color3.fromRGB(108, 108, 255),
    NSuccess    = Color3.fromRGB(72,  185, 120),
    NWarn       = Color3.fromRGB(220, 155, 40),
    NError      = Color3.fromRGB(220, 70,  70),
    Font        = Enum.Font.Gotham,
    FontBold    = Enum.Font.GothamBold,
    FontSemi    = Enum.Font.GothamSemibold,
}

-- ════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════

local function Tw(obj, goal, t, s, d)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out),
        goal):Play()
end

local function New(cls, props, ch)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in pairs(ch    or {}) do c.Parent = o end
    return o
end

local function Corner(r) return New("UICorner",{CornerRadius=UDim.new(0,r or 6)}) end
local function Stroke(c,t) return New("UIStroke",{Color=c or T.Border,Thickness=t or 1}) end
local function List(pad)
    return New("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,pad or 0),
    })
end

local function Draggable(frame, handle)
    handle = handle or frame
    local drag, start, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                       startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- ════════════════════════════════════════
--  SCREENGUI
-- ════════════════════════════════════════

local GUI = New("ScreenGui", {
    Name           = "MolchunHub",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn   = false,
    DisplayOrder   = 999,
})

if syn and syn.protect_gui then
    syn.protect_gui(GUI); GUI.Parent = game:GetService("CoreGui")
elseif gethui then
    GUI.Parent = gethui()
elseif not RunService:IsStudio() then
    GUI.Parent = game:GetService("CoreGui")
else
    GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ════════════════════════════════════════
--  NOTIFICATION CONTAINER
-- ════════════════════════════════════════

local NotifHolder = New("Frame",{
    Name="Notifs", Size=UDim2.new(0,240,1,0),
    Position=UDim2.new(1,-250,0,0),
    BackgroundTransparency=1, Parent=GUI,
},{List(6)})
NotifHolder:FindFirstChildWhichIsA("UIListLayout").VerticalAlignment = Enum.VerticalAlignment.Bottom
New("UIPadding",{PaddingBottom=UDim.new(0,10),PaddingTop=UDim.new(0,10),Parent=NotifHolder})

-- ════════════════════════════════════════
--  LIBRARY
-- ════════════════════════════════════════

local Library = {}
Library.__index = Library

-- ── NOTIFY ───────────────────────────────────────────────────

function Library:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "MolchunHub"
    local body     = opts.Text     or ""
    local ntype    = opts.Type     or "info"
    local duration = opts.Duration or 3.5

    local col = ({info=T.NInfo,success=T.NSuccess,warn=T.NWarn,error=T.NError})[ntype] or T.NInfo

    local card = New("Frame",{
        Size=UDim2.new(1,0,0,56), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=T.NotifBG, BorderSizePixel=0,
        ClipsDescendants=true, Parent=NotifHolder,
    },{Corner(6),Stroke(T.Border)})

    New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=2,Parent=card},{Corner(3)})
    New("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,14,0,12),BackgroundColor3=col,BorderSizePixel=0,ZIndex=2,Parent=card},{Corner(99)})

    New("TextLabel",{
        Size=UDim2.new(1,-38,0,16),Position=UDim2.new(0,28,0,8),
        BackgroundTransparency=1,Text=title,TextColor3=T.TextBright,
        Font=T.FontBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2,Parent=card,
    })
    New("TextLabel",{
        Size=UDim2.new(1,-38,0,0),Position=UDim2.new(0,28,0,25),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Text=body,TextColor3=T.TextMid,
        Font=T.Font,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=2,Parent=card,
    })

    local closeBtn = New("TextButton",{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-20,0,6),
        BackgroundTransparency=1,Text="x",TextColor3=T.TextDim,
        Font=T.FontBold,TextSize=14,ZIndex=3,Parent=card,
    })
    local prog = New("Frame",{
        Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=col,BorderSizePixel=0,ZIndex=2,Parent=card,
    })

    local gone = false
    local function dismiss()
        if gone then return end; gone=true
        Tw(card,{Size=UDim2.new(1,0,0,0)},0.2)
        task.delay(0.22,function() card:Destroy() end)
    end
    closeBtn.MouseButton1Click:Connect(dismiss)
    Tw(prog,{Size=UDim2.new(0,0,0,2)},duration,Enum.EasingStyle.Linear)
    task.delay(duration,dismiss)
end

-- ── WINDOW ───────────────────────────────────────────────────

function Library:CreateWindow(hubName)
    hubName = hubName or "Molchun Hub"

    local Win     = {}
    local allTabs = {}

    -- Root frame
    local Root = New("Frame",{
        Name="MolchunRoot",
        Size=UDim2.new(0,460,0,370),
        Position=UDim2.new(0.5,-230,0.5,-185),
        BackgroundColor3=T.WindowBG,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=GUI,
    },{Corner(8),Stroke(T.Border)})

    -- Sidebar
    local Sidebar = New("Frame",{
        Name="Sidebar",Size=UDim2.new(0,130,1,0),
        BackgroundColor3=T.SidebarBG,BorderSizePixel=0,Parent=Root,
    })
    New("Frame",{
        Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Border,BorderSizePixel=0,Parent=Sidebar,
    })

    -- Logo row (drag handle)
    local LogoRow = New("Frame",{
        Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Parent=Sidebar,
    })
    Draggable(Root, LogoRow)

    New("Frame",{
        Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,11,0.5,-5),
        BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=LogoRow,
    },{Corner(99)})
    New("TextLabel",{
        Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,28,0,0),
        BackgroundTransparency=1,Text=hubName,
        TextColor3=T.TextBright,Font=T.FontBold,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=LogoRow,
    })

    -- Divider under logo
    New("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,36),
        BackgroundColor3=T.Border,BorderSizePixel=0,Parent=Sidebar,
    })

    -- Tab button list
    local TabList = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-38),Position=UDim2.new(0,0,0,38),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=Sidebar,
    },{List()})

    -- Content area
    local Content = New("Frame",{
        Size=UDim2.new(1,-130,1,0),Position=UDim2.new(0,130,0,0),
        BackgroundTransparency=1,Parent=Root,
    })

    -- Header bar
    local Header = New("Frame",{
        Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Parent=Content,
    })
    New("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Border,BorderSizePixel=0,Parent=Header,
    })

    local Breadcrumb = New("TextLabel",{
        Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text=hubName.."  >  --",
        TextColor3=T.TextDim,Font=T.Font,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=Header,
    })

    local ColBtn = New("TextButton",{
        Size=UDim2.new(0,22,0,18),Position=UDim2.new(1,-28,0.5,-9),
        BackgroundColor3=T.SidebarBG,BorderSizePixel=0,
        Text=">|",TextColor3=T.TextDim,Font=T.Font,TextSize=10,Parent=Header,
    },{Corner(3),Stroke(T.Border)})

    local collapsed = false
    ColBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        Tw(Root,{Size=collapsed and UDim2.new(0,130,0,370) or UDim2.new(0,460,0,370)},0.2)
    end)

    -- Row scroll container
    local RowScroll = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-28),Position=UDim2.new(0,0,0,28),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=T.AccentDim,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Parent=Content,
    },{List()})

    -- Internal tab select
    local function SelectTab(td)
        for _,t in ipairs(allTabs) do
            t.Bar.Visible = false
            t.Lbl.TextColor3 = T.TextDim
            t.Rows.Visible = false
            t.Btn.BackgroundTransparency = 1
        end
        td.Bar.Visible = true
        td.Lbl.TextColor3 = T.TextActive
        td.Rows.Visible = true
        td.Btn.BackgroundColor3 = T.WindowBG
        td.Btn.BackgroundTransparency = 0.4
        Breadcrumb.Text = hubName.."  >  "..td.Name
    end

    -- ── ADD TAB ──────────────────────────────────────────────

    function Win:AddTab(name)
        local td    = {Name=name}
        local order = 0

        -- Sidebar button
        local Btn = New("TextButton",{
            Size=UDim2.new(1,0,0,27),BackgroundTransparency=1,
            Text="",BorderSizePixel=0,LayoutOrder=#allTabs+1,Parent=TabList,
        })
        local Bar = New("Frame",{
            Size=UDim2.new(0,2,1,0),BackgroundColor3=T.Accent,
            BorderSizePixel=0,Visible=false,Parent=Btn,
        })
        local Lbl = New("TextLabel",{
            Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,12,0,0),
            BackgroundTransparency=1,Text=name,
            TextColor3=T.TextDim,Font=T.Font,TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,Parent=Btn,
        })
        local Rows = New("Frame",{
            Name=name.."_rows",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,Visible=false,LayoutOrder=#allTabs+1,Parent=RowScroll,
        },{List()})

        td.Btn=Btn; td.Bar=Bar; td.Lbl=Lbl; td.Rows=Rows
        Btn.MouseButton1Click:Connect(function() SelectTab(td) end)
        table.insert(allTabs, td)
        if #allTabs == 1 then SelectTab(td) end

        -- ── Row factory ──────────────────────────────────────

        local function MakeRow(h)
            order += 1
            local r = New("Frame",{
                Size=UDim2.new(1,0,0,h or 32),
                BackgroundColor3=order%2==0 and T.RowEven or T.RowOdd,
                BorderSizePixel=0,LayoutOrder=order,Parent=Rows,
            })
            New("Frame",{
                Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
                BackgroundColor3=T.Border,BorderSizePixel=0,Parent=r,
            })
            return r
        end

        local Tab = {}

        -- ── SECTION LABEL ────────────────────────────────────

        function Tab:AddSection(text)
            order += 1
            local r = New("Frame",{
                Size=UDim2.new(1,0,0,26),BackgroundColor3=T.WindowBG,
                BorderSizePixel=0,LayoutOrder=order,Parent=Rows,
            })
            New("Frame",{
                Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
                BackgroundColor3=T.Border,BorderSizePixel=0,Parent=r,
            })
            New("TextLabel",{
                Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=text,TextColor3=T.TextBright,
                Font=T.FontBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=r,
            })
        end

        -- ── TOGGLE ───────────────────────────────────────────

        function Tab:AddToggle(opts)
            opts = opts or {}
            local label    = opts.Label    or "Toggle"
            local default  = opts.Default  or false
            local callback = opts.Callback or function() end
            local state    = default

            local row = MakeRow(32)

            New("TextLabel",{
                Size=UDim2.new(1,-115,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=label,TextColor3=T.TextMid,
                Font=T.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row,
            })
            New("TextLabel",{
                Size=UDim2.new(0,68,1,0),Position=UDim2.new(1,-112,0,0),
                BackgroundTransparency=1,Text="Click to Bind",TextColor3=T.TextDim,
                Font=T.Font,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Parent=row,
            })

            local track = New("Frame",{
                Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-42,0.5,-9),
                BackgroundColor3=state and T.ToggleOn or T.ToggleOff,
                BorderSizePixel=0,Parent=row,
            },{Corner(99)})
            local knob = New("Frame",{
                Size=UDim2.new(0,14,0,14),
                Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
                BackgroundColor3=T.Knob,BorderSizePixel=0,Parent=track,
            },{Corner(99)})

            local btn = New("TextButton",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row,
            })
            btn.MouseButton1Click:Connect(function()
                state = not state
                Tw(track,{BackgroundColor3=state and T.ToggleOn or T.ToggleOff},0.15)
                Tw(knob,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},0.15)
                callback(state)
            end)

            local obj = {}
            function obj:Set(v)
                state=v
                Tw(track,{BackgroundColor3=state and T.ToggleOn or T.ToggleOff},0.15)
                Tw(knob,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},0.15)
                callback(state)
            end
            function obj:Get() return state end
            return obj
        end

        -- ── SLIDER ───────────────────────────────────────────

        function Tab:AddSlider(opts)
            opts = opts or {}
            local label    = opts.Label    or "Slider"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local default  = math.clamp(opts.Default or min, min, max)
            local decimals = opts.Decimals or 0
            local callback = opts.Callback or function() end
            local current  = default

            local function fmt(v)
                return decimals>0 and string.format("%."..decimals.."f",v) or tostring(math.floor(v+0.5))
            end

            local row = MakeRow(32)

            New("TextLabel",{
                Size=UDim2.new(0.55,0,0,14),Position=UDim2.new(0,10,0,5),
                BackgroundTransparency=1,Text=label,TextColor3=T.TextMid,
                Font=T.Font,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=row,
            })
            local valLbl = New("TextLabel",{
                Size=UDim2.new(0,32,0,14),Position=UDim2.new(1,-38,0,5),
                BackgroundTransparency=1,Text=fmt(default),TextColor3=T.TextDim,
                Font=T.Font,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Parent=row,
            })

            local trackBg = New("Frame",{
                Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,1,-10),
                BackgroundColor3=T.SliderTrack,BorderSizePixel=0,Parent=row,
            },{Corner(99)})

            local p0   = (default-min)/(max-min)
            local fill = New("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=trackBg},{Corner(99)})
            local knob = New("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(p0,-6,0.5,-6),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=trackBg},{Corner(99)})

            local sliding = false
            local hitbox  = New("TextButton",{
                Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0.5,-12),
                BackgroundTransparency=1,Text="",ZIndex=5,Parent=trackBg,
            })

            local function apply(px)
                local ax = trackBg.AbsolutePosition.X
                local aw = trackBg.AbsoluteSize.X
                local p  = math.clamp((px-ax)/aw, 0, 1)
                local raw = min+(max-min)*p
                local val = decimals>0 and tonumber(string.format("%."..decimals.."f",raw)) or math.floor(raw+0.5)
                local fp  = (val-min)/(max-min)
                fill.Size     = UDim2.new(fp,0,1,0)
                knob.Position = UDim2.new(fp,-6,0.5,-6)
                valLbl.Text   = fmt(val)
                if val~=current then current=val; callback(val) end
            end

            hitbox.MouseButton1Down:Connect(function() sliding=true end)
            hitbox.MouseButton1Click:Connect(function() apply(Mouse.X) end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then apply(i.Position.X) end
            end)

            local obj = {}
            function obj:Set(v)
                v=math.clamp(v,min,max)
                local fp=(v-min)/(max-min)
                fill.Size=UDim2.new(fp,0,1,0); knob.Position=UDim2.new(fp,-6,0.5,-6)
                valLbl.Text=fmt(v); current=v; callback(v)
            end
            function obj:Get() return current end
            return obj
        end

        -- ── DROPDOWN ─────────────────────────────────────────

        function Tab:AddDropdown(opts)
            opts = opts or {}
            local label    = opts.Label    or "Dropdown"
            local items    = opts.Items    or {}
            local default  = opts.Default  or (items[1] or "None")
            local callback = opts.Callback or function() end
            local current  = default
            local open     = false
            local dropF    = nil

            local row = MakeRow(32)

            New("TextLabel",{
                Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=label,TextColor3=T.TextMid,
                Font=T.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row,
            })
            local valBtn = New("TextButton",{
                Size=UDim2.new(0,100,0,22),Position=UDim2.new(1,-108,0.5,-11),
                BackgroundColor3=T.AccentDim,BorderSizePixel=0,
                Text=default,TextColor3=T.TextMid,Font=T.Font,TextSize=11,Parent=row,
            },{Corner(4)})

            valBtn.MouseButton1Click:Connect(function()
                if open then
                    if dropF then dropF:Destroy(); dropF=nil end
                    open=false; return
                end
                open=true
                dropF = New("Frame",{
                    Size=UDim2.new(0,100,0,#items*24),Position=UDim2.new(1,-108,1,2),
                    BackgroundColor3=T.SidebarBG,BorderSizePixel=0,ZIndex=20,Parent=row,
                },{Corner(4),Stroke(T.Border),List()})
                for i,item in ipairs(items) do
                    local ib = New("TextButton",{
                        Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,
                        Text=item,TextColor3=item==current and T.TextActive or T.TextMid,
                        Font=T.Font,TextSize=11,LayoutOrder=i,ZIndex=21,Parent=dropF,
                    })
                    ib.MouseButton1Click:Connect(function()
                        current=item; valBtn.Text=item
                        dropF:Destroy(); dropF=nil; open=false
                        callback(item)
                    end)
                end
            end)

            local obj = {}
            function obj:Set(v) current=v; valBtn.Text=v; callback(v) end
            function obj:Get() return current end
            function obj:Refresh(t) items=t end
            return obj
        end

        -- ── BIND ─────────────────────────────────────────────

        function Tab:AddBind(opts)
            opts = opts or {}
            local label    = opts.Label    or "Bind"
            local default  = opts.Default
            local callback = opts.Callback or function() end
            local bound    = default
            local binding  = false

            local row = MakeRow(32)

            New("TextLabel",{
                Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=label,TextColor3=T.TextMid,
                Font=T.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row,
            })
            local bindLbl = New("TextButton",{
                Size=UDim2.new(0,100,1,-6),Position=UDim2.new(1,-108,0,3),
                BackgroundTransparency=1,
                Text=default and default.Name or "Click to Bind",
                TextColor3=T.TextDim,Font=T.Font,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=row,
            })

            bindLbl.MouseButton1Click:Connect(function()
                if binding then return end
                binding=true; bindLbl.Text="..."; bindLbl.TextColor3=T.Accent
                local c; c=UserInputService.InputBegan:Connect(function(i,gpe)
                    if gpe then return end
                    if i.UserInputType==Enum.UserInputType.Keyboard then
                        bound=i.KeyCode; bindLbl.Text=i.KeyCode.Name
                        bindLbl.TextColor3=T.TextDim; binding=false; c:Disconnect(); callback(bound)
                    end
                end)
            end)

            local obj = {}
            function obj:Get() return bound end
            function obj:Set(k) bound=k; bindLbl.Text=k and k.Name or "Click to Bind" end
            return obj
        end

        -- ── BUTTON ───────────────────────────────────────────

        function Tab:AddButton(opts)
            opts = opts or {}
            local label    = opts.Label    or "Button"
            local callback = opts.Callback or function() end

            local row = MakeRow(36)
            local btn = New("TextButton",{
                Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,10,0.5,-12),
                BackgroundColor3=T.AccentDim,BorderSizePixel=0,
                Text=label,TextColor3=T.TextBright,Font=T.FontSemi,TextSize=12,Parent=row,
            },{Corner(4)})
            btn.MouseEnter:Connect(function()       Tw(btn,{BackgroundColor3=T.Accent},0.12) end)
            btn.MouseLeave:Connect(function()       Tw(btn,{BackgroundColor3=T.AccentDim},0.12) end)
            btn.MouseButton1Down:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(80,80,200)},0.05) end)
            btn.MouseButton1Up:Connect(function()   Tw(btn,{BackgroundColor3=T.Accent},0.08) end)
            btn.MouseButton1Click:Connect(callback)
        end

        -- ── TEXTBOX ──────────────────────────────────────────

        function Tab:AddTextbox(opts)
            opts = opts or {}
            local label       = opts.Label       or "Input"
            local placeholder = opts.Placeholder or "Type here..."
            local default     = opts.Default     or ""
            local instant     = opts.Instant     or false
            local callback    = opts.Callback    or function() end

            local row = MakeRow(32)
            New("TextLabel",{
                Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=label,TextColor3=T.TextMid,
                Font=T.Font,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=row,
            })
            local box = New("TextBox",{
                Size=UDim2.new(0,130,0,22),Position=UDim2.new(1,-138,0.5,-11),
                BackgroundColor3=T.AccentDim,BorderSizePixel=0,
                Text=default,PlaceholderText=placeholder,
                TextColor3=T.TextBright,PlaceholderColor3=T.TextDim,
                Font=T.Font,TextSize=11,ClearTextOnFocus=false,Parent=row,
            },{Corner(4),New("UIPadding",{PaddingLeft=UDim.new(0,6)})})

            if instant then
                box:GetPropertyChangedSignal("Text"):Connect(function() callback(box.Text) end)
            else
                box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
            end

            local obj = {}
            function obj:Get() return box.Text end
            function obj:Set(v) box.Text=v end
            return obj
        end

        return Tab
    end

    -- Window-level methods
    function Win:Toggle()  Root.Visible = not Root.Visible end
    function Win:Destroy() Root:Destroy() end

    return Win
end

return Library
