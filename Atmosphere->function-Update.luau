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
	local AtmoHeight = (self.AtmosphereThickness^-1)^0.0625

	if not x then
		x = (Camera.CFrame.Y + self.AltitudeOffset.Value) * ScaleFactor
	end
	local H3 = 10 * self.atten
	local H15 = 15 * self.atten

	local HorizonElevation = -math.deg(math.acos(20925656.2/(20925656.2+math.clamp(x, 0, math.huge))))
	local HorizonElevationSunsetDifference = self.SunElevation-HorizonElevation
	local NormalizedElevation = HorizonElevationSunsetDifference / H3
	
	local EarthTransparencyAltitudeMultiplier = 1/(1+5^(HorizonElevationSunsetDifference-4))
	
	local LookAngle = math.deg(math.atan((Camera.CFrame.LookVector.Y)/math.sqrt(Camera.CFrame.LookVector.X^2+Camera.CFrame.LookVector.Z^2)))
	local LookAngleHorizonDifference = LookAngle-HorizonElevation
	
	local EarthTerminator = Vector2.new(1.01, 1.2) -- EarthTerminatorX, Y
	
	
	local ColorR = self.AtmosphereColor.R * 255
	local ColorG = self.AtmosphereColor.G * 255
	local ColorB = self.AtmosphereColor.B * 255

	local ColorR2 = self.DistantSurfaceColor.R * 255
	local ColorG2 = self.DistantSurfaceColor.G * 255
	local ColorB2 = self.DistantSurfaceColor.B * 255

	local ColorRSunset = self.AtmosphereSunsetColor.R * 255
	local ColorGSunset = self.AtmosphereSunsetColor.G * 255
	local ColorBSunset = self.AtmosphereSunsetColor.B * 255
	
	--/ Daycolors
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
			(((DaycolorR-SunsetColorR)/self.H1)*self.HorizonElevationSunsetDifference10)+SunsetColorR,
			(((DaycolorG-SunsetColorG)/self.H1)*self.HorizonElevationSunsetDifference10)+SunsetColorG,
			(((DaycolorB-SunsetColorB)/self.H1)*self.HorizonElevationSunsetDifference10)+SunsetColorB
		)
	end

	--/ atmospheric extinction
	local AtmosphericExtinctionR = self.AtmosphericExtinctionColor.R*255
	local AtmosphericExtinctionG = self.AtmosphericExtinctionColor.G*255
	local AtmosphericExtinctionB = self.AtmosphericExtinctionColor.B*255
	
	local HorizonElevationSunsetDifferenceAdjustmentEquation = -(((HorizonElevationSunsetDifference - 10) ^ 4) / 1000) + 10
	
	local t3 = Lighting:GetMinutesAfterMidnight()
	local ScalarH3 = H3 / 2.666666666666
	local Fogend = self.FogEndRatio*self.AtmosphereThickness
	local ag2 = self.AirglowTransparency * 2
	local adjs = HorizonElevationSunsetDifference+14
	local elevationnormal = HorizonElevationSunsetDifference / H3

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
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		self.OutdoorAmbientBrightnessEquation = ((((self.OutdoorAmbientBrightnessDay)-self.OutdoorAmbientBrightnessNight)/17.75)*(HorizonElevationSunsetDifference-3.75)+self.OutdoorAmbientBrightnessDay)/255
		self.SunBrightness = self.SunlightBrightness
		self.EarthTransparency = ((self.PlanetTransparency-0.011)/3.75)*HorizonElevationSunsetDifference+0.011
		
		Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*adjs)/255,
			((ColorGResultant/17.75)*adjs)/255,
			((ColorBResultant/17.75)*adjs)/255
		)
		Lighting.FogEnd = (-100000*(HorizonElevationSunsetDifference-3.75)+100000)*Fogend
		
		meta.DistantSurface.Color = Color3.new(ColorR2/255, ColorG2/255, ColorB2/255)
		meta.AirglowLayer.Transparency = 1
		meta.EarthTexture.Color3 = Color3.new(1,1,1)
		
	elseif HorizonElevationSunsetDifference >= -7 and HorizonElevationSunsetDifference < 0 then -- Civil twilight
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		
		self.OutdoorAmbientBrightnessEquation = ((((self.OutdoorAmbientBrightnessDay)-self.OutdoorAmbientBrightnessNight)/17.75)*(HorizonElevationSunsetDifference-3.75)+self.OutdoorAmbientBrightnessDay)/255
		self.SunBrightness = self.NightBrightness
		self.EarthTransparency = 0.011
		
		Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*adjs)/255,
			((ColorGResultant/17.75)*adjs)/255,
			((ColorBResultant/17.75)*adjs)/255
		)
		Lighting.FogEnd = (-25000*(HorizonElevationSunsetDifference)+475000)*Fogend
		
		meta.DistantSurface.Color = Color3.new(0,0,0)
		meta.AirglowLayer.Transparency = self.AirglowTransparency * 2
		meta.EarthTexture.Color3 = Color3.new(7,7,4.5)
		
	elseif HorizonElevationSunsetDifference >= -14 and HorizonElevationSunsetDifference < -7 then -- Nautical twilight
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / ScalarH3)*math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		
		self.OutdoorAmbientBrightnessEquation = ((((self.OutdoorAmbientBrightnessDay)-self.OutdoorAmbientBrightnessNight)/17.75)*(HorizonElevationSunsetDifference-3.75)+self.OutdoorAmbientBrightnessDay)/255
		self.SunBrightness = self.NightBrightness
		self.EarthTransparency = 0.011
		
		Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*adjs)/255,
			((ColorGResultant/17.75)*adjs)/255,
			((ColorBResultant/17.75)*adjs)/255
		)
		Lighting.FogEnd = ((550000/7)*(HorizonElevationSunsetDifference+7)+650000)*Fogend
		
		meta.DistantSurface.Color = Color3.new(0,0,0)
		meta.AirglowLayer.Transparency = ag2
		meta.EarthTexture.Color3 = Color3.new(7,7,4.5)
		
	elseif HorizonElevationSunsetDifference < -14 then -- Night
		self.OutdoorAmbientBrightnessEquation = self.OutdoorAmbientBrightnessNight/255
		self.SunBrightness = self.NightBrightness
		self.EarthTransparency = 0.011
		
		Lighting.FogColor = Color3.new(0,0,0)
		Lighting.FogEnd = 100000*Fogend
		
		meta.DistantSurface.Color = Color3.new(0,0,0)
		meta.AirglowLayer.Transparency = ag2
		meta.EarthTexture.Color3 = Color3.new(7,7,4.5)
		
	elseif HorizonElevationSunsetDifference >= 3.75 then -- Broad daylight
		self.OutdoorAmbientBrightnessEquation = self.OutdoorAmbientBrightnessDay/255
		self.SunBrightness = self.SunlightBrightness
		self.EarthTransparency = self.PlanetTransparency
		
		Lighting.FogColor = Color3.new(ColorR/255, ColorG/255, ColorB/255)
		Lighting.FogEnd = 100000*Fogend
		
		meta.DistantSurface.Color = Color3.new(ColorR2/255, ColorG2/255, ColorB2/255)
		meta.AirglowLayer.Transparency = 1
		meta.EarthTexture.Color3 = Color3.new(1,1,1)
	end

	if HorizonElevationSunsetDifference <= H3 and HorizonElevationSunsetDifference > 0 then
		self.LightEmissionEquation = elevationnormal
		self.ExtinctionSunsetTransparencyEquation = elevationnormal
		if self.EnableSunsetScattering then
			self.ExtinctionTransparencyEquation = (0.8/H3*HorizonElevationSunsetDifferenceAdjustmentEquation)
			self.ExtinctionColorEquation = Color3.fromRGB(
				((255-AtmosphericExtinctionR)/H3)*HorizonElevationSunsetDifference+AtmosphericExtinctionR,
				((255-AtmosphericExtinctionG)/H3)*HorizonElevationSunsetDifference+AtmosphericExtinctionG,
				((255-AtmosphericExtinctionB)/H3)*HorizonElevationSunsetDifference+AtmosphericExtinctionB
				
			)
		else
			self.ExtinctionTransparencyEquation = 0.8
			self.ExtinctionColorEquation = Color3.fromRGB(255,255,255)
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
			local AstroAtmosphericExtinctionR = self.AstronomicalTwilightAtmosphericExtinctionColor.R*255
			local AstroAtmosphericExtinctionG = self.AstronomicalTwilightAtmosphericExtinctionColor.G*255
			local AstroAtmosphericExtinctionB = self.AstronomicalTwilightAtmosphericExtinctionColor.B*255
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
	
	-- extinction
	local ExtinctionIntensity = ((1 - 5) / 20000) * math.clamp(x - 20000, 0, 20000) + 5
	local ExtinctionTransNumSequence = NumberSequence.new(self.ExtinctionTransparencyEquation / (1.5 - 0.5 * math.clamp(x / 32808, 0, 1)) * ((2/3)*(1+((14+math.clamp(HorizonElevationSunsetDifference, -14, 0)))/28)))
	local ExtinctionTransNumSequence_2 = NumberSequence.new(self.ExtinctionTransparencyEquation / (2 * (1+math.clamp(HorizonElevationSunsetDifference, -14, 0) / 28)))
	local ExtinctionColorSequence = ColorSequence.new(self.ExtinctionColorEquation, self.ExtinctionTransparencyEquation)
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
	
	if HorizonElevationSunsetDifference < 0 then
		self.InnerExtinctionSunsetColor = Color3.fromRGB(
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
		self.InnerAtmosphericExtinctionColor = Color3.fromRGB(
			((self.NauticalInnerAtmosphericExtinctionColor.R * 255
				- self.InnerAtmosphericExtinctionColor.R * 255) / H3)
				* (math.abs(HorizonElevationSunsetDifference)) + self.InnerAtmosphericExtinctionColor.R * 255,
			((self.NauticalInnerAtmosphericExtinctionColor.G * 255
				- self.InnerAtmosphericExtinctionColor.G * 255) / H3)
				* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.G * 255,
			((self.NauticalInnerAtmosphericExtinctionColor.B * 255
				- self.InnerAtmosphericExtinctionColor.B * 255) / H3)
				* (math.abs(HorizonElevationSunsetDifference)) + self.InnerAtmosphericExtinctionColor.B * 255
		)
	end
	
	local InnerAtmosphericExtinctionColor = self.InnerAtmosphericExtinctionColor
	local InnerExtinctionSunsetColor = Color3.fromRGB(
		((self.AtmosphericExtinctionColor.R * 255 - self.SunsideAtmosphericExtinctionColor.R * 255) / H3)
			* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.R * 255,
		((self.AtmosphericExtinctionColor.G * 255 - self.SunsideAtmosphericExtinctionColor.G * 255) / H3)
			* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.G * 255,
		((self.AtmosphericExtinctionColor.B * 255 - self.SunsideAtmosphericExtinctionColor.B * 255) / H3)
			* (math.abs(HorizonElevationSunsetDifference)) + self.SunsideAtmosphericExtinctionColor.B * 255
	)

	local ExtinctionSunsetColor1 = ColorSequence.new(
		InnerAtmosphericExtinctionColor,
		InnerExtinctionSunsetColor
	)
	local ExtinctionSunsetColor2 = ColorSequence.new(
		InnerExtinctionSunsetColor,
		InnerAtmosphericExtinctionColor
	)
	
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
	if self.ExtinctionSunsetTransparencyEquation < 1 and script.Customize.EnableSunsetScattering.Value then
		local ExtinctionSunsetBrightness = math.clamp((3 * HorizonElevationSunsetDifference) + 10, 10, 40)
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
					v.Color = ColorSequence.new(self.BeltOfVenusColor)
					v.LightEmission = BeltOfVenusEmission
					v.LightInfluence = BeltOfVenusEmission
				end
			end
		end
		
	else
		for _, v: Beam in pairs(meta.ExtinctionSunset.AtmosphericExtinction2:GetChildren()) do
			if v:IsA("Beam") then
				v.Transparency = NumberSequence.new(1)
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
end
