local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_THEME = {
    Background = Color3.fromRGB(12, 14, 18),
    Surface = Color3.fromRGB(18, 22, 28),
    SurfaceAlt = Color3.fromRGB(26, 31, 39),
    Border = Color3.fromRGB(38, 46, 58),
    Text = Color3.fromRGB(245, 247, 250),
    MutedText = Color3.fromRGB(156, 163, 175),
    Primary = Color3.fromRGB(99, 102, 241),
    PrimaryHover = Color3.fromRGB(129, 140, 248),
    Success = Color3.fromRGB(34, 197, 94),
    Danger = Color3.fromRGB(239, 68, 68),
}

local CHX = {}
CHX.__index = CHX

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[CHX] Callback error:", err)
    end
end

local function mergeTheme(base, overrides)
    local result = {}
    for key, value in pairs(base) do
        result[key] = value
    end
    if overrides then
        for key, value in pairs(overrides) do
            result[key] = value
        end
    end
    return result
end

local function newInstance(className, props)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    return object
end

local function addCorner(parent, radius)
    return newInstance("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 10),
    })
end

local function addStroke(parent, color, transparency)
    return newInstance("UIStroke", {
        Parent = parent,
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function addPadding(parent, left, right, top, bottom)
    return newInstance("UIPadding", {
        Parent = parent,
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or left or 0),
        PaddingBottom = UDim.new(0, bottom or top or left or 0),
    })
end

local function createLabel(props)
    return newInstance("TextLabel", {
        BackgroundTransparency = 1,
        Font = props.Font or Enum.Font.Gotham,
        Text = props.Text or "",
        TextColor3 = props.TextColor3,
        TextSize = props.TextSize or 14,
        TextWrapped = props.TextWrapped == nil and true or props.TextWrapped,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
        AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.Y,
        Size = props.Size or UDim2.new(1, 0, 0, 0),
        Parent = props.Parent,
        LayoutOrder = props.LayoutOrder or 0,
        RichText = props.RichText or false,
    })
end

local function createTextButton(props)
    local button = newInstance("TextButton", {
        AutoButtonColor = false,
        Text = props.Text or "",
        Font = props.Font or Enum.Font.Gotham,
        TextColor3 = props.TextColor3,
        TextSize = props.TextSize or 14,
        BackgroundColor3 = props.BackgroundColor3,
        BackgroundTransparency = props.BackgroundTransparency or 0,
        Size = props.Size,
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        Parent = props.Parent,
        LayoutOrder = props.LayoutOrder or 0,
        AutomaticSize = props.AutomaticSize,
        BorderSizePixel = 0,
    })

    if props.CornerRadius then
        addCorner(button, props.CornerRadius)
    end

    if props.StrokeColor then
        addStroke(button, props.StrokeColor, props.StrokeTransparency)
    end

    return button
end

local function createCard(theme, parent)
    local card = newInstance("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
    })
    addCorner(card, 10)
    addStroke(card, theme.Border)
    addPadding(card, 12, 12, 10, 10)

    local layout = newInstance("UIListLayout", {
        Parent = card,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })

    return card, layout
end

local function bindCanvasSize(scrollingFrame, layout, bottomPadding)
    local function updateCanvas()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (bottomPadding or 0))
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()
end

local function applyHover(button, fromColor, toColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = toColor,
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = fromColor,
        }):Play()
    end)
end

local function makeDraggable(dragHandle, windowFrame)
    local dragging = false
    local dragStart
    local startPosition

    local function update(input)
        local delta = input.Position - dragStart
        windowFrame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = windowFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
        end
    end)
end

local function buildElementHeader(theme, parent, titleText, descText)
    local wrapper = newInstance("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local layout = newInstance("UIListLayout", {
        Parent = wrapper,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    })

    local title = createLabel({
        Parent = wrapper,
        Text = titleText or "Untitled",
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        LayoutOrder = 1,
    })

    local desc
    if descText and descText ~= "" then
        desc = createLabel({
            Parent = wrapper,
            Text = descText,
            TextColor3 = theme.MutedText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            LayoutOrder = 2,
        })
    end

    return wrapper, layout, title, desc
end

function Window:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

function Window:SelectTab(target)
    local chosenTab = target

    if type(target) == "string" then
        for _, tab in ipairs(self.Tabs) do
            if tab.Title == target then
                chosenTab = tab
                break
            end
        end
    end

    if not chosenTab then
        return nil
    end

    for _, tab in ipairs(self.Tabs) do
        local active = tab == chosenTab
        tab.Page.Visible = active
        tab.Button.BackgroundColor3 = active and self.Theme.Primary or self.Theme.SurfaceAlt
        tab.Button.TextColor3 = self.Theme.Text
    end

    self.CurrentTab = chosenTab
    return chosenTab
end

function Window:Destroy()
    if self.Gui then
        self.Gui:Destroy()
    end
end

function Window:Tab(config)
    config = config or {}
    local theme = self.Theme

    local tab = setmetatable({
        Window = self,
        Title = config.Title or ("Tab " .. tostring(#self.Tabs + 1)),
        Theme = theme,
    }, Tab)

    tab.Button = createTextButton({
        Parent = self.TabButtonList,
        Text = tab.Title,
        TextColor3 = theme.Text,
        TextSize = 13,
        BackgroundColor3 = theme.SurfaceAlt,
        Size = UDim2.new(1, 0, 0, 36),
        CornerRadius = 8,
        StrokeColor = theme.Border,
    })

    tab.Page = newInstance("ScrollingFrame", {
        Parent = self.PageHolder,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
    })

    addPadding(tab.Page, 0, 8, 0, 8)

    tab.Layout = newInstance("UIListLayout", {
        Parent = tab.Page,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    bindCanvasSize(tab.Page, tab.Layout, 16)

    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)

    if not self.CurrentTab then
        self:SelectTab(tab)
    end

    return tab
end

function Tab:Section(title)
    local label = createLabel({
        Parent = self.Page,
        Text = string.upper(title or "SECTION"),
        TextColor3 = self.Theme.MutedText,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    return {
        Destroy = function()
            label:Destroy()
        end,
    }
end

function Tab:Label(config)
    config = config or {}
    local theme = self.Theme

    local card = createCard(theme, self.Page)
    local _, _, titleLabel, descLabel = buildElementHeader(theme, card, config.Title or "Label", config.Desc)

    local object = {}

    function object:SetTitle(text)
        titleLabel.Text = text
    end

    function object:SetDesc(text)
        if descLabel then
            descLabel.Text = text
        else
            descLabel = createLabel({
                Parent = card,
                Text = text,
                TextColor3 = theme.MutedText,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                LayoutOrder = 2,
            })
        end
    end

    function object:Destroy()
        card:Destroy()
    end

    return object
end

function Tab:Button(config)
    config = config or {}
    local theme = self.Theme

    local button = createTextButton({
        Parent = self.Page,
        Text = "",
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        CornerRadius = 10,
        StrokeColor = theme.Border,
    })
    addPadding(button, 12, 12, 10, 10)

    local contentLayout = newInstance("UIListLayout", {
        Parent = button,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })

    local _, _, titleLabel, descLabel = buildElementHeader(theme, button, config.Title or "Button", config.Desc)

    local action = newInstance("Frame", {
        Parent = button,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = 10,
    })

    local runButton = createTextButton({
        Parent = action,
        Text = config.ButtonText or "Run",
        TextColor3 = theme.Text,
        TextSize = 13,
        BackgroundColor3 = theme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        CornerRadius = 8,
    })
    applyHover(runButton, theme.Primary, theme.PrimaryHover)

    runButton.MouseButton1Click:Connect(function()
        safeCall(config.Callback)
    end)

    local object = {}

    function object:SetTitle(text)
        titleLabel.Text = text
    end

    function object:SetDesc(text)
        if descLabel then
            descLabel.Text = text
        else
            descLabel = createLabel({
                Parent = button,
                Text = text,
                TextColor3 = theme.MutedText,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                LayoutOrder = 2,
            })
        end
    end

    function object:Destroy()
        button:Destroy()
    end

    return object
end

function Tab:Toggle(config)
    config = config or {}
    local theme = self.Theme
    local value = config.Default == true

    local card = createCard(theme, self.Page)

    local row = newInstance("Frame", {
        Parent = card,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
    })

    local left = newInstance("Frame", {
        Parent = row,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -64, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local leftLayout = newInstance("UIListLayout", {
        Parent = left,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    })

    local titleLabel = createLabel({
        Parent = left,
        Text = config.Title or "Toggle",
        TextColor3 = theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
    })

    local descLabel
    if config.Desc then
        descLabel = createLabel({
            Parent = left,
            Text = config.Desc,
            TextColor3 = theme.MutedText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
        })
    end

    local switch = createTextButton({
        Parent = row,
        Text = "",
        BackgroundColor3 = value and theme.Success or theme.SurfaceAlt,
        Size = UDim2.new(0, 50, 0, 28),
        Position = UDim2.new(1, -50, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        CornerRadius = 999,
        StrokeColor = theme.Border,
    })

    local knob = newInstance("Frame", {
        Parent = switch,
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 22, 0, 22),
        Position = value and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
    })
    addCorner(knob, 999)

    local function syncToggle(newValue, shouldCallback)
        value = newValue == true

        TweenService:Create(switch, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = value and theme.Success or theme.SurfaceAlt,
        }):Play()

        TweenService:Create(knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = value and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }):Play()

        if shouldCallback ~= false then
            safeCall(config.Callback, value)
        end
    end

    switch.MouseButton1Click:Connect(function()
        syncToggle(not value, true)
    end)

    local object = {}

    function object:Set(newValue)
        syncToggle(newValue, true)
    end

    function object:Get()
        return value
    end

    function object:SetTitle(text)
        titleLabel.Text = text
    end

    function object:SetDesc(text)
        if descLabel then
            descLabel.Text = text
        else
            descLabel = createLabel({
                Parent = left,
                Text = text,
                TextColor3 = theme.MutedText,
                TextSize = 12,
                Font = Enum.Font.Gotham,
            })
        end
    end

    function object:Destroy()
        card:Destroy()
    end

    syncToggle(value, false)

    return object
end

function Tab:Input(config)
    config = config or {}
    local theme = self.Theme

    local card = createCard(theme, self.Page)
    local _, _, titleLabel, descLabel = buildElementHeader(theme, card, config.Title or "Input", config.Desc)

    local inputBox = newInstance("TextBox", {
        Parent = card,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = config.Placeholder or "Type here...",
        PlaceholderColor3 = theme.MutedText,
        Text = config.Default or "",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 10,
    })
    addCorner(inputBox, 8)
    addStroke(inputBox, theme.Border)
    addPadding(inputBox, 12, 12, 0, 0)

    inputBox.FocusLost:Connect(function(enterPressed)
        safeCall(config.Callback, inputBox.Text, enterPressed)
    end)

    local object = {}

    function object:Set(text)
        inputBox.Text = tostring(text)
    end

    function object:Get()
        return inputBox.Text
    end

    function object:SetTitle(text)
        titleLabel.Text = text
    end

    function object:SetDesc(text)
        if descLabel then
            descLabel.Text = text
        else
            descLabel = createLabel({
                Parent = card,
                Text = text,
                TextColor3 = theme.MutedText,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                LayoutOrder = 2,
            })
        end
    end

    function object:Destroy()
        card:Destroy()
    end

    return object
end

function CHX:CreateWindow(config)
    config = config or {}

    assert(LocalPlayer, "[CHX] LocalPlayer was not found")

    local theme = mergeTheme(DEFAULT_THEME, config.Theme)
    local playerGui = config.Parent or LocalPlayer:WaitForChild("PlayerGui")

    local gui = newInstance("ScreenGui", {
        Name = config.Name or "CHX",
        Parent = playerGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local root = newInstance("Frame", {
        Parent = gui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = config.Size or UDim2.fromOffset(700, 460),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
    })
    addCorner(root, 14)
    addStroke(root, theme.Border)

    local topbar = newInstance("Frame", {
        Parent = root,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
    })
    addCorner(topbar, 14)

    local topbarFix = newInstance("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
    })

    local titleLabel = createLabel({
        Parent = topbar,
        Text = config.Title or "CHX",
        TextColor3 = theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Position = nil,
        Size = UDim2.new(1, -96, 1, 0),
    })
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    addPadding(titleLabel, 16, 0, 0, 0)

    local closeButton = createTextButton({
        Parent = topbar,
        Text = "×",
        TextColor3 = theme.Text,
        TextSize = 18,
        BackgroundColor3 = theme.Danger,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        CornerRadius = 8,
    })

    local body = newInstance("Frame", {
        Parent = root,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 1, -48),
    })

    local sidebar = newInstance("Frame", {
        Parent = body,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, config.SidebarWidth or 170, 1, 0),
    })

    local pageHolder = newInstance("Frame", {
        Parent = body,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, config.SidebarWidth or 170, 0, 0),
        Size = UDim2.new(1, -(config.SidebarWidth or 170), 1, 0),
    })

    local tabButtonList = newInstance("ScrollingFrame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Primary,
    })

    local tabLayout = newInstance("UIListLayout", {
        Parent = tabButtonList,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    bindCanvasSize(tabButtonList, tabLayout, 12)

    makeDraggable(topbar, root)
    applyHover(closeButton, theme.Danger, Color3.fromRGB(248, 113, 113))

    local window = setmetatable({
        Gui = gui,
        Root = root,
        Theme = theme,
        Title = config.Title or "CHX",
        TitleLabel = titleLabel,
        Sidebar = sidebar,
        PageHolder = pageHolder,
        TabButtonList = tabButtonList,
        Tabs = {},
        CurrentTab = nil,
    }, Window)

    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    return window
end

return CHX
