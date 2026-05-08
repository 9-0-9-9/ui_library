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
    local Window = {Elements = {}, SelectedIdx = 1, Dragging = false, Active = true}
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkidNetUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui")
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 300, 0, 25)
    Main.Position = UDim2.new(0.5, -150, 0.5, -50)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "dih.pmo | " .. os.date("%B %d, %Y")
    Title.TextColor3 = Color3.fromRGB(150, 150, 150)
    Title.TextSize = 12
    Title.Font = Enum.Font.RobotoMono
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = TopBar
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
            if (v:IsA("Frame") or v:IsA("ScrollingFrame")) and v.Name ~= "TopBar" and v.BackgroundTransparency < 1 then
                Tween(v, TweenInfo.new(0.1), {BackgroundTransparency = math.clamp(v.BackgroundTransparency + offset, 0, 1)})
            elseif v:IsA("TextLabel") or v:IsA("TextBox") then
                Tween(v, TweenInfo.new(0.1), {TextTransparency = math.clamp(v.TextTransparency + offset, 0, 1)})
            elseif v:IsA("UIStroke") then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
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
    local function getVisibleElements()
        local visible = {}
        for _, el in ipairs(Window.Elements) do
            table.insert(visible, el)
            if el.IsOpen and el.Children then
                for _, child in ipairs(el.Children) do
                    table.insert(visible, child)
                    if child.IsOpen and child.Children then
                        for _, sub in ipairs(child.Children) do table.insert(visible, sub) end
                    end
                end
            end
        end
        return visible
    end
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not Window.Active then return end
        local visible = getVisibleElements()
        if input.KeyCode == Enum.KeyCode.Down then
            Window.SelectedIdx = math.min(Window.SelectedIdx + 1, #visible)
            Window:UpdateSelection(visible)
        elseif input.KeyCode == Enum.KeyCode.Up then
            Window.SelectedIdx = math.max(Window.SelectedIdx - 1, 1)
            Window:UpdateSelection(visible)
        elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Space then
            local element = visible[Window.SelectedIdx]
            if element and element.Callback then element.Callback() end
        end
    end)
    function Window:UpdateSelection(visible)
        visible = visible or getVisibleElements()
        for i, element in ipairs(visible) do
            local isSelected = (i == Window.SelectedIdx)
            if element.Label then
                Tween(element.Label, TweenInfo.new(0.1), {TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)})
            end
        end
    end
    function Window:AddTab(name)
        local Tab = {IsOpen = false, Children = {}, Label = nil}
        local Frame = Instance.new("Frame")
        Frame.Size, Frame.BackgroundTransparency, Frame.BorderSizePixel, Frame.ClipsDescendants, Frame.Parent = UDim2.new(1, 0, 0, 25), 1, 0, true, Container
        local Label = Instance.new("TextLabel")
        Label.Size, Label.Position, Label.BackgroundTransparency, Label.Text, Label.TextColor3, Label.TextSize, Label.Font, Label.TextXAlignment, Label.Active, Label.Parent = UDim2.new(1, -10, 0, 25), UDim2.new(0, 10, 0, 0), 1, "< + > " .. name, Color3.fromRGB(150, 150, 150), 13, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, false, Frame
        local ChildContainer = Instance.new("Frame")
        ChildContainer.Size, ChildContainer.Position, ChildContainer.BackgroundTransparency, ChildContainer.Parent = UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 25), 1, Frame
        local ChildLayout = Instance.new("UIListLayout")
        ChildLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ChildLayout.Parent = ChildContainer
        local function toggle()
            Tab.IsOpen = not Tab.IsOpen
            Label.Text = (Tab.IsOpen and "< - > " or "< + > ") .. name
            local targetH = Tab.IsOpen and (ChildLayout.AbsoluteContentSize.Y + 25) or 25
            if Tab.IsOpen and targetH <= 25 then targetH = (#Tab.Children * 25) + 25 end
            Tween(Frame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, targetH)})
            Tween(ChildContainer, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, targetH - 25)})
        end
        Tab.Frame, Tab.Label, Tab.Callback = Frame, Label, toggle
        Frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end end)
        ChildLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Tab.IsOpen then
                local h = ChildLayout.AbsoluteContentSize.Y + 25
                Tween(Frame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h)})
                Tween(ChildContainer, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h - 25)})
            end
        end)
        table.insert(Window.Elements, Tab)
        Window:UpdateSelection()
        function Tab:AddToggle(name, default, callback)
            local Toggle = {State = default or false, Callback = callback}
            local TFrame = Instance.new("Frame")
            TFrame.Size, TFrame.BackgroundTransparency, TFrame.BorderSizePixel, TFrame.Parent = UDim2.new(1, 0, 0, 25), 1, 0, ChildContainer
            local TLabel = Instance.new("TextLabel")
            TLabel.Size, TLabel.Position, TLabel.BackgroundTransparency, TLabel.Text, TLabel.TextColor3, TLabel.TextSize, TLabel.Font, TLabel.TextXAlignment, TLabel.Active, TLabel.Parent = UDim2.new(0.5, -10, 1, 0), UDim2.new(0, 20, 0, 0), 1, name, Color3.fromRGB(150, 150, 150), 13, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, false, TFrame
            local Status = Instance.new("TextLabel")
            Status.Size, Status.Position, Status.BackgroundTransparency, Status.TextSize, Status.Font, Status.TextXAlignment, Status.Parent = UDim2.new(0.5, -10, 1, 0), UDim2.new(0.5, 0, 0, 0), 1, 13, Enum.Font.RobotoMono, Enum.TextXAlignment.Right, TFrame
            local function update()
                Status.Text = Toggle.State and "<on>" or "<off>"
                Status.TextColor3 = Toggle.State and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
                if callback then callback(Toggle.State) end
            end
            update()
            TFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Toggle.State = not Toggle.State update() end end)
            Toggle.Frame, Toggle.Label, Toggle.Callback = TFrame, TLabel, function() Toggle.State = not Toggle.State update() end
            table.insert(Tab.Children, Toggle)
            return Toggle
        end
        function Tab:AddSlider(name, default, callback)
            local Slider = {Value = default or "", Callback = callback}
            local SFrame = Instance.new("Frame")
            SFrame.Size, SFrame.BackgroundTransparency, SFrame.BorderSizePixel, SFrame.Parent = UDim2.new(1, 0, 0, 25), 1, 0, ChildContainer
            local SLabel = Instance.new("TextLabel")
            SLabel.Size, SLabel.Position, SLabel.BackgroundTransparency, SLabel.Text, SLabel.TextColor3, SLabel.TextSize, SLabel.Font, SLabel.TextXAlignment, SLabel.Active, SLabel.Parent = UDim2.new(0.5, -10, 1, 0), UDim2.new(0, 20, 0, 0), 1, name, Color3.fromRGB(150, 150, 150), 13, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, false, SFrame
            local Box = Instance.new("TextBox")
            Box.Size, Box.Position, Box.BackgroundColor3, Box.BorderSizePixel, Box.Text, Box.TextColor3, Box.TextSize, Box.Font, Box.Parent = UDim2.new(0.4, 0, 0, 18), UDim2.new(0.6, -10, 0.5, -9), Color3.fromRGB(35, 35, 35), 0, tostring(Slider.Value), Color3.fromRGB(255, 255, 255), 12, Enum.Font.RobotoMono, SFrame
            Box.FocusLost:Connect(function() Slider.Value = Box.Text if callback then callback(Box.Text) end end)
            Slider.Frame, Slider.Label, Slider.Callback = SFrame, SLabel, function() Box:CaptureFocus() end
            table.insert(Tab.Children, Slider)
            return Slider
        end
        function Tab:AddDropdown(name, options, callback)
            local Dropdown = {Options = options or {}, Callback = callback, IsOpen = false, Children = {}}
            local DFrame = Instance.new("Frame")
            DFrame.Size, DFrame.BackgroundTransparency, DFrame.BorderSizePixel, DFrame.ClipsDescendants, DFrame.Parent = UDim2.new(1, 0, 0, 25), 1, 0, true, ChildContainer
            local DLabel = Instance.new("TextLabel")
            DLabel.Size, DLabel.Position, DLabel.BackgroundTransparency, DLabel.Text, DLabel.TextColor3, DLabel.TextSize, DLabel.Font, DLabel.TextXAlignment, DLabel.Active, DLabel.Parent = UDim2.new(1, -10, 0, 25), UDim2.new(0, 20, 0, 0), 1, "+ " .. name, Color3.fromRGB(150, 150, 150), 13, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, false, DFrame
            local OptContainer = Instance.new("Frame")
            OptContainer.Size, OptContainer.Position, OptContainer.BackgroundTransparency, OptContainer.Parent = UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 25), 1, DFrame
            local OptLayout = Instance.new("UIListLayout")
            OptLayout.Parent = OptContainer
            local function dToggle()
                Dropdown.IsOpen = not Dropdown.IsOpen
                DLabel.Text = (Dropdown.IsOpen and "- " or "+ ") .. name
                local h = Dropdown.IsOpen and (OptLayout.AbsoluteContentSize.Y + 25) or 25
                if Dropdown.IsOpen and h <= 25 then h = (#Dropdown.Options * 25) + 25 end
                Tween(DFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h)})
                Tween(OptContainer, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h - 25)})
            end
            DFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dToggle() end end)
            for _, opt in ipairs(Dropdown.Options) do
                local o = Instance.new("TextButton")
                o.Size, o.BackgroundColor3, o.BorderSizePixel, o.Text, o.TextColor3, o.TextSize, o.Font, o.TextXAlignment, o.Parent = UDim2.new(1, 0, 0, 25), Color3.fromRGB(30, 30, 30), 0, "    " .. opt, Color3.fromRGB(200, 200, 200), 12, Enum.Font.RobotoMono, Enum.TextXAlignment.Left, OptContainer
                o.MouseButton1Click:Connect(function() if callback then callback(opt) end dToggle() end)
            end
            Dropdown.Frame, Dropdown.Label, Dropdown.Callback = DFrame, DLabel, dToggle
            table.insert(Tab.Children, Dropdown)
            return Dropdown
        end
        return Tab
    end
    return Window
end
return Library
