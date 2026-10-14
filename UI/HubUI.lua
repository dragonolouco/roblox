local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Player=Players.LocalPlayer
local GuiParent=Player:WaitForChild("PlayerGui")
local Layout=_G.DragonHubLayout or {}
local Callbacks=_G.DragonHubCallbacks or {}
local Actions=_G.DragonHubActions or {}
local Pending=_G.DragonPendingHubValues or {}
local PendingActions=_G.DragonPendingHubActions or {}
_G.DragonHubCallbacks=Callbacks
_G.DragonHubActions=Actions
_G.DragonPendingHubValues=Pending
_G.DragonPendingHubActions=PendingActions

local function RemoveOldInterfaces(Parent)
if not Parent then return end
for _,Name in ipairs({"DragonHUBInterface","DragonHUBRuntimeInterface","ControlButtonGUI"}) do
local Old=Parent:FindFirstChild(Name)
if Old then Old:Destroy() end
end
end
RemoveOldInterfaces(GuiParent)
pcall(function()
    RemoveOldInterfaces(game:GetService("CoreGui")) end)
pcall(function()
    if gethui then RemoveOldInterfaces(gethui()) end end)

local function Round(Object,Radius)
local Corner=Instance.new("UICorner")
Corner.CornerRadius=UDim.new(0,Radius)
Corner.Parent=Object
end

local function RunSafe(Name,Callback,...)
local Arguments={...}
task.spawn(function()
local Success,Error=pcall(function()
    Callback(unpack(Arguments)) end)
if not Success then _G.DragonHubFunctionError=tostring(Name)..": "..tostring(Error) end
end)
end

local function Dispatch(Name,Value)
_G.DragonHubFunctionError=nil
local Callback=Callbacks[Name]
if Callback then
RunSafe(Name,Callback,Value)
else
Pending[Name]=Value
end
end

local Gui=Instance.new("ScreenGui")
Gui.Name="DragonHUBInterface"
Gui.ResetOnSpawn=false
Gui.IgnoreGuiInset=true
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.Parent=GuiParent

local Main=Instance.new("Frame")
Main.Size=UDim2.fromOffset(500,330)
Main.Position=UDim2.new(.5,-250,.5,-165)
Main.BackgroundColor3=Color3.fromRGB(14,15,25)
Main.BorderSizePixel=0
Main.Active=true
Main.Parent=Gui
Round(Main,12)
local Scale=Instance.new("UIScale")
Scale.Parent=Main
local function Resize()
local View=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(500,330)
Scale.Scale=math.min(1,(View.X-16)/500,(View.Y-16)/330)
end
Resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Resize) end
local Stroke=Instance.new("UIStroke")
Stroke.Color=Color3.fromRGB(65,70,108)
Stroke.Thickness=1
Stroke.Parent=Main

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,40)
Header.BackgroundColor3=Color3.fromRGB(22,24,39)
Header.BorderSizePixel=0
Header.Active=true
Header.Parent=Main
Round(Header,12)
local HeaderFill=Instance.new("Frame")
HeaderFill.Size=UDim2.new(1,0,0,12)
HeaderFill.Position=UDim2.new(0,0,1,-12)
HeaderFill.BackgroundColor3=Header.BackgroundColor3
HeaderFill.BorderSizePixel=0
HeaderFill.Parent=Header

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-90,1,0)
Title.Position=UDim2.fromOffset(13,0)
Title.BackgroundTransparency=1
Title.Text="DragonHUB | HUB | "..tostring(_G.DragonDetectedWorld or "Blox Fruits")
Title.TextColor3=Color3.fromRGB(238,240,255)
Title.TextSize=13
Title.Font=Enum.Font.GothamBold
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=Header

local Minimize=Instance.new("TextButton")
Minimize.Size=UDim2.fromOffset(25,20)
Minimize.Position=UDim2.new(1,-61,.5,-10)
Minimize.BackgroundColor3=Color3.fromRGB(42,44,64)
Minimize.BorderSizePixel=0
Minimize.Text="-"
Minimize.TextColor3=Color3.new(1,1,1)
Minimize.Font=Enum.Font.GothamBold
Minimize.TextSize=11
Minimize.Parent=Header
Round(Minimize,5)

local Close=Instance.new("TextButton")
Close.Size=UDim2.fromOffset(25,20)
Close.Position=UDim2.new(1,-31,.5,-10)
Close.BackgroundColor3=Color3.fromRGB(210,55,65)
Close.BorderSizePixel=0
Close.Text="X"
Close.TextColor3=Color3.new(1,1,1)
Close.Font=Enum.Font.GothamBold
Close.TextSize=10
Close.Parent=Header
Round(Close,5)
Close.MouseButton1Click:Connect(function()
    Gui.Enabled=false end)

local Status=Instance.new("TextLabel")
Status.Size=UDim2.new(1,-150,0,22)
Status.Position=UDim2.fromOffset(145,45)
Status.BackgroundColor3=Color3.fromRGB(25,27,43)
Status.BorderSizePixel=0
Status.Text="Carregando funções..."
Status.TextColor3=Color3.fromRGB(148,163,184)
Status.TextSize=10
Status.Font=Enum.Font.Gotham
Status.Parent=Main
Round(Status,6)

local Side=Instance.new("ScrollingFrame")
Side.Size=UDim2.new(0,128,1,-50)
Side.Position=UDim2.fromOffset(8,45)
Side.BackgroundColor3=Color3.fromRGB(20,21,35)
Side.BorderSizePixel=0
Side.ScrollBarThickness=2
Side.AutomaticCanvasSize=Enum.AutomaticSize.Y
Side.CanvasSize=UDim2.new()
Side.Parent=Main
Round(Side,8)
local SideLayout=Instance.new("UIListLayout")
SideLayout.Padding=UDim.new(0,4)
SideLayout.SortOrder=Enum.SortOrder.LayoutOrder
SideLayout.Parent=Side
local SidePadding=Instance.new("UIPadding")
SidePadding.PaddingTop=UDim.new(0,6)
SidePadding.PaddingLeft=UDim.new(0,5)
SidePadding.PaddingRight=UDim.new(0,5)
SidePadding.PaddingBottom=UDim.new(0,6)
SidePadding.Parent=Side

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-150,1,-76)
Content.Position=UDim2.fromOffset(143,71)
Content.BackgroundTransparency=1
Content.Parent=Main

local Pages={}
local TabButtons={}
local function WorldAllowed(World)
if World=="All" then return true end
if World=="Sea1" then return _G.DragonDetectedWorld=="Sea 1" end
if World=="Sea2" then return _G.DragonDetectedWorld=="Sea 2" end
if World=="Sea3" then return _G.DragonDetectedWorld=="Sea 3" end
if World=="Sea2Sea3" then return _G.DragonDetectedWorld~="Sea 1" end
return true
end

local function NewRow(Page,Height)
local Row=Instance.new("Frame")
Row.Size=UDim2.new(1,0,0,Height)
Row.BackgroundColor3=Color3.fromRGB(27,29,46)
Row.BorderSizePixel=0
Row.Parent=Page
Round(Row,7)
return Row
end

local function Label(Row,Text,Right)
local L=Instance.new("TextLabel")
L.Size=UDim2.new(1,-(Right or 70),1,0)
L.Position=UDim2.fromOffset(10,0)
L.BackgroundTransparency=1
L.Text=Text
L.TextColor3=Color3.fromRGB(225,228,244)
L.TextSize=11
L.Font=Enum.Font.Gotham
L.TextXAlignment=Enum.TextXAlignment.Left
L.TextWrapped=true
L.Parent=Row
return L
end

local function AddToggle(Page,Data)
local Row=NewRow(Page,40)
Label(Row,Data.Title,65)
local Track=Instance.new("Frame")
Track.Size=UDim2.fromOffset(42,22)
Track.Position=UDim2.new(1,-52,.5,-11)
Track.BackgroundColor3=Color3.fromRGB(63,66,85)
Track.BorderSizePixel=0
Track.Parent=Row
Round(Track,11)
local Knob=Instance.new("Frame")
Knob.Size=UDim2.fromOffset(16,16)
Knob.Position=UDim2.new(0,3,.5,-8)
Knob.BackgroundColor3=Color3.fromRGB(238,240,255)
Knob.BorderSizePixel=0
Knob.Parent=Track
Round(Knob,8)
local Hit=Instance.new("TextButton")
Hit.Size=UDim2.fromScale(1,1)
Hit.BackgroundTransparency=1
Hit.Text=""
Hit.Parent=Row
local Value=false
local function Render()
Track.BackgroundColor3=Value and Color3.fromRGB(37,99,235) or Color3.fromRGB(63,66,85)
Knob:TweenPosition(Value and UDim2.new(1,-19,.5,-8) or UDim2.new(0,3,.5,-8),Enum.EasingDirection.Out,
    Enum.EasingStyle.Quad,.12,true)
end
Hit.MouseButton1Click:Connect(function()
    Value=not Value Render()
    Dispatch(Data.Title,Value) end)
Render()
end

local function AddButton(Page,Data)
local Row=NewRow(Page,38)
local Hit=Instance.new("TextButton")
Hit.Size=UDim2.new(1,-8,1,-8)
Hit.Position=UDim2.fromOffset(4,4)
Hit.BackgroundColor3=Color3.fromRGB(88,61,190)
Hit.BorderSizePixel=0
Hit.Text=Data.Title
Hit.TextColor3=Color3.new(1,1,1)
Hit.TextSize=11
Hit.Font=Enum.Font.GothamBold
Hit.Parent=Row
Round(Hit,6)
Hit.MouseButton1Click:Connect(function()
local Action=Actions[Data.Title]
_G.DragonHubFunctionError=nil
if Action then RunSafe(Data.Title,Action) else PendingActions[Data.Title]=true end
end)
end

local function AddSlider(Page,Data)
local Row=NewRow(Page,52)
local Text=Label(Row,Data.Title..": "..tostring(Data.Default),15)
Text.Size=UDim2.new(1,-20,0,24)
local Track=Instance.new("Frame")
Track.Size=UDim2.new(1,-24,0,6)
Track.Position=UDim2.fromOffset(12,36)
Track.BackgroundColor3=Color3.fromRGB(61,64,84)
Track.BorderSizePixel=0
Track.Parent=Row
Round(Track,3)
local Fill=Instance.new("Frame")
Fill.BackgroundColor3=Color3.fromRGB(37,99,235)
Fill.BorderSizePixel=0
Fill.Parent=Track
Round(Fill,3)
local Value=Data.Default or Data.Min or 0
local function Set(Input)
local Ratio=math.clamp((Input.Position.X-Track.AbsolutePosition.X)/math.max(Track.AbsoluteSize.X,1),0,
    1)
Value=math.floor((Data.Min+Ratio*(Data.Max-Data.Min))+.5)
Fill.Size=UDim2.new(Ratio,0,1,0)
Text.Text=Data.Title..": "..tostring(Value)
local Callback=Callbacks[Data.Title]
if Callback then RunSafe(Data.Title,Callback,Value) else Pending[Data.Title]=Value end
end
local Initial=(Value-Data.Min)/math.max(Data.Max-Data.Min,1)
Fill.Size=UDim2.new(Initial,0,1,0)
local Hit=Instance.new("TextButton")
Hit.Size=UDim2.new(1,0,4,8)
Hit.Position=UDim2.new(0,0,0,-10)
Hit.BackgroundTransparency=1
Hit.Text=""
Hit.Parent=Track
local Drag=false
Hit.InputBegan:Connect(function(Input)
    if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then Drag=true
    Set(Input) end end)
UIS.InputChanged:Connect(function(Input)
    if Drag and (Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch) then Set(Input) end end)
UIS.InputEnded:Connect(function(Input)
    if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then Drag=false end end)
end

local ActiveDropdownClose
local function AddDropdown(Page,Data)
local Row=NewRow(Page,42)
Label(Row,Data.Title,145)
local Hit=Instance.new("TextButton")
Hit.Size=UDim2.fromOffset(130,28)
Hit.Position=UDim2.new(1,-140,.5,-14)
Hit.BackgroundColor3=Color3.fromRGB(45,48,72)
Hit.BorderSizePixel=0
Hit.Text="Carregando..."
Hit.TextColor3=Color3.fromRGB(225,228,244)
Hit.TextSize=10
Hit.Parent=Row
Round(Hit,6)
Hit.MouseButton1Click:Connect(function()
local Info=_G.DragonHubControlInfo and _G.DragonHubControlInfo[Data.Title]
local Values=Info and Info.Values or {}
if #Values==0 then return end
if ActiveDropdownClose then ActiveDropdownClose() end
local Overlay=Instance.new("TextButton")
Overlay.Size=UDim2.fromScale(1,1)
Overlay.BackgroundTransparency=1
Overlay.Text=""
Overlay.ZIndex=50
Overlay.Parent=Gui
local Height=math.min(#Values*30+8,188)
local Width=math.max(Hit.AbsoluteSize.X,170)
local Viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
local X=math.clamp(Hit.AbsolutePosition.X,6,math.max(6,Viewport.X-Width-6))
local Y=Hit.AbsolutePosition.Y+Hit.AbsoluteSize.Y+3
if Y+Height>Viewport.Y-6 then Y=math.max(6,Hit.AbsolutePosition.Y-Height-3) end
local Popup=Instance.new("Frame")
Popup.Size=UDim2.fromOffset(Width,Height)
Popup.Position=UDim2.fromOffset(X,Y)
Popup.BackgroundColor3=Color3.fromRGB(24,26,43)
Popup.BorderSizePixel=0
Popup.ZIndex=51
Popup.Parent=Gui
Round(Popup,8)
local PopupStroke=Instance.new("UIStroke")
PopupStroke.Color=Color3.fromRGB(74,80,125)
PopupStroke.Thickness=1
PopupStroke.Parent=Popup
local Options=Instance.new("ScrollingFrame")
Options.Size=UDim2.new(1,-8,1,-8)
Options.Position=UDim2.fromOffset(4,4)
Options.BackgroundTransparency=1
Options.BorderSizePixel=0
Options.ScrollBarThickness=3
Options.AutomaticCanvasSize=Enum.AutomaticSize.Y
Options.CanvasSize=UDim2.new()
Options.ZIndex=52
Options.Parent=Popup
local OptionsLayout=Instance.new("UIListLayout")
OptionsLayout.Padding=UDim.new(0,3)
OptionsLayout.SortOrder=Enum.SortOrder.LayoutOrder
OptionsLayout.Parent=Options
local Closed=false
local ClosePopup
ClosePopup=function()
if Closed then return end
Closed=true
if Popup.Parent then Popup:Destroy() end
if Overlay.Parent then Overlay:Destroy() end
if ActiveDropdownClose==ClosePopup then ActiveDropdownClose=nil end
end
ActiveDropdownClose=ClosePopup
Overlay.MouseButton1Click:Connect(ClosePopup)
for Order,Value in ipairs(Values) do
local Option=Instance.new("TextButton")
Option.Size=UDim2.new(1,-4,0,27)
Option.BackgroundColor3=tostring(Value)==Hit.Text and Color3.fromRGB(37,99,235) or Color3.fromRGB(38,
    41,62)
Option.BorderSizePixel=0
Option.Text=tostring(Value)
Option.TextColor3=Color3.fromRGB(232,235,250)
Option.TextSize=10
Option.TextXAlignment=Enum.TextXAlignment.Left
Option.Font=Enum.Font.Gotham
Option.LayoutOrder=Order
Option.ZIndex=53
Option.Parent=Options
Round(Option,5)
local OptionPadding=Instance.new("UIPadding")
OptionPadding.PaddingLeft=UDim.new(0,9)
OptionPadding.Parent=Option
Option.MouseButton1Click:Connect(function()
Hit.Text=tostring(Value)
if Info then Info.Value=Value end
local Callback=Callbacks[Data.Title]
if Callback then RunSafe(Data.Title,Callback,Value) else Pending[Data.Title]=Value end
ClosePopup()
end)
end
end)
task.spawn(function()
while Hit.Parent do
local Info=_G.DragonHubControlInfo and _G.DragonHubControlInfo[Data.Title]
if Info and Info.Values and #Info.Values>0 then
local Current=tostring(Info.Value or Info.Values[1])
if Hit.Text~=Current then Hit.Text=Current end
end
task.wait(.5)
end
end)
end

local function AddInput(Page,Data)
local Row=NewRow(Page,42)
Label(Row,Data.Title,145)
local Input=Instance.new("TextBox")
Input.Size=UDim2.fromOffset(130,28)
Input.Position=UDim2.new(1,-140,.5,-14)
Input.BackgroundColor3=Color3.fromRGB(45,48,72)
Input.BorderSizePixel=0
Input.Text=""
Input.PlaceholderText="Digite aqui"
Input.ClearTextOnFocus=false
Input.TextColor3=Color3.fromRGB(225,228,244)
Input.PlaceholderColor3=Color3.fromRGB(125,130,158)
Input.TextSize=10
Input.Parent=Row
Round(Input,6)
Input.FocusLost:Connect(function()
local Callback=Callbacks[Data.Title]
if Callback then RunSafe(Data.Title,Callback,Input.Text) else Pending[Data.Title]=Input.Text end
end)
end

local First
local function Select(Page)
if ActiveDropdownClose then ActiveDropdownClose() end
for _,P in pairs(Pages) do P.Visible=P==Page end
for Button,P in pairs(TabButtons) do Button.BackgroundColor3=P==Page and Color3.fromRGB(37,99,235) or Color3.fromRGB(34,
    36,55) end
end

for Order,Tab in ipairs(Layout) do
if WorldAllowed(Tab.World) then
local Button=Instance.new("TextButton")
Button.Size=UDim2.new(1,0,0,32)
Button.BackgroundColor3=Color3.fromRGB(34,36,55)
Button.BorderSizePixel=0
Button.Text=Tab.Title
Button.TextColor3=Color3.fromRGB(222,225,242)
Button.TextSize=10
Button.Font=Enum.Font.Gotham
Button.LayoutOrder=Order
Button.Parent=Side
Round(Button,6)
local Page=Instance.new("ScrollingFrame")
Page.Size=UDim2.fromScale(1,1)
Page.BackgroundTransparency=1
Page.BorderSizePixel=0
Page.ScrollBarThickness=3
Page.AutomaticCanvasSize=Enum.AutomaticSize.Y
Page.CanvasSize=UDim2.new()
Page.Visible=false
Page.Parent=Content
local List=Instance.new("UIListLayout")
List.Padding=UDim.new(0,5)
List.SortOrder=Enum.SortOrder.LayoutOrder
List.Parent=Page
local Padding=Instance.new("UIPadding")
Padding.PaddingRight=UDim.new(0,6)
Padding.PaddingBottom=UDim.new(0,6)
Padding.Parent=Page
for _,Control in ipairs(Tab.Controls) do
if WorldAllowed(Control.World or "All") then
if Control.Type=="Toggle" then AddToggle(Page,Control)
elseif Control.Type=="Button" then AddButton(Page,Control)
elseif Control.Type=="Slider" then AddSlider(Page,Control)
elseif Control.Type=="Dropdown" then AddDropdown(Page,Control)
elseif Control.Type=="Input" then AddInput(Page,Control) end
end
end
Pages[Tab.Key]=Page
TabButtons[Button]=Page
Button.MouseButton1Click:Connect(function()
    Select(Page) end)
if not First then First=Page end
end
end
if First then Select(First) end

local Dragging=false
local DragStart
local StartPosition
Header.InputBegan:Connect(function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then Dragging=true
    DragStart=Input.Position StartPosition=Main.Position end
end)
UIS.InputChanged:Connect(function(Input)
if Dragging and (Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch) then
local Delta=Input.Position-DragStart
Main.Position=UDim2.new(StartPosition.X.Scale,StartPosition.X.Offset+Delta.X,StartPosition.Y.Scale,StartPosition.Y.Offset+Delta.Y)
end
end)
UIS.InputEnded:Connect(function(Input)
    if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then Dragging=false end end)

local Minimized=false
Minimize.MouseButton1Click:Connect(function()
if ActiveDropdownClose then ActiveDropdownClose() end
Minimized=not Minimized
Main.Size=Minimized and UDim2.fromOffset(500,40) or UDim2.fromOffset(500,330)
Side.Visible=not Minimized
Content.Visible=not Minimized
Status.Visible=not Minimized
Minimize.Text=Minimized and "+" or "-"
end)

task.spawn(function()
while Gui.Parent do
if _G.DragonHubRuntimeError then
Status.Text="Erro no runtime: "..tostring(_G.DragonHubRuntimeError)
Status.TextColor3=Color3.fromRGB(248,113,113)
elseif _G.DragonHubFunctionError then
Status.Text="Erro na função: "..tostring(_G.DragonHubFunctionError)
Status.TextColor3=Color3.fromRGB(248,113,113)
else
local Count=0
for _ in pairs(Callbacks) do Count=Count+1 end
Status.Text=Count>0 and ("Funções prontas: "..Count) or "Carregando funções..."
Status.TextColor3=Count>0 and Color3.fromRGB(74,222,128) or Color3.fromRGB(148,163,184)
end
task.wait(1)
end
end)

_G.DragonHUBInterfaceReady=true
