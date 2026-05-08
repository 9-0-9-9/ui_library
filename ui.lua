
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Library = {}
local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end
function Library:CreateWindow(name)
    local Window = {Tabs = {}, Elements = {}, SelectedIdx = 1, Dragging = false, Active = true}
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkidNetUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui")
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 300, 0, 25)
    Main.Position = UDim2.new(0.5, -150, 0.5, -50)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 50, 50)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Main
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 25)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "SkidNet"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.RobotoMono
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    local TitleStroke = Instance.new("UIStroke")
    TitleStroke.Color = Color3.fromRGB(0, 0, 0)
    TitleStroke.Thickness = 1
    TitleStroke.Parent = Title
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, -25)
    Container.Position = UDim2.new(0, 0, 0, 25)
    Container.BackgroundTransparency = 1
    Container.Parent = Main
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Container
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    local function setTransparency(offset)
        Tween(Main, TweenInfo.new(0.1), {BackgroundTransparency = math.clamp(Main.BackgroundTransparency + offset, 0, 1)})
        Tween(Stroke, TweenInfo.new(0.1), {Transparency = math.clamp(Stroke.Transparency + offset, 0, 1)})
        for _, v in pairs(Main:GetDescendants()) do
            if v:IsA("Frame") and v.Name ~= "TopBar" and v.BackgroundTransparency < 1 then
                Tween(v, TweenInfo.new(0.1), {BackgroundTransparency = math.clamp(v.BackgroundTransparency + offset, 0, 1)})
            elseif v:IsA("TextLabel") or v:IsA("TextBox") then
                Tween(v, TweenInfo.new(0.1), {TextTransparency = math.clamp(v.TextTransparency + offset, 0, 1)})
            elseif v:IsA("UIStroke") and v ~= Stroke then
                Tween(v, TweenInfo.new(0.1), {Transparency = math.clamp(v.Transparency + offset, 0, 1)})
            end
        end
    end
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Window.Dragging, dragStart, startPos = true, input.Position, Main.Position
            setTransparency(0.2)
            Tween(Main, TweenInfo.new(0.1), {Size = UDim2.new(0, 285, 0, Main.Size.Y.Offset - 15)})
            local connection
            connection = UserInputService.InputEnded:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                    Window.Dragging = false
                    connection:Disconnect()
                    setTransparency(-0.2)
                    Tween(Main, TweenInfo.new(0.1), {Size = UDim2.new(0, 300, 0, Main.Size.Y.Offset + 15)})
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and Window.Dragging then update(input) end
    end)
    local function UpdateHeight()
        local contentSize = Layout.AbsoluteContentSize
        if not Window.Dragging then
            Tween(Main, TweenInfo.new(0.1), {Size = UDim2.new(0, 300, 0, math.clamp(contentSize.Y + 25, 25, 800))})
        end
    end
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not Window.Active then return end
        if input.KeyCode == Enum.KeyCode.Down then
            Window.SelectedIdx = math.min(Window.SelectedIdx + 1, #Window.Elements)
            Window:UpdateSelection()
        elseif input.KeyCode == Enum.KeyCode.Up then
            Window.SelectedIdx = math.max(Window.SelectedIdx - 1, 1)
            Window:UpdateSelection()
        elseif input.KeyCode == Enum.KeyCode.Return then
            local element = Window.Elements[Window.SelectedIdx]
            if element and element.Callback then element.Callback() end
        end
    end)
    function Window:UpdateSelection()
        for i, element in ipairs(Window.Elements) do
            element.Frame.BackgroundColor3 = (i == Window.SelectedIdx) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(25, 25, 25)
        end
    end
    function Window:AddSeparator()
        local Sep = Instance.new("Frame")
        Sep.Size, Sep.BackgroundColor3, Sep.BorderSizePixel, Sep.Parent = UDim2.new(1, 0, 0, 1), Color3.fromRGB(50, 50, 50), 0, Container
    end
    function Window:AddTab(name, callback)
        local Tab = {Callback = callback}
        local Frame = Instance.new("Frame")
        Frame.Size, Frame.BackgroundColor3, Frame.BorderSizePixel, Frame.Parent = UDim2.new(1, 0, 0, 25), Color3.fromRGB(25, 25, 25), 0, Container
        local Label = Instance.new("TextLabel")
        Label.Size, Label.Position, Label.BackgroundTransparency, Label.Text, Label.TextColor3, Label.TextSize, Label.Font, Label.TextXAlignment, Label.Parent = UDim2.new(1, -10, 1, 0), UDim2.new(0, 10, 0, 0), 1, name, Color3.fromRGB(255, 255, 255), 14, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, Frame
        local s = Instance.new("UIStroke")
        s.Color, s.Thickness, s.Parent = Color3.fromRGB(0, 0, 0), 1, Label
        Tab.Frame = Frame
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and callback then callback() end
        end)
        table.insert(Window.Elements, Tab)
        return Tab
    end
    function Window:AddToggle(name, default, callback)
        local Toggle = {State = default or false, Callback = callback}
        local Frame = Instance.new("Frame")
        Frame.Size, Frame.BackgroundColor3, Frame.BorderSizePixel, Frame.Parent = UDim2.new(1, 0, 0, 25), Color3.fromRGB(25, 25, 25), 0, Container
        local Label = Instance.new("TextLabel")
        Label.Size, Label.Position, Label.BackgroundTransparency, Label.Text, Label.TextColor3, Label.TextSize, Label.Font, Label.TextXAlignment, Label.Parent = UDim2.new(0.5, -10, 1, 0), UDim2.new(0, 10, 0, 0), 1, name, Color3.fromRGB(255, 255, 255), 14, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, Frame
        local Status = Instance.new("TextLabel")
        Status.Size, Status.Position, Status.BackgroundTransparency, Status.TextSize, Status.Font, Status.TextXAlignment, Status.Parent = UDim2.new(0.5, -10, 1, 0), UDim2.new(0.5, 0, 0, 0), 1, 14, Enum.Font.RobotoMono, Enum.TextXAlignment.Right, Frame
        local function update()
            Status.Text = Toggle.State and "<on>" or "<off>"
            Status.TextColor3 = Toggle.State and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
            if callback then callback(Toggle.State) end
        end
        update()
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Toggle.State = not Toggle.State
                update()
            end
        end)
        Toggle.Frame, Toggle.Callback = Frame, function() Toggle.State = not Toggle.State update() end
        table.insert(Window.Elements, Toggle)
        return Toggle
    end
    function Window:AddSlider(name, default, callback)
        local Slider = {Value = default or "", Callback = callback}
        local Frame = Instance.new("Frame")
        Frame.Size, Frame.BackgroundColor3, Frame.BorderSizePixel, Frame.Parent = UDim2.new(1, 0, 0, 25), Color3.fromRGB(25, 25, 25), 0, Container
        local Label = Instance.new("TextLabel")
        Label.Size, Label.Position, Label.BackgroundTransparency, Label.Text, Label.TextColor3, Label.TextSize, Label.Font, Label.TextXAlignment, Label.Parent = UDim2.new(0.5, -10, 1, 0), UDim2.new(0, 10, 0, 0), 1, name, Color3.fromRGB(255, 255, 255), 14, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, Frame
        local Box = Instance.new("TextBox")
        Box.Size, Box.Position, Box.BackgroundColor3, Box.BorderSizePixel, Box.Text, Box.TextColor3, Box.TextSize, Box.Font, Box.Parent = UDim2.new(0.4, 0, 0, 18), UDim2.new(0.6, -10, 0.5, -9), Color3.fromRGB(35, 35, 35), 0, tostring(Slider.Value), Color3.fromRGB(255, 255, 255), 12, Enum.Font.RobotoMono, Frame
        Box.FocusLost:Connect(function()
            Slider.Value = Box.Text
            if callback then callback(Box.Text) end
        end)
        Slider.Frame, Slider.Callback = Frame, function() Box:CaptureFocus() end
        table.insert(Window.Elements, Slider)
        return Slider
    end
    function Window:AddDropdown(name, options, callback)
        local Dropdown = {Options = options or {}, Callback = callback, Open = false}
        local Frame = Instance.new("Frame")
        Frame.Size, Frame.BackgroundColor3, Frame.BorderSizePixel, Frame.ClipsDescendants, Frame.Parent = UDim2.new(1, 0, 0, 25), Color3.fromRGB(25, 25, 25), 0, true, Container
        local Label = Instance.new("TextLabel")
        Label.Size, Label.Position, Label.BackgroundTransparency, Label.Text, Label.TextColor3, Label.TextSize, Label.Font, Label.TextXAlignment, Label.Parent = UDim2.new(1, -10, 0, 25), UDim2.new(0, 10, 0, 0), 1, name .. " >", Color3.fromRGB(255, 255, 255), 14, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, Frame
        local OptionContainer = Instance.new("Frame")
        OptionContainer.Size, OptionContainer.Position, OptionContainer.BackgroundTransparency, OptionContainer.Parent = UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 25), 1, Frame
        Instance.new("UIListLayout").Parent = OptionContainer
        local function toggle()
            Dropdown.Open = not Dropdown.Open
            Label.Text = name .. (Dropdown.Open and " v" or " >")
            local h = Dropdown.Open and (#Dropdown.Options * 25 + 25) or 25
            Tween(Frame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h)})
            Tween(OptionContainer, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h - 25)})
        end
        Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
        end)
        for _, opt in ipairs(Dropdown.Options) do
            local o = Instance.new("TextButton")
            o.Size, o.BackgroundColor3, o.BorderSizePixel, o.Text, o.TextColor3, o.TextSize, o.Font, o.TextXAlignment, o.Parent = UDim2.new(1, 0, 0, 25), Color3.fromRGB(30, 30, 30), 0, "  " .. opt, Color3.fromRGB(200, 200, 200), 12, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, OptionContainer
            o.MouseButton1Click:Connect(function() if callback then callback(opt) end toggle() end)
        end
        Dropdown.Frame, Dropdown.Callback = Frame, toggle
        table.insert(Window.Elements, Dropdown)
        return Dropdown
    end
    return Window
end
return Library
