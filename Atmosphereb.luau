-- Atmosphere.lua
--[[
	Made by Pulsarnova (A.k.a. BangoutBoy)
	edited by @vietnamricefarmerz / @_kuronjie
	Version 69
]]
--[[
	/* This script is a code crime. Probably YandereDev level. But I didn't code it, I tried to fix
	   it, so really, who cares? */
]]

--/ add type checking to this because what even...
local AtmoSphere = {
	-- Performance
	LimitRate = true,
	MaxRefreshRate = 1/60,
	LastUpdate = os.clock(),

	-- Colors
	AtmosphereColor = Color3.fromRGB(115, 180, 255),
	AtmosphereReflectionColor = Color3.fromRGB(42, 133, 198),
	AtmosphereSunsetColor = Color3.fromRGB(171, 213, 255),
	AtmosphericExtinctionColor = Color3.fromRGB(255, 100, 0),
	AstronomicalTwilightAtmosphericExtinctionColor = Color3.fromRGB(60, 60, 60),
	InnerAtmosphericExtinctionColor = Color3.fromRGB(255, 85, 0),
	NauticalInnerAtmosphericExtinctionColor = Color3.fromRGB(150, 125, 50),
	NauticalTwilightAtmosphericExtinctionColor = Color3.fromRGB(255, 100, 50),
	AtmosphereTransparency = 1,
	AtmosphereThickness = 1,
	SunsideAtmosphericExtinctionColor = Color3.fromRGB(255, 20, 0),
	BeltOfVenusColor = Color3.fromRGB(0, 13, 25),
	DistantSurfaceColor = Color3.fromRGB(45, 118, 255),

	-- Airglow
	EnableAirglow = true,
	AirglowColor = Color3.fromRGB(0, 255, 0),
	AirglowTransparency = 0.93,

	-- Lighting Changes
	EnableEnvironmentalLightingChanges = true,
	DaytimeSunlightColor = Color3.fromRGB(255, 255, 255),
	NightBrightness = 0,
	OutdoorAmbientBrightnessDay = 128,
	OutdoorAmbientBrightnessNight = 48,
	SunlightBrightness = 5,
	SunriseSunlightColor = Color3.fromRGB(255, 140, 20),

	-- Moon
	EnableMoon = true,
	MoonApparentDiameter = 31.6,
	MoonTexture = "rbxassetid://10855868393",

	-- Sun
	EnableSun = true,
	SunApparentDiameter = 31.983,
	SunAtmosphericExtinctionColor = Color3.fromRGB(255, 140, 50),
	SunAtmosphericExtinctionIntermediateColor = Color3.fromRGB(255, 200, 80),
	SunTemp = 5505,
	SunshineTexture = "rbxassetid://5192965045",
	ThreeDimensionalSunAtmosphericExtinctionColor = Color3.fromRGB(255, 20, 0),
	EnableSunsetScattering = true,

	-- Planet
	PlanetTexture = "rbxassetid://5079554320",
	PlanetTextureNight = "rbxassetid://5088333693",
	PlanetTransparency = 0.421,
	AltitudeOffset = 0,
	Scale = 2.3,
	
	-- Ground Atmosphere
	EnableGroundAtmosphere = true,
	GroundAtmosphereTransparency = 0.8,

	-- Fog
	FogEndRatio = 1,
}
AtmoSphere.AtmosphereMetadata = {}

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Player = game:GetService("Players").LocalPlayer
if not Player then
	return
end
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--/ Ensures that the player to script connection doesn't glitch!
Player.CharacterAdded:Connect(function(Char)
	Character = Char
	Humanoid = Char:WaitForChild("Humanoid")
	HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
end)

for _, v in pairs(Lighting:GetDescendants())do
	if v.ClassName == "Atmosphere" then
		v:Destroy()
	end
end

--/ some global variables
local ScaleFactor = AtmoSphere.Scale
local meta = AtmoSphere.AtmosphereMetadata
local x = (Camera.CFrame.Y + AtmoSphere.AltitudeOffset) * ScaleFactor
local SunTextureGui: ScreenGui

--/ helper function
function AtmoSphere:GlobalScope()
	self.SunDirectionV = Lighting:GetSunDirection()
	self.SunDirectionLength = self.SunDirectionV * 999
	self.CamToSunDirection = self.SunDirectionLength - Camera.CFrame.LookVector
	self.SunElevation = math.deg(math.atan((self.CamToSunDirection.Y)/math.sqrt(self.CamToSunDirection.X^2+self.CamToSunDirection.Z^2)))
	self.atten = 2 ^ (-x/500000)
	self.H1 = 6 * self.atten
end

AtmoSphere:GlobalScope()

function AtmoSphere:Init()
	if self.Initialized then
		return
	end
	self.Initialized = true
	
	--/ Atmosphere model
	meta.AtmosphereModel = Instance.new("Model", workspace)
	meta.AtmosphereModel.Name = "Atmosphere"
	
	--/ Atmosphere
	meta.Atmosphere = Instance.new("Part", meta.AtmosphereModel)
	meta.Atmosphere.CastShadow = false
	meta.Atmosphere.CanCollide = false
	meta.Atmosphere.Anchored = true
	meta.Atmosphere.Material = "Fabric"
	meta.Atmosphere.Name = "Atmosphere"
	meta.Atmosphere.Size = Vector3.new(1, 1, 1)
	meta.Atmosphere.Orientation = Vector3.new(0, -90, 0)
	meta.Atmosphere.Position = Camera.CFrame.Position
	meta.Atmosphere.Color = Color3.new(0,0,0)
	meta.Atmosphere.Transparency = 0
	
	--/ Distant surface
	meta.DistantSurface = Instance.new("Part", meta.AtmosphereModel)
	meta.DistantSurface.Size = Vector3.new(1, 1, 1)
	meta.DistantSurface.Color = Color3.new(33/255, 84/255, 185/255)
	meta.DistantSurface.Name = "DistantSurface"
	meta.DistantSurface.CanCollide = false
	meta.DistantSurface.Orientation = Vector3.new(0, -90, 0)
	meta.DistantSurface.CastShadow = false
	meta.DistantSurface.Anchored = true
	meta.DistantSurface.Material = "SmoothPlastic"
	
	--/ distant surface mesh
	meta.SurfaceMesh = Instance.new("FileMesh", meta.DistantSurface)
	meta.SurfaceMesh.MeshId = "rbxassetid://452341386"
	meta.SurfaceMesh.Scale = Vector3.new(700, 1000, 700)
	
	--/ Atmosphere mesh
	meta.Mesh = Instance.new("FileMesh", meta.Atmosphere)
	meta.Mesh.MeshId = "rbxassetid://5077225120"
	meta.Mesh.Scale = Vector3.new(7600, 3000, 7600)
	meta.Mesh.TextureId = "http://www.roblox.com/asset/?ID=2013298"
	
	--/ Sky
	meta.Sky = Lighting.Sky
	
	--/ Earth
	meta.Earth = Instance.new("Part", meta.AtmosphereModel)
	meta.Earth.Anchored = true
	meta.Earth.Name = "EarthSurface"
	meta.Earth.CanCollide = false
	meta.Earth.Size = Vector3.new(1,1,1)
	meta.Earth.Color = Color3.new(33/255, 84/255, 185/255)
	meta.Earth.CastShadow = false
	meta.Earth.Material = "ForceField"
	meta.Earth.Transparency = 0
	
	meta.EarthMesh = Instance.new("FileMesh", meta.Earth)
	meta.EarthMesh.MeshId = "rbxassetid://5276376752"
	meta.EarthMesh.TextureId = "rbxassetid://2013298"
	meta.EarthMesh.VertexColor = Vector3.new((115/255)*2, (152/255)*2, 2)
	
	meta.EarthTexture = Instance.new("Decal", meta.Earth)
	meta.EarthTexture.Texture = self.PlanetTexture
	
	--/ earth terminator
	meta.EarthTerminator = Instance.new("Part", meta.AtmosphereModel)
	meta.EarthTerminator.Anchored = true
	meta.EarthTerminator.Name = "EarthTerminator"
	meta.EarthTerminator.CanCollide = false
	meta.EarthTerminator.Size = Vector3.new(1,1,1)
	meta.EarthTerminator.Color = Color3.new(33/255, 84/255, 185/255)
	meta.EarthTerminator.Transparency = 1
	meta.EarthTerminator.CastShadow = false
	
	meta.EarthTerminatorMesh = Instance.new("FileMesh", meta.EarthTerminator)
	meta.EarthTerminatorMesh.MeshId = "rbxassetid://5276376752"
	meta.EarthTerminatorTexture = Instance.new("Decal", meta.EarthTerminator)
	meta.EarthTerminatorTexture.Texture = "rbxassetid://5410829227"
	
	--/ earth terminator 2
	meta.EarthTerminator2 = Instance.new("Part", meta.AtmosphereModel)
	meta.EarthTerminator2.Anchored = true
	meta.EarthTerminator2.Name = "EarthTerminator2"
	meta.EarthTerminator2.CanCollide = false
	meta.EarthTerminator2.Size = Vector3.new(1,1,1)
	meta.EarthTerminator2.Color = Color3.new(33/255, 84/255, 185/255)
	meta.EarthTerminator2.Transparency = 1
	meta.EarthTerminator2.CastShadow = false

	meta.EarthTerminatorMesh2 = Instance.new("FileMesh", meta.EarthTerminator2)
	meta.EarthTerminatorMesh2.MeshId = "rbxassetid://5276376752"
	meta.EarthTerminatorTexture2 = Instance.new("Decal", meta.EarthTerminator2)
	meta.EarthTerminatorTexture2.Texture = "rbxassetid://5410829627"
	
	--/ extinctions
	meta.Extinction = script.AtmosphericExtinction:Clone()
	meta.Extinction.Parent = meta.AtmosphereModel
	
	meta.ExtinctionSunset = script.AtmosphericExtinctionSunset:Clone()
	meta.ExtinctionSunset.Parent = meta.AtmosphereModel
	
	--/ airglow
	meta.AirglowLayer = Instance.new("Part", meta.AtmosphereModel)
	meta.AirglowLayer.Anchored = true
	meta.AirglowLayer.Name = "Airglow"
	meta.AirglowLayer.CanCollide = false
	meta.AirglowLayer.Size = Vector3.new(1,1,1)
	meta.AirglowLayer.Color = Color3.new(58/255, 125/255, 21/255)
	meta.AirglowLayer.Orientation = Vector3.new(0,0,0)
	meta.AirglowLayer.CastShadow = false
	meta.AirglowLayer.Material = "ForceField"
	meta.AirglowLayer.Transparency = self.AirglowTransparency
	
	meta.AirglowMesh = Instance.new("FileMesh", meta.AirglowLayer)
	meta.AirglowMesh.MeshId = "rbxassetid://1886703108"
	meta.AirglowMesh.TextureId = "rbxassetid://2013298"
	meta.AirglowMesh.VertexColor = Vector3.new(0,1,0)
	
	--/ bottom atmosphere
	meta.BottomAtmosphere = Instance.new("Part", meta.AtmosphereModel)
	meta.BottomAtmosphere.Anchored = true
	meta.BottomAtmosphere.Name = "BottomAtmosphere"
	meta.BottomAtmosphere.CanCollide = false
	meta.BottomAtmosphere.Size = Vector3.new(1, 1, 1)
	meta.BottomAtmosphere.Color = Color3.new(33/255, 84/255, 185/255)
	meta.BottomAtmosphere.Orientation = Vector3.new(0,90,-90)
	meta.BottomAtmosphere.CastShadow = false
	meta.BottomAtmosphere.Material = "ForceField"
	meta.BottomAtmosphere.Transparency = 0.6
	
	meta.BottomAtmosphereMesh = Instance.new("FileMesh", meta.BottomAtmosphere)
	meta.BottomAtmosphereMesh.MeshId = "rbxassetid://5276376752"
	meta.BottomAtmosphereMesh.TextureId = "rbxassetid://2013298"
	meta.BottomAtmosphereMesh.VertexColor = Vector3.new((115/255)*2,(152/255)*2,2)
	meta.BottomAtmosphereMesh.Scale = Vector3.new(400,3000,3000)
	
	--/ lighting
	self.LightEmissionEquation = 1
	self.OutdoorAmbientBrightnessEquation = 128
	
	--/ fog
	Lighting.FogColor = Color3.new(115/255, 152/255, 255/255)
	Lighting.FogEnd = 100000
	Lighting.FogStart = 0
	self.FogEndRatio = 1
	
	--/ variables
	self.EarthPositionEquation = 1
	self.EarthMeshEquation = 100000
	self.EarthTransparency = self.PlanetTransparency
	
	--/ extinction
	self.ExtinctionTransparencyMultiplier = 1
	self.ExtinctionTransparencyEquation = 0
	self.ExtinctionColorEquation = 255
	self.ExtinctionWidthEquation = 40000
	self.ExtinctionOrientationEquation = 81
	self.ShowTerminator = 1
	
	--/ misc
	self.AirglowTransparencyFactor = 0
	self.HorizonElevationSunsetDifference10 = 10
	self.AtmosphereApparentHeight = 5.5
	
	--/ sun
	self.SunBrightness = 1
	self.SunColor = Color3.fromRGB(255, 255, 255)
	self.SunOffset = Vector2.new(0, 0)

	--/ clocktime & axial tilt
	self.InitialTime = Lighting.ClockTime
	self.InitialGL = Lighting.GeographicLatitude
	
	--/ clock
	self.FindServerClockTime = workspace:FindFirstChild("ServerClockTime")
	self.ClockTimeExists = false
	if self.FindServerClockTime then
		self.ClockTimeExists = true
	else
		self.ClockTimeExists = false
	end
	if self.ClockTimeExists then
		self.InitialTime = workspace.ServerClockTime.Value % 24
	else
		self.InitialTime = Lighting.ClockTime
	end
	
	--/ sun
	meta.Sun3D = script.Sun3D
	meta.Sun3D.Parent = meta.AtmosphereModel
	meta.Sun3D.Transparency = 0.011
	meta.BottomAtmosphereDarkness = Instance.new("Decal", meta.BottomAtmosphere)
	meta.BottomAtmosphereDarkness.Texture = "rbxassetid://7983012824"
	
	self:CreateSun()
	self:Resume()
end

function AtmoSphere:Pause()
	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end
	RunService:UnbindFromRenderStep("Sunshine")
end

function AtmoSphere:Resume()
	if self.Running then
		return
	end
	self.Running = true
	self.UpdateConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
	RunService:BindToRenderStep("Sunshine", Enum.RenderPriority.Last.Value, function()
		self:UpdateSun()
	end)
end

--/ sun object
function AtmoSphere:CreateSun()
	for _, v in pairs(script.Parent:GetChildren()) do
		if v:IsA("ScreenGui") then
			SunTextureGui = v
			break
		end
	end
	if not SunTextureGui then 
		SunTextureGui = Instance.new("ScreenGui", Player.PlayerGui)
		SunTextureGui.ResetOnSpawn = false
		SunTextureGui.DisplayOrder = -1 
		SunTextureGui.Name = "Sun"
	end

	meta.SunTexture = Instance.new("ImageLabel", SunTextureGui)
	meta.SunTexture.Image = self.SunshineTexture
	meta.SunTexture.BackgroundTransparency = 1
	meta.SunTexture.Size = UDim2.new(0, 1000, 0, 1000)
	meta.SunTexture.AnchorPoint = Vector2.new(0.5, 0.5)
	meta.SunTexture.ZIndex = 1

	meta.SunTexture2 = Instance.new("ImageLabel", SunTextureGui)
	meta.SunTexture2.Image = "rbxassetid://5200654205"
	meta.SunTexture2.BackgroundTransparency = 1
	meta.SunTexture2.Size = UDim2.new(0, (2100/Camera.FieldOfView), 0, (2100/Camera.FieldOfView))
	meta.SunTexture2.AnchorPoint = Vector2.new(0.5,0.5)
	meta.SunTexture2.ZIndex = 2

	meta.SunTexture3 = meta.SunTexture:Clone()
	meta.SunTexture3.Parent = SunTextureGui

	self.IsObstructed = false
	--/ static variables
	self.SunOffset = Vector2.new(0, 0)
	if not x then
		x = (Camera.CFrame.Y + self.AltitudeOffset) * ScaleFactor
	end
	self.ignore = {}
	self.ignore[meta.Atmosphere] = meta.Atmosphere
	self.obstructedsize = UDim2.new(0, -5, 0, -5)
	return
end

function AtmoSphere:UpdateSun(deltaTime: number)
	--[[
	RunService:UnbindFromRenderStep("Sunshine")
	RunService:BindToRenderStep("Sunshine", Enum.RenderPriority.Last.Value, function()
	]]
	
	--/ throttle
	if self.LimitRate then
		local now = os.clock()
		if (now - self.LastUpdate) + (1 / math.random(60, 120)) <= deltaTime * 3 + self.MaxRefreshRate then
			return
		end
		self.LastUpdate = now
	end
	
	--/ main
	if not x then
		x = AtmoSphere:GetOffset()
	end
	
	--/ local scope
	local sunPosition = Camera.CFrame.Position + self.SunDirectionLength
	local screenPosition, isVisible = Camera:WorldToScreenPoint(sunPosition)
	local HorizonElevation = -math.deg(math.acos(20925656.2/(20925656.2+x)))
	local CamZoomDistance = (Camera.Focus.Position - Camera.CFrame.Position).Magnitude
	local HorizonElevationSunsetDifference = self.SunElevation-HorizonElevation
	
	local SunExtinctionColor = Color3.fromRGB(
		self.SunAtmosphericExtinctionColor.R*255,
		self.SunAtmosphericExtinctionColor.G*255,
		self.SunAtmosphericExtinctionColor.B*255
	)
	local SunExtinctionColorIntermediate = Color3.fromRGB(
		self.SunAtmosphericExtinctionIntermediateColor.R*255,
		self.SunAtmosphericExtinctionIntermediateColor.G*255,
		self.SunAtmosphericExtinctionIntermediateColor.B*255
	)
	
	local SunsetFOVTransparencyScale = 1 - math.clamp(((Camera.FieldOfView - 5) / 5 + 1) 
		* (HorizonElevationSunsetDifference ^ 3 / 10), 0, 1)
	self.SunApparentDiameterRatio = self.SunApparentDiameter / 31.983
	
	-- local scope cache
	local H2 = 3 * self.atten
	local vs = UDim2.new(0,screenPosition.X,0,screenPosition.Y)
	
	-- horizon elevation sunset difference
	if HorizonElevationSunsetDifference <= 0 then
		self.HorizonElevationSunsetDifference10 = 0
	elseif HorizonElevationSunsetDifference > 0 and HorizonElevationSunsetDifference <= self.H1 then
		self.HorizonElevationSunsetDifference10 = HorizonElevationSunsetDifference
	elseif HorizonElevationSunsetDifference > self.H1 then
		self.HorizonElevationSunsetDifference10 = self.H1
	end
	local HorizonElevationSunsetDifference10Ratio = self.HorizonElevationSunsetDifference10 / self.H1
	local HorizonElevationSunsetDifference10Ratio3 = (math.clamp(self.HorizonElevationSunsetDifference10, 0, 2) * 3) / self.H1
	local HorizonElevationSunsetDifference10Ratio1_5 = (math.clamp(self.HorizonElevationSunsetDifference10, 0, 1) * 6) / self.H1
	
	if CamZoomDistance <= 1.1 then -- Check if player is in first person.
		self.ignore[Character] = Character
	elseif CamZoomDistance > 1.1 then
		self.ignore[Character] = nil
	end

	-- Checks if something is blocking the Sun
	-- Camera.CFrame.Position, self.SunDirectionV * 999 // Line 464
	local raycastparams = RaycastParams.new({
		FilterType = Enum.RaycastFilterType.Exclude,
		FilterDescendantsInstances = self.ignore,
	})
	
	local Obstructed, hitPosition = workspace:Raycast(Camera.CFrame.Position, self.SunDirectionLength, raycastparams)
	meta.SunTexture.Position = vs
	meta.SunTexture2.Position = vs
	meta.SunTexture3.Position = vs
	if Obstructed then 
		self.IsObstructed = true
	else
		self.IsObstructed = false
	end
	
	if isVisible then -- Converts the Sun's location in the sky to position coordinates of the shine gui.
		local AltitudeSunTransparencyFadeRate = math.clamp(-0.00000133333333333 * x + 0.75666666666666, 0.55, 0.75)
		meta.SunTexture.ImageTransparency = 1 - math.clamp(
			((2 - (2.6111111111111 * AltitudeSunTransparencyFadeRate))
				* 30 * (HorizonElevationSunsetDifference10Ratio3 + 0.55
					- AltitudeSunTransparencyFadeRate - SunsetFOVTransparencyScale)),
			0,
			1
		)
		-- sun size cache
		local sizeoffset = 100 + HorizonElevationSunsetDifference10Ratio * 900*self.SunBrightness*(-((Camera.FieldOfView-70)/200)+1)
		meta.SunTexture:TweenSize(
			UDim2.new(
				0, sizeoffset,
				0, sizeoffset
			),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.1,
			true
		)
		meta.SunTexture2.ImageTransparency = 1 - math.clamp(
			((2 - (2.6111111111111 * AltitudeSunTransparencyFadeRate))
				* 30 * (HorizonElevationSunsetDifference10Ratio1_5 + 0.55
					- AltitudeSunTransparencyFadeRate - SunsetFOVTransparencyScale)),
			0,
			1
		)
		meta.SunTexture2:TweenSize(
			UDim2.new(
				0, ((2.5*Camera.ViewportSize.Y*self.SunApparentDiameter/31.983)/Camera.FieldOfView)*self.SunBrightness,
				0, ((2.5*Camera.ViewportSize.Y*self.SunApparentDiameter/31.9)/Camera.FieldOfView)*self.SunBrightness
			),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.1,
			true
		)
		meta.Sun3D.SunsetLight.Light.ImageTransparency = HorizonElevationSunsetDifference10Ratio
		meta.Sun3D.Mesh.Scale = Vector3.new(
			12.25,
			10.5 + (1.75 * HorizonElevationSunsetDifference10Ratio),
			12.25
		) * self.SunApparentDiameterRatio
		if self.IsObstructed then
			meta.SunTexture:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
			meta.SunTexture2:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		elseif self.SunElevation <= HorizonElevation then
			meta.SunTexture:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
			meta.SunTexture2:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		elseif not HorizonElevation then
			meta.SunTexture:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
			meta.SunTexture2:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		end
		meta.SunTexture3.Size = UDim2.new(0, meta.SunTexture.Size.X.Offset / 2, 0, meta.SunTexture.Size.Y.Offset / 2)
		meta.SunTexture3.ImageColor3 = Color3.new(
			meta.SunTexture.ImageColor3.R * 1.5,
			meta.SunTexture.ImageColor3.G * 1.5,
			meta.SunTexture.ImageColor3.B * 1.5
		)
		meta.SunTexture3.Position = meta.SunTexture.Position
		meta.SunTexture3.Rotation = meta.SunTexture.Rotation
		meta.SunTexture3.ImageTransparency = meta.SunTexture.ImageTransparency
	else
		meta.SunTexture:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		meta.SunTexture2:TweenSize(self.obstructedsize,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
		meta.SunTexture3.Size = meta.SunTexture.Size
	end

	if meta.SunTexture.Size.X.Offset <= 0 then -- To ensure the Sun is completely invisible when player is facing away from the Sun.
		meta.SunTexture.Visible = false
		meta.SunTexture2.Visible = false
		meta.SunTexture3.Visible = false
	else
		meta.SunTexture.Visible = true
		meta.SunTexture2.Visible = true
		meta.SunTexture3.Visible = true
	end

	-- Sun Temperature
	local TempValue = math.clamp(self.SunTemp, 2001, math.huge)
	if not self.EnableSunsetScattering then
		TempValue = self.SunTemp
	end
	local Temp = (TempValue + 1095) / 100
	if TempValue <= 0 then
		self.SunColor = Color3.fromRGB(
			255,
			76,
			0
		)
	elseif TempValue > 0 and TempValue <= 1000 then
		self.SunColor = Color3.fromRGB(
			255,
			99.4708025861*math.log(Temp)-161.1195681661,
			0
		)
	elseif TempValue > 1000 and TempValue <= 2000 then
		self.SunColor = Color3.fromRGB(
			255,
			104.49216199393888*math.log(Temp-2)-0.44596950469579133*Temp-155.25485562709179,
			0
		)
	elseif TempValue > 2000 and TempValue <= 6600 then
		self.SunColor = Color3.fromRGB(
			255,
			104.49216199393888*math.log(Temp-2)-0.44596950469579133*Temp-155.25485562709179,
			115.67994401066147*math.log(Temp-10)+0.8274096064007395*Temp-254.76935184120902
		)
	elseif TempValue > 6600 and TempValue <= 40000 then
		self.SunColor = Color3.fromRGB(
			-40.25366309332127*math.log(Temp-55)+0.114206453784165*Temp+351.97690566805693,
			-28.0852963507957*math.log(Temp-50)+0.07943456536662342*Temp+325.4494125711974,
			115.67994401066147*math.log(Temp-10)+0.8274096064007395*Temp-254.76935184120902
		)
	elseif TempValue > 40000 then
		self.SunColor = Color3.fromRGB(
			162,
			192,
			255
		)
	end
	
	if self.EnableSunsetScattering then
		-- intermediate color cache
		local hrzoffset = math.clamp(self.HorizonElevationSunsetDifference10, H2, H2 * 2) - H2
		local H3 = H2 * self.atten
		local IntermediateColor = Color3.new(
			math.clamp(((((self.SunColor.R * 255 - math.clamp(SunExtinctionColorIntermediate.R * 255, 0, self.SunColor.R * 255 - 1)) 
				/ H3) 
				* hrzoffset
				+ SunExtinctionColorIntermediate.R * 255) / 255), 0, 1),

			math.clamp(((((self.SunColor.G * 255 - math.clamp(SunExtinctionColorIntermediate.G * 255, 0, self.SunColor.G * 255 - 1)) 
				/ H3) 
				* hrzoffset
				+ SunExtinctionColorIntermediate.G * 255) / 255), 0, 1),

			math.clamp(((((self.SunColor.B * 255 - math.clamp(SunExtinctionColorIntermediate.B * 255, 0, self.SunColor.B * 255 - 1)) 
				/ H3) 
				* hrzoffset
				+ SunExtinctionColorIntermediate.B * 255) / 255), 0, 1)
		)

		meta.SunTexture.ImageColor3 = Color3.new(
			math.clamp(((((IntermediateColor.R * 255 - SunExtinctionColor.R * 255) 
				/ self.H1) 
				* self.HorizonElevationSunsetDifference10 + SunExtinctionColor.R * 255) / 255), 0, 1),

			math.clamp(((((IntermediateColor.G * 255 - SunExtinctionColor.G * 255) 
				/ self.H1) 
				* self.HorizonElevationSunsetDifference10 + SunExtinctionColor.G * 255) / 255), 0, 1),

			math.clamp(((((IntermediateColor.B * 255 - SunExtinctionColor.B * 255) 
				/ self.H1) 
				* self.HorizonElevationSunsetDifference10 + SunExtinctionColor.B * 255) / 255), 0, 1)
		)
	else
		meta.SunTexture.ImageColor3 = Color3.new(
			math.clamp((((self.SunColor.R * 255 - SunExtinctionColor.R * 255) 
				/ self.H1
				* self.HorizonElevationSunsetDifference10 + SunExtinctionColor.R * 255) / 255), 0, 1),

			math.clamp((((self.SunColor.G * 255 - SunExtinctionColor.G * 255) 
				/ self.H1
				* self.HorizonElevationSunsetDifference10 + SunExtinctionColor.G * 255) / 255), 0, 1),

			math.clamp((((self.SunColor.B * 255 - SunExtinctionColor.B * 255) 
				/ self.H1
				* self.HorizonElevationSunsetDifference10 + SunExtinctionColor.B * 255) / 255), 0, 1)
		)
	end
	meta.SunTexture.Rotation = -(screenPosition.x-Camera.ViewportSize.X/2)/100 -- Sunshine rotation as a function of the screen's x-axis.
	
	--/ sunset
	if Lighting.ClockTime < 12 then
		meta.Sun3D.SunsetLight.ExtentsOffsetWorldSpace = Vector3.new(5, 0, 0)
	else
		meta.Sun3D.SunsetLight.ExtentsOffsetWorldSpace = Vector3.new(-5, 0, 0)
	end
		
	local AboveHorizon = HorizonElevationSunsetDifference > -2
	if x > 5000 then
		AboveHorizon = HorizonElevationSunsetDifference > 0
	elseif x > 1000 and x <= 5000 then
		AboveHorizon = HorizonElevationSunsetDifference > -0.5
	end
	if self.EnableSun then
		if AboveHorizon and HorizonElevationSunsetDifference < self.H1 then
			meta.Sun3D.Position = Camera.CFrame.Position
			meta.Sun3D.Mesh.Offset = Vector3.new(70000, 70000, 70000) * self.SunDirectionV
		else
			meta.Sun3D.Position = Vector3.new(0, -200000, 0)
			meta.Sun3D.Mesh.Offset = meta.Sun3D.Position
		end
		meta.Sun3D.SunsetLight.StudsOffsetWorldSpace = meta.Sun3D.Mesh.Offset
		meta.Sun3D.SunsetLight.Brightness = math.clamp(400 - (x / 28), 40, 400)
		meta.Sun3D.SunsetLight.Size = UDim2.new(10000 * self.SunBrightness, 0, math.clamp((-x / 16) + 10000, 4000, 10000) * self.SunBrightness, 0)
		meta.Sun3D.SunsetLight.Light.ImageColor3 = self.ThreeDimensionalSunAtmosphericExtinctionColor
		SunTextureGui.Enabled = true
		meta.Sky.SunTextureId = "rbxassetid://6196665106"
	else
		meta.Sun3D.Position = Camera.CFrame.Position - Vector3.new(0, 100000, 0)
		SunTextureGui.Enabled = false
		meta.Sky.SunTextureId = ""
	end
end

function AtmoSphere:Update(deltaTime)
	AtmoSphere:GlobalScope()
	if self.LimitRate then
		local now = os.clock()
		if (now - self.LastUpdate) + (1 / math.random(60, 120)) <= deltaTime * 3 + self.MaxRefreshRate then
			return
		end
		self.LastUpdate = now
	end
	
	--/ main
	--/ declare some variables.
	local AtmoHeight = ((self.AtmosphereThickness)^-1)^0.0625
	
	local H3 = 10*(self.atten)
	local H15 = 15*(self.atten)
	local HS = (H3 / 2.666666666666)
	
	if not x then
		x = (Camera.CFrame.Y + self.AltitudeOffset) * ScaleFactor
	end
	
	local ColorR = self.AtmosphereColor.R * 255
	local ColorG = self.AtmosphereColor.G * 255
	local ColorB = self.AtmosphereColor.B * 255
	
	local ColorR2 = self.DistantSurfaceColor.R * 255
	local ColorG2 = self.DistantSurfaceColor.G * 255
	local ColorB2 = self.DistantSurfaceColor.B * 255
	
	local ColorRSunset = self.AtmosphereSunsetColor.R * 255
	local ColorGSunset = self.AtmosphereSunsetColor.G * 255
	local ColorBSunset = self.AtmosphereSunsetColor.B * 255
	
	local DaycolorR = self.DaytimeSunlightColor.R
	local DaycolorG = self.DaytimeSunlightColor.G
	local DaycolorB = self.DaytimeSunlightColor.B

	local SunsetColorR = self.SunriseSunlightColor.R
	local SunsetColorG = self.SunriseSunlightColor.G
	local SunsetColorB = self.SunriseSunlightColor.B
	
	if self.EnableEnvironmentalLightingChanges then
		Lighting.OutdoorAmbient = Color3.new(self.OutdoorAmbientBrightnessEquation,self.OutdoorAmbientBrightnessEquation,self.OutdoorAmbientBrightnessEquation)
		Lighting.Brightness = self.SunBrightness
		Lighting.ColorShift_Top = Color3.new(
			(((DaycolorR-SunsetColorR)/(self.H1))*self.HorizonElevationSunsetDifference10)+SunsetColorR,
			(((DaycolorG-SunsetColorG)/(self.H1))*self.HorizonElevationSunsetDifference10)+SunsetColorG,
			(((DaycolorB-SunsetColorB)/(self.H1))*self.HorizonElevationSunsetDifference10)+SunsetColorB
		)
	end	
	
	local AtmosphericExtinctionR = self.AtmosphericExtinctionColor.R*255
	local AtmosphericExtinctionG = self.AtmosphericExtinctionColor.G*255
	local AtmosphericExtinctionB = self.AtmosphericExtinctionColor.B*255

	local HorizonElevation = -math.deg(math.acos(20925656.2/(20925656.2+math.clamp(x, 0, math.huge))))
	local HorizonElevationSunsetDifference = self.SunElevation-HorizonElevation
	local HorizonElevationSunsetDifferenceAdjustmentEquation = -(((HorizonElevationSunsetDifference - 10) ^ 4) / 1000) + 10
	
	local EarthTransparencyAltitudeMultiplier = 1/(1+5^(HorizonElevationSunsetDifference-4))
	local LookAngle = math.deg(math.atan((Camera.CFrame.LookVector.Y)/math.sqrt(Camera.CFrame.LookVector.X^2+Camera.CFrame.LookVector.Z^2)))
	local LookAngleHorizonDifference = LookAngle-HorizonElevation
	
	local EarthTerminatorX = 1.01
	local EarthTerminatorY = 1.2

	local t3 = Lighting:GetMinutesAfterMidnight()
	
	if HorizonElevationSunsetDifference <= -18 then
		meta.Atmosphere.Transparency = 1
		meta.Sky.StarCount = 3000
		
	elseif HorizonElevationSunsetDifference > -18 and HorizonElevationSunsetDifference <= -14 then
		meta.Atmosphere.Transparency = -(HorizonElevationSunsetDifference+14)/4
		meta.Sky.StarCount = 3000
		
	elseif HorizonElevationSunsetDifference > -14 and HorizonElevationSunsetDifference <= 0 then
		meta.Atmosphere.Transparency = 0
		meta.Sky.StarCount = 3000
		
	elseif HorizonElevationSunsetDifference > 0 then
		meta.Atmosphere.Transparency = 0
		meta.Sky.StarCount = 0
	end

	if HorizonElevationSunsetDifference >= 0 and HorizonElevationSunsetDifference < 3.75 then -- Pre-Sunrise/set
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		
		self.OutdoorAmbientBrightnessEquation = ((((self.OutdoorAmbientBrightnessDay)-self.OutdoorAmbientBrightnessNight)/17.75)*(HorizonElevationSunsetDifference-3.75)+self.OutdoorAmbientBrightnessDay)/255
		self.EarthTransparency = ((self.PlanetTransparency-0.011)/3.75)*HorizonElevationSunsetDifference+0.011
		self.SunBrightness = self.SunlightBrightness
		
		Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorGResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorBResultant/17.75)*(HorizonElevationSunsetDifference+14))/255
		)
		Lighting.FogEnd = (-100000*(HorizonElevationSunsetDifference-3.75)+100000)*self.FogEndRatio*self.AtmosphereThickness
		
		meta.DistantSurface.Color = Color3.new(ColorR2/255, ColorG2/255, ColorB2/255)
		meta.AirglowLayer.Transparency = 1
		meta.EarthTexture.Color3 = Color3.new(1,1,1)
		
	elseif HorizonElevationSunsetDifference >= -7 and HorizonElevationSunsetDifference < 0 then -- Civil twilight
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		
		self.OutdoorAmbientBrightnessEquation = ((((self.OutdoorAmbientBrightnessDay)-self.OutdoorAmbientBrightnessNight)/17.75)*(HorizonElevationSunsetDifference-3.75)+self.OutdoorAmbientBrightnessDay)/255
		self.EarthTransparency = 0.011
		self.SunBrightness = self.NightBrightness
		
		Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorGResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorBResultant/17.75)*(HorizonElevationSunsetDifference+14))/255
		)
		Lighting.FogEnd = (-25000*(HorizonElevationSunsetDifference)+475000)*self.FogEndRatio*self.AtmosphereThickness
		meta.DistantSurface.Color = Color3.new(0,0,0)
		meta.AirglowLayer.Transparency = self.AirglowTransparency + self.AirglowTransparencyFactor
		meta.EarthTexture.Color3 = Color3.new(7,7,4.5)
		
	elseif HorizonElevationSunsetDifference >= -14 and HorizonElevationSunsetDifference < -7 then -- Nautical twilight
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / HS)*math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		
		self.OutdoorAmbientBrightnessEquation = ((((self.OutdoorAmbientBrightnessDay)-self.OutdoorAmbientBrightnessNight)/17.75)*(HorizonElevationSunsetDifference-3.75)+self.OutdoorAmbientBrightnessDay)/255
		self.EarthTransparency = 0.011
		self.SunBrightness = self.NightBrightness
		
		Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorGResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorBResultant/17.75)*(HorizonElevationSunsetDifference+14))/255
		)
		Lighting.FogEnd = ((550000/7)*(HorizonElevationSunsetDifference+7)+650000)*self.FogEndRatio*self.AtmosphereThickness
		
		meta.DistantSurface.Color = Color3.new(0,0,0)
		meta.AirglowLayer.Transparency = self.AirglowTransparency + self.AirglowTransparencyFactor
		meta.EarthTexture.Color3 = Color3.new(7,7,4.5)
		
	elseif HorizonElevationSunsetDifference < -14 then -- Night
		self.OutdoorAmbientBrightnessEquation = self.OutdoorAmbientBrightnessNight
		self.EarthTransparency = 0.011
		self.SunBrightness = self.NightBrightness
		
		Lighting.FogColor = Color3.new(0,0,0)
		Lighting.FogEnd = 100000*self.FogEndRatio*self.AtmosphereThickness
		
		meta.DistantSurface.Color = Color3.new(0,0,0)
		meta.AirglowLayer.Transparency = self.AirglowTransparency + self.AirglowTransparencyFactor
		meta.EarthTexture.Color3 = Color3.new(7,7,4.5)
		
	elseif HorizonElevationSunsetDifference >= 3.75 then -- Broad daylight
		self.OutdoorAmbientBrightnessEquation = self.OutdoorAmbientBrightnessDay/255
		self.EarthTransparency = self.PlanetTransparency
		self.SunBrightness = self.SunlightBrightness
		
		Lighting.FogColor = Color3.new(ColorR/255, ColorG/255, ColorB/255)
		Lighting.FogEnd = 100000*self.FogEndRatio*self.AtmosphereThickness
		
		meta.DistantSurface.Color = Color3.new(ColorR2/255, ColorG2/255, ColorB2/255)
		meta.AirglowLayer.Transparency = 1
		meta.EarthTexture.Color3 = Color3.new(1,1,1)
	end
	
	if HorizonElevationSunsetDifference <= H3 and HorizonElevationSunsetDifference > 0 then
		self.LightEmissionEquation = (1/H3)*HorizonElevationSunsetDifference -- HorizonElevationSunsetDifference / H3
		self.ExtinctionSunsetTransparencyEquation = (1/H3*HorizonElevationSunsetDifference) -- HorizonElevationSunsetDifference / H3
		if self.EnableSunsetScattering then
			self.ExtinctionTransparencyEquation = (0.8/H3*HorizonElevationSunsetDifferenceAdjustmentEquation)
			self.ExtinctionColorEquation = Color3.fromRGB(
				((255-AtmosphericExtinctionR)/10*self.atten)*HorizonElevationSunsetDifference+AtmosphericExtinctionR,
				((255-AtmosphericExtinctionG)/10*self.atten)*HorizonElevationSunsetDifference+AtmosphericExtinctionG,
				((255-AtmosphericExtinctionB)/10*self.atten)*HorizonElevationSunsetDifference+AtmosphericExtinctionB
			)
		else
			self.ExtinctionTransparencyEquation = 0.8
			self.ExtinctionColorEquation = Color3.new(1,1,1)
		end
		
	elseif HorizonElevationSunsetDifference > H3 then
		self.LightEmissionEquation = 1
		self.ExtinctionTransparencyEquation = 0.8
		self.ExtinctionSunsetTransparencyEquation = 1
		self.ExtinctionColorEquation = Color3.fromRGB(255,255,255)
		
	elseif HorizonElevationSunsetDifference > -14 and HorizonElevationSunsetDifference <= 0 then
		self.LightEmissionEquation = 0
		self.ExtinctionSunsetTransparencyEquation = (1/(1.2*H3)*math.abs(HorizonElevationSunsetDifference))
		if self.EnableSunsetScattering then
			self.ExtinctionTransparencyEquation = (-HorizonElevationSunsetDifference/14)
			local AstroAtmosphericExtinctionR = self.AstronomicalTwilightAtmosphericExtinctionColor.R * 255
			local AstroAtmosphericExtinctionG = self.AstronomicalTwilightAtmosphericExtinctionColor.G * 255
			local AstroAtmosphericExtinctionB = self.AstronomicalTwilightAtmosphericExtinctionColor.B * 255
			self.ExtinctionColorEquation = Color3.fromRGB(
				((AstroAtmosphericExtinctionR-AtmosphericExtinctionR)/14)*-HorizonElevationSunsetDifference+AtmosphericExtinctionR,
				((AstroAtmosphericExtinctionG-AtmosphericExtinctionG)/14)*-HorizonElevationSunsetDifference+AtmosphericExtinctionG,
				((AstroAtmosphericExtinctionB-AtmosphericExtinctionB)/14)*-HorizonElevationSunsetDifference+AtmosphericExtinctionB
			)
		else
			self.ExtinctionTransparencyEquation = 0.8
			self.ExtinctionColorEquation = Color3.fromRGB(255,255,255)
		end
		
	elseif HorizonElevationSunsetDifference <= -14 then
		self.LightEmissionEquation = 0
		self.ExtinctionTransparencyEquation = 1
		self.ExtinctionSunsetTransparencyEquation = 1
		if self.EnableSunsetScattering then
			self.ExtinctionColorEquation = Color3.fromRGB(AtmosphericExtinctionR,AtmosphericExtinctionG,AtmosphericExtinctionB)
		else
			self.ExtinctionTransparencyEquation = 0.8
			self.ExtinctionColorEquation = Color3.fromRGB(255,255,255)
		end
	end
	
	local ExtinctionIntensity = ((1 - 5) / 20000) * math.clamp(x - 20000, 0, 20000) + 5
	local ExtinctionTransNumSequence = NumberSequence.new(self.ExtinctionTransparencyEquation / (1.5 - 0.5 * math.clamp(x / 32808, 0, 1)) * ((2/3)*(1+((14+math.clamp(HorizonElevationSunsetDifference, -14, 0)))/28)))
	local ExtinctionTransNumSequence_2 = NumberSequence.new(self.ExtinctionTransparencyEquation / (2 * (1+math.clamp(HorizonElevationSunsetDifference, -14, 0) / 28)))
	local ExtinctionColorSequence = ColorSequence.new(self.ExtinctionColorEquation, self.ExtinctionTransparencyEquation)
	
	local ExtinctionSunsetBrightness = math.clamp((3 * HorizonElevationSunsetDifference) + 10, 10, 40)
	local BeltOfVenusEmission = math.clamp(0.4 * HorizonElevationSunsetDifference + 1, 0, 1)
	local ExtinctionTransNumSequenceSunset1 = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1);
		NumberSequenceKeypoint.new(math.clamp(((HorizonElevationSunsetDifference - 10) / 30) + 1, 0.3, 1), self.ExtinctionSunsetTransparencyEquation + 0.1);
		NumberSequenceKeypoint.new(1, self.ExtinctionSunsetTransparencyEquation);
	})
	local ExtinctionTransNumSequenceSunset2 = NumberSequence.new({
		NumberSequenceKeypoint.new(0, self.ExtinctionSunsetTransparencyEquation);
		NumberSequenceKeypoint.new(math.clamp(-(HorizonElevationSunsetDifference - 10) / 30, 0.3, 1), self.ExtinctionSunsetTransparencyEquation + 0.1);
		NumberSequenceKeypoint.new(1, 1);
	})
	local ExtinctionTransNumSequenceSunset1BoV = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1);
		NumberSequenceKeypoint.new(math.clamp(((HorizonElevationSunsetDifference - 10) / 30) + 1, 0.3, 1), self.ExtinctionSunsetTransparencyEquation + 0.1);
		NumberSequenceKeypoint.new(1, self.ExtinctionSunsetTransparencyEquation + math.clamp(-(HorizonElevationSunsetDifference + 6.6) / 2.7, 0, 1));
	})
	local ExtinctionTransNumSequenceSunset2BoV = NumberSequence.new({
		NumberSequenceKeypoint.new(0, self.ExtinctionSunsetTransparencyEquation + math.clamp(-(HorizonElevationSunsetDifference + 6.6) / 2.7, 0, 1));
		NumberSequenceKeypoint.new(math.clamp(-(HorizonElevationSunsetDifference - 10) / 30, 0.3, 1), self.ExtinctionSunsetTransparencyEquation + 0.1 + math.clamp(-(HorizonElevationSunsetDifference + 6.6) / 2.7, 0, 1));
		NumberSequenceKeypoint.new(1, 1);
	})

	local BeltOfVenusEmission = math.clamp(0.4 * HorizonElevationSunsetDifference + 1, 0, 1)
	local InnerAtmosphericExtinctionColor = self.InnerAtmosphericExtinctionColor
	local InnerExtinctionSunsetColor = Color3.fromRGB(((self.AtmosphericExtinctionColor.R * 255 - self.SunsideAtmosphericExtinctionColor.R * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.R * 255,((self.AtmosphericExtinctionColor.G * 255 - self.SunsideAtmosphericExtinctionColor.G * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.G * 255,((self.AtmosphericExtinctionColor.B * 255 - self.SunsideAtmosphericExtinctionColor.B * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.B * 255)
	local ExtinctionSunsetColor1 = ColorSequence.new(InnerAtmosphericExtinctionColor,InnerExtinctionSunsetColor)
	local ExtinctionSunsetColor2 = ColorSequence.new(InnerExtinctionSunsetColor,InnerAtmosphericExtinctionColor)
	local VenusSequenceColor = ColorSequence.new(self.BeltOfVenusColor)
	
	local MaxAtmosphericExtinctionColor = NumberSequence.new(1)
	
	for _, v: Beam in pairs(meta.Extinction.AtmosphericExtinction2:GetChildren()) do
		if v:IsA("Beam") then
			v.Brightness = ExtinctionIntensity
			v.LightEmission = self.LightEmissionEquation
			v.Color = ExtinctionColorSequence
			
			if v.Name == "Beam1" or v.Name == "Beam2" or v.Name == "Beam3" or v.Name == "Beam4" then
				v.Transparency = ExtinctionTransNumSequence_2

			elseif v.Name == "Beam5" or v.Name == "Beam6" or v.Name == "Beam7" or v.Name == "Beam8" then
				v.Transparency = ExtinctionTransNumSequence
			end
		end
	end

	--SUNSET
	if self.ExtinctionSunsetTransparencyEquation < 1 and self.EnableSunsetScattering then
		for _, v: Beam in pairs(meta.ExtinctionSunset.AtmosphericExtinction2:GetChildren()) do
			if v:IsA("Beam") then
				v.Brightness = ExtinctionSunsetBrightness
				
				if v.Name == "Beam1" or v.Name == "Beam5" then
					v.Transparency = ExtinctionTransNumSequenceSunset1
					v.Color = ExtinctionSunsetColor1
					
				elseif v.Name == "Beam2" or v.Name == "Beam6" then
					v.Transparency = ExtinctionTransNumSequenceSunset2
					v.Color = ExtinctionSunsetColor2
					
				elseif v.Name == "Beam3" or v.Name == "Beam7" then
					v.Transparency = ExtinctionTransNumSequenceSunset1BoV
					
				elseif v.Name == "Beam4" or v.Name == "Beam8" then
					v.Transparency = ExtinctionTransNumSequenceSunset2BoV
				end
				
				if v.Name == "Beam3" or v.Name == "Beam4" or v.Name == "Beam7" or v.Name == "Beam8" then
					v.Color = VenusSequenceColor
					v.LightEmission = BeltOfVenusEmission
					v.LightInfluence = BeltOfVenusEmission
				end
			end
		end

		if HorizonElevationSunsetDifference < 0 then
			InnerExtinctionSunsetColor = Color3.fromRGB(
				((self.NauticalTwlightAtmosphericExtinctionColor.R * 255
					- self.SunsideAtmosphericExtinctionColor.R * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.R * 255,
				((self.NauticalTwlightAtmosphericExtinctionColor.G * 255
					- self.SunsideAtmosphericExtinctionColor.G * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.G * 255,
				((self.NauticalTwlightAtmosphericExtinctionColor.B * 255
					- self.SunsideAtmosphericExtinctionColor.B * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.B * 255
			)
			InnerAtmosphericExtinctionColor = Color3.fromRGB(
				((self.NauticalInnerAtmosphericExtinctionColor.R * 255
					- self.InnerAtmosphericExtinctionColor.R * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + self.InnerAtmosphericExtinctionColor.R * 255,
				((self.NauticalInnerAtmosphericExtinctionColor.G * 255
					- self.InnerAtmosphericExtinctionColor.G * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + self.InnerAtmosphericExtinctionColor.G * 255,
				((self.NauticalInnerAtmosphericExtinctionColor.B * 255- self.InnerAtmosphericExtinctionColor.B * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + self.InnerAtmosphericExtinctionColor.B * 255)
		end
		
	else
		for _, v: Beam in pairs(meta.ExtinctionSunset.AtmosphericExtinction2:GetChildren()) do
			if v:IsA("Beam") then
				v.Transparency = MaxAtmosphericExtinctionColor
			end
		end
	end
	
	if HorizonElevationSunsetDifference >= -14 and HorizonElevationSunsetDifference < 0 then
		self.ShowTerminator = -HorizonElevationSunsetDifference/14
		meta.EarthTexture.Texture = self.PlanetTextureNight
		meta.Mesh.TextureId = "http://www.roblox.com/asset/?ID=2013298"
		
	elseif HorizonElevationSunsetDifference < -14 then
		self.ShowTerminator = 1
		meta.EarthTexture.Texture = self.PlanetTextureNight
		
	elseif HorizonElevationSunsetDifference >= 0 then
		self.ShowTerminator = 0
		meta.EarthTexture.Texture = self.PlanetTexture
	end
	
	if self.SunElevation < 0 and self.SunElevation >= -17.5 then
		meta.Mesh.TextureId = "http://www.roblox.com/asset/?ID=2013298"
		
	elseif self.SunElevation < -17.5 or self.SunElevation >= 0 then
		meta.Mesh.TextureId = ""
	end
	
	if --[[x <= 10000 and]] x > 0 then
		self.FogEndRatio = 1
		local d = 25400
		local b = -60715
		local c = 30500
		local f = -43630
		local a7 = 1.31047990554
		local b7 = 3.9710993937e-26
		local c7 = 5.85019468322
		local d7 = 0.701839373626
		local f7 = -2.9477486752e-11
		local g7 = 3.05504012873
		local h7 = -2607.06952132
		local i7 = 0.168115525945
		local j7 = 43.9601841689
		local a6 = 2.7154155381e+19
		local b6 = -5.1373398109e+19
		local c6 = 9.1620578497e+9
		local d6 = 9.1430590143e+9
		local f6 = 2.421957201e+19
		local g6 = 9.1219469736e+9
		
		Lighting.FogStart = 0
		
		meta.Atmosphere.Position = Vector3.new(
			Camera.CFrame.Position.X,
			(x/ScaleFactor)-(x-((((x+d)*(x+b))/(x+c))-f-18178.846))-self.AltitudeOffset,
			Camera.CFrame.Position.Z
		)
		meta.DistantSurface.Position = Vector3.new(
			Camera.CFrame.Position.X,
			(x/ScaleFactor)-(x-(2.95*x-162000))-self.AltitudeOffset,
			Camera.CFrame.Position.Z
		)
		meta.SurfaceMesh.Scale = Vector3.new(700, 25*(((x/10000)-10)^2)+1000, 700)
		meta.Mesh.Scale = Vector3.new(
			(a6/(((x-50000)^2)+c6))+(b6/(((x-50000)^2)+d6))+(f6/(((x-50000)^2)+g6)),
			3000+((60/10000)*(x-10000)),
			(a6/(((x-50000)^2)+c6))+(b6/(((x-50000)^2)+d6))+(f6/(((x-50000)^2)+g6))
		)
	elseif x <= 0 then
		local d = 25400
		local b = -60715
		local c = 30500
		local f = -43630
		
		self.FogEndRatio = 1
		
		Lighting.FogStart = 0
		
		meta.Atmosphere.Position = Vector3.new(
			Camera.CFrame.Position.X,
			(x/ScaleFactor)-(x-(-25111.502+x))-self.AltitudeOffset,
			Camera.CFrame.Position.Z
		)
		meta.DistantSurface.Position = Vector3.new(
			Camera.CFrame.Position.X,
			(x/ScaleFactor)-(x-(-162000+x))-self.AltitudeOffset,
			Camera.CFrame.Position.Z
		)
		meta.SurfaceMesh.Scale = Vector3.new(700, 3500, 700)
		meta.Mesh.Scale = Vector3.new(7600,2940,7600)
	end
end

return AtmoSphere
