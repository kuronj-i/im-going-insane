local ScaleFactor = (script.Customize.Scale.Value)^-1
	local AtmoThinness = script.Customize.AtmosphereTransparency.Value
	local AtmoHeight = ((script.Customize.AtmosphereThickness.Value)^-1)^0.0625
	local ColorR = script.Customize.AtmosphereColor.Value.R*255
	local ColorG = script.Customize.AtmosphereColor.Value.G*255
	local ColorB = script.Customize.AtmosphereColor.Value.B*255
	local ColorRSunset = script.Customize.AtmosphereSunsetColor.Value.R*255
	local ColorGSunset = script.Customize.AtmosphereSunsetColor.Value.G*255
	local ColorBSunset = script.Customize.AtmosphereSunsetColor.Value.B*255
	local ColorR2 = script.Customize.DistantSurfaceColor.Value.R*255
	local ColorG2 = script.Customize.DistantSurfaceColor.Value.G*255
	local ColorB2 = script.Customize.DistantSurfaceColor.Value.B*255
	local SunBrightness = script.Customize.EnableSun.SunBrightness.Value
	local x = (Camera.CFrame.Position.Y+script.Customize.AltitudeOffset.Value)*ScaleFactor
	local SunDirectionV = game.Lighting:GetSunDirection()
	local CamToSunDirection = (SunDirectionV * 999)-Camera.CFrame.LookVector
	local SunElevation = math.deg(math.atan((CamToSunDirection.y)/math.sqrt(CamToSunDirection.x^2+CamToSunDirection.z^2)))
	local HorizonElevation = -math.deg(math.acos(20925656.2/(20925656.2+math.clamp(x, 0, math.huge))))
	local HorizonElevationSunsetDifference = SunElevation-HorizonElevation
	local EarthTransparencyAltitudeMultiplier = 1/(1+5^(HorizonElevationSunsetDifference-4))
	local LookAngle = math.deg(math.atan((Camera.CFrame.LookVector.Y)/math.sqrt(Camera.CFrame.LookVector.X^2+Camera.CFrame.LookVector.Z^2)))
	local LookAngleHorizonDifference = LookAngle-HorizonElevation
	local EarthTerminatorX = 1.01
	local EarthTerminatorY = 1.2
	local H3 = 10*(2^(-x/500000))
	local H15 = 15*(2^(-x/500000))	
	local t3 = game.Lighting:GetMinutesAfterMidnight()
	if HorizonElevationSunsetDifference <= -18 then
		Atmosphere.Transparency = 1
		Sky.StarCount = 3000
	elseif HorizonElevationSunsetDifference > -18 and HorizonElevationSunsetDifference <= -14 then
		Atmosphere.Transparency = -(HorizonElevationSunsetDifference+14)/4
		Sky.StarCount = 3000
	elseif HorizonElevationSunsetDifference > -14 and HorizonElevationSunsetDifference <= 0 then
		Atmosphere.Transparency = 0
		Sky.StarCount = 3000
	elseif HorizonElevationSunsetDifference > 0 then
		Atmosphere.Transparency = 0
		Sky.StarCount = 0
	end
	
	if HorizonElevationSunsetDifference >= 0 and HorizonElevationSunsetDifference < 3.75 then -- Pre-Sunrise/set
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		OutdoorAmbientBrightnessEquation = ((((script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value)
			-script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessNight.Value)/17.75)*(HorizonElevationSunsetDifference-3.75)
				+script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value)/255
		game.Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorGResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorBResultant/17.75)*(HorizonElevationSunsetDifference+14))/255
		)
		game.Lighting.FogEnd = (-100000*(HorizonElevationSunsetDifference-3.75)+100000)*FogEndRatio*AtmoThinness
		DistantSurface.Color = Color3.new(ColorR2/255, ColorG2/255, ColorB2/255)
		SunBrightness = script.Customize.EnableEnvironmentalLightingChanges.SunlightBrightness.Value
		AirglowLayer.Transparency = 1
		EarthTransparency = ((script.Customize.PlanetTransparency.Value-0.011)/3.75)*HorizonElevationSunsetDifference+0.011
		EarthTexture.Color3 = Color3.new(1,1,1)
	elseif HorizonElevationSunsetDifference >= -7 and HorizonElevationSunsetDifference < 0 then -- Civil twilight
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		OutdoorAmbientBrightnessEquation = ((((script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value)
			-script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessNight.Value)/17.75)
				*(HorizonElevationSunsetDifference-3.75)+script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value)/255
		game.Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorGResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorBResultant/17.75)*(HorizonElevationSunsetDifference+14))/255
		)
		game.Lighting.FogEnd = (-25000*(HorizonElevationSunsetDifference)+475000)*FogEndRatio*AtmoThinness
		DistantSurface.Color = Color3.new(0,0,0)
		SunBrightness = script.Customize.EnableEnvironmentalLightingChanges.NightBrightness.Value
		AirglowLayer.Transparency = script.Customize.EnableAirglow.AirglowTransparency.Value + AirglowTransparency
		EarthTransparency = 0.011
		EarthTexture.Color3 = Color3.new(7,7,4.5)
	elseif HorizonElevationSunsetDifference >= -14 and HorizonElevationSunsetDifference < -7 then -- Nautical twilight
		local ColorRResultant = math.clamp((-(ColorRSunset - ColorR) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorRSunset, math.min(ColorR, ColorRSunset), math.max(ColorR, ColorRSunset))
		local ColorGResultant = math.clamp((-(ColorGSunset - ColorG) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorGSunset, math.min(ColorG, ColorGSunset), math.max(ColorG, ColorGSunset))
		local ColorBResultant = math.clamp((-(ColorBSunset - ColorB) / (H3 / 2.666666666666))
			* math.abs(HorizonElevationSunsetDifference) + ColorBSunset, math.min(ColorB, ColorBSunset), math.min(ColorB, ColorBSunset))
		OutdoorAmbientBrightnessEquation = ((((script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value)
			-script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessNight.Value)/17.75)
				*(HorizonElevationSunsetDifference-3.75)+script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value)/255
		game.Lighting.FogColor = Color3.new(
			((ColorRResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorGResultant/17.75)*(HorizonElevationSunsetDifference+14))/255,
			((ColorBResultant/17.75)*(HorizonElevationSunsetDifference+14))/255
		)
		game.Lighting.FogEnd = ((550000/7)*(HorizonElevationSunsetDifference+7)+650000)*FogEndRatio*AtmoThinness
		DistantSurface.Color = Color3.new(0,0,0)
		SunBrightness = script.Customize.EnableEnvironmentalLightingChanges.NightBrightness.Value
		AirglowLayer.Transparency = script.Customize.EnableAirglow.AirglowTransparency.Value + AirglowTransparency
		EarthTransparency = 0.011
		EarthTexture.Color3 = Color3.new(7,7,4.5)
	elseif HorizonElevationSunsetDifference < -14 then -- Night
		OutdoorAmbientBrightnessEquation = script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessNight.Value/255
		game.Lighting.FogColor = Color3.new(0,0,0)
		game.Lighting.FogEnd = 100000*FogEndRatio*AtmoThinness
		DistantSurface.Color = Color3.new(0,0,0)
		SunBrightness = script.Customize.EnableEnvironmentalLightingChanges.NightBrightness.Value
		AirglowLayer.Transparency = script.Customize.EnableAirglow.AirglowTransparency.Value + AirglowTransparency
		EarthTransparency = 0.011
		EarthTexture.Color3 = Color3.new(7,7,4.5)
	elseif HorizonElevationSunsetDifference >= 3.75 then -- Broad daylight
		OutdoorAmbientBrightnessEquation = script.Customize.EnableEnvironmentalLightingChanges.OutdoorAmbientBrightnessDay.Value/255
		game.Lighting.FogColor = Color3.new(ColorR/255, ColorG/255, ColorB/255)
		game.Lighting.FogEnd = 100000*FogEndRatio*AtmoThinness
		DistantSurface.Color = Color3.new(ColorR2/255, ColorG2/255, ColorB2/255)
		SunBrightness = script.Customize.EnableEnvironmentalLightingChanges.SunlightBrightness.Value
		AirglowLayer.Transparency = 1
		EarthTransparency = script.Customize.PlanetTransparency.Value
		EarthTexture.Color3 = Color3.new(1,1,1)
	end
	local DaycolorR = script.Customize.EnableEnvironmentalLightingChanges.DaytimeSunlightColor.Value.R
	local DaycolorG = script.Customize.EnableEnvironmentalLightingChanges.DaytimeSunlightColor.Value.G
	local DaycolorB = script.Customize.EnableEnvironmentalLightingChanges.DaytimeSunlightColor.Value.B
	local SunsetColorR = script.Customize.EnableEnvironmentalLightingChanges.SunriseSunlightColor.Value.R
	local SunsetColorG = script.Customize.EnableEnvironmentalLightingChanges.SunriseSunlightColor.Value.G
	local SunsetColorB = script.Customize.EnableEnvironmentalLightingChanges.SunriseSunlightColor.Value.B
	if script.Customize.EnableEnvironmentalLightingChanges.Value == true then
		game.Lighting.OutdoorAmbient = Color3.new(OutdoorAmbientBrightnessEquation,OutdoorAmbientBrightnessEquation,OutdoorAmbientBrightnessEquation)
		game.Lighting.Brightness = SunBrightness
		game.Lighting.ColorShift_Top = Color3.new(
			(((DaycolorR-SunsetColorR)/(6*(2^(-x/500000))))*HorizonElevationSunsetDifference10)+SunsetColorR,
			(((DaycolorG-SunsetColorG)/(6*(2^(-x/500000))))*HorizonElevationSunsetDifference10)+SunsetColorG,
			(((DaycolorB-SunsetColorB)/(6*(2^(-x/500000))))*HorizonElevationSunsetDifference10)+SunsetColorB
		)
	else
		game.Lighting.OutdoorAmbient = game.Lighting.OutdoorAmbient
		game.Lighting.Brightness = game.Lighting.Brightness
		game.Lighting.ColorShift_Top = game.Lighting.ColorShift_Top
	end	
	local AtmosphericExtinctionR = script.Customize.AtmosphericExtinctionColor.Value.R*255
	local AtmosphericExtinctionG = script.Customize.AtmosphericExtinctionColor.Value.G*255
	local AtmosphericExtinctionB = script.Customize.AtmosphericExtinctionColor.Value.B*255
	local HorizonElevationSunsetDifferenceAdjustmentEquation = -(((HorizonElevationSunsetDifference - 10) ^ 4) / 1000) + 10
	if HorizonElevationSunsetDifference <= H3 and HorizonElevationSunsetDifference > 0 then
		LightEmissionEquation = (1/H3)*HorizonElevationSunsetDifference
		ExtinctionSunsetTransparencyEquation = (1/H3*HorizonElevationSunsetDifference)
		if script.Customize.EnableSunsetScattering.Value then
			ExtinctionTransparencyEquation = (0.8/H3*HorizonElevationSunsetDifferenceAdjustmentEquation)
			ExtinctionColorEquation = Color3.fromRGB(
				((255-AtmosphericExtinctionR)/10*(2^(-x/500000)))*HorizonElevationSunsetDifference+AtmosphericExtinctionR,
				((255-AtmosphericExtinctionG)/10*(2^(-x/500000)))*HorizonElevationSunsetDifference+AtmosphericExtinctionG,
				((255-AtmosphericExtinctionB)/10*(2^(-x/500000)))*HorizonElevationSunsetDifference+AtmosphericExtinctionB
			)
		else
			ExtinctionTransparencyEquation = 0.8
			ExtinctionColorEquation = Color3.fromRGB(255,255,255)
		end
	elseif HorizonElevationSunsetDifference > H3 then
		LightEmissionEquation = 1
		ExtinctionTransparencyEquation = 0.8
		ExtinctionSunsetTransparencyEquation = 1
		ExtinctionColorEquation = Color3.fromRGB(255,255,255)
	elseif HorizonElevationSunsetDifference > -14 and HorizonElevationSunsetDifference <= 0 then
		LightEmissionEquation = 0
		ExtinctionSunsetTransparencyEquation = (1/(1.2*H3)*math.abs(HorizonElevationSunsetDifference))
		if script.Customize.EnableSunsetScattering.Value then
			ExtinctionTransparencyEquation = (-HorizonElevationSunsetDifference/14)
			local AstroAtmosphericExtinctionR = script.Customize.AtmosphericExtinctionColor.AstronomicalTwilightAtmosphericExtinctionColor.Value.R*255
			local AstroAtmosphericExtinctionG = script.Customize.AtmosphericExtinctionColor.AstronomicalTwilightAtmosphericExtinctionColor.Value.G*255
			local AstroAtmosphericExtinctionB = script.Customize.AtmosphericExtinctionColor.AstronomicalTwilightAtmosphericExtinctionColor.Value.B*255
			ExtinctionColorEquation = Color3.fromRGB(
				((AstroAtmosphericExtinctionR-AtmosphericExtinctionR)/14)*-HorizonElevationSunsetDifference+AtmosphericExtinctionR,
				((AstroAtmosphericExtinctionG-AtmosphericExtinctionG)/14)*-HorizonElevationSunsetDifference+AtmosphericExtinctionG,
				((AstroAtmosphericExtinctionB-AtmosphericExtinctionB)/14)*-HorizonElevationSunsetDifference+AtmosphericExtinctionB
			)
		else
			ExtinctionTransparencyEquation = 0.8
			ExtinctionColorEquation = Color3.fromRGB(255,255,255)
		end
	elseif HorizonElevationSunsetDifference <= -14 then
		LightEmissionEquation = 0
		ExtinctionTransparencyEquation = 1
		ExtinctionSunsetTransparencyEquation = 1
		if script.Customize.EnableSunsetScattering.Value then
			ExtinctionColorEquation = Color3.fromRGB(AtmosphericExtinctionR,AtmosphericExtinctionG,AtmosphericExtinctionB)
		else
			ExtinctionTransparencyEquation = 0.8
			ExtinctionColorEquation = Color3.fromRGB(255,255,255)
		end
	end
	local ExtinctionIntensity = ((1 - 5) / 20000) * math.clamp(x - 20000, 0, 20000) + 5
	Extinction.AtmosphericExtinction2.Beam1.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam2.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam3.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam4.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam5.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam6.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam7.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam8.Brightness = ExtinctionIntensity
	Extinction.AtmosphericExtinction2.Beam1.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam2.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam3.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam4.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam5.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam6.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam7.LightEmission = LightEmissionEquation
	Extinction.AtmosphericExtinction2.Beam8.LightEmission = LightEmissionEquation
	local ExtinctionTransNumSequence = NumberSequence.new(ExtinctionTransparencyEquation / (1.5 - 0.5 * math.clamp(x / 32808, 0, 1)) * ((2/3)*(1+((14+math.clamp(HorizonElevationSunsetDifference, -14, 0)))/28)))
	local ExtinctionTransNumSequence_2 = NumberSequence.new(ExtinctionTransparencyEquation / (2 * (1+math.clamp(HorizonElevationSunsetDifference, -14, 0) / 28)))
	Extinction.AtmosphericExtinction2.Beam1.Transparency = ExtinctionTransNumSequence_2
	Extinction.AtmosphericExtinction2.Beam2.Transparency = ExtinctionTransNumSequence_2
	Extinction.AtmosphericExtinction2.Beam3.Transparency = ExtinctionTransNumSequence_2
	Extinction.AtmosphericExtinction2.Beam4.Transparency = ExtinctionTransNumSequence_2
	Extinction.AtmosphericExtinction2.Beam5.Transparency = ExtinctionTransNumSequence
	Extinction.AtmosphericExtinction2.Beam6.Transparency = ExtinctionTransNumSequence
	Extinction.AtmosphericExtinction2.Beam7.Transparency = ExtinctionTransNumSequence
	Extinction.AtmosphericExtinction2.Beam8.Transparency = ExtinctionTransNumSequence
	local ExtinctionColorSequence = ColorSequence.new(ExtinctionColorEquation, ExtinctionTransparencyEquation)
	Extinction.AtmosphericExtinction2.Beam1.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam2.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam3.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam4.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam5.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam6.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam7.Color = ExtinctionColorSequence
	Extinction.AtmosphericExtinction2.Beam8.Color = ExtinctionColorSequence

	--SUNSET
	if ExtinctionSunsetTransparencyEquation < 1 and script.Customize.EnableSunsetScattering.Value then
		local ExtinctionSunsetBrightness = math.clamp((3 * HorizonElevationSunsetDifference) + 10, 10, 40)
		ExtinctionSunset.AtmosphericExtinction2.Beam1.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam2.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam3.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam4.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam5.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam6.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam7.Brightness = ExtinctionSunsetBrightness
		ExtinctionSunset.AtmosphericExtinction2.Beam8.Brightness = ExtinctionSunsetBrightness
		local ExtinctionTransNumSequenceSunset1 = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1);
			NumberSequenceKeypoint.new(math.clamp(((HorizonElevationSunsetDifference - 10) / 30) + 1, 0.3, 1), ExtinctionSunsetTransparencyEquation + 0.1);
			NumberSequenceKeypoint.new(1, ExtinctionSunsetTransparencyEquation);
		})
		local ExtinctionTransNumSequenceSunset2 = NumberSequence.new({
			NumberSequenceKeypoint.new(0, ExtinctionSunsetTransparencyEquation);
			NumberSequenceKeypoint.new(math.clamp(-(HorizonElevationSunsetDifference - 10) / 30, 0.3, 1), ExtinctionSunsetTransparencyEquation + 0.1);
			NumberSequenceKeypoint.new(1, 1);
		})
		local ExtinctionTransNumSequenceSunset1BoV = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1);
			NumberSequenceKeypoint.new(math.clamp(((HorizonElevationSunsetDifference - 10) / 30) + 1, 0.3, 1), ExtinctionSunsetTransparencyEquation + 0.1);
			NumberSequenceKeypoint.new(1, ExtinctionSunsetTransparencyEquation + math.clamp(-(HorizonElevationSunsetDifference + 6.6) / 2.7, 0, 1));
		})
		local ExtinctionTransNumSequenceSunset2BoV = NumberSequence.new({
			NumberSequenceKeypoint.new(0, ExtinctionSunsetTransparencyEquation + math.clamp(-(HorizonElevationSunsetDifference + 6.6) / 2.7, 0, 1));
			NumberSequenceKeypoint.new(math.clamp(-(HorizonElevationSunsetDifference - 10) / 30, 0.3, 1), ExtinctionSunsetTransparencyEquation + 0.1 + math.clamp(-(HorizonElevationSunsetDifference + 6.6) / 2.7, 0, 1));
			NumberSequenceKeypoint.new(1, 1);
		})
		ExtinctionSunset.AtmosphericExtinction2.Beam1.Transparency = ExtinctionTransNumSequenceSunset1
		ExtinctionSunset.AtmosphericExtinction2.Beam2.Transparency = ExtinctionTransNumSequenceSunset2
		ExtinctionSunset.AtmosphericExtinction2.Beam3.Transparency = ExtinctionTransNumSequenceSunset1BoV
		ExtinctionSunset.AtmosphericExtinction2.Beam4.Transparency = ExtinctionTransNumSequenceSunset2BoV
		ExtinctionSunset.AtmosphericExtinction2.Beam5.Transparency = ExtinctionTransNumSequenceSunset1
		ExtinctionSunset.AtmosphericExtinction2.Beam6.Transparency = ExtinctionTransNumSequenceSunset2
		ExtinctionSunset.AtmosphericExtinction2.Beam7.Transparency = ExtinctionTransNumSequenceSunset1BoV
		ExtinctionSunset.AtmosphericExtinction2.Beam8.Transparency = ExtinctionTransNumSequenceSunset2BoV

		local BeltOfVenusEmission = math.clamp(0.4 * HorizonElevationSunsetDifference + 1, 0, 1)
		ExtinctionSunset.AtmosphericExtinction2.Beam3.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam4.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam7.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam8.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam3.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam4.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam7.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam8.Color = ColorSequence.new(script.Customize.BeltOfVenusColor.Value)
		ExtinctionSunset.AtmosphericExtinction2.Beam3.LightEmission = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam4.LightEmission = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam7.LightEmission = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam8.LightEmission = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam3.LightInfluence = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam4.LightInfluence = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam7.LightInfluence = BeltOfVenusEmission
		ExtinctionSunset.AtmosphericExtinction2.Beam8.LightInfluence = BeltOfVenusEmission
		local InnerAtmosphericExtinctionColor = script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value
		local InnerExtinctionSunsetColor = Color3.fromRGB(((script.Customize.AtmosphericExtinctionColor.Value.R * 255 - script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.R * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.R * 255,((script.Customize.AtmosphericExtinctionColor.Value.G * 255 - script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.G * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.G * 255,((script.Customize.AtmosphericExtinctionColor.Value.B * 255 - script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.B * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.B * 255)
		if HorizonElevationSunsetDifference < 0 then
			InnerExtinctionSunsetColor = Color3.fromRGB(
				((script.Customize.AtmosphericExtinctionColor.NauticalTwlightAtmosphericExtinctionColor.Value.R * 255
					- script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.R * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.R * 255,
				((script.Customize.AtmosphericExtinctionColor.NauticalTwlightAtmosphericExtinctionColor.Value.G * 255
					- script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.G * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.G * 255,
				((script.Customize.AtmosphericExtinctionColor.NauticalTwlightAtmosphericExtinctionColor.Value.B * 255
					- script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.B * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.SunsideAtmosphericExtinctionColor.Value.B * 255
			)
			InnerAtmosphericExtinctionColor = Color3.fromRGB(
				((script.Customize.AtmosphericExtinctionColor.NauticalInnerAtmosphericExtinctionColor.Value.R * 255
					- script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.R * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.R * 255,
				((script.Customize.AtmosphericExtinctionColor.NauticalInnerAtmosphericExtinctionColor.Value.G * 255
					- script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.G * 255) / H3)
					* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.G * 255,
				((script.Customize.AtmosphericExtinctionColor.NauticalInnerAtmosphericExtinctionColor.Value.B * 255- script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.B * 255) / H3)* (math.abs(HorizonElevationSunsetDifference)) + script.Customize.AtmosphericExtinctionColor.InnerAtmosphericExtinctionColor.Value.B * 255)
		end
		local ExtinctionSunsetColor1 = ColorSequence.new(InnerAtmosphericExtinctionColor,InnerExtinctionSunsetColor)
		local ExtinctionSunsetColor2 = ColorSequence.new(InnerExtinctionSunsetColor,InnerAtmosphericExtinctionColor)
		ExtinctionSunset.AtmosphericExtinction2.Beam1.Color = ExtinctionSunsetColor1
		ExtinctionSunset.AtmosphericExtinction2.Beam2.Color = ExtinctionSunsetColor2
		ExtinctionSunset.AtmosphericExtinction2.Beam5.Color = ExtinctionSunsetColor1
		ExtinctionSunset.AtmosphericExtinction2.Beam6.Color = ExtinctionSunsetColor2
	else
		ExtinctionSunset.AtmosphericExtinction2.Beam1.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam2.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam3.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam4.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam5.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam6.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam7.Transparency = NumberSequence.new(1)
		ExtinctionSunset.AtmosphericExtinction2.Beam8.Transparency = NumberSequence.new(1)
	end
	if HorizonElevationSunsetDifference >= -14 and HorizonElevationSunsetDifference < 0 then
		ShowTerminator = -HorizonElevationSunsetDifference/14
		EarthTexture.Texture = script.Customize.PlanetTextureNight.Value
		Mesh.TextureId = "http://www.roblox.com/asset/?ID=2013298"
	elseif HorizonElevationSunsetDifference < -14 then
		ShowTerminator = 1
		EarthTexture.Texture = script.Customize.PlanetTextureNight.Value
	elseif HorizonElevationSunsetDifference >= 0 then
		ShowTerminator = 0
		EarthTexture.Texture = script.Customize.PlanetTexture.Value
	end
	if SunElevation < 0 and SunElevation >= -17.5 then
		Mesh.TextureId = "http://www.roblox.com/asset/?ID=2013298"
	elseif SunElevation < -17.5 or SunElevation >= 0 then
		Mesh.TextureId = ""
	end
