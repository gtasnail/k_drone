--please checkout my scripts here! https://kbase.tebex.io/
--please do not reupload my script/use my script for paid work you are free to use/modify it but no reuploading :P

RegisterCommand("spawndrone", function(source, args, rawCommand)
    TriggerEvent("k_drone:spawnDrone")
end, false)


function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    return true
end

local dronemodel = "ba_prop_battle_drone_quad"
local droneSpawned = false

RegisterNetEvent('k_drone:spawnDrone', function()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    while not HasModelLoaded(dronemodel) do
        RequestModel(dronemodel)
        Citizen.Wait(10)
    end

    while not HasModelLoaded("prop_cs_tablet") do
        RequestModel("prop_cs_tablet")
        Citizen.Wait(10)
    end
  
  
    if HasModelLoaded(dronemodel) and HasModelLoaded("prop_cs_tablet") then
        drone = CreateObject(dronemodel, playerCoords.x,playerCoords.y, playerCoords.z, 1, 0, 1)
        Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        print(Cam)
		AttachCamToEntity(Cam, drone, 0.0, -1.0, 0.1, true)
        SetEntityHeading(drone, GetEntityHeading(player))
        Citizen.CreateThread(function()
			while DoesCamExist(Cam) do
				Citizen.Wait(5)

				SetCamRot(Cam, GetEntityRotation(drone))
			end
		end)
        local waitTime = 500 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(player), GetEntityCoords(drone), true) / 10)
        RenderScriptCams(1, 1, waitTime, 1, 1)
        droneSpawned = true
        left = GetEntityHeading(player)
        right = GetEntityHeading(player)
        FreezeEntityPosition(player, true)
        SetTimecycleModifier("scanline_cam_cheap")


		tablet = CreateObject(GetHashKey("prop_cs_tablet"), GetEntityCoords(player), true)

		AttachEntityToEntity(TabletEntity, player, GetPedBoneIndex(player, 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	
        LoadAnim('amb@code_human_in_bus_passenger_idles@female@tablet@idle_a')

		TaskPlayAnim(player, "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
	
		Citizen.CreateThread(function()
			while DoesEntityExist(RCCar.TabletEntity) do
				Citizen.Wait(5)
	
				if not IsEntityPlayingAnim(player, "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3) then
					TaskPlayAnim(player, "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
				end
			end

		end)



        while droneSpawned do
            Wait(0)
            local droneCoords = GetEntityCoords(drone)
            local forward = GetEntityForwardVector(drone)
            local forwardX = GetEntityForwardX(drone)
            local forwardY = GetEntityForwardY(drone)
            if IsControlPressed(0, 22) then
                SetEntityVelocity(drone, 0.0, 0.0, 5.0)
            end
            if IsControlPressed(0, 32) then
                SetEntityVelocity(drone, forwardX * 20, forwardY * 20, 1)
            end
            if IsControlPressed(0, 33) then
                SetEntityVelocity(drone, forwardX * -10, forwardY * -10, 1)
            end
            if IsControlPressed(0, 189) then
                left = left + 2
                SetEntityHeading(drone, left)
            end
            if IsControlPressed(0, 190) then
                left = left - 2
                SetEntityHeading(drone, left)
            end
            if IsControlJustPressed(0, 38) then
                droneSpawned = false
            end
            
            local dronedist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(drone))
            if dronedist <= 200.0 then
                distFloat = string.format("%01.1f",dronedist)
                --Draw3DText(droneCoords.x, droneCoords.y, droneCoords.z+0.1, 'Distance from you: ~g~'..distFloat)
                print(dronedist)
                if dronedist >= 0.0 and dronedist <= 50.0 then
                    SetTimecycleModifier("scanline_cam_cheap")
                    SetTimecycleModifierStrength(1.0)

                elseif dronedist >= 50.0 and dronedist <= 100.0 then
                    SetTimecycleModifier("scanline_cam_cheap")
                    SetTimecycleModifierStrength(2.0)

                elseif dronedist >= 100.0 and dronedist <= 150.0 then
                    SetTimecycleModifier("scanline_cam_cheap")
                    SetTimecycleModifierStrength(3.0)

                elseif dronedist >= 150.0 and dronedist <= 200.0 then
                    SetTimecycleModifier("scanline_cam_cheap")
                    SetTimecycleModifierStrength(4.0)

                end
                if not NetworkHasControlOfEntity(drone) then
                    NetworkRequestControlOfEntity(drone)
                end
            elseif dronedist >= 200.0 then
                droneSpawned = false
            end
        end
        RenderScriptCams(0, 1, waitTime, 1, 0)

		Citizen.Wait(waitTime)
        NetworkRequestControlOfEntity(drone)
        DeleteEntity(drone)
        DestroyCam(Cam)
		ClearTimecycleModifier()
        droneSpawned = false
        FreezeEntityPosition(player, false) 
        ClearPedTasks(player)
        ClearPedSecondaryTask(player)
        DeleteEntity(tablet)
    end
end)
